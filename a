#!/bin/bash
# Check if a filename is provided as a command-line argument
if [ $# -eq 0 ]; then
   echo "Usage: $0 <filename>"
   exit 1
fi

# File name containing names to is only argument
file="$1"

# Array to store lines
friends=()

# Read each line of the file and populate the array
while IFS= read -r line; do
    friends+=("$line")
done < "$file"

# Add friend records for testing.  
for i in "${friends[@]}"
do
        : 
        echo $i
        aws dynamodb put-item --table-name Eeny-redo --item \
                         '{ "Name": {"S": "'$i'"} }' 
done
