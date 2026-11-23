from client import parser, run

if __name__ == "__main__":
    command = parser("Delete one or more exact IDs")
    command.add_argument("ids", nargs="+")
    run(command, "delete")
