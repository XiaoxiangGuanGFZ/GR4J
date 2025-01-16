
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <math.h>
#include "def_constants.h"
#include "Func_Snow.h"

/******************
 * parameters of the degree-day snow amodule
 * 
  # Tmlt        the base temperature above which snow melt is allowed
  # SNO50       the depth of snow when the basin is 50% covered by snow, unit:mm
  # SNO100      the shreshold depth of snow, above which there is 100% cover  , unit:mm
  # Ls          snow temperature lag factor
  # Trs         air temperature above which the precipitation is all rainfall, 
  # Bmlt6       melt factor on June 21 (mm H2O/day-℃)
  # Bmlt12      melt factor on December 21 (mm H2O/day-℃)
  # Tsnow_0     initial snow temperature
  # SNO_0       initial snow depth
 * **********/

void P_Rain_Snow(
    double Prec,
    double Trs,
    double Tav,
    double *Rainfall,
    double *Snowfall
)
{
    if (Tav >= Trs)
    {
        *Rainfall = Prec;
        *Snowfall = 0.0;
    } else {
        *Snowfall = Prec;
        *Rainfall = 0.0;
    }
}

/**************************
 * variables:
 * int dn               number of day in a year
 * double Tav       	daily average air temperature
 * double Tmax          daily maximum air temperature
 * double Ep            daily potential evapotranspiration
 * double SNO0          snow for the previous step
 * double Tsnow0        snow temperature for the previous step
 * double *SNO          snow after this step
 * double *Tsnow        snow temperature after this step
 * double *SNOmlt       snowmelt for this time step
 * double *Eres         residual evapotranspiration
 * 
 * **********************/

void Model_SNOW(
    int dn,
    double Snowfall,
    double Tav,
    double Tmax,
    double Ep,
    double Tsnow0,
    double SNO0,
    double *Tsnow,
    double *SNO,
    double *SNOmlt,
    double *Eres,
    double SNO50,
    double SNO100,
    double Ls,
    double Bmlt6,
    double Bmlt12,
    double Tmlt)
{
    // if (SNO50 <= 0.0)
    // {
    //     printf("Error: SNO50 cannot be zero.\n");
    //     return -1; // Indicate an error
    // }
    double ratio;
    double cov1, cov2;
    ratio = SNO50 / SNO100;
    // if (ratio <= 0.0)
    // {
    //     printf("Error: SNO50 / SNO100 must be positive.\n");
    //     return -1; // Indicate an error
    // }
    cov2 = log(0.05 / ratio) / (ratio - 0.95);
    cov1 = log(0.05) + 0.95 * cov2;
    
    double sno_cov;
    double Bmlt;
    *SNO = SNO0 + Snowfall;
    if (*SNO >= Ep)
    {
        *SNO = *SNO - Ep;
        *Eres = 0.0;
    }
    else
    {
        *Eres = Ep - *SNO;
        *SNO = 0.0;
    }
    if (*SNO <= 0.0001)
    {
        *SNOmlt = 0.0;
        // *SNO = 0.0;
        *Tsnow = Tav;
    }
    else
    {
        sno_cov = (*SNO / SNO100) / (*SNO / SNO100 + exp(cov1 - cov2 * *SNO / SNO100));
        *Tsnow = Tsnow0 * (1 - Ls) + Tav * Ls;
        Bmlt = (Bmlt6 + Bmlt12) / 2 + (Bmlt6 - Bmlt12) / 2 * sin(2 * PI / 365 * (dn - 81));
        *SNOmlt = Bmlt * sno_cov * (*Tsnow / 2 + Tmax / 2 - Tmlt);
        if (*SNOmlt < 0.001)
        {
            *SNOmlt = 0.0;
        }
        
        *SNO = *SNO - *SNOmlt;
        if (*SNO < 0.001)
        {
            *SNO = 0.0;
            *Tsnow = Tav;
        }
    }
}

