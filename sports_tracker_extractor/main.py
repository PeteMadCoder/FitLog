#!/usr/bin/env python3
"""
Main entry point for the Sports Tracker Extractor & Compiler.
Parses CLI flags and routes execution to the extractor and/or compiler modules.
"""

import argparse
from extractor import run_extraction
from compiler import compile_gpx_to_json


def main():
    parser = argparse.ArgumentParser(
        description="Sports Tracker Extractor & Compiler for FitLog."
    )
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        "--extract",
        action="store_true",
        help="Extract workouts from Sports Tracker (downloads GPX files to data/)",
    )
    group.add_argument(
        "--compile",
        action="store_true",
        help="Compile all GPX files in data/ to workouts_import.json",
    )
    group.add_argument(
        "--both",
        action="store_true",
        help="Perform both extraction and compilation sequentially",
    )

    parser.add_argument(
        "--data-dir",
        type=str,
        default="data",
        help="Directory to save/read GPX files (default: data)",
    )
    parser.add_argument(
        "--output",
        type=str,
        default="workouts_import.json",
        help="Output JSON file name (default: workouts_import.json)",
    )

    args = parser.parse_args()

    success = True

    if args.extract or args.both:
        print("--- Starting Extraction Step ---")
        success = run_extraction(args.data_dir)

    if success and (args.compile or args.both):
        print("\n--- Starting Compilation Step ---")
        compile_gpx_to_json(data_dir=args.data_dir, output_file=args.output)


if __name__ == "__main__":
    main()
