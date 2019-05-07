FROM sameersbn/postgresql:9.6-2

# Install cron
RUN apt-get update -y && apt-get -y install cron curl && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Mod tz
RUN sudo echo "Asia/Shanghai" > /etc/timezone
RUN sudo dpkg-reconfigure -f noninteractive tzdata

# Add crontab file in the cron directory
ADD crontab /tmp/crontab

# Setup cron job
RUN cat /tmp/crontab | crontab

# Add scripts
RUN mkdir /root/scripts
ADD scripts /root/scripts

# Create the log file to be able to run tail
RUN mkdir -p /var/pgsql-backups

# Run the command on container startup
CMD env > /tmp/my_env && touch /var/log/cron.log && cron && tail -f /var/log/cron.log
