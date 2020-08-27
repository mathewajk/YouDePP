#!/bin/bash

n=0;
for file in *.srt; do
printf -v new "%03d_$file" "$((++n))"
mv -v -- "$file" "$new"
done
