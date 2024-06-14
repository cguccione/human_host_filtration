#!/usr/bin/env python
# Author: Lucas Patel
# Date: 12/22/23
# Description: This script computes max, average, and custom PML metrics over the distribution of PMLs in a sample of reads, then filters out human reads based on a threshold. By default, the metric used is "custom" and is set to 0.175. Metric options are "max", "average", and "custom".
# Usage: python filter_pmls.py [input_pml_file] [original_fastq] [output_dir][metric (optional)]

import sys
import os
import numpy as np
import pandas as pd
import math

THRESHOLDS = {
    'max': 31,
    'average': 3.306,
    'custom': 0.175
}

def calculate_run_lengths(pml_values):
    runs = []
    current_run = 0
    for score in pml_values:
        if score == 0:
            if current_run > 0:
                runs.append(current_run)
            current_run = 0
        else:
            current_run = max(current_run, score)
    if current_run > 0:
        runs.append(current_run)
    return runs

def calculate_custom_metric(pml_values, min_run_length=5):
    """
    Calculate a custom metric that considers the length and count of runs of non-zero PML scores.
    :param pml_values: numpy array of PML scores for a single read.
    :param min_run_length: minimum length of a run to be considered.
    :return: normalized custom metric value.
    """
    runs = [run for run in calculate_run_lengths(pml_values) if run >= min_run_length]
    total_run_length = sum(runs)
    run_count = len(runs)
    adjustment_factor = math.log(run_count + 1) if run_count > 0 else 0
    max_pml_score = max(pml_values)
    adjusted_run_length_score = total_run_length * adjustment_factor
    hybrid_score = (max_pml_score + adjusted_run_length_score) / 2
    normalized_hybrid_score = hybrid_score / len(pml_values) if len(pml_values) > 0 else 0
    return normalized_hybrid_score

def process_file(pml_file, fastq_file, out_path, metric, threshold, min_run_length):
    base_filename = os.path.basename(pml_file).rsplit('.', 1)[0]

    #human_output_path = os.path.join(out_path, f'{base_filename}.human.fastq')
    non_human_output_path = os.path.join(out_path, f'{base_filename}.non-human.fastq')
    human_output_path = os.path.join(out_path, f'{base_filename}.non-human.ids.txt')

    with open(pml_file, 'r') as pml, \
         open(non_human_output_path, 'w') as non_human_out:
        
        while True:
            pml_lines = [pml.readline().strip() for _ in range(2)]
            
            if not pml_lines[-1]:
                break

             # Split PML lines into two groups
            read_id1, pml_line1 = pml_lines[:2]
            pml_values1 = np.array(pml_line1.split(), dtype=int)
            metric_value1 = calculate_metric(pml_values1, metric, min_run_length)

            if metric_value1 < threshold:
                print(read_id1[1:])

def calculate_metric(pml_values, metric, min_run_length):
    """
    Calculate the metric for a set of PML values based on the specified type.
    :param pml_values: numpy array of PML scores for a single read.
    :param metric: string specifying the metric type ('max', 'average', or 'custom').
    :return: the calculated metric value.
    """
    if metric == 'max':
        return pml_values.max()
    elif metric == 'average':
        return pml_values.mean()
    elif metric == 'custom':
        return calculate_custom_metric(pml_values, min_run_length)
    else:
        raise ValueError(f"Unknown metric type: {metric}")

def main():
    if len(sys.argv) < 4:
        print("Usage: python filter_pmls.py [input_pml_file] [original_fastq] [output_dir] [optional: metric]")
        sys.exit(1)

    input_file = sys.argv[1]
    original_fastq = sys.argv[2]
    out_path = sys.argv[3]
    metric = sys.argv[4] if len(sys.argv) > 4 else 'custom'
    threshold = float(sys.argv[5]) if len(sys.argv) > 5 else THRESHOLDS[metric]
    min_run_length = int(sys.argv[6]) if len(sys.argv) > 6 else 5

    process_file(input_file, original_fastq, out_path, metric, threshold, min_run_length)

if __name__ == "__main__":
    main()
