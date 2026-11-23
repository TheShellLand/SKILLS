from contextlib import closing
import json
import math
import os
import signal
import socket
import sqlite3
import stat
import struct

from client import parser


def vector_blob(raw, dimensions):
    values = json.loads(raw)
    if not isinstance(values, list) or len(values) != dimensions:
        raise ValueError(f"Expected a JSON array of {dimensions} numbers")
    if any(type(value) not in (int, float) or not math.isfinite(value) for value in values):
        raise ValueError("Vector coordinates must be finite numbers")
    return struct.pack(f"={dimensions}f", *values)


def dispatch(db, dimensions, request):
    operation = request["operation"]
    if operation == "status":
        version, count = db.execute("SELECT vec_version(), count(*) FROM vectors").fetchone()
        return {"dimensions": dimensions, "sqlite_vec": version, "count": count}
    if operation == "put":
        row_id, content = request["id"], request["text"]
        if not row_id:
            raise ValueError("ID must not be empty")
        embedding = vector_blob(request["vector"], dimensions)
        with db:
            db.execute(
                "INSERT INTO vectors VALUES (?, ?, ?) ON CONFLICT(id) DO UPDATE SET "
                "content = excluded.content, embedding = excluded.embedding",
                (row_id, content, embedding),
            )
        return {"id": row_id}
    if operation == "get":
        row = db.execute("SELECT id, content AS text FROM vectors WHERE id = ?",
                         (request["id"],)).fetchone()
        return {"row": dict(row) if row else None}
    if operation == "delete":
        with db:
            deleted = sum(
                db.execute("DELETE FROM vectors WHERE id = ?", (row_id,)).rowcount
                for row_id in request["ids"]
            )
        return {"deleted": deleted}
    if operation == "stop":
        return {"stopped": True}

    limit = request["limit"]
    if type(limit) is not int or limit < 1:
        raise ValueError("Limit must be positive")
    if operation == "search":
        embedding = vector_blob(request["vector"], dimensions)
        rows = db.execute(
            "SELECT id, content AS text, vec_distance_L2(embedding, ?) AS distance "
            "FROM vectors ORDER BY distance, id LIMIT ?", (embedding, limit),
        )
    elif operation == "list":
        rows = db.execute(
            "SELECT id, content AS text FROM vectors WHERE id > ? ORDER BY id LIMIT ?",
            (request["after"], limit),
        )
    elif operation == "duplicates":
        groups = db.execute(
            "SELECT embedding FROM vectors GROUP BY embedding HAVING count(*) > 1 "
            "ORDER BY min(id) LIMIT ?", (limit,),
        )
        return {"groups": [
            [row["id"] for row in db.execute(
                "SELECT id FROM vectors WHERE embedding = ? ORDER BY id", (group["embedding"],)
            )]
            for group in groups
        ]}
    else:
        raise ValueError(f"Unknown operation: {operation}")
    return {"rows": [dict(row) for row in rows]}


def serve(listener, db, dimensions):
    while True:
        connection, _ = listener.accept()
        with connection, connection.makefile("rb") as stream:
            connection.settimeout(5)
            try:
                message = stream.readline(8 * 1024 * 1024)
                if not message.endswith(b"\n"):
                    raise ValueError("Expected a newline-terminated request under 8 MiB")
                request = json.loads(message)
                result = dispatch(db, dimensions, request)
            except (OSError, ValueError, TypeError, KeyError, OverflowError, sqlite3.Error) as error:
                result = {"error": str(error)}
            try:
                connection.sendall(json.dumps(result).encode() + b"\n")
            except OSError:
                pass
            if result.get("stopped"):
                return


def terminate(_signal, _frame):
    raise KeyboardInterrupt


def main():
    command = parser("Start a passwordless in-memory SQLite vector database")
    command.add_argument("--dimensions", type=int, required=True)
    args = command.parse_args()
    if args.dimensions < 1:
        command.error("--dimensions must be positive")
    path = args.socket.absolute()
    try:
        import sqlite_vec

        path.parent.mkdir(mode=0o700, exist_ok=True)
        directory = path.parent.lstat()
        if (not stat.S_ISDIR(directory.st_mode) or directory.st_uid != os.getuid()
                or directory.st_mode & 0o077):
            command.error("Socket parent must be a private directory owned by the current user")
        with closing(sqlite3.connect(":memory:")) as db, socket.socket(socket.AF_UNIX) as listener:
            db.row_factory = sqlite3.Row
            if not hasattr(db, "enable_load_extension"):
                command.exit(1, "This Python cannot load SQLite extensions. Use the pi-agent image's Python.\n")
            db.enable_load_extension(True)
            try:
                sqlite_vec.load(db)
            finally:
                db.enable_load_extension(False)
            db.execute(
                "CREATE TABLE vectors (id TEXT PRIMARY KEY NOT NULL, content TEXT, "
                "embedding BLOB NOT NULL)"
            )
            listener.bind(str(path))
            try:
                path.chmod(0o600)
                listener.listen()
                signal.signal(signal.SIGTERM, terminate)
                print(json.dumps({"ready": True, "socket": str(path)}), flush=True)
                serve(listener, db, args.dimensions)
            finally:
                path.unlink(missing_ok=True)
    except KeyboardInterrupt:
        return
    except (ImportError, OSError, sqlite3.Error) as error:
        command.exit(1, f"{error}\n")


if __name__ == "__main__":
    main()
