"""Print the current local or UTC calendar date as YYYY-MM-DD."""

import argparse
from datetime import datetime, timezone


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--utc', action='store_true', help='Use UTC instead of system local time.')
    args = parser.parse_args()
    now = datetime.now(timezone.utc) if args.utc else datetime.now().astimezone()
    print(now.date().isoformat())


if __name__ == '__main__':
    main()
