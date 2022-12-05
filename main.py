import itertools
import sys
import time
from pathlib import Path
from threading import Thread

import matlab.engine as matlab

# User defined values
jj = 0
st = 460
fin2 = 517
stf = 6
finf = 6
low = 0.002
high = 1
gsfact1 = 0.9
dgs = 0.2
dcy = 50
dd = 20
dlr = 0
l2 = 0.0029

cycles_st = 300
cycles_fin = 900
cycles_delta = 50
days_st = 90
days_fin = 180
days_delta = 30
cells_st = 150
cells_fin = 351
cells_delta = 50
lrate_st = 3
lrate_fin = 9
lrate_delta = 2
gsfact_st = 7
gsfact_fin = 9
gsfact_delta = 2

n_gpus = 3


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


def join_threads(threads: list):
    [thread.join() for thread in threads]


def chunks(l, n):
    """Yield n number of striped chunks from l."""
    for i in range(0, n):
        yield l[i::n]


def run_scripts(scripts_path: Path):
    sys.path.insert(1, str(scripts_path))

    engines = []
    threads = []
    chunkz = chunks(generate_combinations(), n_gpus)
    for idx, chunk in enumerate(chunkz):
        def worker(igpu: int):
            for cycles, day, cells, lrate, gsfact in chunk:
                eng = matlab.start_matlab()
                engines.append(eng)

                eng.loop2(jj, st, fin2, stf, finf, high, low, gsfact, dgs, cycles,
                          dcy, day, dd, lrate, dlr, cells, l2, igpu, nargout=0)
                eng.quit()
                time.sleep(0.8)

        thread = Thread(target=worker, args=(idx + 1,))
        thread.start()
        threads.append(thread)

    return threads


def main():
    matlab_path = Path(r'C:\Users\sfous\Desktop\forex\nick\matlab_gpu_script')
    threads = run_scripts(scripts_path=matlab_path)
    #quit_all(engines=engines)
    join_threads(threads=threads)


if __name__ == '__main__':
    main()
