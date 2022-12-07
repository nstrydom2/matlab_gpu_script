import itertools
import sys
import time
import random
from pathlib import Path

import matlab.engine as matlab

from threading import Thread


def generate_combinations(cycles_st, cycles_fin, cycles_delta, days_st, days_fin, days_delta, cells_st,
                          cells_fin, cells_delta, lrate_st, lrate_fin, lrate_delta, gsfact_st, gsfact_fin,
                          gsfact_delta):
    cycles_fin += 1 if cycles_st == cells_fin else 0
    cycles = [x for x in range(cycles_st, cycles_fin, cycles_delta)]

    days_fin += 1 if days_st == days_fin else 0
    days = [x for x in range(days_st, days_fin, days_delta)]

    cells_fin += 1 if cells_st == cells_fin else 0
    cells = [x for x in range(cells_st, cells_fin, cells_delta)]

    lrate_fin += 1 if lrate_st == lrate_fin else 0
    lrates = [x * 0.001 for x in range(lrate_st, lrate_fin, lrate_delta)]

    gsfact_fin += 1 if gsfact_st == gsfact_fin else 0
    gsfacts = [0.1 * x for x in range(gsfact_st, gsfact_fin, gsfact_delta)]

    result = list(itertools.product(cycles, days, cells, lrates, gsfacts))
    return result


def quit_all(engines: list):
    [eng.quit() for eng in engines]


def chunks(seq, size):
    return [seq[i::size] for i in range(size)]


def run_scripts(scripts_path: Path, output_path, jj, st, fin2, stf, finf, low, high, gsfact1, dgs, dcy, dd, dlr,
                l2, cycles_st, cycles_fin, cycles_delta, days_st, days_fin, days_delta, cells_st,
                cells_fin, cells_delta, lrate_st, lrate_fin, lrate_delta, gsfact_st, gsfact_fin,
                gsfact_delta, n_gpus):
    sys.path.insert(1, str(scripts_path))

    engines = []
    threads = []
    rout = output_path
    combs = generate_combinations(cycles_st, cycles_fin, cycles_delta, days_st, days_fin, days_delta,
                                  cells_st, cells_fin, cells_delta, lrate_st, lrate_fin, lrate_delta,
                                  gsfact_st, gsfact_fin, gsfact_delta)
    chunkz = list(chunks(combs, n_gpus))
    for idx, fchunk in enumerate(chunkz):
        def worker(chunk, igpu):
            for chunk_idx, chunk_tuple in enumerate(chunk):
                random.seed(int(time.time()))
                sleep_rand = random.randint(2, 6)
                time.sleep(sleep_rand)

                cycles, days, cells, lrate, gsfact = chunk_tuple

                chunk_idx += len(chunk) * idx if idx > 0 else 0
                print(f'Hash idx = {chunk_idx}')

                eng = matlab.start_matlab()
                engines.append(eng)

                eng.loop2(jj, st, fin2, stf, finf, high, low, gsfact, dgs,
                          cycles, dcy, days, dd, lrate, dlr, cells, l2,
                          igpu, rout, nargout=0)

        time.sleep(2)
        t = Thread(target=worker, args=(fchunk, idx+1))
        t.start()

        threads.append(t)

    [t.join() for t in threads]

    return engines


def scan(output_path, jj, st, fin2, stf, finf, low, high, gsfact1, dgs, dcy, dd, dlr, l2, cycles_st,
         cycles_fin, cycles_delta, days_st, days_fin, days_delta, cells_st, cells_fin, cells_delta,
         lrate_st, lrate_fin, lrate_delta, gsfact_st, gsfact_fin, gsfact_delta, n_gpus):
    matlab_path = Path('C:/Users/User/Desktop/forex/nick/matlab_gpu_script')
    engines = run_scripts(matlab_path, output_path, jj, st, fin2, stf, finf, low, high, gsfact1, dgs, dcy, dd, dlr,
                          l2, cycles_st, cycles_fin, cycles_delta, days_st, days_fin, days_delta,
                          cells_st, cells_fin, cells_delta, lrate_st, lrate_fin, lrate_delta, gsfact_st,
                          gsfact_fin, gsfact_delta, n_gpus)
    quit_all(engines=engines)
