#!/usr/bin/python3
# -*-coding:utf-8 -*

import sys
import re

for line in sys.stdin:
    line = line.strip()
    words = line.split()
    for word in words:
        # Remove symbols using regex
        cleaned_word = re.sub(r'[^a-zA-Z0-9]', '', word)
        # Print the cleaned word without checking isalpha
        print(cleaned_word + "\t1")
