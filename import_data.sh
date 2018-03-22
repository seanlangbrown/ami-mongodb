# pass data file to import as first arbument: import_data.sh filename
# upload file to aws with: scp -i ~/aws/keypair.pem local_file user@ec2_elastic_ip:/aws_file
mongoimport -h 127.0.0.1:27017 --db wegot-sidebar --collection restaurants --drop --file $1

mongo wegot-sidebar --eval "db.restaurants.createIndex( { result.place_id: 1 } )"