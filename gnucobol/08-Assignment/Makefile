PGM=CALAGE
SUB=AGECALC
FLAGS=-x -locsql -L /usr/local/lib -q

export COB_LIBRARY_PATH=/usr/local/lib
export COB_LDFLAGS=-Wl,--no-as-needed
export COB_PRELOAD=libocsql

out:
	esqlOC -static -o $(PGM).cbl $(PGM).cob
	cobc $(FLAGS) $(PGM).cbl
# The subprogram has no SQL, so it skips esqlOC. -m builds a module
# (AGECALC.so) that CALAGE loads when it first calls it.
	cobc -m -q $(SUB).cob

	rm $(PGM).cbl

debug:
	esqlOC -static -o $(PGM).cbl $(PGM).cob

clean:
	rm -f $(PGM) $(PGM).c $(PGM).c.h $(PGM).c.l.h $(PGM).i $(PGM).cbl
	rm -f $(SUB).so $(SUB).c $(SUB).c.h $(SUB).c.l.h $(SUB).i
