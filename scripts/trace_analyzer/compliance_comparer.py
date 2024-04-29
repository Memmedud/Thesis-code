import os

def compare_files(file):
    stats = [0, 0]
    with open(file, 'r') as f1:
        lines = f1.readlines()

    # Compare lines and report differences
    num_lines = len(lines)
    for i in range(num_lines):
        line1 = lines[i].strip().split()[0]
        line2 = lines[i].strip().split()[1]
        stats[0] += 1
        if line1 != line2:
            stats[1] += 1
    return stats

test_class = "P"

# Example usage:
root_dir = "/home/mats/masteroppgave/Thesis-code/sw/riscv-arch-test/diffs"
total_stats = []
total_fails = 0
total_tests = 0
for root, dirs, files in os.walk(f"{root_dir}/{test_class}"):
    for filename in files:
        full_name = os.path.join(root, filename)
        res = compare_files(full_name)
        total_stats.append({'testname' : filename, 'pass-fail' : res, 'coverage' : round(1 - (res[1] / res[0]), 3)})
        total_fails = total_fails + res[1]

def key_func(e):
    return e['coverage']

total_stats.sort(key=key_func)

overall = [0, 0]
once = False
print("Failing tests and its coverage")
for i in total_stats:
    overall[0] += i['pass-fail'][0]
    overall[1] += i['pass-fail'][1]
    if ((i['coverage'] > 0.9) and not once):
        print("----------------------------------------------------------")
        once = True
    print(i)

print(f"Total failing coverage {1 - (overall[1] / overall[0])}")

# Count total number of tests and fails
# Example usage:
root_dir = "/home/mats/masteroppgave/Thesis-code/sw/riscv-arch-test/riscv-test-suite/rv32i_m"
total_stats = []
for root, dirs, files in os.walk(f"{root_dir}/{test_class}/references"):
    for filename in files:
        full_name = os.path.join(root, filename)
        with open(full_name, 'r') as file:
            total_tests = total_tests + len(file.readlines())

print("Total tests: ", total_tests)
print("Total fails: ", total_fails)
print("Total pass-rate: ", 1-(total_fails/total_tests))
