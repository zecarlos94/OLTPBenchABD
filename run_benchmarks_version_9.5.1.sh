#!/bin/bash

CONFIG_FILES=$(ls config_files)
DEFAULT_COLOR='\033[0m'
GREEN_COLOR='\033[0;32m'
RED_COLOR='\033[0;31m'

# Backup current postgresql.conf file.
cp Databases/abd/postgresql.conf Databases/abd/postgresql.conf.backup

# Start server with the current configuration.
pg_ctl -D Databases/abd start
sleep 1

for file in $CONFIG_FILES
do
  printf "${GREEN_COLOR}[ CONFIG ]${DEFAULT_COLOR} Copying "
  printf "${RED_COLOR}config_files/$file ${DEFAULT_COLOR}\n"

  # Replace configuration file.
  cp config_files/$file Databases/abd/postgresql.conf

  # Reload configuration files.
  pg_ctl -D Databases/abd reload
  wait $!

  # Create folder for current iteration
  mkdir $file

  # Run benchmark
  cd Benchmark
  ./oltpbenchmark -b epinions -c config/abd.xml --create=true --load=true --execute=true -s 5 -o ../$file/$file
  cd ..
  sleep 10

  # Run pgbadger
  pgbadger Databases/abd/pg_log/postgresql.log -o $file.html -O $file/
  rm Databases/abd/pg_log/*.log
	
done

# Shut down server.
pg_ctl -D Databases/abd stop

# Put backup file back in place and remove the backup.
cp Databases/abd/postgresql.conf.backup Databases/abd/postgresql.conf
rm Databases/abd/postgresql.conf.backup

