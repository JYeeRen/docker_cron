#!/bin/bash

. /tmp/my_env
echo $DB_HOST >> /var/log/cron.log
echo "test" >> /var/log/cron.log
