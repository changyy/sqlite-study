sqlite_target=sqlite-amalgamation-3080000.zip
sqlite_url=http://www.sqlite.org/2013/${sqlite_target}
sqlite_header=sqlite3.h sqlite3ext.h

LIB=-ldl -pthread
BIN=sqlite3
FLAGS=-DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS3_PARENTHESIS

all: sqlite changyy.so

sqlite: fts3_tokenizer.h sqlite3.c
	$(CC) $(FLAGS) sqlite3.c shell.c changyy_tokenizer.c -o $(BIN) $(LIB)

sqlite3.c:
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


test: changyy.so sqlite
	@ rm -rf ./test.db && ./$(BIN) test.db "CREATE VIRTUAL TABLE data USING fts3();" && echo "[INFO] fts3(fts4) is enabled"
	@ rm -rf ./test.db && echo -e ".load $(PWD)/changyy \n CREATE VIRTUAL TABLE data USING fts3(tokenize=changyy);" | ./$(BIN) test.db && echo "[INFO] changyy_tokenizer is enabled"

changyy.so: fts3_tokenizer.h changyy_tokenizer.c
	@ gcc -fPIC -c changyy_tokenizer.c -o changyy_tokenizer.o
	@ gcc -shared -o changyy.so changyy_tokenizer.o
	@ test -e changyy.so && echo "[INFO] changyy.so is ok"

fts3_tokenizer.h: sqlite3.c
	@ echo $(shell grep -n "#ifndef _FTS3_TOKENIZER_H_" sqlite3.c | cut -f 1 -d ":" ) > /tmp/_FTS3_TOKENIZER_H_.begin
	@ sed -n "$(shell grep -n "#ifndef _FTS3_TOKENIZER_H_" sqlite3.c | cut -f 1 -d ":" ),$$"p sqlite3.c > /tmp/_FTS3_TOKENIZER_H_.middle
	@ sed -n "1,$(shell grep -n "#endif" /tmp/_FTS3_TOKENIZER_H_.middle | head -n 1 | cut -f 1 -d ":")"p /tmp/_FTS3_TOKENIZER_H_.middle > fts3_tokenizer.h
	@ test -e fts3_tokenizer.h && test -s fts3_tokenizer.h && echo "[INFO] fts3_tokenizer.h is ok"

clean:
	rm -rf ./$(BIN) ./test.db ./changyy.so ./*.o ./a.out ./fts3_tokenizer.h ./sqlite3.c ./sqlite3.h ./sqlite3ext.h ./shell.c
