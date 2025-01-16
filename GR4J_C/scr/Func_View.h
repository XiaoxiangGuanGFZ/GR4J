#ifndef VIEW_module
#define VIEW_module

extern int flag_obs;

void Preview_GP(
    ST_GP *p_gp
);

void Preview_data(
    int num_view,
    int CALC_N,
    ST_DATE *ts_date,
    ST_VAR_IN *p_vars_in
);


void Preview_Para_sim(
    ST_PARA_SIM Para_sim
);


void Preview_Para_snow(
    ST_PARA_SNOW Para_snow
);


#endif
