import itertools
import sys
from pathlib import Path

import matlab.engine as matlab

# User defined values
jj = 0
st = 516
fin2 = 517
stf = 10
finf = 10
low = .04
high = 1
gsfact1 = 0.9
dgs = 0.2
dcy = 50
dd = 20
dlr = 0
l2 = 0

cycles_st = 1100
cycles_fin = 900
cycles_delta = -50
days_st = 1
days_fin = 150
days_delta = 1
cells_st = 350
cells_fin = 340
cells_delta = 30
lrate_st = 5
lrate_fin = 8
lrate_delta = -1
gsfact_st = 7
gsfact_fin = 8
gsfact_delta = 1


def generate_combinations():
    cycles = [x for x in range(cycles_st, cycles_fin, cycles_delta)]
    days = [x for x in range(days_st, days_fin, days_delta)]
    cells = [x for x in range(cells_st, cells_fin, cells_delta)]
    lrates = [x * 0.001 for x in range(lrate_st, lrate_fin, lrate_delta)]
    gsfacts = [0.1 * x for x in range(gsfact_st, gsfact_fin, gsfact_delta)]

    result = list(itertools.product(cycles, days, cells, lrates, gsfacts))
    return result


def quit_all(engines: list):
    [eng.quit() for eng in engines]


def run_scripts(scripts_path: Path):
    sys.path.insert(1, str(scripts_path))

    engines = []
    for cycle, day, cell, lrate, gsfact in generate_combinations():
        eng = matlab.start_matlab()
        engines.append(eng)

        eng.loop2(jj, st, fin2, stf, finf, high, low, gsfact, dgs,
                  dcy, day, dd, lrate, dlr)

    return engines


def main():
    matlab_path = Path('C:/Users/Nick/PycharmProjects/matlab_script')
    engines = run_scripts(scripts_path=matlab_path)
    quit_all(engines=engines)


if __name__ == '__main__':
    main()
