all: 0 1 2 3

0:
	@swig -tcl -pkgversion 1.0 lip.i
1:
	@gcc -c -fpic lip.c lip_wrap.c -I../liberty_parse-2.6
2:
	gcc -L/usr/lib -shared -o lip.so \
	lip.o \
	lip_wrap.o \
	../liberty_parse-2.6/.libs/PI.o \
	../liberty_parse-2.6/.libs/syntax_checks.o \
	../liberty_parse-2.6/.libs/liberty_parser.o \
	../liberty_parse-2.6/.libs/libhash.o \
	../liberty_parse-2.6/.libs/libstrtab.o \
	../liberty_parse-2.6/.libs/mymalloc.o \
	../liberty_parse-2.6/.libs/token.o \
	../liberty_parse-2.6/.libs/syntax_decls.o \
	../liberty_parse-2.6/.libs/group_lookup.o \
	../liberty_parse-2.6/.libs/attr_lookup.o \
	../liberty_parse-2.6/.libs/liberty_front_lex.o \
	-ltcl8.6

3:
	@t.tcl


PREFIX:=${HOME}
install:
	mkdir  -p           ${PREFIX}/usr/local/lib/lip
	cp     lip_init.tcl ${PREFIX}/usr/local/lib/lip
	cp     lip.tcl      ${PREFIX}/usr/local/lib/lip
	cp     lip.so       ${PREFIX}/usr/local/lib/lip
	cp     pkgIndex.tcl ${PREFIX}/usr/local/lib/lip
instools:
	mkdir  -p           ${PREFIX}/usr/local/bin/lip
	rm     -rf          ${PREFIX}/usr/local/bin/lip
	cp     -r tools     ${PREFIX}/usr/local/bin/lip
