from client import parser, run


if __name__ == "__main__":
    command = parser("Find nearest vectors by L2 distance")
    command.add_argument("vector")
    command.add_argument("--limit", type=int, default=10)
    run(command, "search")
