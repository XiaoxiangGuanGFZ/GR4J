#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "def_constants.h"
#include "def_structs.h"
#include "Func_UH.h"

void Model_UH1(
    double x4,
    double **UH,
    int *UH1_len
)
{
    if (x4 <= 1)
    {
        *UH1_len = 1;
        *UH = (double *)malloc(sizeof(double) * *UH1_len);
        *(*UH + 0) = 1;
    } else {
        *UH1_len = (int)ceil(x4);
        double *S;
        S = (double *)malloc(sizeof(double) * *UH1_len);
        *UH = (double *)malloc(sizeof(double) * *UH1_len);
        for (size_t i = 0; i < *UH1_len; i++)
        {
            if (i + 1 < x4)
            {
                *(S + i) = pow( (i + 1) / x4, 2.5);
            } else {
                *(S + i) = 1;
            }
        }
        *(*UH + 0) = *(S + 0);
        for (size_t i = 1; i < *UH1_len; i++)
        {
            *(*UH + i) = *(S + i) - *(S + i -1);
        }     
        free(S);   
    }
}


void Preview_UH(
    double *UH,
    int UH_len
)
{
    for (size_t i = 0; i < UH_len; i++)
    {
        printf("%d\t%f\n", i + 1, *(UH + i));
    }
}


void Model_UH2(
    double x4,
    double **UH,
    int *UH_len
){
    if (x4 <= 0.5)
    {
        *UH_len = 1;
        *UH = (double *)malloc(sizeof(double) * *UH_len);
        *(*UH + 0) = 1;
    } else if (x4 > 0.5 && x4 < 1)
    {
        *UH_len = 2;
        *UH = (double *)malloc(sizeof(double) * *UH_len);
        *(*UH + 0) = 1 - 0.5 * pow(2 - 1 / x4, 2.5);
        *(*UH + 1) = 1 - *(*UH + 0);
    } else if (x4 == 1)
    {
        *UH_len = 2;
        *UH = (double *)malloc(sizeof(double) * *UH_len);
        *(*UH + 0) = 0.5 * pow(1 / x4, 2.5);
        *(*UH + 1) = 1 - *(*UH + 0);
    } else if (x4 > 1)
    {
        double *S;
        *UH_len = ((int)ceil(x4)) * 2;
        *UH = (double *)malloc(sizeof(double) * *UH_len);
        S = (double *)malloc(sizeof(double) * *UH_len);
        for (size_t i = 0; i < *UH_len; i++)
        {
            if (i + 1 <= x4)
            {
                *(S + i) = 0.5 * pow((i + 1) / x4, 2.5); 
            } else if (i + 1 > x4 && i + 1 < 2 * x4)
            {
                *(S + i) = 1 - 0.5 * pow(2 - (i + 1) / x4, 2.5);
            } else {
                *(S + i) = 1;
            }
        }
        *(*UH + 0) = *(S + 0);
        for (size_t i = 1; i < *UH_len; i++)
        {
            *(*UH + i) = *(S + i) - *(S + i - 1);
        }
        free(S);
    }
}



