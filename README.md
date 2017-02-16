MongoDB backup script.
Usage: ./mongo_backup.sh -h <mongodb host> -d <database to backup> -b <bucket name with out S3 prefix> -f <destination directory name>
./mongo_backup.sh -h mymongohost -d mydatabase -b mybucket -f mybackup

The script uses mongodump.
