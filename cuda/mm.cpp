#include <stdio.h>
#include <string.h>
#include <cstdlib>
#include <cmath>
#include <omp.h>
#include <ctime>



/*
int A[][4] = {{2,0,-1,1},
              {1,2,0,1}

            };

int B[][4] = {

                {1,5,-7},
                {1,1,0},
                {0,-1,1},
                {2,0,0}
            };


*/

int main(){

    int qtd_lin_a,qtd_lin_b,qtd_col_a,qtd_col_b;



    int A[900][900];

    int B[900][900];
    //int C[2][4];



    int C[900][900];

    int acumulador;



   qtd_lin_a = 900;
   qtd_col_a = 900;

   qtd_lin_b = qtd_col_a;
   qtd_col_b =900;


   /* puts("\n\nMultiplicacao de matrizes");
    puts("\n\tDigite a qtd de linhas de A: ");
    scanf("%d", &qtd_lin_a);
    puts("\n\tDigite a qtd de colunas de A: ");
    scanf("%d", &qtd_col_a);
    qtd_lin_b = qtd_col_a;
    puts("\n\tDigite a qtd de colunas de B: ");
    scanf("%d", &qtd_col_b);*/


    srand ( time(NULL) );

for(int i = 0; i<qtd_lin_a; ++i){
        for(int j = 0; j<qtd_col_a; ++j){
            A[i][j] =rand() % 10;
        }
    }

    for(int i = 0; i<qtd_lin_b; ++i){
        for(int j = 0; j<qtd_col_b; ++j){
            B[i][j] =rand() % 10;
        }
    }


/*
  puts("\n\nA: ");
    for(int i = 0; i<qtd_lin_a; i++){

        for(int j = 0; j<qtd_col_a; j++){
            printf(" %d", A[i][j]);
        }
        puts("\n");

    }


    puts("\n\nB: ");
    for(int i = 0; i<qtd_lin_b; i++){

        for(int j = 0; j<qtd_col_b; j++){
            printf(" %d", B[i][j]);
        }
        puts("\n");

    }
*/
    /***************/
//  #pragma omp parallel for private(acumulador)
    for(int linha = 0; linha < qtd_lin_a; ++linha){
        for(int coluna = 0; coluna< qtd_col_b; ++coluna){
            acumulador = 0;
            for(int i = 0; i<qtd_col_a; ++i){
                acumulador = acumulador + (A[linha][i]*B[i][coluna]);
            }
            C[linha][coluna] = acumulador;
        }
    }


  /*puts("\n\nC: ");
    for(int i = 0; i<qtd_lin_a; i++){

        for(int j = 0; j<qtd_col_b; j++){
            printf(" %d", C[i][j]);
        }
        puts("\n");

    }*/


    return 0;
}


