/******************************************
Pareja: DanMat27 y FPS
File: alfa.l
******************************************/

/******************************************/
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "alfa.h"
#include "y.tab.h"

int numero_linea = 1;
int numero_columna = 1;
int error = 0; 
%}

%option noyywrap
/******************************************/

/******************************************/
/* DEFINICIONES */
TABULADOR "\t"
ESPACIO " "
SALTO_LINEA "\n"
COMENTARIO "//"+([ 0-9a-zA-Z_:<>=]*)+"\n"
PALABRA [a-zA-Z_]*
NUMERO [0-9]*
ID [0-9a-zA-Z_]*

MAIN "main"
INT "int"
BOOLEAN "boolean"
ARRAY "array"
FUNCTION "function"
IF "if"
ELSE "else"
WHILE "while"
SCANF "scanf"
PRINTF "printf"
RETURN "return"

/* EXAMEN 2015 */
INIT "init"
/***************/

/* EXAMEN 2014 */
COMPARE "compare"
WITH "with"
LESS "less"
EQUAL "equal"
GREATER "greater"
/***************/

/* EXAMEN 2013 */
MODULO "%"
INCREMENTO "+="
/***************/

/* EXAMEN 2012 */
LONGITUD "long"
/***************/

/* EXAMEN 2011 */
POTENCIA "^"
/***************/

PUNTOYCOMA ";"
COMA ","
PARENTESISIZQUIERDO "("
PARENTESISDERECHO ")"
CORCHETEIZQUIERDO "["
CORCHETEDERECHO "]"
LLAVEIZQUIERDA "{"
LLAVEDERECHA "}"
ASIGNACION "="
MAS "+"
MENOS "-"
DIVISION "/"
ASTERISCO "*"
AND "&&"
OR "||"
NOT "!"
IGUAL "=="
DISTINTO "!="
MENORIGUAL "<="
MAYORIGUAL ">="
MENOR "<"
MAYOR ">"

IDENTIFICADOR {ID}

CONSTANTE_ENTERA {NUMERO}
TRUE "true"
FALSE "false"

ERROR [^{PALABRA}|{NUMERO}|{TABULADOR}|{ESPACIO}|{SALTO_LINEA}|{COMENTARIO}]
/******************************************/

/******************************************/
/* REGLAS */
%%

{TABULADOR} {
	numero_columna += 4;
}

{ESPACIO} {
	numero_columna++;
}

{SALTO_LINEA} {
	numero_linea++;
	numero_columna = 1;
}

{COMENTARIO} {
	numero_linea++;
	numero_columna = 1;
}

{MAIN} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_MAIN;
}

{INT} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_INT;
}

{BOOLEAN} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_BOOLEAN;
}

{ARRAY} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_ARRAY;
}

{FUNCTION} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_FUNCTION;
}

{IF} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_IF;
}

{ELSE} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_ELSE;
}

{WHILE} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_WHILE;
}

{PRINTF} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_PRINTF;
}

{SCANF} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_SCANF;
}

{RETURN} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_RETURN;
}

{PUNTOYCOMA} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_PUNTOYCOMA;
}

{COMA} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_COMA;
}

{PARENTESISIZQUIERDO} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_PARENTESISIZQUIERDO;
}

{PARENTESISDERECHO} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_PARENTESISDERECHO;
}

{CORCHETEIZQUIERDO} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_CORCHETEIZQUIERDO;
}

{CORCHETEDERECHO} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_CORCHETEDERECHO;
}

{LLAVEIZQUIERDA} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_LLAVEIZQUIERDA;
}

{LLAVEDERECHA} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_LLAVEDERECHA;
}

{ASIGNACION} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_ASIGNACION;
}

{MAS} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_MAS;
}

{MENOS} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_MENOS;
}

{DIVISION} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_DIVISION;
}

{ASTERISCO} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_ASTERISCO;
}

{AND} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_AND;
}

{OR} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_OR;
}

{NOT} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_NOT;
}

{IGUAL} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_IGUAL;
}

{DISTINTO} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_DISTINTO;
}

{MENORIGUAL} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_MENORIGUAL;
}

{MAYORIGUAL} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_MAYORIGUAL;
}

{MENOR} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_MENOR;
}

{MAYOR} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_MAYOR;
}

{CONSTANTE_ENTERA} {
	numero_columna+=yyleng;
	yylval.atributos.valor_entero=atoi(yytext);
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_CONSTANTE_ENTERA;
}

{TRUE} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_TRUE;
}

{FALSE} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_FALSE;
}


{INIT} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_INIT;
}

{COMPARE} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_COMPARE;
} 

{WITH} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_WITH;
} 

{LESS} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_LESS;
} 

{EQUAL} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_EQUAL;
} 

{GREATER} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_GREATER;
}

{MODULO} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_MODULO;
}

{INCREMENTO} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_INCREMENTO;
}

{POTENCIA} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_POTENCIA;
}

{LONGITUD} {
	numero_columna+=yyleng;
	strcpy(yylval.atributos.lexema, yytext);
	fprintf(yyout,";D:\t%s\n",yytext);
	return TOK_LONGITUD;
}


{IDENTIFICADOR} {
	strcpy(yylval.atributos.lexema, yytext);
	if(yyleng<=MAX_LONG_ID){
		fprintf(yyout,";D:\t%s\n",yytext);
		numero_columna+=yyleng;
	}
	else{
		error=1;
		fprintf(stdout,"****Error en [lin %d, col %d]: identificador demasiado largo (%s)\n", numero_linea, numero_columna,yytext);
	}
	return TOK_IDENTIFICADOR;
}

{ERROR} {
	error = 1;
	fprintf(stderr,"****Error en [lin %d, col %d]: simbolo no permitido (%s)\n", numero_linea, numero_columna-yyleng, yytext);
	return TOK_ERROR;
}

%%
/******************************************/
