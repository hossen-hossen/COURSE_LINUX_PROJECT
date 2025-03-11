#!/usr/bin/env bash

MAIN_LOG="q4_process.log"
ERR_LOG="q4_errors.log"
echo "=== Q4 Script Start ===" | tee -a "$MAIN_LOG"

CSV_FILE=""
VENV_PATH="$HOME/plant_venv_v2"
REQ_FILE="../Q2/requirements.txt"
PY_SCRIPT="../Q2/plant_plots.py"
IMAGES_DIR="PlotImages"

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--csvFile)
      CSV_FILE="$2"
      shift 2
      ;;
    -v|--virtualHome)
      VENV_PATH="$2"
      shift 2
      ;;
    -r|--requirements)
      REQ_FILE="$2"
      shift 2
      ;;
    *)
      echo "Unknown parameter: $1" | tee -a "$MAIN_LOG"
      shift
      ;;
  esac
done

# If CSV not specified, guess the first .csv in current dir
if [ -z "$CSV_FILE" ]; then
  CSV_FILE=$(ls *.csv 2>/dev/null | head -n 1)
  if [ -z "$CSV_FILE" ]; then
    echo "No CSV provided or found. Exiting." | tee -a "$MAIN_LOG" "$ERR_LOG"
    exit 1
  fi
  echo "Auto-detected CSV: $CSV_FILE" | tee -a "$MAIN_LOG"
fi

# Create or reuse the venv
if [ -d "$VENV_PATH" ]; then
  echo "Using existing virtual env: $VENV_PATH" | tee -a "$MAIN_LOG"
else
  echo "Creating new venv at $VENV_PATH" | tee -a "$MAIN_LOG"
  python3 -m venv "$VENV_PATH" >>"$MAIN_LOG" 2>>"$ERR_LOG"
  if [ $? -ne 0 ]; then
    echo "venv creation failed." | tee -a "$MAIN_LOG" "$ERR_LOG"
    exit 1
  fi
fi

# Activate
echo "Activating venv..." | tee -a "$MAIN_LOG"
source "$VENV_PATH/bin/activate"
if [ $? -ne 0 ]; then
  echo "Failed to activate venv." | tee -a "$MAIN_LOG" "$ERR_LOG"
  exit 1
fi

# Install requirements if the file exists
if [ -f "$REQ_FILE" ]; then
  echo "Installing from $REQ_FILE" | tee -a "$MAIN_LOG"
  pip install -r "$REQ_FILE" >>"$MAIN_LOG" 2>>"$ERR_LOG"
else
  echo "Missing $REQ_FILE, skipping pip install." | tee -a "$MAIN_LOG"
fi

# Check for the Q2 python script
if [ ! -f "$PY_SCRIPT" ]; then
  echo "No script at $PY_SCRIPT" | tee -a "$MAIN_LOG" "$ERR_LOG"
  deactivate
  exit 1
fi

# We'll store images in IMAGES_DIR
mkdir -p "$IMAGES_DIR"

echo "Processing CSV: $CSV_FILE" | tee -a "$MAIN_LOG"

# Skip header with tail
tail -n +2 "$CSV_FILE" | while IFS= read -r line; do
  # remove quotes
  clean=$(echo "$line" | sed 's/"//g')
  IFS=',' read -r plant heights leaves dryweights <<< "$clean"

  # Make subfolder for the plant
  subdir="$IMAGES_DIR/$plant"
  mkdir -p "$subdir"

  echo "Running Q2 script for $plant" | tee -a "$MAIN_LOG"
  python3 "$PY_SCRIPT" --plant "$plant" --height $heights --leaf_count $leaves --dry_weight $dryweights \
    >>"$MAIN_LOG" 2>>"$ERR_LOG"
  if [ $? -eq 0 ]; then
    # Move .png to subdir
    mv "${plant}"_*.png "$subdir" 2>/dev/null
    echo "Plots succeeded for $plant" | tee -a "$MAIN_LOG"
  else
    echo "Error generating plots for $plant" | tee -a "$MAIN_LOG" "$ERR_LOG"
  fi
done

# Archive everything
TSTAMP=$(date +"%Y%m%d_%H%M")
ARCHFILE="plots_q4_${TSTAMP}.tar.gz"
tar -czf "$ARCHFILE" "$IMAGES_DIR" >>"$MAIN_LOG" 2>>"$ERR_LOG"
mv "$ARCHFILE" ../../BACKUPS/
echo "Archived $ARCHFILE to BACKUPS" | tee -a "$MAIN_LOG"

# Deactivate
deactivate
echo "=== Q4 Script End ===" | tee -a "$MAIN_LOG"
