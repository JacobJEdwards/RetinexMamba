#!/bin/bash

# This script processes image folders using the Retinexformer model.
# It takes a single argument: the main directory containing the subfolders to process.

# --- Configuration ---
# Set the model you want to use here.
# Make sure the WEIGHTS and CONFIG files match.
WEIGHTS="pretrained_weights/LOL_v1.pth"
CONFIG="Options/RetinexMamba_LOL_v1.yml"
# ---------------------


# Check if the user has provided a directory
if [ -z "$1" ]; then
  echo "Usage: $0 <main_directory>"
  exit 1
fi

MAIN_DIR=$1
PYTHON_SCRIPT="process_folder.py"

# --- Pre-run Checks ---
if [ ! -d "$MAIN_DIR" ]; then
  echo "Error: Directory '$MAIN_DIR' not found."
  exit 1
fi
if [ ! -f "$PYTHON_SCRIPT" ]; then
  echo "Error: Python script '$PYTHON_SCRIPT' not found."
  exit 1
fi
if [ ! -f "$WEIGHTS" ]; then
  echo "Error: Weights file '$WEIGHTS' not found."
  exit 1
fi
if [ ! -f "$CONFIG" ]; then
  echo "Error: Config file '$CONFIG' not found."
  exit 1
fi
# ---------------------

# Find all subdirectories in the main directory and process them
find "$MAIN_DIR" -mindepth 1 -maxdepth 1 -type d | while read -r SUB_DIR; do
  echo "--- Processing subdirectory: $SUB_DIR ---"

  # Define the folders to process within each subdirectory
  TARGET_FOLDERS=("images_8" "images_8_contrast" "images_8_multiexposure" "images_8_variance")

  for FOLDER in "${TARGET_FOLDERS[@]}"; do
    INPUT_FOLDER="$SUB_DIR/$FOLDER"
    OUTPUT_FOLDER="${INPUT_FOLDER}_retinexmamba"

    if [ -d "$INPUT_FOLDER" ]; then
      echo "Processing folder: $INPUT_FOLDER"
      uv run "$PYTHON_SCRIPT" --opt "$CONFIG" --weights "$WEIGHTS" --input_folder "$INPUT_FOLDER" --output_folder
      "$OUTPUT_FOLDER"
    else
      echo "Skipping... Folder not found: $INPUT_FOLDER"
    fi
  done
done

echo "--- All processing complete. ---"