# Add friend records for testing.  
letters=("Alfa" "Bravo" "Charlie" "Delta" "Echo" "Foxtrot" "Golf" "Hotel" "India" "Juliett")
for i in "${letters[@]}"
do
        : 
        sed 's/alice/'$i'/g' add10.json > new10.json
        aws dynamodb batch-write-item --request-items file://new10.json
done
rm new10.json
