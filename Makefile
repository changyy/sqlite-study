sqlite_target=sqlite-amalgamation-3080000.zip
sqlite_url=http://www.sqlite.org/2013/${sqlite_target}
sqlite_header=sqlite3.h sqlite3ext.h

LIB=-ldl -pthread
BIN=sqlite3
FLAGS=-DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS3_PARENTHESIS

sqlite:
	@ \
	( \
		test -e sqlite3.c \
		&& test -e sqlite3.h \
		&& test -e sqlite3ext.h \
	) \
	|| \
	( \
		(test -e ${sqlite_target} || wget ${sqlite_url}) \
		&& unzip -j ${sqlite_target} \
	)

	$(CC) $(FLAGS) sqlite3.c shell.c -o $(BIN) $(LIB)

test:
	@ rm -rf ./test.db && ./$(BIN) test.db "CREATE VIRTUAL TABLE data USING fts3();" && echo "fts3(fts4) is enabled"

clean:
	rm ./$(BIN) ./test.db
