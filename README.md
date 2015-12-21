# awsmysqls3backup

General Information
===================

This script will allow Amazon AWS users to backup their websites and MySQL databases to S3 buckets. This allows you to keep the backups off the EC2 instances onto cheaper S3 storage.

<blockquote>WARNING: Please read Amazon's guidance on setting up IAM users for S3 access. Do not use your root account for this. Setup a specific IAM user that only has basic S3 bucket PUT and List permissions. Think security first! Feel free to contact me if you have questions about this.</blockquote>

Generally, the script will backup each of your MySQL databases to the temp directory. There is a temp directory for each webiste. Then it will backup each of your websites. After successful backups, it will upload all files to your S3 Bucket (folder for each website). The script will remove all files it creates and it list the most recent 6 files uploaded to each of the S3 bucket folders. Lastly, it will email you with the results of the script.

You can easily create a cron job to run this regularly.

Initial Setup Tips
------------------

You'll need to create a .backups file. Put this file in a secure location and ensure no one can access it. The contents of the file should be as follows. Add a line for each database user and password. Be consistent on the order for every section of the configuration.

```BASH
MYSQL_USER=(
"DBUser1"
"DBUser2"
"DBUser3"
)

MYSQL_PASSWORD=(
"DBPassword1"
"DBPassword2"
"DBPassword3"
)
```

Update the path to the .backups file

```BASH
source /path/to/.backups
```

Update the email path txt file which stores the results to be sent to your email. You'll need to create the backuproot folder. You can call it whatever but be consistent throughout the script.

```BASH
EMAILMESSAGE="/path/to/backuproot/email.txt"
TOEMAIL="admin@example.com"
FROMEMAIL="admin@example.com"
```
Change the websitename# to the names of your websites
```BASH
DB_FILE_NAME=(
"websitename1db-`date +%Y%m%d%H%M`.sql.gz"
"websitename2db-`date +%Y%m%d%H%M`.sql.gz"
"websitename3db-`date +%Y%m%d%H%M`.sql.gz"
)
```

Change the websitename# to the names of your websites
```BASH
WEB_NAME=(
"websitename1web_`date +%Y%m%d%H%M`.tar.gz"
"websitename2web_`date +%Y%m%d%H%M`.tar.gz"
"websitename3web_`date +%Y%m%d%H%M`.tar.gz"
)
```
Change /path/to/website# to the directories for each of your websites
```BASH
WEBSITE=(
"/path/to/websitename1/"
"/path/to/websitename2/"
"/path/to/websitename3/"
)
```

Change databasename# to the names of each database
```BASH
SQLDB=(
"databasename1"
"databasename2"
"databasename3"
)
```

Change /path/to/backuproot/websitename# to each of websites you have.
```BASH
SAVE_DIR=(
"/path/to/backuproot/websitename1"
"/path/to/backuproot/websitename2"
"/path/to/backuproot/websitename3"
)
```
Change the S3bucketname/website for each of your websites. The Bucket and folders need to be created prior
```BASH
S3BUCKET=(
"s3bucketname/websitename1"
"s3bucketname/websitename2"
"s3bucketname/websitename3"
)
```
Update your MySQL hostname and port
```BASH
SQLHOST="hostname"
SQLPORT="MySQLport#"
```
