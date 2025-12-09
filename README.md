# COBOL 

I have setup a cobol environment on my local linux machine. So that I can practice writing cobol and debugging it. Here is the configuration I have so that I can set it up again if needed.

### Configuration
```
Compiler GnuCobol install via dnf
Database - PostgreSQL - install via dnf
SQL Precompiler - EsqlOC - install via dnf
Editor - VSCode - install from Microsoft Website(for newest version)
Extensions - 
    Debugger - COBOL debugger - Oleg Kunitsyn
    Make     - Makefile Tools - Microsoft
    Cobol    - Rech COBOL     - rechinformatica
```

ODBC -
    Config file /etc/odbc.ini
```
[COBODBC]
Description=ODBC for PostgreSQL
Driver=PostgreSQL
ServerName=localhost
Port=5432
UserName=admin
Password=password
Database=cobol
ByteaAsLongVarBinary=1
UseDeclareFetch=1
```
PostGresSQL - Configuration connections to use md5

### Debugging
I have to run the preprocessor, and then debug the *.cbl file instead of the .cob