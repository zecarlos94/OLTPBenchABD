#!/bin/bash

CONFIG_FILES=$(ls config_files)
DEFAULT_COLOR='\033[0m'
GREEN_COLOR='\033[0;32m'
RED_COLOR='\033[0;31m'

# Backup current postgresql.conf file.
cp Database_4_Servers/r1/dados/postgresql.conf Database_4_Servers/r1/dados/postgresql.conf.backup

# Start server with the current configuration.
pg_ctl -D Database_4_Servers/r1/dados -o "-F -p 5432" start
sleep 1

# Start standby servers.
pg_ctl -D Database_4_Servers/r2/dados -o "-F -p 5433" start
sleep 1

pg_ctl -D Database_4_Servers/r3/dados -o "-F -p 5434" start
sleep 1

pg_ctl -D Database_4_Servers/r4/dados -o "-F -p 5435" start
sleep 1

for file in $CONFIG_FILES
do
  printf "${GREEN_COLOR}[ CONFIG ]${DEFAULT_COLOR} Copying "
  printf "${RED_COLOR}config_files/$file ${DEFAULT_COLOR}\n"

  # Replace configuration file.
  cp config_files/$file Database_4_Servers/r1/dados/postgresql.conf

  # restart configuration files.
  pg_ctl -D Database_4_Servers/r1/dados -o "-F -p 5432" restart
  wait $!

  pg_ctl -D Database_4_Servers/r2/dados -o "-F -p 5433" restart
  wait $!

  pg_ctl -D Database_4_Servers/r3/dados -o "-F -p 5434" restart
  wait $!

  pg_ctl -D Database_4_Servers/r4/dados -o "-F -p 5435" restart
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
  rm Database_4_Servers/r1/dados/pg_log/*.log

  # Replace configuration file.
  # cp config_files/$file Database_4_Servers/r1/dados/postgresql.conf

  # Restart configuration files.
  # pg_ctl -D Database_4_Servers/r1/dados -o "-F -p 5432" restart
  # wait $!

  # pg_ctl -D Database_4_Servers/r2/dados -o "-F -p 5433" restart
  # wait $!

  # pg_ctl -D Database_4_Servers/r3/dados -o "-F -p 5434" restart
  # wait $!

  # pg_ctl -D Database_4_Servers/r4/dados -o "-F -p 5435" restart
  # wait $!

  # Run benchmark
  cd Benchmark-Bruno/
  ./oltpbenchmark -b epinions -c config/dba.xml --execute=true -s 5
  wait $!
  cd results/
  mv -v *.* ../../$file
  # leave results folder
  cd ..
  # leave Benchmark folder
  cd ..
  sleep 10


  # Run pgbadger
  pgbadger Database_4_Servers/r1/dados/pg_log/postgresql.log -o $file.html -O $file/
  rm Database_4_Servers/r1/dados/pg_log/*.log

done

# Shut down master server.
pg_ctl -D Database_4_Servers/r1/dados -o "-F -p 5432" stop

# Shut down standby servers.
pg_ctl -D Database_4_Servers/r2/dados -o "-F -p 5433" stop

pg_ctl -D Database_4_Servers/r3/dados -o "-F -p 5434" stop

pg_ctl -D Database_4_Servers/r4/dados -o "-F -p 5435" stop

# Put backup file back in place and remove the backup.
cp Database_4_Servers/r1/dados/postgresql.conf.backup Database_4_Servers/r1/dados/postgresql.conf
rm Database_4_Servers/r1/dados/postgresql.conf.backup
