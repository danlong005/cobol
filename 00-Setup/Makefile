PGM=HELLO
FLAGS=-x -locsql -L /usr/lib64/libocsql.so -q

out: setup
	esqlOC -static -o $(PGM).cbl $(PGM).cob
	cobc $(FLAGS) $(PGM).cbl

	rm $(PGM).cbl

debug: setup
	esqlOC -static -o $(PGM).cbl $(PGM).cob

setup:
	export COB_LIBRARY_PATH=/usr/lib64/libocsql.so
	export COB_LDFLAGS=-Wl,--no-as-needed
	export COB_PRELOAD=libocsql

clean:
	rm $(PGM) $(PGM).c $(PGM).c.h $(PGM).c.l.h $(PGM).i rm $(PGM).cbl