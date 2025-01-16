#ifndef GR4J_module
#define GR4J_module


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
);

void Model_Routing(
    ST_VAR_GR4J *p_var_sim,
    int CALC_N,
    double *UH1,
    double *UH2,
    int UH1_len,
    int UH2_len,
    double x2,
    double x3
);


#endif

