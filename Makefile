mkfromtemplate: lex.yy.o funcs.o
	gcc -o mkfromtemplate lex.yy.o funcs.o -ll `pkg-config --cflags --libs glib-2.0`
	rm lex.yy.c lex.yy.o funcs.o funcs.h.gch

lex.yy.o: lex.yy.c
	gcc -c  lex.yy.c  -ll `pkg-config --cflags --libs glib-2.0`	

funcs.o: funcs.c funcs.h
	gcc -c funcs.c funcs.h `pkg-config --cflags --libs glib-2.0`

lex.yy.c:mkfromtemplate.l
	flex mkfromtemplate.l	

clean :
	rm lex.yy.c lex.yy.o mkfromtemplate funcs.o funcs.h.gch

restart :
	find -type d -exec rm -rf {} +
	rm lex.yy.c lex.yy.o mkfromtemplate funcs.o funcs.h.gch
