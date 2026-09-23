# COBOL 

I have setup a cobol environment on my local linux machine. So that I can practice writing cobol and debugging it. Here is the configuration I have so that I can set it up again if needed.

### Configuration
Tested on Zorin OS 18 (Ubuntu 24.04 based). The full install steps are in [03-Assignment/Assignment.md](03-Assignment/Assignment.md).
```
Compiler GnuCobol install via apt
Database - PostgreSQL - install via apt
SQL Precompiler - EsqlOC - build from source (GnuCOBOL contrib SVN), installs to /usr/local
Editor - VSCode - install from Microsoft Website(for newest version)
Extensions - 
    Debugger - COBOL debugger - Oleg Kunitsyn
    Make     - Makefile Tools - Microsoft
    Cobol    - Rech COBOL     - rechinformatica
```

ODBC -
    Config file ~/.odbc.ini (or /etc/odbc.ini for all users)
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
PostGresSQL - The default Ubuntu password authentication works, no pg_hba.conf changes needed

### Building
Every assignment builds the same way, with esqlOC even when it has no SQL.
```
make        # build the program
make clean  # remove the program and build files
```

### Debugging
I have to run the preprocessor, and then debug the *.cbl file instead of the .cob. `make debug` runs just the preprocessor.
