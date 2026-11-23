import argparse
import json
import os
from pathlib import Path
import socket

DEFAULT_SOCKET = Path(f"/tmp/pi-sqlite-vector-{os.getuid()}/database.sock")


def parser(description):
    command = argparse.ArgumentParser(description=description)
    command.add_argument("--socket", type=Path, default=DEFAULT_SOCKET)
    return command


def run(command, operation):
    arguments = vars(command.parse_args())
    path = arguments.pop("socket")
    try:
        request = json.dumps({"operation": operation, **arguments}).encode()
        with socket.socket(socket.AF_UNIX) as connection:
            connection.settimeout(60)
            connection.connect(str(path))
            connection.sendall(request + b"\n")
            with connection.makefile("rb") as response:
                result = json.loads(response.readline())
        if "error" in result:
            command.exit(1, json.dumps(result) + "\n")
        print(json.dumps(result))
    except (OSError, ValueError) as error:
        command.exit(1, json.dumps({"error": str(error)}) + "\n")
