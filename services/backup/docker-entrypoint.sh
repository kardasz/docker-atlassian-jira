#!/bin/bash
set -e

if [ "$1" = '/usr/bin/supervisord' ]; then

    # Task cleanup (remove old backups > 14 days)
    echo "find ${JIRA_BACKUP} -type f -mtime +14 -exec rm -f {} \;" > /cronjob_jira.cleanup.sh
    chmod +x /cronjob_jira.cleanup.sh

    # Task backup postgress
    echo "PGPASSWORD=${PGPASSWORD} pg_dump -h postgres -U jira | gzip > ${JIRA_BACKUP}/jira.postgres.\`date +%Y-%m-%d-%H-%M-%S\`.gz" > /cronjob_jira.postgres.sh
    chmod +x /cronjob_jira.postgres.sh

    # Task backup data
    echo "tar --exclude='data/xml-data/build-dir' -cf ${JIRA_BACKUP}/jira.data.\`date +%Y-%m-%d-%H-%M-%S\`.tar -C `dirname ${JIRA_HOME}` `basename ${JIRA_HOME}`" > /cronjob_jira.data.sh
    chmod +x /cronjob_jira.data.sh

    # Create crontab file
    echo '' > /etc/crontab

    # ENV
    echo 'SHELL=/bin/bash' >> /etc/crontab
    echo 'PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin' >> /etc/crontab

    if [ "${CRON_CLEANUP}" != "" ]; then
        echo "${CRON_CLEANUP} atlassian bash /cronjob_jira.cleanup.sh 2>&1" >> /etc/crontab
    fi

    if [ "${CRON_POSTGRES}" != "" ]; then
        echo "${CRON_POSTGRES} atlassian bash /cronjob_jira.postgres.sh 2>&1" >> /etc/crontab
    fi

    if [ "${CRON_DATA}" != "" ]; then
        echo "${CRON_DATA} atlassian bash /cronjob_jira.data.sh 2>&1" >> /etc/crontab
    fi

    # Blank line
    echo '' >> /etc/crontab
fi

exec "$@"
