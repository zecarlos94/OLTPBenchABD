# OLTPBenchABD

# Objectives

1. Install and configure oltpbench benchmark with abd.xml, measuring performance results adequated to your own hardware.
2. Optmize and justify the performance measured taking into consideration both plans and redudance mechanisms used.
3. Optmize and justify the performance taking into consideration all postgresql configuration parameters.

# Source Code and instalatlion instructions:
   https://github.com/oltpbenchmark/oltpbench
   https://github.com/oltpbenchmark/oltpbench/wiki/Quickstart

# Logs analysis:
  http://dalibo.github.io/pgbadger/

# Execution plans analysis:
  http://www.postgresql.org/docs/9.5/static/sql-explain.html

# Eager materialized views in PostgreSQL:
  http://tech.jonathangardner.net/wiki/PostgreSQL/Materialized_Views
  http://www.pgcon.org/2008/schedule/events/69.en.html

# Running

Start by turning on your database server by using `pg_ctl -D db start`.
Now that the database is running you are ready to run the benchmark commands.

You should have your database populated before benchmarking, so use:
`./oltpbenchmark -b epinions -c config/abd.xml --create=true --load=true`

Now that the database is populated run:
`./oltpbenchmark -b epinions -c config/abd.xml --execute=true -s [sample window] -o [outputfile]`

Note: If you do not know what sample window to use try 5.

# Troubleshooting

If something fails follow these steps to make sure you've got everything ready.

1. Start the database server with `pg_ctl -D db start`. If the database does not exist, `db` folder is missing, then create it with `initdb -D db`.
2. Make sure you have a user named `abd` with password `abd` in postgres. If you do not have it, login into postgres, with `psql postgres` and create it with `CREATE USER abd WITH PASSWORD abd;`
3. Finally make sure you have a database named `epinions`. If you do not have one then run `createdb epinions` while your database server is running.

# Using the Benchmark Script

There is a `run_benchmarks.sh` script which you can run to run benchmarks with different
configuration files. All the different configuration files should be in the `config_files`
folder, it does not matter the extension of file, only that it has the needed attributes for
the postgres databse to run.

If you do not know which attributes are needed start with the default `db/postgresql.conf`
file and check the [Official Postgresql Server Configuration Documentation](https://www.postgresql.org/docs/9.4/static/runtime-config.html) for info on each of the parameters.

