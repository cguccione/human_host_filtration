import unittest
from unittest.mock import mock_open, patch, MagicMock
import sys
import os
import numpy as np

sys.path.insert(0, os.path.abspath('scripts'))
from qiita_filter_pmls import calculate_metric, calculate_custom_metric, process_file, main

class TestFilterPMLs(unittest.TestCase):
    def setUp(self):
        # create pml array 31-1 with padded 0
        self.pml_values = np.zeros(150, dtype=int)
        self.pml_values[:31] = np.arange(31, 0, -1)

    def test_max_metric(self):
        expected_max = 31
        calculated_max = calculate_metric(self.pml_values, 'max', 5)
        self.assertEqual(calculated_max, expected_max, "Max metric calculation failed.")

    def test_average_metric(self):
        expected_average = 3.306
        calculated_average = calculate_metric(self.pml_values, 'average', 5)
        self.assertAlmostEqual(calculated_average, expected_average, places=2, msg="Average metric calculation failed.")

    def test_custom_metric(self):
        expected_custom = 0.175
        calculated_custom = calculate_metric(self.pml_values, 'custom', 5)
        self.assertAlmostEqual(calculated_custom, expected_custom, places=2, msg="Custom metric calculation failed.")

class TestProcessFile(unittest.TestCase):
    def test_process_file_stdin(self):
        with patch('sys.stdin', new=MagicMock()) as mock_stdin:
            mock_stdin.readline.side_effect = [
                "@read1\n",
                "30 30 0 0\n",
                "@read2\n",
                "0 0 0 0\n",
                "",
                ""
            ]
            with patch('builtins.print') as mock_print:
                process_file(sys.stdin, 'max', 1, 5)
                mock_print.assert_called_with("read2")

    def test_process_file_regular_file(self):
        mock_data = "@read1\n30 30 0 0\n@read2\n0 0 0 0\n"
        m = mock_open(read_data=mock_data)
        with patch('builtins.open', m):
          with patch('builtins.print') as mock_print:
            process_file(open('fakefile.txt', 'r'), 'max', 1, 5)
            mock_print.assert_called_with("read2")
            m.assert_called_once_with('fakefile.txt', 'r')

class TestMainFunction(unittest.TestCase):
    def test_main_with_regular_file(self):
        test_args = ["script_name", "fakefile.txt", "max", "1", "5"]
        m_open = mock_open(read_data="data")
        
        with patch.object(sys, 'argv', test_args):
            with patch('builtins.open', m_open) as mocked_open:
                with patch('qiita_filter_pmls.process_file') as mocked_process:
                    main()
                    mocked_open.assert_called_once_with("fakefile.txt", 'r')
                    mocked_process.assert_called_once()
                    file_handle = mocked_open()
                    file_handle.close.assert_called_once()

    def test_main_with_stdin(self):
        test_args = ["script_name", "-", "max", "1", "5"]
        
        with patch.object(sys, 'argv', test_args):
            with patch('qiita_filter_pmls.process_file') as mocked_process:
                with patch('sys.stdin', new_callable=MagicMock) as mock_stdin:
                    main()
                    mocked_process.assert_called_once_with(mock_stdin, 'max', 1.0, 5)
                    mock_stdin.close.assert_not_called()


if __name__ == '__main__':
    unittest.main()
