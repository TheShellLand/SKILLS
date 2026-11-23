from client import parser, run

if __name__ == "__main__":
    command = parser("Find byte-identical float32 vectors")
    command.add_argument("--limit", type=int, default=10)
    run(command, "duplicates")
