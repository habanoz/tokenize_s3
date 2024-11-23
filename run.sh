#!/bin/bash

pip install -r requirements.txt
python tokenize_ds.py -ts 16 --local work_dir --logs s3://tokenize-bucket20241123081319090400000001/tokenize-dir/logs stas/openwebtext-10k s3://tokenize-bucket20241123081319090400000001/tokenize-dir