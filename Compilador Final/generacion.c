/**
* File: generacion.c
* Autores: Daniel Mateo
*          Franccy del Piero Sambrano
* Grupo: 1362
*/

#include <stdio.h>
#include <stdlib.h>
#include "generacion.h"

void escribir_cabecera_bss(FILE* fpasm){
  fprintf(fpasm,"segment .bss\n");
  fprintf(fpasm,"\t__esp resd 1\n");
}

void escribir_subseccion_data(FILE* fpasm){
  fprintf(fpasm,"segment .data\n");
  fprintf(fpasm, "\t_error_div0 db \"Error de division por 0!\",0 \n");
  fprintf(fpasm, "\t_error_indice db \"Error por indice fuera de rango!\",0 \n");
}

void declarar_variable(FILE* fpasm, char * nombre, int tipo, int tamano){
  if(tipo == ENTERO){
    fprintf(fpasm, "\t_%s resd %d\n", nombre, tamano);
  }
  else if(tipo==BOOLEANO){
    fprintf(fpasm, "\t_%s resd %d\n", nombre, tamano);
  }
  else;
}

void escribir_segmento_codigo(FILE* fpasm){
  fprintf(fpasm, "segment .text\n");
  fprintf(fpasm, "\tglobal main\n");
  fprintf(fpasm, "\textern scan_int, scan_boolean, print_int, print_boolean, print_blank, print_endofline, print_string\n");
}

void escribir_inicio_main(FILE* fpasm){
  fprintf(fpasm, "main:\n");
  fprintf(fpasm, "\tmov dword [__esp], esp\n");
}

void escribir_operando(FILE* fpasm, char* nombre, int es_variable){
  if (es_variable){
    fprintf(fpasm, "\tpush dword _%s\n", nombre); /* DIRECCION VARIABLE */
  }
  else{
    fprintf(fpasm, "\tpush %s\n", nombre); /* VALOR DIRECTO */
  }
}

void escribir_operando_array(FILE* fpasm, char* operando, int es_inmediato, int tamano) {
	fprintf(fpasm, "\tpop dword eax\n");
	if (es_inmediato == 1) {
		fprintf(fpasm, "\tmov eax, [eax]\n");
	}
	fprintf(fpasm, "\tcmp eax, 0\n");
	fprintf(fpasm, "\tjl near fin_indice_fuera_rango\n");
	fprintf(fpasm, "\tcmp eax, %d\n", tamano);
	fprintf(fpasm, "\tjge near fin_indice_fuera_rango\n");

	fprintf(fpasm, "\tmov dword edx, _%s\n", operando);
	fprintf(fpasm, "\tlea eax, [edx + eax*4]\n");
	fprintf(fpasm, "\tpush dword eax\n");
}

void escribir_operando_funcion(FILE* fpasm, int n_parametro) {
	fprintf(fpasm, "\tmov dword eax, ebp\n");
	fprintf(fpasm, "\tadd eax, %d\n", 4*n_parametro);
	fprintf(fpasm, "\tpush dword eax\n");
}

void asignar(FILE* fpasm, char* nombre, int es_variable){
  fprintf(fpasm,"\tpop dword eax\n");
  if (es_variable){
    fprintf(fpasm,"\tmov dword eax, [eax]\n");
  }
  fprintf(fpasm,"\tmov dword [_%s], eax\n", nombre);
}

void asignar_vector(FILE* fpasm, int es_variable){
	fprintf(fpasm, "\tpop dword eax\n");
	if (es_variable) {
		fprintf(fpasm, "\tmov eax, [eax]\n");
	}
	fprintf(fpasm, "\tpop dword edx\n");
	fprintf(fpasm, "\tmov [edx], eax\n");
}

void sumar(FILE* fpasm, int es_variable_1, int es_variable_2){
    fprintf(fpasm, "\tpop dword edx\n");
    if (es_variable_2 == 1){
      fprintf(fpasm, "\tmov dword edx , [edx]\n");
    }
    fprintf(fpasm, "\tpop dword eax\n");
    if (es_variable_1 == 1){
      fprintf(fpasm, "\tmov dword eax , [eax]\n");
    }
    fprintf(fpasm, "\tadd eax, edx\n");
    fprintf(fpasm, "\tpush dword eax\n");
}

void restar(FILE* fpasm, int es_variable_1, int es_variable_2){
  fprintf(fpasm, "\tpop dword edx\n");
  if (es_variable_2 == 1){
    fprintf(fpasm, "\tmov dword edx , [edx]\n");
  }
  fprintf(fpasm, "\tpop dword eax\n");
  if (es_variable_1 == 1){
    fprintf(fpasm, "\tmov dword eax , [eax]\n");
  }
  fprintf(fpasm, "\tsub eax, edx\n");
  fprintf(fpasm, "\tpush dword eax\n");
}

void multiplicar(FILE* fpasm, int es_variable_1, int es_variable_2){
  fprintf(fpasm, "\tpop dword edx\n");
  if (es_variable_2 == 1){
    fprintf(fpasm, "\tmov dword edx , [edx]\n");
  }
  fprintf(fpasm, "\tpop dword eax\n");
  if (es_variable_1 == 1){
    fprintf(fpasm, "\tmov dword eax , [eax]\n");
  }
  fprintf(fpasm, "\timul eax, edx\n");
  fprintf(fpasm, "\tpush dword eax\n");
}

void dividir(FILE* fpasm, int es_variable_1, int es_variable_2){
  fprintf(fpasm, "\tpop dword ecx\n");
  if (es_variable_2 == 1){
    fprintf(fpasm, "\tmov dword ecx, [ecx]\n");
  }
  fprintf(fpasm, "\tpop dword eax\n");
  if (es_variable_1 == 1){
    fprintf(fpasm, "\tmov dword eax, [eax]\n");
  }
  fprintf(fpasm, "\tcmp ecx, 0\n");
  fprintf(fpasm, "\tje near error_div_cero\n");
  fprintf(fpasm, "\tcdq\n");
  fprintf(fpasm, "\tidiv ecx\n");
  fprintf(fpasm, "\tpush dword eax\n");
}

void o(FILE* fpasm, int es_variable_1, int es_variable_2){
  fprintf(fpasm, "\tpop dword edx\n");
  if (es_variable_2 == 1){
    fprintf(fpasm, "\tmov dword edx , [edx]\n");
  }
  fprintf(fpasm, "\tpop dword eax\n");
  if (es_variable_1 == 1){
    fprintf(fpasm, "\tmov dword eax , [eax]\n");
  }
  fprintf(fpasm, "\tor eax, edx\n");
  fprintf(fpasm, "\tpush dword eax\n");
}

void y(FILE* fpasm, int es_variable_1, int es_variable_2){
  fprintf(fpasm, "\tpop dword edx\n");
  if (es_variable_2 == 1){
    fprintf(fpasm, "\tmov dword edx , [edx]\n");
  }
  fprintf(fpasm, "\tpop dword eax\n");
  if (es_variable_1 == 1){
    fprintf(fpasm, "\tmov dword eax , [eax]\n");
  }
  fprintf(fpasm, "\tand eax, edx\n");
  fprintf(fpasm, "\tpush dword eax\n");
}

void cambiar_signo(FILE* fpasm, int es_variable){
  fprintf(fpasm, "\tpop dword eax\n");
  if (es_variable == 1){
    fprintf(fpasm, "\tmov dword eax , [eax]\n");
  }
  fprintf(fpasm, "\tneg eax\n");
  fprintf(fpasm, "\tpush dword eax\n");
}

void no(FILE* fpasm, int es_variable, int cuantos_no){
  fprintf(fpasm, "\tpop dword eax\n");
  if(es_variable){
    fprintf(fpasm, "\tmov dword eax, [eax]\n");
  }
  fprintf(fpasm, "\tor eax, eax\n");
  fprintf(fpasm, "\tjz near neg%d\n", cuantos_no);
  fprintf(fpasm, "\tmov dword eax, 0\n");
  fprintf(fpasm, "\tjmp fin_neg%d\n", cuantos_no);
  fprintf(fpasm, "neg%d:\n", cuantos_no);
  fprintf(fpasm, "\tmov dword eax, 1\n");
  fprintf(fpasm, "fin_neg%d:\n", cuantos_no);
  fprintf(fpasm, "\tpush dword eax\n");
}

void igual(FILE* fpasm, int es_variable1, int es_variable2, int etiqueta){
    fprintf(fpasm, "\tpop dword edx\n");
    if (es_variable2 == 1){
          fprintf(fpasm, "\tmov dword edx, [edx]\n");
    }
    fprintf(fpasm, "\tpop dword eax\n");
    if (es_variable1 == 1){
          fprintf(fpasm, "\tmov dword eax, [eax]\n");
    }
    fprintf(fpasm, "\tcmp eax,edx\n");
    fprintf(fpasm, "\tje near igual%d\n", etiqueta);
    fprintf(fpasm, "\tpush dword 0\n");
    fprintf(fpasm, "\tjmp near fin_igual%d\n", etiqueta);
    fprintf(fpasm, "\tigual%d:\n", etiqueta);
    fprintf(fpasm, "\tpush dword 1\n");
    fprintf(fpasm, "\tfin_igual%d:\n", etiqueta);
}

void distinto(FILE* fpasm, int es_variable1, int es_variable2, int etiqueta){
  fprintf(fpasm, "\tpop dword edx\n");
  if (es_variable2 == 1){
        fprintf(fpasm, "\tmov dword edx, [edx]\n");
  }
  fprintf(fpasm, "\tpop dword eax\n");
  if (es_variable1 == 1){
        fprintf(fpasm, "\tmov dword eax, [eax]\n");
  }
  fprintf(fpasm, "\tcmp eax,edx\n");
  fprintf(fpasm, "\tjne near distinto%d\n", etiqueta);
  fprintf(fpasm, "\tpush dword 0\n");
  fprintf(fpasm, "\tjmp near fin_distinto%d\n", etiqueta);
  fprintf(fpasm, "\tdistinto%d:\n", etiqueta);
  fprintf(fpasm, "\tpush dword 1\n");
  fprintf(fpasm, "\tfin_distinto%d:\n", etiqueta);
}

void menor_igual(FILE* fpasm, int es_variable1, int es_variable2, int etiqueta){
  fprintf(fpasm, "\tpop dword edx\n");
  if (es_variable2 == 1){
        fprintf(fpasm, "\tmov dword edx, [edx]\n");
  }
  fprintf(fpasm, "\tpop dword eax\n");
  if (es_variable1 == 1){
        fprintf(fpasm, "\tmov dword eax, [eax]\n");
  }
  fprintf(fpasm, "\tcmp eax,edx\n");
  fprintf(fpasm, "\tjle near menorigual%d\n", etiqueta);
  fprintf(fpasm, "\tpush dword 0\n");
  fprintf(fpasm, "\tjmp near fin_menorigual%d\n", etiqueta);
  fprintf(fpasm, "\tmenorigual%d:\n", etiqueta);
  fprintf(fpasm, "\tpush dword 1\n");
  fprintf(fpasm, "\tfin_menorigual%d:\n", etiqueta);
}

void mayor_igual(FILE* fpasm, int es_variable1, int es_variable2, int etiqueta){
  fprintf(fpasm, "\tpop dword edx\n");
  if (es_variable2 == 1){
        fprintf(fpasm, "\tmov dword edx, [edx]\n");
  }
  fprintf(fpasm, "\tpop dword eax\n");
  if (es_variable1 == 1){
        fprintf(fpasm, "\tmov dword eax, [eax]\n");
  }
  fprintf(fpasm, "\tcmp eax,edx\n");
  fprintf(fpasm, "\tjge near mayorigual%d\n", etiqueta);
  fprintf(fpasm, "\tpush dword 0\n");
  fprintf(fpasm, "\tjmp near fin_mayorigual%d\n", etiqueta);
  fprintf(fpasm, "\tmayorigual%d:\n", etiqueta);
  fprintf(fpasm, "\tpush dword 1\n");
  fprintf(fpasm, "\tfin_mayorigual%d:\n", etiqueta);
}

void menor(FILE* fpasm, int es_variable1, int es_variable2, int etiqueta){
  fprintf(fpasm, "\tpop dword edx\n");
  if (es_variable2 == 1){
        fprintf(fpasm, "\tmov dword edx, [edx]\n");
  }
  fprintf(fpasm, "\tpop dword eax\n");
  if (es_variable1 == 1){
        fprintf(fpasm, "\tmov dword eax, [eax]\n");
  }
  fprintf(fpasm, "\tcmp eax,edx\n");
  fprintf(fpasm, "\tjl near menor%d\n", etiqueta);
  fprintf(fpasm, "\tpush dword 0\n");
  fprintf(fpasm, "\tjmp near fin_menor%d\n", etiqueta);
  fprintf(fpasm, "\tmenor%d:\n", etiqueta);
  fprintf(fpasm, "\tpush dword 1\n");
  fprintf(fpasm, "\tfin_menor%d:\n", etiqueta);
}
void mayor(FILE* fpasm, int es_variable1, int es_variable2, int etiqueta){
  fprintf(fpasm, "\tpop dword edx\n");
  if (es_variable2 == 1){
        fprintf(fpasm, "\tmov dword edx, [edx]\n");
  }
  fprintf(fpasm, "\tpop dword eax\n");
  if (es_variable1 == 1){
        fprintf(fpasm, "\tmov dword eax, [eax]\n");
  }
  fprintf(fpasm, "\tcmp eax,edx\n");
  fprintf(fpasm, "\tjg near mayor%d\n", etiqueta);
  fprintf(fpasm, "\tpush dword 0\n");
  fprintf(fpasm, "\tjmp near fin_mayor%d\n", etiqueta);
  fprintf(fpasm, "\tmayor%d:\n", etiqueta);
  fprintf(fpasm, "\tpush dword 1\n");
  fprintf(fpasm, "\tfin_mayor%d:\n", etiqueta);
}

void escribir(FILE* fpasm, int es_variable, int tipo){
  if(es_variable == 1){
    fprintf(fpasm, "\tpop dword eax\n");
    fprintf(fpasm, "\tmov dword eax, [eax]\n");
    fprintf(fpasm, "\tpush dword eax\n");
  }

  if(tipo == ENTERO){
    fprintf(fpasm, "\tcall print_int\n");
  }
  else if(tipo == BOOLEANO){
    fprintf(fpasm, "\tcall print_boolean\n");
  }
  else;

  fprintf(fpasm, "\tadd esp, 4\n");
  fprintf(fpasm, "\tcall print_endofline\n");
}

void leer(FILE* fpasm, char* nombre, int tipo){
  fprintf(fpasm, "\tpush dword _%s\n", nombre);
  if(tipo == ENTERO){
    fprintf(fpasm, "\tcall scan_int\n");
  }
  else if(tipo == BOOLEANO){
    fprintf(fpasm, "\tcall scan_boolean\n");
  }
  else;

  fprintf(fpasm, "\tadd esp, 4\n");
}

void escribir_fin(FILE* fpasm){
  fprintf(fpasm, "\tjmp fin\n");

  fprintf(fpasm, "error_div_cero:\n");
  fprintf(fpasm, "\tpush dword _error_div0\n");
  fprintf(fpasm, "\tcall print_string\n");
  fprintf(fpasm, "\tadd esp, 4\n");
  fprintf(fpasm, "\tcall print_endofline\n");

  fprintf(fpasm, "fin_indice_fuera_rango:\n");
  fprintf(fpasm, "\tpush dword _error_indice\n");
  fprintf(fpasm, "\tcall print_string\n");
  fprintf(fpasm, "\tadd esp, 4\n");
  fprintf(fpasm, "\tcall print_endofline\n");

  fprintf(fpasm, "fin:\n");
  fprintf(fpasm, "\tmov dword esp, [__esp]\n");
  fprintf(fpasm, "\tret\n");
}

void while_inicio(FILE * fpasm, int etiqueta){
  fprintf(fpasm, "inicio_while%d:\n", etiqueta);
}

void while_exp_pila(FILE * fpasm, int exp_es_variable, int etiqueta){
    fprintf(fpasm, "\tpop dword eax\n");

    if (exp_es_variable > 0){
      fprintf(fpasm, "\tmov eax, [eax]\n");
    }
    fprintf(fpasm, "\tcmp eax,0\n");
    fprintf(fpasm, "\tje near fin_while%d\n", etiqueta);
}

void while_fin( FILE * fpasm, int etiqueta){
  fprintf(fpasm, "\tjmp near inicio_while%d\n", etiqueta);
  fprintf(fpasm, "fin_while%d:\n", etiqueta);
}

void asignarDestinoEnPila(FILE* fpasm, int es_variable){
  fprintf(fpasm, "\tpop dword ebx\n");
  fprintf(fpasm, "\tpop dword eax\n");
  if (es_variable == 1){
    fprintf(fpasm, "\tmov eax, [eax]\n");
  }
  fprintf(fpasm, "\tmov [ebx], eax\n");
}

void escribir_elemento_vector(FILE * fpasm,char * nombre_vector,
int tam_max, int exp_es_direccion){
  fprintf(fpasm, "\tpop dword eax\n");
  if (exp_es_direccion == 1){
      fprintf(fpasm, "\tmov dword eax, [eax]\n");
  }
  fprintf(fpasm, "\tcmp eax, 0\n");
  fprintf(fpasm, "\tjl near fin_indice_fuera_rango\n");
  fprintf(fpasm, "\tcmp eax, %d \n",tam_max-1);
  fprintf(fpasm, "\tjg near fin_indice_fuera_rango\n");
  fprintf(fpasm, "\tmov dword edx, _%s\n",nombre_vector);
  fprintf(fpasm, "\tlea eax, [edx+eax*4]\n");
  fprintf(fpasm, "\tpush dword eax\n");
}

void ifthenelse_inicio(FILE * fpasm, int exp_es_variable, int etiqueta){
  fprintf(fpasm, "\tpop dword eax\n");
if (exp_es_variable == 1){
  fprintf(fpasm, "\tmov eax, [eax]\n");
  }
 fprintf(fpasm, "\tcmp eax, 0\n");
 fprintf(fpasm, "\tje near fin_then%d\n",etiqueta);
}

void ifthen_inicio(FILE * fpasm, int exp_es_variable, int etiqueta){
  fprintf(fpasm, "\tpop dword eax\n");
if (exp_es_variable == 1){
  fprintf(fpasm, "\tmov eax, [eax]\n");
  }
  fprintf(fpasm, "\tcmp eax, 0\n");
  fprintf(fpasm, "\tje near fin_then%d\n",etiqueta);
}

void ifthen_fin(FILE * fpasm, int etiqueta){
  fprintf(fpasm, "fin_then%d:\n",etiqueta);
}

void ifthenelse_fin_then( FILE * fpasm, int etiqueta){
    fprintf(fpasm, "\tjmp near fin_ifelse%d\n",etiqueta);
    fprintf(fpasm, "fin_then%d:\n",etiqueta);
}

void ifthenelse_fin( FILE * fpasm, int etiqueta){
      fprintf(fpasm, "fin_ifelse%d:\n",etiqueta);
}

void declararFuncion(FILE * fd_asm, char * nombre_funcion, int num_var_loc){
  fprintf(fd_asm, "_%s:\n", nombre_funcion);
  fprintf(fd_asm, "\tpush dword ebp\n");
  fprintf(fd_asm, "\tmov ebp, esp\n");
  fprintf(fd_asm, "\tsub esp, %d\n", 4*num_var_loc);
}

void escribirParametro(FILE* fpasm, int pos_parametro, int num_total_parametros){
  int d_ebp;
  d_ebp = 4*( 1 + (num_total_parametros - pos_parametro));
  fprintf(fpasm, "\tlea eax, [ebp + %d]\n", d_ebp);
  fprintf(fpasm, "\tpush dword eax\n");
}

void escribirVariableLocal(FILE* fpasm, int posicion_variable_local){
  int d_ebp;
  d_ebp = 4*posicion_variable_local;
  fprintf(fpasm, "\tlea eax, [ebp - %d]\n", d_ebp);
  fprintf(fpasm, "\tpush dword eax\n");
}

void operandoEnPilaAArgumento(FILE * fd_asm, int es_variable){
  if (es_variable == 1){
    fprintf(fd_asm, "\tpop dword eax\n");
    fprintf(fd_asm, "\tmov eax, [eax]\n");
    fprintf(fd_asm, "\tpush dword eax\n");
  }
}

void retornarFuncion(FILE * fd_asm, int es_variable){
  fprintf(fd_asm, "\tpop dword eax\n");
  if (es_variable == 1){
    fprintf(fd_asm, "\tmov dword eax, [eax]\n");
  }
  fprintf(fd_asm, "\tmov esp, ebp\n");
  fprintf(fd_asm, "\tpop dword ebp\n");
  fprintf(fd_asm, "\tret\n");
}

void limpiarPila(FILE * fd_asm, int num_argumentos){
  fprintf(fd_asm, "\tadd esp, %d\n", num_argumentos*4);
}

void llamarFuncion(FILE * fd_asm, char * nombre_funcion, int num_argumentos){
  fprintf(fd_asm, "\tcall _%s\n", nombre_funcion);
  limpiarPila(fd_asm, num_argumentos);
  fprintf(fd_asm, "\tpush dword eax\n");
}
