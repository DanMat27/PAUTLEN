/**
* File: tablasimbolos.c
* Autores: DanMat27
*          FPS
*/

#include <stdio.h>
#include "tablasimbolos.h"

/*Declaramos las dos tablas hash que usaremos */
TABLA_HASH *TablaSimbolosGlobal = NULL;
TABLA_HASH *TablaSimbolosLocal = NULL;

/* Declaramos como variable global si no existe la tabla local. En caso contrario será global*/
STATUS Declarar(const char *id, INFO_SIMBOLO *desc_id){
    if (TablaSimbolosLocal == NULL){
        return DeclararGlobal(id,desc_id);
    }
    return DeclararLocal(id,desc_id);
}

/*Declaramos como ambito global. Lo busca en este ámbito. Si no lo encuentra lo inserta */
STATUS DeclararGlobal(const char *id, INFO_SIMBOLO *desc_id){
    if (TablaSimbolosGlobal == NULL){
        TablaSimbolosGlobal = crear_tabla(TABLA_SIMBOLOS_GLOBAL_TAM);
        if (TablaSimbolosGlobal == NULL){
            return ERR;
        }
    }
    if (buscar_simbolo(TablaSimbolosGlobal,id) == NULL){
       return insertar_simbolo(TablaSimbolosGlobal, id, desc_id->categoria, desc_id->tipo, desc_id->clase, desc_id->adicional1, desc_id->adicional2);
    }
    return ERR;
}

/*Declaramos el ámbito local donde buscamos el simbolo. En caso de no encontrarlo lo añade */
STATUS DeclararLocal(const char* id, INFO_SIMBOLO* desc_id){
    INFO_SIMBOLO*  busca;
    busca = buscar_simbolo(TablaSimbolosLocal, id);
   if(busca == NULL) {
        return insertar_simbolo(TablaSimbolosLocal, id, desc_id->categoria, desc_id->tipo, desc_id->clase, desc_id->adicional1, desc_id->adicional2);
    }
    return ERR;
}

/*Mira si el id está en el ámbito global. En caso de no estarlo devuelve NULL */
INFO_SIMBOLO *UsoGlobal(const char* id){
    INFO_SIMBOLO*  busca;
    if (TablaSimbolosGlobal == NULL){
        return NULL;
    }
    busca = buscar_simbolo(TablaSimbolosGlobal, id);

    if (busca == NULL){
        return NULL;
    }
    return busca;
}

/*Mira si el id está en el ámbito local. En caso de estarlo lo devuelve. EN caso contrario mira en el ambito global */
INFO_SIMBOLO *UsoLocal(const char* id){
    INFO_SIMBOLO*  busca;

    if (TablaSimbolosLocal == NULL){
        return UsoGlobal(id);
    }
    busca = buscar_simbolo(TablaSimbolosLocal,id);
    if (busca == NULL){
        return UsoGlobal(id);
    }
    return busca;
}
/*Declaramos una función y creamos el ámbito local */
STATUS DeclararFuncion(const char* id, INFO_SIMBOLO* desc_id){
    STATUS resultado;
    if (buscar_simbolo(TablaSimbolosGlobal,id) == NULL){
        resultado = insertar_simbolo(TablaSimbolosGlobal, id, desc_id->categoria, desc_id->tipo, desc_id->clase, desc_id->adicional1, desc_id->adicional2);
        if (resultado == ERR){
            return ERR;
        }
        /*Si hubiese un ámbito local previamente creado */
        if (TablaSimbolosLocal != NULL){
            liberar_tabla(TablaSimbolosLocal);
        }
        TablaSimbolosLocal = crear_tabla(TABLA_SIMBOLOS_LOCAL_TAM);
        if (TablaSimbolosLocal == NULL){
            /*Liberamos recursos*/
            borrar_simbolo(TablaSimbolosGlobal, id);
            return ERR;
        }
        resultado = insertar_simbolo(TablaSimbolosLocal, id, desc_id->categoria, desc_id->tipo, desc_id->clase, desc_id->adicional1, desc_id->adicional2);
        if (resultado == ERR){
            borrar_simbolo(TablaSimbolosGlobal, id);
            liberar_tabla(TablaSimbolosLocal);
            TablaSimbolosLocal = NULL;
            return ERR;
        }
        return OK;
    }
    return ERR;
}

/*Finaliza la función realizada */
STATUS CerrarFuncion(){
    /*Al no existir tabla global hay error */
    if (TablaSimbolosLocal == NULL){
        return ERR;
    }
    liberar_tabla(TablaSimbolosLocal);
    TablaSimbolosLocal = NULL;
    return OK;
}
/*Finaliza el ámbito global */
void Terminar(){
    if (TablaSimbolosLocal != NULL){
        liberar_tabla(TablaSimbolosLocal);
    }
    liberar_tabla(TablaSimbolosGlobal);
    return;
}
int EsLocal(const char *id) {
    if(TablaSimbolosLocal == NULL) {
        return 0;
    }
    return buscar_simbolo(TablaSimbolosLocal, id)!=NULL;

}