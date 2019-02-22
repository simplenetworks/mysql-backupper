#!/bin/bash

set -e

echo "Backup Job started"

DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p /backups

echo "Starting mysql dump"
MYSQL_FILE="/backups/$DATE-mysql-backup.tar.gz"
mysqldump --all-databases --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USER --password=$MYSQL_PASSWORD --result-file=$MYSQL_FILE
echo "Mysql dump completed"

echo "Start sending backups to FTP server"
ncftpput -u $FTP_USER -p $FTP_PASSWORD -o useCLNT=0,useMLST=0,useSIZE=0,allowProxyForPORT=1 $FTP_HOST $FTP_BACKUP_FOLDER $MYSQL_FILE
rm -f $MYSQL_FILE
echo "Backup sent to FTP server"
rm -rf backups/
echo "Backup Job finished"