/**
* File: alfa.c
* Autores: Daniel Mateo
*          Franccy del Piero Sambrano
* Grupo: 1362
*/
#include <stdio.h>
#include <stdlib.h>
#include "alfa.h"
  
extern FILE* yyin, *yyout;
int yylex();
int yyparse();
  
/* FUNCION PRINCIPAL */
int main(int argc, char* argv[]) {
  int as = 0;
  
    if (argc != 3){
        fprintf(stdout, "Error. Debe introducir fichero de entrada y de salida.\n");
        return 0;
    }
  
    yyin = fopen(argv[1],"r");
    if(!yyin){
        fprintf(stdout, "Error al abrir el fichero de entrada\n");
        return 0;
    }
  
    yyout = fopen(argv[2],"w");
    if(!yyout){
        fprintf(stdout, "Error al abrir el fichero de salida\n");
        fclose(yyin);
        return 0;
    }
  
    escribir_subseccion_data(yyout);
    escribir_cabecera_bss(yyout);
  
    as = yyparse(); /* Analizador sintactico */
  
    if(as!=0){
        printf("Error durante el análisis\n");  
    }
    else{
        printf("Análisis realizado con éxito\n");
        escribir_fin(yyout);
    }
  
    fclose(yyout);
    fclose(yyin);
  
    return 0;
}