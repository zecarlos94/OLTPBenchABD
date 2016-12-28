#!/bin/bash

CONFIG_FILES=$(ls config_files)
DEFAULT_COLOR='\033[0m'
GREEN_COLOR='\033[0;32m'
RED_COLOR='\033[0;31m'

# Backup current postgresql.conf file.
cp replication/r1/dados/postgresql.conf replication/r1/dados/postgresql.conf.backup



for file in $CONFIG_FILES
do
  printf "${GREEN_COLOR}[ CONFIG ]${DEFAULT_COLOR} Copying "
  printf "${RED_COLOR}config_files/$file ${DEFAULT_COLOR}\n"

  # Replace configuration file.
  cp config_files/$file replication/r1/dados/postgresql.conf

  # start configuration files.
  pg_ctl -D replication/r1/dados -o "-F -p 5432" start
  wait $!

  pg_ctl -D replication/r2/dados -o "-F -p 5433" start
  wait $!

  pg_ctl -D replication/r3/dados -o "-F -p 5434" start
  wait $!

  pg_ctl -D replication/r4/dados -o "-F -p 5435" start
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

  # Replace configuration file.
  # cp config_files/$file replication/r1/dados/postgresql.conf

  # Restart configuration files.
  # pg_ctl -D replication/r1/dados -o "-F -p 5432" restart
  # wait $!

  # pg_ctl -D replication/r2/dados -o "-F -p 5433" restart
  # wait $!

  # pg_ctl -D replication/r3/dados -o "-F -p 5434" restart
  # wait $!

  # pg_ctl -D replication/r4/dados -o "-F -p 5435" restart
  # wait $!

  # Run benchmark
  cd Benchmark-Bruno/
  ./oltpbenchmark -b epinions -c config/dba.xml --execute=true -s 5 -o ../$file/$file
  #wait $!
  #cd results/
  #mv -v *.* ../../$file
  # leave results folder
  #cd ..
  # leave Benchmark folder
  cd ..
  sleep 10


  # Shut down master server.
  pg_ctl -D replication/r1/dados -o "-F -p 5432" stop

  # Shut down standby servers.
  pg_ctl -D replication/r2/dados -o "-F -p 5433" stop

  pg_ctl -D replication/r3/dados -o "-F -p 5434" stop

  pg_ctl -D replication/r4/dados -o "-F -p 5435" stop
 
  # Run pgbadger
  pgbadger replication/r1/dados/pg_log/postgresql.log -o $file.html -O $file/
  

  # Delete Creation and Load Logs
  rm replication/r1/dados/pg_log/*.log
  rm replication/r2/dados/pg_log/*.log
  rm replication/r3/dados/pg_log/*.log
  rm replication/r4/dados/pg_log/*.log

  # Delete Archive
  rm replication/r1/dados/archive/*.*
  rm replication/r2/dados/archive/*.*
  rm replication/r3/dados/archive/*.*
  rm replication/r4/dados/archive/*.*

done

# Put backup file back in place and remove the backup.
cp replication/r1/dados/postgresql.conf.backup replication/r1/dados/postgresql.conf
rm replication/r1/dados/postgresql.conf.backup
