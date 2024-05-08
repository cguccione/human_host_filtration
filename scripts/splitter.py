import argparse

def process_fastq(input_file, output_file):
    """Process the FASTQ file to remove isolated mates."""
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        read_pairs = {}
        try:
            while True:
                # Read the four lines of one FASTQ record
                identifier = infile.readline().strip()
                if not identifier:
                    break
                sequence = infile.readline().strip()
                plus_line = infile.readline().strip()
                quality = infile.readline().strip()

                # Extract mate type and core identifier
                mate_type = identifier.split()[-1][-1]  # Assuming /1 or /2
                core_identifier = identifier.rsplit('/', 1)[0]

                # Store in dictionary
                if core_identifier not in read_pairs:
                    read_pairs[core_identifier] = {}
                read_pairs[core_identifier][mate_type] = (identifier, sequence, plus_line, quality)

        except EOFError:
            pass  # End of file reached

        # Output complete pairs
        for core_id, mates in read_pairs.items():
            if len(mates) == 2:
                for mate_type in sorted(mates.keys()):
                    identifier, sequence, plus_line, quality = mates[mate_type]
                    outfile.write(f"{identifier}\n{sequence}\n{plus_line}\n{quality}\n")

def main():
    parser = argparse.ArgumentParser(description="Process interleaved FASTQ files to remove unpaired reads.")
    parser.add_argument("input_file", type=str, help="The path to the interleaved FASTQ file.")
    parser.add_argument("output_file", type=str, help="The path to output the cleaned FASTQ file.")
    args = parser.parse_args()

    process_fastq(args.input_file, args.output_file)

if __name__ == "__main__":
    main()

