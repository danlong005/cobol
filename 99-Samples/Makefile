PGM=FETCHTBL
FLAGS=-x -locesql -lpq

out:
	ocesql $(PGM).cob $(PGM).cbl
	cobc $(FLAGS) $(PGM).cbl

	rm $(PGM).cbl

clean:
	rm $(PGM)