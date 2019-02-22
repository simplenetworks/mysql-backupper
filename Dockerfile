FROM ubuntu

RUN apt-get update && \
    apt-get install -y cron ncftp mysql-client && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ADD backup.sh /backup.sh
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chmod +x /backup.sh

ENTRYPOINT ["/entrypoint.sh"]