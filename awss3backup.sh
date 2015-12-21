#!/usr/bin/env bash

# Import MySQL Usernames and Password. .backups file should look like below minus comments
#MYSQL_USER=(
#"DBUser1"
#"DBUser2"
#"DBUser3"
#)

#MYSQL_PASSWORD=(
#"DBPassword1"
#"DBPassword2"
#"DBPassword3"
#)

source /path/to/.backups

# Email Variables
EMAILMESSAGE="/path/to/backuproot/email.txt"
TOEMAIL="admin@example.com"
FROMEMAIL="admin@example.com"

# Add file for each database being backed up
DB_FILE_NAME=(
"websitename1db-`date +%Y%m%d%H%M`.sql.gz"
"websitename2db-`date +%Y%m%d%H%M`.sql.gz"
"websitename3db-`date +%Y%m%d%H%M`.sql.gz"
)

# Add file for each website being backed up
WEB_NAME=(
"websitename1web_`date +%Y%m%d%H%M`.tar.gz"
"websitename2web_`date +%Y%m%d%H%M`.tar.gz"
"websitename3web_`date +%Y%m%d%H%M`.tar.gz"
)

# Add directory location for each website being backed up
WEBSITE=(
"/path/to/websitename1/"
"/path/to/websitename2/"
"/path/to/websitename3/"
)

# Add each database being backed up
SQLDB=(
"databasename1"
"databasename2"
"databasename3"
)

# Add directory in Temp location for each website/database
SAVE_DIR=(
"/path/to/backuproot/websitename1"
"/path/to/backuproot/websitename2"
"/path/to/backuproot/websitename3"
)

# Add S3 Bucket and folder for each website/database
S3BUCKET=(
"s3bucketname/websitename1"
"s3bucketname/websitename2"
"s3bucketname/websitename3"
)

# Add SQL Database Server Host and Post
SQLHOST="hostname"
SQLPORT="MySQLport#"

#create Subject line of the email

echo -e "Subject: Amazon Backups\n\n" > $EMAILMESSAGE

#for each SQL Database perform a mysqldump
arraylength=${#SQLDB[@]}

for (( i=0; i<${arraylength}; i++ ));
do
     mysqldump -h ${SQLHOST} -P ${SQLPORT} -u ${MYSQL_USER[$i]} -p${MYSQL_PASSWORD[$i]} ${SQLDB[$i]} | gzip > ${SAVE_DIR[$i]}/${DB_FILE_NAME[$i]}
done

arraylength=${#WEBSITE[@]}
#for each website performance backup
for (( i=0; i<${arraylength}; i++ ));
do
     tar -czvf ${SAVE_DIR[$i]}/${WEB_NAME[$i]} ${WEBSITE[$i]}
done

#for each website/database upload to S3 bucket
arraylength=${#WEBSITE[@]}
for (( i=0; i<${arraylength}; i++ ));

do

if [ -e ${SAVE_DIR[$i]}/${DB_FILE_NAME[$i]} ]; then

    # Upload database backup to S3 bucket
	aws s3 cp ${SAVE_DIR[$i]}/${DB_FILE_NAME[$i]} s3://${S3BUCKET[$i]}/${DB_FILE_NAME[$i]}

    # Make sure command was successful
    if [ "$?" -ne "0" ]; then
        echo 'Database Upload to AWS failed: ' ${SAVE_DIR[$i]}/${DB_FILE_NAME[$i]} >> $EMAILMESSAGE 
		echo -e "\n\n" >> $EMAILMESSAGE
        exit 1
    fi
	
	# Write Database successful to email message
    echo 'Database Upload to AWS Successful: ' ${SAVE_DIR[$i]}/${DB_FILE_NAME[$i]} >> $EMAILMESSAGE 
	echo -e "\n\n" >> $EMAILMESSAGE	

	# Upload website backup to S3 bucket
	aws s3 cp ${SAVE_DIR[$i]}/${WEB_NAME[$i]} s3://${S3BUCKET[$i]}/${WEB_NAME[$i]}

    # Make sure command was successful
    if [ "$?" -ne "0" ]; then
        echo 'Website Upload to AWS failed: ' ${SAVE_DIR[$i]}/${WEB_NAME[$i]} >> $EMAILMESSAGE 
		echo -e "\n\n" >> $EMAILMESSAGE
        exit 1
    fi

	# Write Website successful to email message
    echo 'Website Upload to AWS Successful: ' ${SAVE_DIR[$i]}/${WEB_NAME[$i]} >> $EMAILMESSAGE 
	echo -e "\n\n" >> $EMAILMESSAGE


    # If successful remove backup file
    rm ${SAVE_DIR[$i]}/${DB_FILE_NAME[$i]}
    rm ${SAVE_DIR[$i]}/${WEB_NAME[$i]}
	
fi
done

arraylength=${#WEBSITE[@]}
#for each website/database write S3 bucket list (last 6 entries)
for (( i=0; i<${arraylength}; i++ ));
do
     aws s3 ls s3://${S3BUCKET[$i]} --recursive | sort | tail -n 6 >> $EMAILMESSAGE
done

# write ending email note
echo -e "\n\n" >> $EMAILMESSAGE
echo -e "Backup Completed. Review S3 logs above.\n\n" >> $EMAILMESSAGE

# send mail
sendmail -f "$FROMEMAIL" "$TOEMAIL" < $EMAILMESSAGE

#delete email
rm $EMAILMESSAGE

exit 0
