/**
* File: tablaHash.c
* Autores: DanMat27
*          FPS
*/

#include <stdio.h>
#include <stdlib.h>
#include "tablaHash.h"
#include <string.h>

/*Creamos el simbolo */
INFO_SIMBOLO *crear_info_simbolo(const char *lexema, CATEGORIA categ, TIPO tipo,
CLASE clase, int adic1, int adic2){
    INFO_SIMBOLO* info = NULL;
    info = (INFO_SIMBOLO*)calloc(1,sizeof(INFO_SIMBOLO));
    if (info == NULL){
        return NULL;
    }

        if (!(info->lexema = strdup(lexema))) {
            free(info);
            return NULL;
        }
    info->categoria = categ;
    info->tipo = tipo;
    info->clase = clase;
    info->adicional1 = adic1;
    info->adicional2 = adic2;
    
    return info;
}
/*Liberamos el símbolo */
void liberar_info_simbolo(INFO_SIMBOLO *is){
    if (is != NULL){
    if (is->lexema != NULL)
        free(is->lexema);
        free(is);
        return;
    }
}
/*Creamos un nodo */
NODO_HASH *crear_nodo(INFO_SIMBOLO *is){
    NODO_HASH* nodo;
    nodo = (NODO_HASH*)calloc(1,sizeof(NODO_HASH));
    if (nodo == NULL){
        return NULL;
    }
    nodo->info = is;
    nodo->siguiente = NULL;
    return nodo;
    
}
/*Liberamos el nodo */
void liberar_nodo(NODO_HASH *nh){
        if (nh) {
        liberar_info_simbolo(nh->info);
        free(nh);
    }
}
/*Creamos la tabla HASH */
TABLA_HASH *crear_tabla(int tam){
    TABLA_HASH *tabla = NULL;
    
    tabla = (TABLA_HASH*)calloc(1,sizeof(TABLA_HASH));
    if (tabla == NULL){
        return NULL;
    }
    tabla->tam = tam;
    tabla->tabla = (NODO_HASH**)calloc(tam,sizeof(NODO_HASH*));
    if (tabla->tabla == NULL){
        free(tabla);
        return NULL;
    }
    return tabla;
}
/* Liberamos la tabla creadas anteriormente */
void liberar_tabla(TABLA_HASH *th){
    int i;
    NODO_HASH* n1;
    NODO_HASH* n2;
    /*Comprobamos si la tabla existe */
    if (th) {
        if (th->tabla) {
            for (i = 0; i < th->tam; i++) {
                n1 = th->tabla[i];
                /* Libera cada elemento */
                while (n1) {
                    n2 = n1->siguiente;
                    liberar_nodo(n1);
                    n1 = n2;      
                }
            }
            free(th->tabla);
        }
        free(th);
    }
}
/* Función que busca el hash */
unsigned long hash(const char* str){
    unsigned long hash = HASH_INI;
    unsigned char* puntero;

    for(puntero = (unsigned char*)str; *puntero;puntero++){
        hash = hash*HASH_FACTOR + *puntero;
    }
    return hash;
}
/* Busca el sinbolo en la tabla */
INFO_SIMBOLO *buscar_simbolo(const TABLA_HASH *th, const char *lexema){
   unsigned int ind;    
    NODO_HASH *n;
        
    /* Calcular posición */
    ind = hash(lexema) % th->tam;
    /* Buscar en lista enlazada */
    n = th->tabla[ind];
    while (n && (!n->info || strcmp(n->info->lexema, lexema))) {
        n = n->siguiente;
    }
    return n ? n->info : NULL;
}
/*Insertamos el simbolo si no se encuentra en ese ambito */
STATUS insertar_simbolo(TABLA_HASH *th, const char *lexema, CATEGORIA categ, TIPO
tipo, CLASE clase, int adic1, int adic2){
    int indice;
    INFO_SIMBOLO *simbolo;    
    NODO_HASH *n_hash = NULL;

    if (buscar_simbolo(th, lexema)) {
        return ERR;
    }
    /* Calcular posición */
    indice = hash(lexema) % th->tam;
    /* Reservar nodo e info del nodo */
    simbolo = crear_info_simbolo(lexema,categ,tipo,clase,adic1,adic2);
    if (!simbolo) {
        return ERR;
    }
    n_hash = crear_nodo(simbolo);
    if (!n_hash) {
        liberar_info_simbolo(simbolo);
        return ERR;
    }
    /* Insertar al principio de la lista enlazada para ahorrar tiempo */
    n_hash->siguiente = th->tabla[indice];
    th->tabla[indice] = n_hash;
    return OK;

}
/*Borramos el simbolo dentro del ambito */
void borrar_simbolo(TABLA_HASH *th, const char *lexema){
    int indice;
    NODO_HASH *actual = NULL;
    NODO_HASH*anterior = NULL;
    /*Posicion del hash actual */
    indice = hash(lexema) % th->tam;
    
    actual = th->tabla[indice];
    while(actual && (actual->info != NULL || strcmp(actual->info->lexema,lexema))){
        anterior = actual;
        actual = actual->siguiente;
    }
    if (!actual){
        return;
    }
    /*Borramos el primer nodo */
    if (!anterior){
        th->tabla[indice] = actual->siguiente;
    }
    else
    {
        anterior->siguiente = actual->siguiente;
    }
    liberar_nodo(actual);
    return;
    
}
