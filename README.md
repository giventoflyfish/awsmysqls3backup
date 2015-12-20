# awss3backup

General Information
===================

This script will allow Amazon AWS users to backup their website and MySQL databases to S3 buckets. This allows you to keep the backups off the EC2 instances onto cheaper S3 storage.

<blockquote>WARNING: Please read Amazon's guidances on setting up IAM users for S3 access. Do not use your root account for this. Setup a specific IAM users that only has basic S3 bucket PUT and List permissions. Think security first! Feel free to contact me if you have questions about this.</blockquote>

Initial Setup Tips
------------------

You'll need to create a .backups file. Please this file in a secure location and ensure no one case access it. The contents of the file should be as follows. Add a line for each database user and password.

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



