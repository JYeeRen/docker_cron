#!/bin/bash

time_tag=$(date '+%Y%m%d%H%M')
curl --header "Content-Type: application/json" \
--request POST \
--data '{"msgtype": "text", "text": {"content": "'${time_tag}':太阳城HRM LIVE 开始备份..."}, "at": {"isAtAll": false}}' \
https://oapi.dingtalk.com/robot/send?access_token=2b8cc74f742358bc3c220fd2f20507ac3315c42065b19b310fa093982c42739a


curl --header "Content-Type: application/json" \
--request POST \
--data '{"msgtype": "text", "text": {"content": "'${time_tag}':太阳城HRM LIVE 开始清理7日前备份..."},"at": {"isAtAll": false}}' \
https://oapi.dingtalk.com/robot/send?access_token=2b8cc74f742358bc3c220fd2f20507ac3315c42065b19b310fa093982c42739a

echo "${time_tag}:Remove Backups brfore 7 days ..." >> /var/log/cron.log
find /var/pgsql-backups -type f -name "pgsql-backup.*.tar.gz" -mtime +7 -exec rm -f {} \;

echo "${time_tag}:Starting Backup PostgreSQL ..." >> /var/log/cron.log

cur_time=$(date '+%Y%m%d%H%M')
PGPASSWORD=${DB_PASS} pg_dump -d ${DB_NAME} -h ${DB_HOST} -U ${DB_USER} > "pgsql-backup.$cur_time.dump"
tar zcvf "/var/pgsql-backups/pgsql-backup.$cur_time.tar.gz" *.dump
tar zcvf "/var/fs-backups/fs-back.${cur_time.tar.gz}" fs_data

echo "${time_tag}:Remove temp file ..." >> /var/log/cron.log
rm -rf pgsql-backup.*.dump

echo "${time_tag}:Finish Backup ..." >> /var/log/cron.log

curl --header "Content-Type: application/json" \
--request POST \
--data '{"msgtype": "text", "text": {"content": "'${time_tag}':太阳城HRM LIVE '"${cur_time}"' 备份完成。"},"at": {"isAtAll": false}}' \
https://oapi.dingtalk.com/robot/send?access_token=2b8cc74f742358bc3c220fd2f20507ac3315c42065b19b310fa093982c42739a
