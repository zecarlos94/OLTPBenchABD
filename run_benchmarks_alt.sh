#!/bin/bash

CONFIG_FOLDERS=$(ls config_files/Postgresql.Conf\ Files)
DEFAULT_COLOR='\033[0m'
GREEN_COLOR='\033[0;32m'
RED_COLOR='\033[0;31m'
BLUE_COLOR='\033[0;34m'

# Backup current postgresql.conf file.
cp db/postgresql.conf db/postgresql.conf.backup

# Start server with the current configuration.
pg_ctl -D db start
sleep 1

for folder in $CONFIG_FOLDERS
do
  CONFIG_FILES=$(ls config_files/Postgresql.Conf\ Files/$folder)

  for file in $CONFIG_FILES
  do
    # Check if file has .conf extension, ignore .txt files.
    if [ ${file: -5} == ".conf" ]
    then
      printf "${GREEN_COLOR}[ CONFIG ]${DEFAULT_COLOR} Copying "
      printf "${RED_COLOR}config_files/$file ${DEFAULT_COLOR}\n"

      # Replace configuration file.
      cp config_files/$file db/postgresql.conf

      # # Reload configuration files.
      pg_ctl -D db reload
      wait $!

      printf "${BLUE_COLOR}[ BENCHMARK ]${DEFAULT_COLOR} Running\n"
      # Run benchmark
      # ....
      printf "${BLUE_COLOR}[ BENCHMARK ]${DEFAULT_COLOR} Done\n"

      # Sleep for 5 seconds to no influence next results.
      sleep 5
    fi
  done

done

# Shut down server.
pg_ctl -D db stop

# Put backup file back in place and remove the backup.
cp db/postgresql.conf.backup db/postgresql.conf
rm db/postgresql.conf.backup


