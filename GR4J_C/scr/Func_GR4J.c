#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "def_constants.h"
#include "def_structs.h"
#include "Func_GR4J.h"


/***********
 * 
 * some GR4J runoff production parameters:
  Pn = NULL  # 有效降水，mm
  Ps = NULL  # 补充产流水库的降水量
  Pr = NULL  # 总的产流量，mm
  En = NULL  # 剩余蒸发能力，mm
  Es = NULL  # 产流水库蒸散发量，mm
  S,         # water volume in the first water tank (box)
  S0         # first water store water volume for previous step
*****/


/*********************
 * 
  # GR4J parameters:
  # x1 = 350  #产流水库容量，mm
  # x2 = 0   #地下水交换系数，mm
  # x3 = 90   #汇流水库容量，mm
  # x4 = 1.7  #单位线汇流时间，d
 * 
 *********************/



void Model_GR4J(
    double Rainfall,
    double SNOmlt,
    double Eres,
    double *Pn,
    double *Ps,
    double *Pr,
    double *En,
    double *Es,
    double S0,
    double *S,
    double x1
)
{
    double PP;
    double Perc;
    PP = Rainfall + SNOmlt;
    if (PP >= Eres)
    {
        *Pn = PP - Eres;
        *En = 0;
        *Ps = x1 * (1 - pow(S0 / x1, 2)) * tanh(*Pn / x1) / (1 + S0 / x1 + tanh(*Pn / x1));
        *Es = 0;
    } else {
        *En = Eres - PP;
        *Pn = 0;
        *Es = S0 * (2 - S0 / x1) * tanh(*En / x1) / (1 + (1 - S0 / x1) * tanh(*En / x1));
        *Ps = 0;
    }
    // printf("S0: %f, Ps: %f, Es: %f\n", S0, *Ps, *Es);
    *S = S0 - *Es + *Ps;
    Perc = *S * (1 - pow(1 + pow(4.0 * *S / (9.0 * x1), 4.0), -1.0 / 4.0));
    *S = *S - Perc;
    *Pr = Perc + *Pn- *Ps;
}


void Model_Routing(
    ST_VAR_GR4J *p_var_sim,
    int CALC_N,
    double *UH1,
    double *UH2,
    int UH1_len,
    int UH2_len,
    double x2,
    double x3
)
{
    double FF;
    double R0;
    for (size_t i = 0; i < CALC_N; i++)
    {
        if (i == 0)
        {
            R0 = x3 * 0.1;
        } else {
            R0 = (p_var_sim + i - 1)->R;
        }
        
        (p_var_sim + i)->Q1 = 0.0;
        (p_var_sim + i)->Q9 = 0.0;
        if (i + 1 >= UH2_len)
        {
            for (size_t k = 0; k < UH1_len; k++)
            {
                (p_var_sim + i)->Q9 += *(UH1 + k) * (p_var_sim + i - k)->Pr * 0.9; 
            }
            for (size_t k = 0; k < UH2_len; k++)
            {
                (p_var_sim + i)->Q1 += *(UH2 + k) * (p_var_sim + i - k)->Pr * 0.1;
            }
        } else if (i + 1 >= UH1_len && i + 1 < UH2_len)
        {
            for (size_t k = 0; k < UH1_len; k++)
            {
                (p_var_sim + i)->Q9 += *(UH1 + k) * (p_var_sim + i - k)->Pr * 0.9; 
            }
            for (size_t k = 0; k < i + 1; k++)
            {
                (p_var_sim + i)->Q1 += *(UH2 + k) * (p_var_sim + i - k)->Pr * 0.1;
            }
        } else if (i + 1 < UH1_len)
        {
            for (size_t k = 0; k < i + 1; k++)
            {
                (p_var_sim + i)->Q9 += *(UH1 + k) * (p_var_sim + i - k)->Pr * 0.9; 
            }
            for (size_t k = 0; k < i + 1; k++)
            {
                (p_var_sim + i)->Q1 += *(UH2 + k) * (p_var_sim + i - k)->Pr * 0.1;
            }
        }
        FF = x2 * pow(R0 / x3, 7.0 / 2.0);
        (p_var_sim + i)->R = fmax(0.0, (p_var_sim + i)->Q9 + FF + R0);
        (p_var_sim + i)->Qr = (p_var_sim + i)->R * (1 - pow(1 + pow((p_var_sim + i)->R / x3, 4.0), (double)(-1.0 / 4.0)));
        (p_var_sim + i)->R = (p_var_sim + i)->R - (p_var_sim + i)->Qr;
        (p_var_sim + i)->Qd = fmax(0.0, (p_var_sim + i)->Q1 + FF);
        (p_var_sim + i)->Q = (p_var_sim + i)->Qr + (p_var_sim + i)->Qd;
    }
    
}

