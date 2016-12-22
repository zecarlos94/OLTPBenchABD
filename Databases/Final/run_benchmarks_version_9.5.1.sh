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

  # Drop Materialized Views, Indexes, Clusters and Triggers from remove_queries.sql script
  cd Databases/
  psql -h localhost -f remove_queries.sql
  cd ..

  # Create and Load DB
  cd Benchmark
  ./oltpbenchmark -b epinions -c config/abd.xml --create=true --load=true -s 5 -o ../$file/$file
  cd ..

  # Create Materialized Views, Indexes and Clusters from new_queries.sql and triggers_refresh scripts
  cd Databases/
  psql -h localhost -f new_queries.sql
  psql -h localhost -f triggers_refresh.sql
  cd ..

  # Delete all logs refering to creation and loading queries
  rm Databases/abd/pg_log/*.log

  # Run benchmark
  cd Benchmark
  ./oltpbenchmark -b epinions -c config/abd.xml --execute=true -s 5 -o ../$file/$file
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

