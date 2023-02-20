lj: lj.c lj.h lex.yy.c lib.h
	gcc -h lib.h -h lj.h lj.c lex.yy.c -o lj

sample: lj
	./lj < sample.sh
	gcc clap.c

lex.yy.c: lj.l
	flex lj.l

lj.c: lj.y
	bison --graph -d lj.y -o lj.c

clean:
	rm lj.c lj.h lex.yy.c lj.gv clap.c lj