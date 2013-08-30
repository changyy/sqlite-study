sqlite_target=sqlite-amalgamation-3080000.zip
sqlite_url=http://www.sqlite.org/2013/${sqlite_target}
sqlite_header=sqlite3.h sqlite3ext.h

LIB=-ldl -pthread
BIN=sqlite3
FLAGS=-DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS3_PARENTHESIS

sqlite: fts3_tokenizer.h
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

	$(CC) $(FLAGS) sqlite3.c shell.c changyy_tokenizer.c -o $(BIN) $(LIB)

test: changyy.so sqlite
	@ rm -rf ./test.db
	@ ./$(BIN) test.db "CREATE VIRTUAL TABLE data USING fts3();" && echo "fts3(fts4) is enabled"
	@ rm -rf ./test.db
	@ echo -e ".load $(PWD)/changyy \n CREATE VIRTUAL TABLE data USING fts3(tokenize=changyy);" | ./$(BIN) test.db && echo "changyy_tokenizer is enabled"

changyy.so:
	@ gcc -fPIC -c changyy_tokenizer.c -o changyy_tokenizer.o
	@ gcc -shared -o changyy.so changyy_tokenizer.o
	@ test -e changyy.so && echo "changyy.so built"

fts3_tokenizer.h:
	#grep -n "#ifndef _FTS3_TOKENIZER_H_" sqlite3.c
	begin_number=`grep -n "#ifndef _FTS3_TOKENIZER_H_" sqlite3.c | cut -f1 -d:`
	echo ${begin_number}

clean:
	rm -rf ./$(BIN) ./test.db ./changyy.so ./*.o ./a.out
