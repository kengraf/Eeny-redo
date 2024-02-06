# Add friend records for testing.  
friends=("Kabir.Bardai" "David.Blodgett" "Matthew.Cusack" "Chase.Cushman" "Theo.DiMambro" "Adam.Elsner" "Ethan.Healey" "Anuj.Joshi" "Austin.Kc" "Lauren.Kennelly" "Savannah.Malo" "Logan.McKinley" "Austin.Niles" "Diego.Pacheco.Galdeano" "Jonathan.Ross" "Joseph.Roussos" "Jack.Schneider" "Christopher.Sullivan" "Logan.White")
for i in "${friends[@]}"
do
        : 
        aws dynamodb put-item --table-name EenyMeenyMinyMoe --item \
                         '{ "Name": {"S": "'$i'"} }' 
done
