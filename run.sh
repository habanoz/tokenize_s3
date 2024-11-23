#!/bin/bash

pip install -r requirements.txt
python tokenize_ds.py -ts 4 --local work_dir stas/openwebtext-10k s3://tokenize-bucket20241123081319090400000001/tokenize-dir