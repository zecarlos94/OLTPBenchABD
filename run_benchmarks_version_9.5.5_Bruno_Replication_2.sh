#!/bin/bash

CONFIG_FILES=$(ls config_files)
DEFAULT_COLOR='\033[0m'
GREEN_COLOR='\033[0;32m'
RED_COLOR='\033[0;31m'

# Backup current postgresql.conf file.
cp replication_2/r1/dados/postgresql.conf replication_2/r1/dados/postgresql.conf.backup

# Start server with the current configuration.
pg_ctl -D replication_2/r1/dados -o "-F -p 5432" start
sleep 1

# Start standby servers.
pg_ctl -D replication_2/r2/dados -o "-F -p 5433" start
sleep 1

for file in $CONFIG_FILES
do
  printf "${GREEN_COLOR}[ CONFIG ]${DEFAULT_COLOR} Copying "
  printf "${RED_COLOR}config_files/$file ${DEFAULT_COLOR}\n"

  # Replace configuration file.
  cp config_files/$file replication_2/r1/dados/postgresql.conf

  # restart configuration files.
  pg_ctl -D replication_2/r1/dados -o "-F -p 5432" restart
  wait $!

  pg_ctl -D replication_2/r2/dados -o "-F -p 5433" restart
  wait $!


  # Create folder for current iteration
  mkdir $file

  # Drop Materialized Views, Indexes and Clusters from remove_queries.sql script
  # cd Databases/
  # psql -h localhost -f remove_queries.sql
  # cd ..

  # Run benchmark
  cd Benchmark-Bruno/
  ./oltpbenchmark -b epinions -c config/dba.xml --create=true --load=true -s 5 -o ../$file/$file
  cd ..
  sleep 10

  # Create Materialized Views, Indexes and Clusters from new_queries.sql script
  # cd Databases/
  # psql -h localhost -f new_queries.sql
  # cd ..

  # Delete Creation and Load Logs
  rm replication/r1/dados/pg_log/*.log
  rm replication/r2/dados/pg_log/*.log
  rm replication/r3/dados/pg_log/*.log
  rm replication/r4/dados/pg_log/*.log

  # Delete Archive
  rm replication/r1/archive/*.*
  rm replication/r2/archive/*.*
  rm replication/r3/archive/*.*
  rm replication/r4/archive/*.*

  # Replace configuration file.
  # cp config_files/$file replication_2/r1/dados/postgresql.conf

  # Restart configuration files.
  # pg_ctl -D replication_2/r1/dados -o "-F -p 5432" restart
  # wait $!

  # pg_ctl -D replication_2/r2/dados -o "-F -p 5433" restart
  # wait $!

  # pg_ctl -D replication_2/r3/dados -o "-F -p 5434" restart
  # wait $!

  # pg_ctl -D replication_2/r4/dados -o "-F -p 5435" restart
  # wait $!

  # Run benchmark
  cd Benchmark-Bruno/
  ./oltpbenchmark -b epinions -c config/dba.xml --execute=true -s 5 -o ../$file/$file
  # leave Benchmark folder
  cd ..
  sleep 10


  # Run pgbadger
  pgbadger replication_2/r1/dados/pg_log/postgresql.log -o $file.html -O $file/

   # Delete Creation and Load Logs
  rm replication/r1/dados/pg_log/*.log
  rm replication/r2/dados/pg_log/*.log
  rm replication/r3/dados/pg_log/*.log
  rm replication/r4/dados/pg_log/*.log

  # Delete Archive
  rm replication/r1/archive/*.*
  rm replication/r2/archive/*.*
  rm replication/r3/archive/*.*
  rm replication/r4/archive/*.*

done

# Shut down master server.
pg_ctl -D replication_2/r1/dados -o "-F -p 5432" stop

# Shut down standby servers.
pg_ctl -D replication_2/r2/dados -o "-F -p 5433" stop


# Put backup file back in place and remove the backup.
cp replication_2/r1/dados/postgresql.conf.backup replication_2/r1/dados/postgresql.conf
rm replication_2/r1/dados/postgresql.conf.backup
