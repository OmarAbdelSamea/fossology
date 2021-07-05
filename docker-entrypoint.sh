#!/bin/bash
# FOSSology docker-entrypoint script
# Copyright Siemens AG 2016, fabio.huser@siemens.com
# Copyright TNG Technology Consulting GmbH 2016, maximilian.huber@tngtech.com
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.
#
# Description: startup helper script for the FOSSology Docker container

set -o errexit -o nounset -o pipefail

db_host="${FOSSOLOGY_DB_HOST:-db}"
db_name="${FOSSOLOGY_DB_NAME:-fossology}"
db_user="${FOSSOLOGY_DB_USER:-fossy}"
db_password="${FOSSOLOGY_DB_PASSWORD:-fossy}"

# Write configuration
cat <<EOM > /etc/fossology/Db.conf
dbname=$db_name;
host=$db_host;
user=$db_user;
password=$db_password;
EOM

sed -i 's/address = .*/address = '"${FOSSOLOGY_SCHEDULER_HOST:-scheduler.svc}"'/' \
    /etc/fossology/fossology.conf

sed -i 's/localhost = .*/nomos = nomos.agent-svc \/etc\/fossology 10 nomos/' \
 /etc/fossology/fossology.conf

# sed -i 's/host=.*/host=db;/' /etc/fossology/Db.conf
# Startup DB if needed or wait for external DB
if [[ "$1" == "scheduler" ]]; then
  if [[ $db_host == 'db' ]]; then
    echo '*****************************************************'
    echo 'WARNING: No database host was set and therefore the'
    echo 'internal database without persistency will be used.'
    echo 'THIS IS NOT RECOMENDED FOR PRODUCTIVE USE!'
    echo '*****************************************************'
    sleep 10
    # psqln=0
    # until [ "$psqln" -ge 10 ]; do
    #   su postgres -c 'echo \\q|psql'
    #   if [ $? = 0 ]; then
    #       break
    #   fi
    #   echo "WARNING: postgresql isn't running. Retrying..."
    #   sleep 15
    #   psqln=$((psqln+1))
    # done
    # su postgres -c 'echo \\q|psql'
    # if [ $? != 0 ]; then
    #   echo "ERROR: postgresql isn't running"
    # fi
    /etc/init.d/postgresql start
  else
    test_for_postgres() {
      PGPASSWORD=$db_password psql -h "$db_host" "$db_name" "$db_user" -c '\l' >/dev/null
      return $?
    }
    until test_for_postgres; do
      >&2 echo "Postgres is unavailable - sleeping"
      sleep 1
    done
  fi
fi  

# # Setup environment
if [[ $# -eq 0 || ($# -eq 1 && "$1" == "scheduler") ]]; then
    /usr/lib/fossology/fo-postinstall --common --database --licenseref
fi

# Start Fossology
echo
echo 'Fossology initialisation complete; Starting up...'
echo
if [[ $# -eq 0 ]]; then
  /etc/init.d/cron start
  /etc/fossology/mods-enabled/scheduler/agent/fo_scheduler \
    --log /dev/stdout \
    --verbose=4095 \
    --reset &
  /usr/sbin/apache2ctl -D FOREGROUND
elif [[ $# -eq 1 && "$1" == "scheduler" ]]; then
  exec /etc/fossology/mods-enabled/scheduler/agent/fo_scheduler \
    --log /dev/stdout \
    --verbose=4095 \
    --reset
elif [[ $# -eq 1 && "$1" == "web" ]]; then
  sleep 20
  service cron start
  exec /usr/sbin/apache2ctl -e info -D FOREGROUND
elif [[ $# -eq 1 && "$1" == "agent" ]]; then
  exec /bin/bash
  exec /etc/fossology/mods-enabled/nomos/agent/nomos -h
  exec /usr/sbin/sshd -D
  sleep infinity
  echo "agent2"
else
  exec "$@"
fi
