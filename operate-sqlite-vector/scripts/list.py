from client import parser, run


if __name__ == "__main__":
    command = parser("List rows in ID order")
    command.add_argument("--after", default="")
    command.add_argument("--limit", type=int, default=10)
    run(command, "list")
