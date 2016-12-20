#!/bin/bash

CONFIG_FILES=$(ls config_files)
DEFAULT_COLOR='\033[0m'
GREEN_COLOR='\033[0;32m'
RED_COLOR='\033[0;31m'

# Backup current postgresql.conf file.
cp Databases/DB_BA/postgresql.conf Databases/DB_BA/postgresql.conf.backup

# Start server with the current configuration.
pg_ctl -D Databases/DB_BA start
sleep 1

for file in $CONFIG_FILES
do
  printf "${GREEN_COLOR}[ CONFIG ]${DEFAULT_COLOR} Copying "
  printf "${RED_COLOR}config_files/$file ${DEFAULT_COLOR}\n"

  # Replace configuration file.
  cp config_files/$file Databases/DB_BA/postgresql.conf

  # Reload configuration files.
  pg_ctl -D Databases/DB_BA reload
  wait $!

  # Create folder for current iteration
  mkdir $file

  # Run benchmark
  cd Benchmark-Bruno/
  ./oltpbenchmark -b epinions -c config/dba.xml --create=true --load=true -s 5 -o ../$file/$file
  cd ..
  sleep 10

  # Delete Creation and Load Logs
  rm Databases/DB_BA/pg_log/*.log

  # Replace configuration file.
  cp config_files/$file Databases/DB_BA/postgresql.conf

  # Reload configuration files.
  pg_ctl -D Databases/DB_BA reload
  wait $!

  # Run benchmark
  cd Benchmark-Bruno/
  ./oltpbenchmark -b epinions -c config/dba.xml --execute=true -s 5 -o ../$file/$file
  cd ..
  sleep 10

  # Run pgbadger
  pgbadger Databases/DB_BA/pg_log/postgresql.log -o $file.html -O $file/
  rm Databases/DB_BA/pg_log/*.log

done

# Shut down server.
pg_ctl -D Databases/DB_BA stop

# Put backup file back in place and remove the backup.
cp Databases/DB_BA/postgresql.conf.backup Databases/DB_BA/postgresql.conf
rm Databases/DB_BA/postgresql.conf.backup
