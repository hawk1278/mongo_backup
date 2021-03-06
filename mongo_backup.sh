#!/bin/bash -x

TIME=`date '+%d%m%Y'`
DTG=`date '+%d%m%Y-%H%M%S'`
LOGNAME=mongo_backup-$DTG.log
MD=`which mongodump`
AWS=`which aws`
REGION=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}'`

write_log(){
  echo "$DTG - $1 - $2" >> "${LOGNAME}"
}


while getopts "h:d:b:f:" option
do
  case "${option}"
  in
	h) HOST=${OPTARG};;
        d) DB=${OPTARG};;
        b) BUCKET=${OPTARG};;
	f) DEST=${OPTARG};; 
	\?) echo "Invalid argument" && echo "Usage: ./mongo_backup.sh -h <MONGOHOST> -d <DB> -b <BUCKET NAME> -f <DESTINATION>" && exit 1;;
  esac
done

TAR=$DEST/../mongo_backup-$TIME.tar
# Create a directory for the backups
write_log "INFO" "Creating backup directory."
mkdir $DEST

# Initiate backup
write_log "INFO" "Backing up $HOST/$DB"
if ! $MD -h $HOST -d $DB -o $DEST;
then
  write_log "ERROR" "Backup failed."
  echo "Backup failed!."
  exit 1
fi

write_log "INFO" "Creating tar of backup."
tar cvf $TAR `basename $DEST`
write_log "INFO" "Uploading to S3 bucket $BUCKET"
if ! $AWS s3 cp $TAR s3://$BUCKET/mongo_backup-$TIME.tar --sse AES256 --region $REGION;
then
  write_log "ERROR" "Failed to upload to bucket, $BUCKET"
  echo "Failed to upload to bucket, $BUCKET"
  exit 1
fi



exit 0
