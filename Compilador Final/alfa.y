/******************************************
Pareja: Daniel Mateo y Franccy del Piero Sambrano
File: alfa.y
******************************************/

/******************************************/
%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "alfa.h"
#include "y.tab.h"

extern int yylex();
extern int yyparse();
extern FILE* yyin; /* Fichero entrada */
extern FILE* yyout; /* Fichero de salida */
extern int yyleng; /* Longitud de simbolo leido */

extern int numero_linea, numero_columna; /* Numeros de filas y columnas */
extern int error; /* Indica si hay error */

void yyerror(const char* s); /* Funcion de error */

CLASE tipo_actual; /* Variable global tipo actual */
TIPO clase_actual; /* Variable global clase actual */

/* Referencias a la tabla de simbolos */
INFO_SIMBOLO* lectura;
INFO_SIMBOLO insertar;

int tamanio_vector; /* Tamanio del vector */
int num_negaciones=0; /* Numero negaciones aritmeticas */
int num_comparaciones=0; /* Numero de comparaciones */
int num_condicionales=0; /* Numero de condicionales */
int num_bucles=0; /* Numero de bucles */
int posicion_variable_local_actual=0; /* Posicion variable local actual */
int num_variables_locales_actual=0; /* Numero de variables locales */
int num_parametros_actual = 0;/* Numero de parametros */
int posicion_parametro_actual = 0; /* Posicion de parametro actual */
int es_func = 0; /* Indica si es funcion */
int es_call = 0; /* Indica si es llamada a una funcion */
int parametros = 0;/* Parametros */
int hay_return = 0;/* Indica si hay retorno */
%}
/******************************************/

/******************************************/
/* Estructura de yylval */
%union {
	tipo_atributos atributos;
}
/******************************************/

/******************************************/
/* Declarar simbolos terminales (Tokens) */
%token TOK_MAIN               
%token TOK_INT                 
%token TOK_BOOLEAN            
%token TOK_ARRAY               
%token TOK_FUNCTION            
%token TOK_IF                 
%token TOK_ELSE               
%token TOK_WHILE               
%token TOK_SCANF               
%token TOK_PRINTF              
%token TOK_RETURN              
%token TOK_PUNTOYCOMA          
%token TOK_COMA                
%token TOK_PARENTESISIZQUIERDO 
%token TOK_PARENTESISDERECHO   
%token TOK_CORCHETEIZQUIERDO   
%token TOK_CORCHETEDERECHO     
%token TOK_LLAVEIZQUIERDA      
%token TOK_LLAVEDERECHA        
%token TOK_ASIGNACION          
%token TOK_MAS                 
%token TOK_MENOS               
%token TOK_DIVISION            
%token TOK_ASTERISCO           
%token TOK_AND                 
%token TOK_OR                  
%token TOK_NOT                 
%token TOK_IGUAL               
%token TOK_DISTINTO            
%token TOK_MENORIGUAL          
%token TOK_MAYORIGUAL          
%token TOK_MENOR               
%token TOK_MAYOR

%token <atributos> TOK_IDENTIFICADOR
%token <atributos> TOK_CONSTANTE_ENTERA

%token TOK_TRUE                
%token TOK_FALSE               
%token TOK_ERROR

/* Precedencia de operadores */
%left TOK_MAS TOK_MENOS TOK_OR
%left TOK_ASTERISCO TOK_DIVISION TOK_AND 
%right TOK_NOT MU /* MU = Token de precedencia para el - de signo contrario */


/* Declarar simbolos no terminales */
%type <atributos> constante_entera
%type <atributos> constante_logica
%type <atributos> constante
%type <atributos> elemento_vector
%type <atributos> while
%type <atributos> while_exp
%type <atributos> if_exp
%type <atributos> if_exp_sentencias
%type <atributos> func_name
%type <atributos> func_declaration
%type <atributos> call_func
%type <atributos> identificador
%type <atributos> exp


/* Declarar axioma */
%start axioma
/******************************************/

/******************************************/
/* Definiciones */
%%

/* Regla de axioma (el axioma de la cadena) */
axioma: TOK_MAIN TOK_LLAVEIZQUIERDA declaraciones escribirTabla funciones escribirMain sentencias TOK_LLAVEDERECHA { 
		fprintf(yyout, ";R1:\t<programa> ::= main { <declaraciones> <funciones> <sentencias> }\n");
	}
;

/* Regla de declaraciones (engloba varias declaraciones) */
declaraciones: declaracion {
		fprintf(yyout, ";R2:\t<declaraciones> ::= <declaracion>\n");
	}
	| declaracion declaraciones{
		fprintf(yyout, ";R3:\t<declaraciones> ::= <declaracion> <declaraciones>\n");
	}
;

/* Regla de declaracion (una declaracion. Ej: int x;) */
declaracion: clase identificadores TOK_PUNTOYCOMA {
		fprintf(yyout, ";R4:\t<declaracion> ::= <clase> <identificadores> ;\n");		
	}
;

/* Regla de clase (un tipo de clase: vector o escalar) */
/* Asignamos tipo de la clase a variable global para herencia */
clase: clase_escalar {
		fprintf(yyout, ";R5:\t<clase> ::= <clase_escalar>\n");
		clase_actual = ESCALAR;
	}
	| clase_vector {
		fprintf(yyout, ";R7:\t<clase> ::= <clase_vector>\n");
		clase_actual = VECTOR;
	}
;

/* Regla clase_escalar (una clase escalar. Ej: int) */
clase_escalar: tipo {
		fprintf(yyout, ";R9:\t<clase_escalar> ::= <tipo>\n");
	}
;

/* Regla de tipo (la clase: int o boolean) */
/* Asignamos tipo del terminal a variable global para herencia */
tipo: TOK_INT {
		fprintf(yyout, ";R10:\t<tipo> ::= int\n");
		tipo_actual = ENTERO;
	}
	| TOK_BOOLEAN {
		fprintf(yyout, ";R11:\t<tipo> ::= boolean\n");
		tipo_actual = BOOLEANO;
	}
;

/* Regla de clase_vector (una clase vector. Ej: array int [2]) */
/* Si el vector posee un tamanio no permitido, se imprime un error */
clase_vector: TOK_ARRAY tipo TOK_CORCHETEIZQUIERDO TOK_CONSTANTE_ENTERA  TOK_CORCHETEDERECHO {
		tamanio_vector = $4.valor_entero;
		if(tamanio_vector < 1 || tamanio_vector > MAX_TAMANIO_VECTOR){
			fprintf(yyout,"****Error semantico en lin %d: El tamanyo del vector <nombre_vector> excede los limites permitidos (1,64).\n", numero_linea);
			return -1;
		}
		fprintf(yyout,";R15:\t<clase_vector> ::= array <tipo> [ <constante_entera> ]\n");
	}
; 

/* Regla de identificadores (engloba varios indentificadores) */
identificadores: identificador {
		fprintf(yyout, ";R18:\t<identificadores> ::= <identificador>\n");
	}
	| identificador TOK_COMA identificadores {
		fprintf(yyout, ";R19:\t<identificadores> ::= <identificador> , <identificadores>\n");
	}

;

/* Regla de las funciones (engloba varias funciones) */
funciones: funcion funciones {
		fprintf(yyout,";R20:\t<funciones> ::= <funcion> <funciones>\n");
	}
	| /* lambda */ {
		fprintf(yyout,";R21:\t<funciones> ::= \n");
	}
;

/* Nombre de una funcion */
func_name: TOK_FUNCTION tipo TOK_IDENTIFICADOR {
		hay_return = 0;
		es_func = 1;
		lectura = UsoLocal($3.lexema);
		if(lectura != NULL){
			fprintf(yyout,"****Error semantico en lin %d: Declaracion duplicada.\n", numero_linea);
			return -1;
		}

		insertar.lexema = $3.lexema;
		insertar.categoria = FUNCION;
		insertar.clase = ESCALAR;
		insertar.tipo = tipo_actual;

		strcpy($$.lexema, $3.lexema);
		$$.tipo = tipo_actual;

		DeclararFuncion($3.lexema, &insertar);
		posicion_variable_local_actual = 0;
		num_variables_locales_actual = 0;
		num_parametros_actual = 0;
		posicion_parametro_actual = 0;
	}
;

/* Declaracion de una funcion */
/* Actualizamos el numero de parametros */
/* Declaramos funcion en nasm */
func_declaration: func_name TOK_PARENTESISIZQUIERDO parametros_funcion TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA declaraciones_func {
		lectura = UsoLocal($1.lexema);
		if(lectura == NULL){
			fprintf(yyout,"****Error semantico en lin %d: Declaracion duplicada.\n", numero_linea);
			return -1;
		}

		lectura->adicional1 = num_parametros_actual;
		strcpy($$.lexema, $1.lexema);
		$$.tipo = $1.tipo;

		declararFuncion(yyout, $1.lexema, num_variables_locales_actual);
	}
;

/* Regla de funcion (una funcion. Ej: function int f(pf){df s}) */
/* Escribimos retorno de la funcion en nasm */
funcion: func_declaration sentencias TOK_LLAVEDERECHA {
		if(hay_return == 0){
			fprintf(yyout,"****Error semantico en lin %d: Funcion %s sin sentencia de retorno.\n", numero_linea, $1.lexema);
			return -1;
		}

		CerrarFuncion();

		lectura = UsoLocal($1.lexema);
		if(lectura == NULL){
			fprintf(yyout,"****Error semantico en lin %d: Declaracion duplicada.\n", numero_linea);
			return -1;
		}

		lectura->adicional1 = num_parametros_actual;
		es_func = 0;

		fprintf(yyout,";R22:\t<funcion> ::= function <tipo> <identificador> ( <parametros_funcion> ) { <declaraciones_func> <sentencias> }\n");
	}
;

/* Regla de parametros_funcion (engloba los parametros de una funcion) */
parametros_funcion: parametro_funcion resto_parametros_funcion {
		fprintf(yyout,";R23:\t<parametros_funcion> ::= <parametro_funcion> <resto_parametros_funcion>\n");
	}
	| /* lambda */ {
		fprintf(yyout,";R24:\t<parametros_funcion> := \n");
	}
;

/* Regla de resto_parametros_funcion (engloba mas parametros de una funcion despues de otra anterior) */
resto_parametros_funcion: TOK_PUNTOYCOMA parametro_funcion resto_parametros_funcion {
		fprintf(yyout,";R25:\t<resto_parametros_funcion> ::= ; <parametro_funcion> <resto_parametros_funcion>\n");
	}
	| /* lambda */ {
		fprintf(yyout,";R26:\t<resto_parametros_funcion> ::= \n");
	}
;

/* Regla de parametro_funcion (un parametro de una funcion. Ej: int p) */
parametro_funcion: tipo identificador_funcion {
		num_parametros_actual++;
		posicion_parametro_actual++;
		fprintf(yyout,";R27:\t<parametro_funcion> ::= <tipo> <identificador>\n");
	}
;

/* Regla de un identificador en una funcion */
identificador_funcion: TOK_IDENTIFICADOR {
		lectura = UsoLocal($1.lexema);
		if(lectura != NULL){
			fprintf(yyout,"****Error semantico en lin %d: Declaracion duplicada.\n", numero_linea);
			return -1;
		}

		insertar.lexema = $1.lexema;
		insertar.categoria = PARAMETRO;
		insertar.clase = ESCALAR;
		insertar.tipo = tipo_actual;
		insertar.adicional1 = num_parametros_actual;

		Declarar($1.lexema, &insertar);
	}
;

/* Regla de declaraciones_func (engloba las declaraciones de una funcion) */
declaraciones_func: declaraciones {
		fprintf(yyout,";R28:\t<declaraciones_func> ::= <declaraciones>\n");
	}
	| /* lambda */ {
		fprintf(yyout,";R29:\t<declaraciones_func> ::= \n");
	}
;	

/* Regla de sentencias (engloba varias sentencias) */
sentencias: sentencia {
		fprintf(yyout, ";R30:\t<sentencias> ::= <sentencia>\n");
	}
	| sentencia sentencias {
		fprintf(yyout, ";R31:\t<sentencias> ::= <sentencia> <sentencias>\n");
	}
;

/* Regla de sentecia (una sentencia. Ej: x=2;) */
sentencia: sentencia_simple TOK_PUNTOYCOMA {
		fprintf(yyout,";R32:\t<sentencia> ::= <sentencia_simple> ;\n");
	}
	| bloque {
		fprintf(yyout,";R33:\t<sentencia> ::= <bloque>\n");
	}
;

/* Regla de sentencia_simple (una sentencia simple: asignacion, lectura, escritura o retorno) */
sentencia_simple: asignacion {
		fprintf(yyout,";R34:\t<sentencia_simple> ::= <asignacion>\n");
	}
	| lectura {
		fprintf(yyout,";R35:\t<sentencia_simple> ::= <lectura>\n");
	}
	| escritura {
		fprintf(yyout,";R36:\t<sentencia_simple> ::= <escritura>\n");
	}
	| retorno_funcion {
		fprintf(yyout,";R38:\t<sentencia_simple> ::= <retorno_funcion>\n");
	}
;

/* Regla de bloque (un bloque: condicional o bucle) */
bloque: condicional {
		fprintf(yyout,";R40:\t<bloque> ::= <condicional>\n");
	}
	| bucle {
		fprintf(yyout,";R41:\t<bloque> ::= <bucle>\n");
	}
;

/* Regla de asginacion (una asignacion. Ej: x=27) */
asignacion: TOK_IDENTIFICADOR TOK_ASIGNACION exp {
		lectura = UsoLocal($1.lexema);
		if(lectura == NULL){
			fprintf(yyout,"****Error semantico en lin %d: Variable no inicializada.\n", numero_linea);
			return -1;
		}
		else {
			if(lectura->categoria == FUNCION){
				fprintf(yyout,"****Error semantico en lin %d: Asignacion incompatible.\n", numero_linea);
				return -1;
			}

			if(lectura->clase == VECTOR){
				fprintf(yyout,"****Error semantico en lin %d: Asignacion incompatible.\n", numero_linea);
				return -1;
			}

			if(lectura->tipo != $3.tipo){
				fprintf(yyout,"****Error semantico en lin %d: Asignacion incompatible.\n", numero_linea);
				return -1;
			}

			if(UsoGlobal($1.lexema) == NULL){
				if(lectura->categoria == PARAMETRO){
					escribirParametro(yyout, lectura->adicional1,num_parametros_actual);
				}
				else{
					escribirVariableLocal(yyout,lectura->adicional1+1);
				}
				asignarDestinoEnPila(yyout,$3.es_direccion);
			}
			else{
				asignar(yyout, $1.lexema, $3.es_direccion);
				fprintf(yyout,";R43:\t<asignacion> ::= <identificador> = <exp>\n");
			}
		}
	}
	| elemento_vector TOK_ASIGNACION exp {
		if($1.tipo != $3.tipo) {
			fprintf(yyout, "****Error semantico en lin %d: Asignacion incompatible.\n", numero_linea);
			return -1;
		}
		asignar_vector(yyout, $3.es_direccion);
		fprintf(yyout,";R44:\t<asignacion> ::= <elemento_vector> = <exp>\n");
	}
;

/* Regla de elemento_vector (un elemento de un vector. Ej: x[0]) */
elemento_vector: TOK_IDENTIFICADOR TOK_CORCHETEIZQUIERDO exp TOK_CORCHETEDERECHO {
		lectura = UsoLocal($1.lexema);
		if(lectura == NULL){
			fprintf(yyout,"****Error semantico en lin %d: Declaracion duplicada.\n", numero_linea);
			return -1;
		}

		if(lectura->categoria == FUNCION){
			fprintf(yyout,"****Error semantico en lin %d: Asignacion incompatible.\n", numero_linea);
			return -1;
		}

		$$.tipo = lectura->tipo;
		$$.es_direccion = 1;

		if($3.tipo != ENTERO){
			fprintf(yyout,"****Error semantico en lin %d: El indice en una operacion de indexacion tiene que ser de tipo entero.\n", numero_linea);
			return -1;
		} 
		escribir_operando_array(yyout, $1.lexema,$3.es_direccion, lectura->adicional1);
		fprintf(yyout,";R48:\t<elemento_vector> ::= <identificador> [ <exp> ]\n");
	}
;

/* Regla de condicional (un condicional de if-else con sus sentencias) */
condicional: if_exp_sentencias TOK_LLAVEDERECHA {
		ifthenelse_fin(yyout, $1.etiqueta);
		fprintf(yyout,";R50:\t<condicional> ::= if ( <exp> ) { <sentencias> }\n");
	}
	| if_exp_sentencias TOK_LLAVEDERECHA TOK_ELSE TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA{
		ifthenelse_fin(yyout, $1.etiqueta);
		fprintf(yyout,";R51:\t<condicional> ::= if ( <exp> ) { <sentencias> } else { <sentencias> }\n");
	}
;

/* Regla para la expresion de declaracion de un if */
if_exp: TOK_IF exp TOK_LLAVEIZQUIERDA {
		if($2.tipo != BOOLEANO){
			fprintf(yyout,"****Error semantico en lin %d: Condicional con condicion de tipo int.\n", numero_linea);
			return -1;
		}

		$$.etiqueta = num_condicionales++;
		ifthenelse_inicio(yyout, $2.es_direccion, $$.etiqueta);	
	}
;

/* Regla para las sentencias de un bloque if */
if_exp_sentencias:  if_exp sentencias {
		$$.etiqueta = $1.etiqueta;
		ifthenelse_fin_then(yyout, $$.etiqueta);
	}
;

/* Regla de bucle (un bucle while con sus sentencias) */
bucle: while_exp sentencias TOK_LLAVEDERECHA {
		while_fin(yyout, $1.etiqueta);
		fprintf(yyout,";R52:\t<bucle> ::= while ( <exp> ) { <sentencias> }\n");
	}
;

while: TOK_WHILE {
		$$.etiqueta = num_bucles++;
		while_inicio(yyout, $$.etiqueta);
	}
;

while_exp: while exp TOK_LLAVEIZQUIERDA {
		if($2.tipo != BOOLEANO) {
			fprintf(yyout, "****Error semantico en lin %d: Bucle con condicion de tipo int.\n", numero_linea);
			return -1;
		}

		$$.etiqueta = $1.etiqueta;
		while_exp_pila(yyout, $2.es_direccion, $$.etiqueta);
	}
;

/* Regla de lectura (un scanf de un identificador) */
lectura: TOK_SCANF TOK_IDENTIFICADOR  {
		lectura = UsoLocal($2.lexema);
		if (lectura == NULL){
			fprintf(yyout,"****Error semantico en la linea %d. Acceso a variable no declarada (%s). \n",numero_linea,$2.lexema);
			return -1;
		}
		leer(yyout,$2.lexema,lectura->tipo);	
		fprintf(yyout,";R54:\t<lectura> ::= scanf <identificador>\n");
	}
;

/* Regla de escritura (un printf de una expresion) */
escritura: TOK_PRINTF exp {
		escribir(yyout,($2.es_direccion),($2.tipo));
		fprintf(yyout,";R56:\t<escritura> ::= printf <exp>\n");
	}
;

/* Regla de retorno_funcion (un return con una expresion) */
retorno_funcion: TOK_RETURN exp {
		if (!es_func){
			fprintf(yyout,"****Error semantico en la linea %d. La sentencia del retorno se encuentra fuera de la función.\n",numero_linea);
			return -1;
		}
		hay_return =1;
		retornarFuncion(yyout, $2.es_direccion);
		fprintf(yyout,";R61:\t<retorno_funcion> ::= return <exp>\n");
	}
;

/* Regla de exp (una expresion. Ej: x + x. Ej: 27)*/
exp: exp TOK_MAS exp {
		if($1.tipo!=ENTERO || $3.tipo != ENTERO) {
			fprintf(yyout, "****Error semantico en lin %d: Operacion aritmetica con operandos booleanos.\n", numero_linea);
			return -1;
		}
		sumar(yyout, $1.es_direccion, $3.es_direccion);
		$$.es_direccion = 0;
		$$.tipo = ENTERO;
		fprintf(yyout,";R72:\t<exp> ::= <exp> + <exp>\n");
	}
	| exp TOK_MENOS exp {
		if($1.tipo!=ENTERO || $3.tipo != ENTERO) {
			fprintf(yyout, "****Error semantico en lin %d: Operacion aritmetica con operandos booleanos.\n", numero_linea);
			return -1;
		}
		$$.tipo = ENTERO;		
		restar(yyout, $1.es_direccion, $3.es_direccion);
		$$.es_direccion = 0;
		fprintf(yyout,";R73:\t<exp> ::= <exp> - <exp>\n");
	}
	| exp TOK_DIVISION exp {
		if($1.tipo!=ENTERO || $3.tipo != ENTERO) {
			fprintf(yyout, "****Error semantico en lin %d: Operacion aritmetica con operandos booleanos.\n", numero_linea);
			return -1;
		}
		$$.tipo = ENTERO;		
		dividir(yyout, $1.es_direccion, $3.es_direccion);
		$$.es_direccion = 0;
		fprintf(yyout,";R74:\t<exp> ::= <exp> / <exp>\n");
	}
	| exp TOK_ASTERISCO exp {
		if($1.tipo!=ENTERO || $3.tipo != ENTERO) {
			fprintf(yyout, "****Error semantico en lin %d: Operacion aritmetica con operandos booleanos.\n", numero_linea);
			return -1;
		}
		$$.tipo = ENTERO;		
		multiplicar(yyout, $1.es_direccion, $3.es_direccion);
		$$.es_direccion = 0;
		fprintf(yyout,";R75:\t<exp> ::= <exp> * <exp>\n");
	}
	| TOK_MENOS exp %prec MU {
		if($2.tipo!=ENTERO) {
		fprintf(yyout, "****Error semantico en lin %d: Operacion aritmetica con operandos boolean.\n", numero_linea);
		return -1; 
		}
		$$.tipo = ENTERO;
		cambiar_signo(yyout, $2.es_direccion);
		$$.es_direccion = 0;
		fprintf(yyout,";R76:\t<exp> ::= - <exp>\n");
	}
	| exp TOK_AND exp {
		if($1.tipo!=BOOLEANO || $3.tipo != BOOLEANO) {
			fprintf(yyout, "****Error semantico en lin %d: Operacion logica con operandos enteros.\n", numero_linea);
			return -1;
			}
		$$.tipo = BOOLEANO;
		y(yyout, $1.es_direccion, $3.es_direccion);
		$$.es_direccion = 0;
		fprintf(yyout,";R77:\t<exp> ::= <exp> && <exp>\n");
	}
	| exp TOK_OR exp {
		if($1.tipo!=BOOLEANO || $3.tipo != BOOLEANO) {
			fprintf(yyout, "****Error semantico en lin %d: Operacion logica con operandos enteros.\n", numero_linea);
			return -1;
			}
		$$.tipo = BOOLEANO;
		o(yyout, $1.es_direccion, $3.es_direccion);
		$$.es_direccion = 0;
		fprintf(yyout,";R78:\t<exp> ::= <exp> || <exp>\n");
	}
	| TOK_NOT exp {
		if($2.tipo != BOOLEANO) {
			fprintf(yyout, "****Error semantico en lin %d: Operacion logica con operandos enteros.\n", numero_linea);
			return -1;
			}
		$$.tipo = BOOLEANO;
		no(yyout, $2.es_direccion, num_negaciones++);
		$$.es_direccion = 0;
		fprintf(yyout,";R79:\t<exp> ::= ! <exp>\n");
	}
	| TOK_IDENTIFICADOR {
    	strcpy($$.lexema, $1.lexema);
    	lectura = UsoLocal($1.lexema);
		if(lectura == NULL) {
			fprintf(yyout, "****Error semantico en lin %d: Acceso a variable no declarada (%s).\n", numero_linea, $1.lexema);
			return -1;
		}
		if (UsoGlobal($1.lexema) == NULL) {
			/* Estamos en una funcion y la variable es local */
			if(lectura->categoria == PARAMETRO) {
				escribir_operando_funcion(yyout, (num_parametros_actual-lectura->adicional1)+1);
			} else {

				escribir_operando_funcion(yyout, -(lectura->adicional1+1));
			}

		} else {
			if(lectura->categoria==FUNCION) {
				/* NUNCA SUCEDE */
				fprintf(yyout,"Identificador no valido\n");
				return -1;
			}
			
			escribir_operando(yyout, $1.lexema, 1);
		}
		$$.es_direccion = 1;
		$$.tipo = lectura->tipo;

		fprintf(yyout,";R80:\t<exp> ::= <identificador>\n");
	}
	| constante {
		$$.tipo =$1.tipo;
		$$.es_direccion = $1.es_direccion;
		escribir_operando(yyout, $1.lexema, 0);
		fprintf(yyout,";R81:\t<exp> ::= <constante>\n");
	}
	| TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO {
   		$$.tipo =$2.tipo;
    	$$.es_direccion = $2.es_direccion;		
		fprintf(yyout,";R82:\t<exp> ::= ( <exp> )\n");
	}
	| TOK_PARENTESISIZQUIERDO comparacion TOK_PARENTESISDERECHO {
    	$$.tipo =BOOLEANO;
    	$$.es_direccion = 0;
		fprintf(yyout,";R83:\t<exp> ::= ( <comparacion> )\n");
	}
	| elemento_vector {
		fprintf(yyout,";R85:\t<exp> ::= <elemento_vector>\n");
	}
	| call_func lista_expresiones TOK_PARENTESISDERECHO {
    	lectura = UsoLocal($1.lexema);
		if(lectura == NULL) {
			fprintf(yyout, "****Error semantico en lin %d: Funcion no declarada (%s).\n",numero_linea, $1.lexema);
			return -1;
		}
		if(lectura->categoria != FUNCION){
			fprintf(yyout, "****Error semantico en lin %d: El identificador no es una funcion (%s).\n", numero_linea, $1.lexema);
			return -1;
		}

		if(lectura->adicional1 != parametros) {
			fprintf(yyout, "****Error semantico en lin %d: Numero incorrecto de parametros en llamada a funcion.\n",numero_linea);
			return -1;
		}
		es_call = 0;
		$$.tipo = lectura->tipo;
		llamarFuncion(yyout, $1.lexema, lectura->adicional1);		
		fprintf(yyout,";R88:\t<exp> ::= <identificador> ( <lista_expresiones> )\n");
	}
;

call_func: TOK_IDENTIFICADOR TOK_PARENTESISIZQUIERDO {
  if(es_call) {
    fprintf(yyout, "****Error semantico en lin %d: No esta permitido el uso de llamadas a funciones como parametros de otras funciones.\n", numero_linea);
    return -1;
  }
  es_call = 1;
  parametros = 0;
  strcpy($$.lexema, $1.lexema);
}

/* Regla de lista_expresiones (engloba varias expresiones dentro de una lista) */
lista_expresiones: expf resto_lista_expresiones {
		es_call = 0;
  		parametros++;
		fprintf(yyout,";R89:\t<lista_expresiones> ::= <exp> <resto_lista_expresiones>\n");
	}
	| /* lambda */ {
		es_call = 0;
		fprintf(yyout,";R90:\t<lista_expresiones> ::= \n");
	}
;

/* Regla de resto_lista_expresiones (engloba varias expresiones despues de una expresion en una lista de expresiones) */
resto_lista_expresiones: TOK_COMA expf resto_lista_expresiones {
		parametros++;
		fprintf(yyout,";R91:\t<resto_lista_expresiones> ::= , <exp> <resto_lista_expresiones>\n");
	}
	| /* lambda */ {
		fprintf(yyout,";R92:\t<resto_lista_expresiones> ::=\n");
	}
;

expf: exp {

	operandoEnPilaAArgumento(yyout, $1.es_direccion);
}


/* Regla de comparacion (una comparacion. Ej: x==0) */
comparacion: exp TOK_IGUAL exp {
		if($1.tipo != ENTERO || $3.tipo != ENTERO) {
			fprintf(yyout, "****Error semantico en lin %d: Comparacion con operandos boolean.\n", numero_linea);
			return -1;
		}
		igual(yyout, $1.es_direccion, $3.es_direccion, num_comparaciones++);
		fprintf(yyout,";R93:\t<comparacion> ::= <exp> == <exp>\n");
	}
	| exp TOK_DISTINTO exp {
		if($1.tipo != ENTERO || $3.tipo != ENTERO) {
			fprintf(yyout, "****Error semantico en lin %d: Comparacion con operandos boolean.\n", numero_linea);
			return -1;
		}
		distinto(yyout, $1.es_direccion, $3.es_direccion, num_comparaciones++);
		fprintf(yyout,";R94:\t<comparacion> ::= <exp> != <exp>\n");
	}
	| exp TOK_MENORIGUAL exp {
		if($1.tipo != ENTERO || $3.tipo != ENTERO) {
			fprintf(yyout, "Error semantico en lin %d: Comparacion con operandos boolean.\n", numero_linea);
			return -1;
		}
		menor_igual(yyout, $1.es_direccion, $3.es_direccion, num_comparaciones++);
		fprintf(yyout,";R95:\t<comparacion> ::= <exp> <= <exp>\n");
	}
	| exp TOK_MAYORIGUAL exp {
		if($1.tipo != ENTERO || $3.tipo != ENTERO) {
			fprintf(yyout, "****Error semantico en lin %d: Comparacion con operandos boolean.\n", numero_linea);
			return -1;
		}
		mayor_igual(yyout, $1.es_direccion, $3.es_direccion, num_comparaciones++);
		fprintf(yyout,";R96:\t<comparacion> ::= <exp> >= <exp>\n");
	}
	| exp TOK_MENOR exp {
		if($1.tipo != ENTERO || $3.tipo != ENTERO) {
			fprintf(yyout, "****Error semantico en lin %d: Comparacion con operandos boolean.\n", numero_linea);
			return -1;
		}
		menor(yyout, $1.es_direccion, $3.es_direccion, num_comparaciones++);		
		fprintf(yyout,";R97:\t<comparacion> ::= <exp> < <exp>\n");
	} 
	| exp TOK_MAYOR exp {
		if($1.tipo != ENTERO || $3.tipo != ENTERO) {
			fprintf(yyout, "****Error semantico en lin %d: Comparacion con operandos boolean.\n", numero_linea);
			return -1;
		}
		mayor(yyout, $1.es_direccion, $3.es_direccion, num_comparaciones++);
		fprintf(yyout,";R98:\t<comparacion> ::= <exp> > <exp>\n");
	}
;

/* Regla de constante (una constante: logica o entera) */
constante: constante_logica {
		$$.tipo = $1.tipo; 
		$$.es_direccion = $1.es_direccion; 
		strcpy($$.lexema, $1.lexema); 
		fprintf(yyout,";R99:\t<constante> ::= <constante_logica>\n");
	}
	| constante_entera {
		$$.tipo = $1.tipo; 
		$$.es_direccion = $1.es_direccion; 
		strcpy($$.lexema, $1.lexema); 
		fprintf(yyout,";R100:\t<constante> ::= <constante_entera>\n");
	}
;

/* Regla de constante_logica (una constante logica. Ej: true) */
constante_logica: TOK_TRUE {
		$$.tipo = BOOLEANO; 
		$$.es_direccion = 0; 
		strcpy($$.lexema, "1");
		fprintf(yyout,";R102:\t<constante_logica> ::= true\n");
	}
	| TOK_FALSE {
		$$.tipo = BOOLEANO; 
		$$.es_direccion = 0; 
		strcpy($$.lexema, "0");
		fprintf(yyout,";R103:\t<constante_logica> ::= false\n");
	}
;

/* Regla de constante_entera (una constante entera. Ej: 3) */
constante_entera: TOK_CONSTANTE_ENTERA {
		$$.tipo = ENTERO; 
		$$.es_direccion = 0;
		fprintf(yyout,";R104:\t<constante_entera> ::= TOK_CONSTANTE_ENTERA\n");
	}
;

/* Regla de identificador (un identificador. Ej: x) */
identificador: TOK_IDENTIFICADOR {
		lectura = UsoLocal($1.lexema);
		if((lectura != NULL && !es_func) || (lectura != NULL && EsLocal($1.lexema)) ) {
			fprintf(yyout, "****Error semantico en lin %d: Declaracion duplicada.\n", numero_linea);
			return -1;
		}

		insertar.lexema = $1.lexema;
		insertar.categoria = VARIABLE;
		insertar.clase = clase_actual;
		insertar.tipo = tipo_actual;
		if(clase_actual == VECTOR) {
			insertar.adicional1 = tamanio_vector;
		} 
		else {
			insertar.adicional1 = 1;
		}

		if(es_func) {
			if(clase_actual == VECTOR) {
				fprintf(yyout, "****Error semantico en lin %d: Variable local de tipo no escalar.\n", numero_linea);
				return -1;
			}
			insertar.adicional1 = num_variables_locales_actual;
			num_variables_locales_actual++;
			posicion_variable_local_actual++;
		} 
		else {
			declarar_variable(yyout, $1.lexema, tipo_actual,  insertar.adicional1);  
		}

		Declarar($1.lexema, &insertar);
		fprintf(yyout, ";R108:\t<identificador> ::= TOK_IDENTIFICADOR\n");
	}
;

escribirTabla: {  
		escribir_segmento_codigo(yyout); 
	}
;

escribirMain: { 
		escribir_inicio_main(yyout); 
	}
;

%%
/******************************************/

/******************************************/
/* Funcion de error en el parser */
void yyerror(const char* s) {
	fprintf(stdout,"****Error sintáctico en [lin %d, col %d]\n", numero_linea, numero_columna);
}
/******************************************/
