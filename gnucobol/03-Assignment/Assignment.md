# Assignment 03

We have worked with flat files and done input and output files. Now let's work with SQL in our program. You will find the database.sql file will have all the sql needed to create your database. Once that has been ran you can write your program.

# Linux Setup with PostgreSQL (Zorin OS / Ubuntu)

This program uses the esqlOC precompiler, which talks to PostgreSQL through ODBC.
Tested on Zorin OS 18 (Ubuntu 24.04 based).

Install PostgreSQL, GnuCobol, ODBC and the build tools
```
sudo apt install postgresql postgresql-client gnucobol g++ \
    subversion autoconf automake libtool \
    unixodbc unixodbc-dev odbc-postgresql
```

Build and install esqlOC. There is no apt package, and the tarball linked in its README is gone, so get the source from the GnuCOBOL contrib SVN.
`autoreconf -fi` is needed because the source ships an old libtool script that fails with a version mismatch.
```
mkdir -p ~/src && cd ~/src
svn export https://svn.code.sf.net/p/gnucobol/contrib/trunk/esql esql
cd esql
autoreconf -fi
./configure
make
sudo make install
sudo ldconfig
```
This installs `esqlOC` to `/usr/local/bin` and `libocsql.so` to `/usr/local/lib`.

Create the database user and database
```
sudo -u postgres psql -c "CREATE ROLE admin LOGIN PASSWORD 'password'"
sudo -u postgres createdb -O admin cobol
PGPASSWORD=password psql -h localhost -U admin -d cobol -f database.sql
```
The `create database` line in `database.sql` will fail (the database already exists, or `admin` isn't allowed to create databases). That is fine, the rest of the script still runs in `cobol`.

Set up the ODBC data source. Put this in `~/.odbc.ini` (just for you) or `/etc/odbc.ini` (all users).
On Ubuntu the driver is named `PostgreSQL Unicode`, not `PostgreSQL` as on Fedora.
```
[COBODBC]
Description=ODBC for PostgreSQL
Driver=PostgreSQL Unicode
ServerName=localhost
Port=5432
UserName=admin
Password=password
Database=cobol
ByteaAsLongVarBinary=1
UseDeclareFetch=1
```
Test it with `isql -v COBODBC admin password`.

Build and run
```
make
./CALAGE
```

# Output
```
*** STARTING ***
TOTAL EMPLOYEES: 0002
```
The esqlOC runtime also prints `OCSQL:` log lines around this output.
