from client import parser, run

if __name__ == "__main__":
    command = parser("Fetch a row by ID")
    command.add_argument("id")
    run(command, "get")
