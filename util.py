import itertools
import sys
from pathlib import Path

import matlab.engine as matlab


def generate_combinations(cycles_st, cycles_fin, cycles_delta, days_st, days_fin, days_delta, cells_st,
                          cells_fin, cells_delta, lrate_st, lrate_fin, lrate_delta, gsfact_st, gsfact_fin,
                          gsfact_delta):
    cycles = [x for x in range(cycles_st, cycles_fin, cycles_delta)]
    days = [x for x in range(days_st, days_fin, days_delta)]
    cells = [x for x in range(cells_st, cells_fin, cells_delta)]
    lrates = [x * 0.001 for x in range(lrate_st, lrate_fin, lrate_delta)]
    gsfacts = [0.1 * x for x in range(gsfact_st, gsfact_fin, gsfact_delta)]

    result = list(itertools.product(cycles, days, cells, lrates, gsfacts))
    return result


def quit_all(engines: list):
    [eng.quit() for eng in engines]


def run_scripts(scripts_path: Path, output_path, jj, st, fin2, stf, finf, low, high, gsfact1, dgs, dcy, dd, dlr,
                l2, cycles_st, cycles_fin, cycles_delta, days_st, days_fin, days_delta, cells_st,
                cells_fin, cells_delta, lrate_st, lrate_fin, lrate_delta, gsfact_st, gsfact_fin,
                gsfact_delta):
    sys.path.insert(1, str(scripts_path))

    engines = []
    rout = output_path
    combs = generate_combinations(cycles_st, cycles_fin, cycles_delta, days_st, days_fin, days_delta,
                                  cells_st, cells_fin, cells_delta, lrate_st, lrate_fin, lrate_delta,
                                  gsfact_st, gsfact_fin, gsfact_delta)
    for cycle, day, cell, lrate, gsfact in combs:
        eng = matlab.start_matlab()
        engines.append(eng)

        eng.loop2(jj, st, fin2, stf, finf, high, low, gsfact, dgs,
                  dcy, day, dd, lrate, dlr, igpu, rout, nargout=0)

    return engines


def scan(output_path, jj, st, fin2, stf, finf, low, high, gsfact1, dgs, dcy, dd, dlr, l2, cycles_st,
         cycles_fin, cycles_delta, days_st, days_fin, days_delta, cells_st, cells_fin, cells_delta,
         lrate_st, lrate_fin, lrate_delta, gsfact_st, gsfact_fin, gsfact_delta):
    matlab_path = Path('C:/Users/Nick/PycharmProjects/matlab_script')
    engines = run_scripts(matlab_path, output_path, jj, st, fin2, stf, finf, low, high, gsfact1, dgs, dcy, dd, dlr,
                          l2, cycles_st, cycles_fin, cycles_delta, days_st, days_fin, days_delta,
                          cells_st, cells_fin, cells_delta, lrate_st, lrate_fin, lrate_delta, gsfact_st,
                          gsfact_fin, gsfact_delta)
    quit_all(engines=engines)
