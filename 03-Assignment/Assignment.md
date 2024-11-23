# Assignment 03

We have worked with flat files and done input and output files. Now let's work with SQL in our program. You will find the database.sql file will have all the sql needed to create your database. Once that has been ran you can write your program.

# Linux Setup with PostgreSQL

Add the following to your .bashrc
```
export COBCPY=/home/<yourName>/Open-COBOL-ESQL-1.3/copy
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
export CFLAGS="-I/usr/local/include"
export LDFLAGS="-L/usr/local/lib"
```

Install GnuCobol 
```
sudo apt install gnucobol
```

Download and Install OceSQL
```
wget https://github.com/opensourcecobol/Open-COBOL-ESQL/archive/refs/tags/v1.3.zip
unzip v1.3.zip
cd Open-COBOL-ESQL-1.3
./configure
make
make install
```


# Output
```
*** STARTING ***
TOTAL EMPLOYEES: 0002
```