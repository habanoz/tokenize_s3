#!/bin/bash

if [ -z "$1" ]; then
  echo "Error: Bucket name is not set"
  exit 1
fi

echo "Installing packages"
sudo apt update
sudo apt install build-essential -qq  -y
sudo apt install python3.12-dev -qq -y
sudo apt install python3.12-venv -qq -y

echo "Creating venv"
python3 -m venv .venv
source .venv/bin/activate

echo "Installing dependencies"
pip3 install -q -r requirements.txt

echo "Running script"
python3 tokenize_ds.py -ts 16 --local work_dir --logs "s3://$1/tokenize-dir/logs" stas/openwebtext-10k "s3://$1/tokenize-dir"

echo "Done!"