import time


def draw(positions: set[complex]):
    max_x = max(int(z.real) for z in positions)
    max_y = max(int(z.imag) for z in positions)
    drawing = [
        "".join(["#" if x + y * 1j in positions else "." for x in range(0, max_x + 1)])
        for y in reversed(range(0, max_y + 1))
    ]
    print("\n".join(drawing))


def split(positions: set[complex], p: complex, counter: int) -> int:
    positions.add(p + 1)
    positions.add(p + 1j)
    positions.remove(p)
    return counter + 1


def clear_position(positions: set[complex], p: complex, counter: int) -> int:
    if p not in positions:
        return counter

    counter = clear_position(positions, p + 1, counter)
    counter = clear_position(positions, p + 1j, counter)
    counter = split(positions, p, counter)

    draw(positions)
    print()
    time.sleep(0.2)

    return counter


def solve(m, n):
    positions: set[complex] = set()
    positions.add(0 + 0j)
    to_clear = {x + y * 1j for x in range(m + 1) for y in range(n + 1)}

    counter = 0
    while not to_clear.isdisjoint(positions):
        # print(positions)
        p = next(iter(to_clear.intersection(positions)))
        counter = clear_position(positions, p, counter)
    return counter


def main():
    solve(4, 4)


if __name__ == "__main__":
    main()
