#include <stdio.h>
#include <stdlib.h>
#include "def_constants.h"
#include "def_structs.h"
#include "Func_View.h"

void Preview_GP(
    ST_GP *p_gp
)
{
    printf("------------ configuration: \n");
    printf("- %10s: %s\n", "FP_DATA", p_gp->FP_DATA);
    printf("- %10s: %s\n", "FP_OUT", p_gp->FP_OUT);
    printf("- %10s: %s\n", "PARA_SNOW", p_gp->PARA_SNOW);
    printf("- %10s: %s\n", "PARA_SIM", p_gp->PARA_SIM);
    printf("- %10s: %s\n", "FLAG_OBS", p_gp->FLAG_OBS);
    printf("- %10s: %s\n", "FLAG_MUTE", p_gp->FLAG_MUTE);
    printf("- %10s: %d\n", "CALC_N", p_gp->CALC_N);
}


void Preview_data(
    int num_view,
    int CALC_N,
    ST_DATE *ts_date,
    ST_VAR_IN *p_vars_in
)
{
    printf("------------ data preview: \n");
    if (num_view > CALC_N)
    {
        num_view = CALC_N;
        printf("only preview %d rows of data\n", num_view);
    }
    printf("y,m,d,Prec,Ep,Tavg,Tmax");
    if (flag_obs == 1)
    {
        printf(",Qobs\n");
    } else {
        printf("\n");
    }
    
    for (size_t i = 0; i < num_view; i++)
    {
        printf(
            "%d,%d,%d,%.2f,%.2f,%.2f,%.2f",
            (ts_date + i)->y,
            (ts_date + i)->m,
            (ts_date + i)->d,
            (p_vars_in + i)->Prec,
            (p_vars_in + i)->Epot,
            (p_vars_in + i)->Tair,
            (p_vars_in + i)->Tmax
        );
        if (flag_obs == 1)
        {
            printf(",%.2f\n", (p_vars_in + i)->Qobs);
        } else {
            printf("\n");
        }
        
    }
    
}

void Preview_Para_sim(
    ST_PARA_SIM Para_sim
)
{
    printf("------------ model parameters: \n");
    printf("%6s: %f\n", "x1", Para_sim.x1);
    printf("%6s: %f\n", "x2", Para_sim.x2);
    printf("%6s: %f\n", "x3", Para_sim.x3);
    printf("%6s: %f\n", "x4", Para_sim.x4);
}

void Preview_Para_snow(
    ST_PARA_SNOW Para_snow
)
{
    printf("------------ snow parameters: \n");
    printf("%6s: %f\n", "Trs", Para_snow.Trs);
    printf("%6s: %f\n", "Tmlt", Para_snow.Tmlt);
    printf("%6s: %f\n", "SNO50", Para_snow.SNO50);
    printf("%6s: %f\n", "SNO100", Para_snow.SNO100);
    printf("%6s: %f\n", "Ls", Para_snow.Ls);
    printf("%6s: %f\n", "Bmlt6", Para_snow.Bmlt6);
    printf("%6s: %f\n", "Bmlt12", Para_snow.Bmlt12);
}

