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

test_class = "M"

# Example usage:
root_dir = "/home/mats/masteroppgave/Thesis-code/sw/riscv-arch-test/diffs"
total_stats = []
for root, dirs, files in os.walk(f"{root_dir}/{test_class}"):
    for filename in files:
        full_name = os.path.join(root, filename)
        res = compare_files(full_name)
        total_stats.append({'testname' : filename, 'pass-fail' : res, 'coverage' : round(1 - (res[1] / res[0]), 3)})

def key_func(e):
    return e['coverage']

total_stats.sort(key=key_func)

overall = [0, 0]
print("Failing tests and its coverage")
for i in total_stats:
    overall[0] += i['pass-fail'][0]
    overall[1] += i['pass-fail'][1]
    print(i)

print(f"Total failing coverage {1 - (overall[1] / overall[0])}")