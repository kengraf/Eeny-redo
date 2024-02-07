#!/bin/bash

# File name containing names to is only argument
file="$1"

# Array to store lines
friends=()

# Read each line of the file and populate the array
while IFS= read -r line; do
    lines+=("$friends")
done < "$file"

# Add friend records for testing.  
for i in "${friends[@]}"
do
        : 
        aws dynamodb put-item --table-name EenyMeenyMinyMoe --item \
                         '{ "Name": {"S": "'$i'"} }' 
done
