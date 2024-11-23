#!/bin/bash

echo "Installing packages"
sudo apt update
sudo apt install python3.12-dev
sudo apt install python3.12-venv

echo "Installing dependencies"
pip3 install -r requirements.txt

echo "Running script"
python3 tokenize_ds.py -ts 2 --local work_dir --logs s3://tokenize-bucket20241123081319090400000001/tokenize-dir/logs stas/openwebtext-10k s3://tokenize-bucket20241123081319090400000001/tokenize-dir

echo "Done!"