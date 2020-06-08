# DanMat27
# FPS
# File: Makefile

CC = gcc
BS = bison
FLAGS = -Wall -ansi
BFLAGS = -d -y -v
FX = flex

OBS = y.tab.o lex.yy.o tablasimbolos.o tablaHash.o generacion.o


#GENERAR EJECUTABLE COMPILADOR
all: $(OBS)
	$(CC) $(CFLAGS) -o alfa alfa.c $(OBS)

#GENERAR OBJETO lex.yy.o
lex.yy.o: lex.yy.c 
	$(CC) $(CFLAGS) -c lex.yy.c

#GENERAR OBJETO y.tab.o
y.tab.o: y.tab.h y.tab.c
	$(CC) $(CFLAGS) -c y.tab.c

#GENERAR OBJETO generacion.o
generacion.o: generacion.c generacion.h
	$(CC) $(CFLAGS) -c generacion.c

#GENERAR OBJETO tablaHash.o
tablaHash.o: tablaHash.c tablaHash.h
	$(CC) $(CFLAGS) -c tablaHash.c

#GENERAR OBJETO tablaHash.o
tablasimbolos.o: tablasimbolos.c tablasimbolos.h
	$(CC) $(CFLAGS) -c tablasimbolos.c

#GENERAR FICHERO y.tab.h
y.tab.c: alfa.y
	$(BS) $(BFLAGS) alfa.y 

#GENERAR FICHERO y.tab.h
y.tab.h: alfa.y
	$(BS) $(BFLAGS) alfa.y 

#GENERAR FICHERO lex.yy.c
lex.yy.c: alfa.l y.tab.h
	$(FX) alfa.l



#PRUEBAS
p:
	nasm -g -o prueba.o -f elf32 prueba.asm
	gcc -m32 -o prueba prueba.o alfalib.o


#LIMPIAR EJECUTABLES, OBJETOS Y OTROS
clear:
	rm -rf $(OBS) alfa lex.yy.c y.tab.h y.tab.c y.output prueba prueba.o prueba.asm
