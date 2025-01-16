#ifndef FUNC_IO
#define FUNC_IO

extern int flag_obs;

void import_global(char fname[], ST_GP *p_gp);

void removeLeadingSpaces(char *str);

void import_data(
    char FP_DATA[],
    int CALC_N,
    ST_DATE *ts_date,
    ST_VAR_IN *p_vars_in);

int is_leap_year(int year);

int calculate_day_number(
    int y,
    int m,
    int d);

void Write_sim2csv(
    char *FP_OUT,
    ST_DATE *ts_date,
    ST_VAR_IN *p_vars_in,
    ST_VAR_SNOW *p_vars_snow,
    ST_VAR_GR4J *p_vars_sim,
    int CALC_N);


#endif