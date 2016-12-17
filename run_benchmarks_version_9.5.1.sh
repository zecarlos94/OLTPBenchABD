#!/bin/bash

CONFIG_FILES=$(ls config_files)
DEFAULT_COLOR='\033[0m'
GREEN_COLOR='\033[0;32m'
RED_COLOR='\033[0;31m'

# Backup current postgresql.conf file.
cp abd/postgresql.conf abd/postgresql.conf.backup

# Start server with the current configuration.
pg_ctl -D abd start
sleep 1

for file in $CONFIG_FILES
do
  printf "${GREEN_COLOR}[ CONFIG ]${DEFAULT_COLOR} Copying "
  printf "${RED_COLOR}config_files/$file ${DEFAULT_COLOR}\n"

  # Replace configuration file.
  cp config_files/$file abd/postgresql.conf

  # Reload configuration files.
  pg_ctl -D abd reload
  wait $!

  # Run benchmark
  mkdir $file
  ./oltpbenchmark -b epinions -c config/abd.xml --create=true --load=true --execute=true -s 5 -o $file/$file
  sleep 5

  # Run pgbadger
  pgbadger abd/pg_log/postgresql.log
  cp abd/pg_log/out.html $file/$file.html
  rm abd/pg_log/*.log
	
done

# Shut down server.
pg_ctl -D abd stop

# Put backup file back in place and remove the backup.
cp abd/postgresql.conf.backup abd/postgresql.conf
rm abd/postgresql.conf.backup

