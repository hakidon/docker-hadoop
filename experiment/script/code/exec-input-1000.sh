#!/bin/bash

hdfs dfs -rm -r  output

mapred streaming \
-input input/input-1000.txt \
-output output \
-mapper "python3 mapper.py" \
-reducer "python3 reducer.py" \
-file /home/mapper.py \
-file /home/reducer.py