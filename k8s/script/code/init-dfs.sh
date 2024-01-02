#!/bin/bash

hdfs dfs -mkdir -p /user/root
hdfs dfs -mkdir input
hdfs dfs -put /home/input-500.txt input/input-500.txt
hdfs dfs -put /home/input-1000.txt input/input-1000.txt
hdfs dfs -put /home/input-5000.txt input/input-5000.txt
hdfs dfs -put /home/input-10000.txt input/input-10000.txt