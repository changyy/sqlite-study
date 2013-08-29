sqlite_target=sqlite-amalgamation-3080000.zip
sqlite_url=http://www.sqlite.org/2013/${sqlite_target}
sqlite_header=sqlite3.h sqlite3ext.h

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

all: sqlite3.h sqlite3ext.h sqlite3.c
	echo "OK"
