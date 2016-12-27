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

# Create Epinions DB
cd Databases/
psql -h localhost -f createdb.sql
cd ..

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

  # Drop Materialized Views, Indexes, Clusters and Triggers from remove_queries.sql script
  cd Databases/
  psql -h localhost  -d epinions -f remove_queries.sql
  cd ..

  # Create and Load DB
  cd oltpbenchSQL/
  ./oltpbenchmark -b epinions -c config/dba.xml --create=true --load=true -s 5 -o ../$file/$file
  cd ..

  # Delete all logs refering to creation and loading queries
  rm Databases/DB_BA/pg_log/*.log

  # Create Views+Triggers+Indexes after loading all data
  cd Databases/
  psql -h localhost -d epinions -f triggers_refresh.sql
  cd ..

  # Run benchmark
  cd oltpbenchSQL/
  ./oltpbenchmark -b epinions -c config/dba.xml --execute=true -s 5 -o $file
  wait $!
  cd results/
  mv -v *.* ../../$file/
  cd ..
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
