import os
import glob
import json


def get_last_n_files(directory, n, extension):
    # Get list of files with the specified extension sorted by modification time
    files = glob.glob(os.path.join(directory, f'*.{extension}'))
    files.sort(key=os.path.getmtime, reverse=True)
    return files[:n]


def print_transcript_from_json(file_path):
    with open(file_path, 'r') as file:
        data = json.load(file)

        # Check if 'results' and 'transcripts' fields exist in the JSON data
        if 'results' in data and 'transcripts' in data['results']:
            transcripts = data['results']['transcripts']
            for transcript in transcripts:
                print(transcript.get('transcript', 'No transcript found'))
        else:
            print("No transcript field found in JSON data.")
    print('\n' + '-'*50 + '\n')


def main():
    directory = r'C:\Users\Dguillen\Downloads'
    num_files = 3
    extension = 'json'

    last_files = get_last_n_files(directory, num_files, extension)

    if not last_files:
        print("No JSON files found.")
        return

    print("Last {} JSON files:".format(num_files))
    for i, file_path in enumerate(last_files):
        print(f"{i+1}: {file_path}")

    # Ask user to choose a file to read
    while True:
        choice = input(
            f"Enter the number of the file you want to read (1-{len(last_files)}): ")
        if choice.isdigit() and 1 <= int(choice) <= len(last_files):
            chosen_file = last_files[int(choice) - 1]
            break
        else:
            print(
                f"Invalid choice. Please enter a number between 1 and {len(last_files)}.")

    print(f"\nReading file: {chosen_file}\n")
    print_transcript_from_json(chosen_file)


if __name__ == "__main__":
    main()
