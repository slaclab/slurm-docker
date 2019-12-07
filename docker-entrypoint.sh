#!/bin/sh

# setup munge
if [ -e /mnt/munge/munge.key ]; then
  echo "Copying munge key from /mnt/munge/munge.key"
  cp /mnt/munge/munge.key /etc/munge/munge.key
  chown munge:munge /etc/munge/munge.key
  chmod 400 /etc/munge/munge.key
fi

# setup slurm
chown slurm:slurm /var/spool/slurmd /var/run/slurmd /var/lib/slurmd /var/log/slurm

# pick up relevant supervisord conf
SUPERVISORD_CONFIG=${SUPERVISORD_CONFIG:-/etc/slurmctld-supervisord.conf}
echo "Starting with $SUPERVISORD_CONFIG..."
exec /usr/bin/supervisord --configuration $SUPERVISORD_CONFIG

