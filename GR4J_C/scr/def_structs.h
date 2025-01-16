#ifndef structs
#define structs


typedef struct
{
    /* data */
    char FP_DATA[300];
    char FP_OUT[300];
    char PARA_SNOW[1000];
    char PARA_SIM[1000];
    char FLAG_OBS[10];
    char FLAG_MUTE[10];
    int CALC_N;

} ST_GP;

typedef struct
{
    double Prec;  // precipitation, mm
    double Tair;  // daily average air temperature
    double Tmax;  // daily maximum air temperature
    double Epot;  // potential evapotranspiration, mm 
    double Qobs;  // observated streamflow, mm
} ST_VAR_IN;


typedef struct 
{
    double Pn;
    double Ps;
    double Pr;
    double En;
    double Es;
    double S;
    double R;
    double Q1;
    double Q9;
    double Qr;
    double Qd;
    double Q;
} ST_VAR_GR4J;


typedef struct 
{
    double Rainfall;
    double Snowfall;
    double SNO;
    double Tsnow;
    double SNOmlt;
    double Eres;
} ST_VAR_SNOW;


typedef struct 
{
    double Kg;
    double x1;
    double x2;
    double x3;
    double x4;
} ST_PARA_SIM;


typedef struct 
{
    double Trs;
    double Tmlt;
    double SNO50;
    double SNO100;
    double Ls;
    double Bmlt6;
    double Bmlt12;
} ST_PARA_SNOW;


typedef struct
{
    int y;
    int m;
    int d;
    int dn; // number of the day in a year
} ST_DATE;



#endif


