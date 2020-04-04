mft: lex.yy.o funcs.o
	gcc -o mft lex.yy.o funcs.o -ll `pkg-config --cflags --libs glib-2.0`
	rm lex.yy.c lex.yy.o funcs.o funcs.h.gch

lex.yy.o: lex.yy.c
	gcc -c  lex.yy.c  -ll `pkg-config --cflags --libs glib-2.0`	

funcs.o: funcs.c funcs.h
	gcc -c funcs.c funcs.h `pkg-config --cflags --libs glib-2.0`

lex.yy.c:mft.l
	flex mft.l	

clean :
	rm lex.yy.c lex.yy.o mft funcs.o funcs.h.gch 	

restart :
	rm lex.yy.c lex.yy.o mft funcs.o funcs.h.gch
	find -type d -exec rm -rf {} +
