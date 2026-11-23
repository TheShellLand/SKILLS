from client import parser, run


if __name__ == "__main__":
    command = parser("Stop the database and discard its contents")
    run(command, "stop")
