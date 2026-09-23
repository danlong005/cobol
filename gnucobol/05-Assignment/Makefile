PGM=CALAGE
FLAGS=-x -locsql -L /usr/local/lib -q

export COB_LIBRARY_PATH=/usr/local/lib
export COB_LDFLAGS=-Wl,--no-as-needed
export COB_PRELOAD=libocsql

out:
	esqlOC -static -o $(PGM).cbl $(PGM).cob
	cobc $(FLAGS) $(PGM).cbl

	rm $(PGM).cbl

debug:
	esqlOC -static -o $(PGM).cbl $(PGM).cob

clean:
	rm -f $(PGM) $(PGM).c $(PGM).c.h $(PGM).c.l.h $(PGM).i $(PGM).cbl
