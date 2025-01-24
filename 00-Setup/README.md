# Setting up Cobol with SQL on Linux

$ sudo apt install gnucobol

Once you have done this you can compile the Hello.cbl program.
```
$ cobc -x Hello.cob

$ ./HELLO
```

install the postgresql client
```
$ sudo apt install postgresql-client
```

install the following postgresql packages
```
$ sudo apt install libpq5 libpq-dev
```

run the following command to download the preprocessor
```
$ https://github.com/opensourcecobol/Open-COBOL-ESQL/archive/refs/tags/v1.3.zip
```

unzip the zip file
```
$ unzip v1.3.zip
```

make the preprocessor
```
$ cd ~/Open-COBOL-ESQL-1.2
$ export CPATH=/usr/include/postgresql/
$ ./configure
$ make
```

install the preprocessor
```
$ sudo make install
```

add the following lines to your .bashrc/.zshrc
```
export CPPFLAGS="-I/usr/include/postgresql"
export COBCPY=/home/dlong/Open-COBOL-ESQL-1.2/copy
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
export CFLAGS="-I/usr/local/include"
export LDFLAGS="-L/usr/local/lib"
```

# WSL stuff
Add Windows Firewall Inbound Port Rule for WSL2 IP Addresses:

Open Windows Defender Firewall with Advanced Security
```
Click New Rule...
Select Port for rule type
Select TCP and for Specific local ports enter 5432
Select Allow the connection. Connecting from WSL2 won't be secure so don't select the secure option
Select at least Public. Can select Domain and Private as well. I could only connect if Public was selected
Name the rule e.g. Postgres - connect from WSL2 and create it
Right click newly created rule and select Properties then click on the Scope tab
Under Remote IP address, select These IP addresses then click Add... and enter range 172.0.0.1 to 172.254.254.254
Repeat step 9 for IP address range 192.0.0.1 to 192.254.254.254
Click Apply then OK
Make sure rule is enabled
```

Configure Postgres to Accept Connections from WSL2 IP Addresses

Assuming a default install/setup of Postgresql for Windows the following files are located under C:\Program Files\PostgreSQL\$VERSION\data

Verify that postgresql.conf has following set:
```
listen_addresses = '*'
```
This should already be set to '*' so nothing do here.

Update pg_hba.conf to allow connections from WSL2 range e.g. for Postgresl 12:
```
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
host    all             all             172.0.0.0/8             md5
host    all             all             192.0.0.0/8             md5
```