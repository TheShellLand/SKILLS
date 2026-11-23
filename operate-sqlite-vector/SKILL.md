---
name: operate-sqlite-vector
description: Initialize and operate a passwordless in-memory SQLite database with sqlite-vec in pi-agent. Use to store, search, inspect, update, or delete caller-supplied embeddings across shell commands.
---

# Operate SQLite Vector

Run the Python scripts from this skill's `scripts/` directory inside the running
`pi-agent:sqlite3-vector` container. Use the image's `python`, which has `sqlite_vec`.
Use one database per embedding model and dimension. Supply already-generated vectors
from that same model for both writes and queries.

Initialize the database in a long-lived terminal or background job:

```sh
python init.py --dimensions 3
```

Wait for the ready message, then run clients in the same container as the same OS user.
The foreground server owns the sole `:memory:` connection. Its private Unix socket
provides local access without a password. All data disappears when the server
exits or the container stops. To run multiple databases, pass the same
`--socket /absolute/private/path.sock` to initialization and every client for
that database. The socket's parent must be private and owned by the current user.
After a crash, use a fresh socket path or remove the stale socket after confirming
the previous server has exited.

Illustrative commands for a three-dimensional database:

```sh
python status.py
python write.py chunk-1 '[1,0,0]' --text 'Example text'
python search.py --limit 5 -- '[0.9,0,0]'
python get.py chunk-1
python list.py --limit 20
python list.py --after chunk-1 --limit 20
python duplicates.py --limit 20
python delete.py chunk-1
python stop.py
```

Use stable source/chunk IDs. Writing the same ID replaces its vector and text.
Search returns the nearest rows by exact Euclidean distance, lower first,
using
sqlite-vec's [scalar functions](https://alexgarcia.xyz/sqlite-vec/features/knn.html#manually-with-sql-scalar-functions).
The search scans all rows and suits small in-memory collections. Lookup,
listing, and search return IDs and text. All clients return JSON and exit
nonzero on command errors.

Duplicate inspection groups byte-identical float32 vectors and reports their IDs.
Review the IDs and source text before deleting. Different chunks can legitimately
share a vector. Delete only the explicit IDs selected for cleanup. Deletion removes
the whole row. Stop only when the user is ready to discard the database.
