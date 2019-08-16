#!/bin/sh

chown slurm:slurm /var/spool/slurmd /var/run/slurmd /var/lib/slurmd /var/log/slurm

# pick up relevant supervisord conf
SUPERVISORD_CONFIG=${SUPERVISORD_CONFIG:-/etc/slurmctld-supervisord.conf}

echo "Starting with $SUPERVISORD_CONFIG..."

hostname -s

exec /usr/bin/supervisord --configuration $SUPERVISORD_CONFIG

