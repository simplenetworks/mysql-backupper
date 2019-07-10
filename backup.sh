#!/bin/bash

set -e

echo "Backup Job started"

DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p /backups

echo "Starting mysql dump"
MYSQL_FILE="/backups/$DATE-mysql-backup.tar.gz"
mysqldump --all-databases --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USER --password=$MYSQL_PASSWORD --result-file=$MYSQL_FILE
echo "Mysql dump completed"

if [[ "$DOCUMENTS_BACKUP" ]]; then
    : "${DOCUMENTS_FOLDER:=/documents}" 
    echo "Starting documents backup from $DOCUMENTS_FOLDER"
    DOCUMENTS_FILE="/backups/$DATE-documents-backup.tar.gz"
    tar -zcf $DOCUMENTS_FILE $DOCUMENTS_FOLDER
    echo "Documents backup completed"
fi

echo "Start sending backups to FTP server"
ncftpput -u $FTP_USER -p $FTP_PASSWORD -o useCLNT=0,useMLST=0,useSIZE=0,allowProxyForPORT=1 $FTP_HOST $FTP_BACKUP_FOLDER $MYSQL_FILE
rm -f $MYSQL_FILE
if [[ "$DOCUMENTS_BACKUP" ]]; then
    ncftpput -u $FTP_USER -p $FTP_PASSWORD -o useCLNT=0,useMLST=0,useSIZE=0,allowProxyForPORT=1 $FTP_HOST $FTP_BACKUP_FOLDER $DOCUMENTS_FILE
    rm -f $DOCUMENTS_FILE
fi
echo "Backup sent to FTP server"
rm -rf backups/

if [[ "$BACKUP_DAYS" ]]; then
  echo "Start cleaning backups older than $BACKUP_DAYS days"
  CLEAN_OLD_SCRIPT_PATH="/clean-old-backups.sh"
  "$CLEAN_OLD_SCRIPT_PATH"
fi

echo "Backup Job finished"
