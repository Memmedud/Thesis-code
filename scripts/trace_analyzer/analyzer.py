

verbose=False

def parse_strings(file_path):
    with open(file_path, 'r') as file:
        # Read and return the list of strings from the file
        return [line.strip().lower() for line in file]
    
def get_third_column(line):
    columns = line.split()
    return columns[2] if len(columns) > 2 else None

def search_strings(search_file_path, strings_to_search):
    matches_count = {string: 0 for string in strings_to_search}

    with open(search_file_path, 'r') as search_file:
        for line_number, line in enumerate(search_file, start=1):
            third_column = get_third_column(line)
            if third_column:
                for string_to_search in strings_to_search:
                    if string_to_search.lower() == third_column:
                        matches_count[string_to_search] += 1
                        if verbose:
                            print(f"Found '{string_to_search}' at line {line_number}: {line.strip()}")
    
    return matches_count


# Replace 'strings_file.txt' with the path to your file containing strings
strings_file_path = 'Instructions.txt'

# Replace 'search_file.txt' with the path to your file to search through
search_file_path = '/home/mats/masteroppgave/Thesis-code/results/bins/pext/ic/ic_tflm.lst'

# Parse strings from the file
strings_to_search = parse_strings(strings_file_path)

# Search for the parsed strings in the search file
matches_count = search_strings(search_file_path, strings_to_search)

for string, count in matches_count.items():
    if count > 0:
        print(f"Number of matches for '{string}': {count}")