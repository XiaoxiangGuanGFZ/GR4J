

#ifndef SNOW_module
#define SNOW_module

void P_Rain_Snow(
    double Prec,
    double Trs,
    double Tav,
    double *Rainfall,
    double *Snowfall
);

void Model_SNOW(int dn,
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
          double Tmlt);


#endif

