import unittest
import sys
import os
import numpy as np

sys.path.insert(0, os.path.abspath('scripts'))
from filter_pmls import calculate_metric, calculate_custom_metric

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
        # Only the non-zero values contribute to the average
        expected_average = 3.306
        calculated_average = calculate_metric(self.pml_values, 'average', 5)
        self.assertAlmostEqual(calculated_average, expected_average, places=2, msg="Average metric calculation failed.")

    def test_custom_metric(self):
        expected_custom = 0.175
        calculated_custom = calculate_metric(self.pml_values, 'custom', 5)
        self.assertAlmostEqual(calculated_custom, expected_custom, places=2, msg="Custom metric calculation failed.")

if __name__ == '__main__':
    unittest.main()
