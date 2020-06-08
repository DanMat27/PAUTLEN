/**
* File: alfa.h
* Autores: Daniel Mateo
*          Franccy del Piero Sambrano
* Grupo: 1362
*/

#ifndef ALFA_H
#define ALFA_H

#include "tablaHash.h"
#include "tablasimbolos.h"
#include "generacion.h"

/* Variables Tamanios */
#define MAX_LONG_ID 100
#define MAX_TAMANIO_VECTOR 64
#define TAMANIO_HASH 727
#define TAMANIO 100

/* Variables para diferenciar clases */
#define ESCALAR 0
#define VECTOR 1

/* Estructura de atributos */
typedef struct
{
    char lexema[MAX_LONG_ID+1];
    int tipo;
    int valor_entero;
    int es_direccion;
    int etiqueta;
} tipo_atributos;

#endif 