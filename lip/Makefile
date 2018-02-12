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

aa:
	gcc a.c -o a

create_pkg_index:
	echo "pkg_mkIndex . lip.tcl lip.so" > tcmd
	tclsh tcmd
	#rm tcmd

PACKAGE_PATH:=/home/chihkang/usr/local/lib
TOOLS_PATH=/home/chihkang/bin/lip
i:
	mkdir -p ${PACKAGE_PATH}/lip
	cp lip.tcl ${PACKAGE_PATH}/lip
	cp lip.so ${PACKAGE_PATH}/lip
	cp pkgIndex.tcl ${PACKAGE_PATH}/lip
	cp tools/*.tcl ${TOOLS_PATH}
