from client import parser, run


if __name__ == "__main__":
    command = parser("Upsert a vector by stable ID")
    command.add_argument("id")
    command.add_argument("vector")
    command.add_argument("--text")
    run(command, "put")
