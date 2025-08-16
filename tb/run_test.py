#!/usr/bin/env python3
import sys
import subprocess
import pathlib
import shutil

ROOT = pathlib.Path(__file__).resolve().parent.parent
PROG_DIR = ROOT / 'tb' / 'tb_programs'
MAKE = ['make','-C',str(ROOT)]

TESTS = [
  ('01_adds.hex', '01_adds.exp', 220),
  ('02_load_store.hex', '02_load_store.exp', 400),
  ('03_branch.hex', '03_branch.exp', 300),
  ('04_branch_not_taken.hex', '04_branch_not_taken.exp', 300),
  ('05_load_use.hex', '05_load_use.exp', 400),
]

def run_one(hex_name: str, exp_name: str, cycles: int) -> bool:
    target_hex = ROOT / 'imem_init.hex'
    shutil.copy(PROG_DIR / hex_name, target_hex)
    vvp = ROOT / 'build' / 'tb_simple.vvp'
    # Rebuild
    r = subprocess.run(MAKE + ['clean','sim'], capture_output=True, text=True)
    if r.returncode != 0:
        print(r.stdout)
        print(r.stderr)
        print(f'BUILD_FAIL {hex_name}')
        return False
    # Run with plusargs (recompile includes testbench so we only need to run once after build)
    cmd = ['vvp', str(vvp), f'+CYCLES={cycles}', f'+EXP=tb/tb_programs/{exp_name}']
    sim = subprocess.run(cmd, capture_output=True, text=True, cwd=ROOT)
    out = sim.stdout
    print(out)
    # Determine pass/fail: look for summary line
    passed = 'ALL' in out and 'CHECKS PASSED' in out and 'FAILED' not in out
    status = 'PASS' if passed else 'FAIL'
    print(f'[{status}] {hex_name}')
    return passed

def main():
  results = []
  for hex_name, exp_name, cycles in TESTS:
    print(f'=== Running {hex_name} (cycles={cycles}) ===')
    ok = run_one(hex_name, exp_name, cycles)
    results.append((hex_name, ok))
  passed = sum(1 for _,ok in results if ok)
  total = len(results)
  print('==== SUMMARY ====')
  for name, ok in results:
    print(f'{name}: {"PASS" if ok else "FAIL"}')
  print(f'Overall: {passed}/{total} passed')
  if passed != total:
    sys.exit(1)
  else:
    sys.exit(0)

if __name__=='__main__':
  main()
