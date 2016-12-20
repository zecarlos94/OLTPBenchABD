#!/bin/bash

CONFIG_FILES=$(ls config_files)
DEFAULT_COLOR='\033[0m'
GREEN_COLOR='\033[0;32m'
RED_COLOR='\033[0;31m'

# Backup current postgresql.conf file.
cp Databases/DBA/postgresql.conf Databases/DBA/postgresql.conf.backup

# Start server with the current configuration.
pg_ctl -D Databases/DBA start
sleep 1

for file in $CONFIG_FILES
do
  printf "${GREEN_COLOR}[ CONFIG ]${DEFAULT_COLOR} Copying "
  printf "${RED_COLOR}config_files/$file ${DEFAULT_COLOR}\n"

  # Replace configuration file.
  cp config_files/$file Databases/DBA/postgresql.conf

  # Reload configuration files.
  pg_ctl -D Databases/DBA reload
  wait $!

  # Create folder for current iteration
  mkdir $file

  # Run benchmark
  cd Benchmark-Andre/
  ./oltpbenchmark -b epinions -c config/dba.xml --create=true --load=true -s 5 -o ../$file/$file
  cd ..
  sleep 10

  # Delete Creation and Load Logs
  rm Databases/DBA/pg_log/*.log

  # Replace configuration file.
  cp config_files/$file Databases/DBA/postgresql.conf

  # Reload configuration files.
  pg_ctl -D Databases/DBA reload
  wait $!

  # Run benchmark
  cd Benchmark-Andre/
  ./oltpbenchmark -b epinions -c config/dba.xml --execute=true -s 5 -o ../$file/$file
  cd ..
  sleep 10

  # Run pgbadger
  pgbadger Databases/DBA/pg_log/postgresql.log -o $file.html -O $file/
  rm Databases/DBA/pg_log/*.log

done

# Shut down server.
pg_ctl -D Databases/DBA stop

# Put backup file back in place and remove the backup.
cp Databases/DBA/postgresql.conf.backup Databases/DBA/postgresql.conf
rm Databases/DBA/postgresql.conf.backup
