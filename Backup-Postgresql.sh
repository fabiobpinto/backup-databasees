#!/bin/bash
# Database name
db_name=zabbix

# Backup storage directory 
backupfolder=/backup/postgresql/

# Number of days to store the backup 
keep_day=5

sqlfile=$backupfolder/zabbix-database-bkp-$(date +%d-%m-%Y_%H-%M-%S).sql
zipfile=$backupfolder/zabbix-database-bkp-$(date +%d-%m-%Y_%H-%M-%S).gz

# Create a backup

echo "##### HORA DE INICIO: $(date +%d-%m-%Y_%H-%M) #####" >> /backup/postgresql/logs/log.txt

if pg_dump $db_name > $sqlfile ; then
   echo "Sql dump created" >>  /backup/postgresql/logs/log.txt
   gzip -c $sqlfile > $zipfile
   echo "The backup was successfully compressed" >> /backup/postgresql/logs/log.txt
else
   echo "No backup was created!" >> /backup/postgresql/logs/log.txt
   exit
fi


echo "##### Removendo o $sqlfile #####" >> /backup/postgresql/logs/log.txt

rm $sqlfile

# Delete old backup 
#find $backupfolder -mtime +$keep_day -delete
find $backupfolder -mtime $keep_day -size +5G >> /backup/postgresql/logs/arquivo_delete.txt

echo "##### HORA DE FIM: $(date +%d-%m-%Y_%H-%M) #####" >> /backup/postgresql/logs/log.txt
echo "###################################################" >>/backup/postgresql/logs/log.txt

