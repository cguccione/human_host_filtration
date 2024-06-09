import unittest
import os
import gzip

class TestPipelineOutput(unittest.TestCase):
    def setUp(self):
        """Setup the base directory and file names."""
        self.base_directory = "data/host-filtered/"
        self.file_names = ["50.00p-HG002.maternal_50.00p-FDA-ARGO-41_sim_SUB-h100000-m100000_R1.fastq.gz", 
                           "50.00p-HG002.maternal_50.00p-FDA-ARGO-41_sim_SUB-h100000-m100000_R2.fastq.gz"]

    def test_files_read_count(self):
        """Test each gzipped file for the correct number of reads."""
        for file_name in self.file_names:
            file_path = os.path.join(self.base_directory, file_name)
            try:
                with gzip.open(file_path, 'rt') as file:
                    line_count = sum(1 for line in file)
                    self.assertEqual(line_count/4, 49998, f"{file_name} does not have the expected number of reads. Was Method 1 used?")
            except FileNotFoundError:
                print(f"File {file_name} does not exist. Ensure the pipeline is run first.")
            except Exception as e:
                self.fail(f"An unexpected error occurred while reading {file_name}: {str(e)}")

if __name__ == '__main__':
    unittest.main()

