#!/usr/bin/env python3

f = open("data.csv")
for l in f.readlines():
    print(l.replace("\0", ""))
