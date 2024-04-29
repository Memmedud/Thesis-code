def compare_files(file1, file2):
    num_differences = 0
    with open(file1, 'r') as f1, open(file2, 'r') as f2:
        lines1 = f1.readlines()
        lines2 = f2.readlines()

    # Compare lines and report differences
    num_lines = min(len(lines1), len(lines2))
    for i in range(num_lines):
        line1 = lines1[i].strip().split()[2:]
        line2 = lines2[i].strip().split()[2:]
        if line1 != line2:
            print(f"Line {i + 1} differs:")
            print(f"   {file2}: {lines2[i-1]}")
            print(f"   {file1}: {lines1[i-1]}")
            print(f"   {file1}: {lines1[i]}")
            print(f"   {file2}: {lines2[i]}")
            print()
            num_differences += 1
        if num_differences > 5:
            print("Too many diffs")
            break

    # Report if one file has more lines than the other
    if len(lines1) > len(lines2):
        print(f"{file1} has more lines.")
    elif len(lines1) < len(lines2):
        print(f"{file2} has more lines.")
    else:
        print("Both files have the same number of lines.")

# Example usage:
file1 = "/home/mats/masteroppgave/Thesis-code/hw/ibex/trace_core_00000000.log"
file2 = "/home/mats/masteroppgave/Thesis-code/hw/ibex_pext/trace_core_00000000.log"
compare_files(file1, file2)