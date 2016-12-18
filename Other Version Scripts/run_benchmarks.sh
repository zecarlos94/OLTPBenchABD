#!/bin/bash

CONFIG_FILES=$(ls config_files)
DEFAULT_COLOR='\033[0m'
GREEN_COLOR='\033[0;32m'
RED_COLOR='\033[0;31m'

# Backup current postgresql.conf file.
cp db/postgresql.conf db/postgresql.conf.backup

# Start server with the current configuration.
pg_ctl -D db start
sleep 1

for file in $CONFIG_FILES
do
  printf "${GREEN_COLOR}[ CONFIG ]${DEFAULT_COLOR} Copying "
  printf "${RED_COLOR}config_files/$file ${DEFAULT_COLOR}\n"

  # Replace configuration file.
  cp config_files/$file db/postgresql.conf

  # Reload configuration files.
  pg_ctl -D db reload
  wait $!

  # Run benchmark

  sleep 5
done

# Shut down server.
pg_ctl -D db stop

# Put backup file back in place and remove the backup.
cp db/postgresql.conf.backup db/postgresql.conf
rm db/postgresql.conf.backup


