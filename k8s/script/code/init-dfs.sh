#!/bin/bash

hdfs dfs -mkdir -p /user/root
hdfs dfs -mkdir input
hdfs dfs -put /home/input-500.txt input-500/input-500.txt
hdfs dfs -put /home/input-1000.txt input-1000/input-1000.txt
hdfs dfs -put /home/input-5000.txt input-5000/input-5000.txt
hdfs dfs -put /home/input-10000.txt input-10000/input-10000.txt