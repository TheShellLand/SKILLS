from client import parser, run


if __name__ == "__main__":
    command = parser("Show database status")
    run(command, "status")
