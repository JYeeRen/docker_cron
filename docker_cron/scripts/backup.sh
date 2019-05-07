#!/bin/bash

. /tmp/my_env

sendDingTalkMsg() {
    local time_tag=$(date '+%Y%m%d%H%M')
    curl --header "Content-Type: application/json" \
    --request POST \
    --data '{"msgtype": "text", "text": {"content": "DB-'$DB_NUM'-'$time_tag':'$*'"}, "at": {"isAtAll": false}}' \
    https://oapi.dingtalk.com/robot/send?access_token=2b8cc74f742358bc3c220fd2f20507ac3315c42065b19b310fa093982c42739a

    return 0
}

sendErrorDingTalkMsg() {
    local time_tag=$(date '+%Y%m%d%H%M')
    curl --header "Content-Type: application/json" \
    --request POST \
    --data '{"msgtype": "text", "text": {"content": "DB-'$DB_NUM'-'$time_tag':'$*'"}, "at": {"isAtAll": true}}' \
    https://oapi.dingtalk.com/robot/send?access_token=2b8cc74f742358bc3c220fd2f20507ac3315c42065b19b310fa093982c42739a

    return 0
}

func_clean_overdue() {
    find /var/pgsql-backups -type f -name "pgsql-backup.*.tar.gz" -mtime +7 -exec rm -f {} \; || return 1
    find /var/fs-backups -type f -name "fs-backup.*.tar.gz" -mtime +7 -exec rm -f {} \; || return 1
    return 0
}

func_pg_dump() {
    local cur_time=$(date '+%Y%m%d%H%M')
    PGPASSWORD=${DB_PASS} pg_dump -d ${DB_NAME} -h ${DB_HOST} -U ${DB_USER} > "pgsql-backup.$cur_time.dump" || return 1
    tar zcvf "/var/pgsql-backups/pgsql-backup.$cur_time.tar.gz" *.dump || return 1
    rm -rf pgsql-backup.*.dump

    return 0
}

func_fs_copy() {
    local cur_time=$(date '+%Y%m%d%H%M')
    tar zcvf "/var/fs-backups/fs-backup.${cur_time}.tar.gz" -C ${FS_PATH} ${FS_DIR_NAME} || return 1
    return 0
}

func_df_info() {
    local df_res="$(df -h | sed -n '2p' | awk {'print $1,$4,$5'} | sed 's/[ ][ ]*/-/g')"
    sendDingTalkMsg "$df_res"
}

func_clean_overdue
if [ $? -eq 0 ]
then
    echo "clean ok"
else
    sendErrorDingTalkMsg "清理过期备份失败"
    exit 1
fi
func_pg_dump
if [ $? -eq 0 ]
then
    echo "db_dump ok"
else
    sendErrorDingTalkMsg "创建数据库备份失败"
    exit 1
fi
func_fs_copy
if [ $? -eq 0 ]
then
    echo "fs copy ok"
else
    sendErrorDingTalkMsg "创建文件服务器备份失败"
    exit 1
fi

sendDingTalkMsg "备份完成."
func_df_info
