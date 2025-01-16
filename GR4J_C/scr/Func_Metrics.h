#ifndef FUNC_METRIC
#define FUNC_METRIC

void Metrics(
    double *sim, double *obs, int counts,
    double *nse,
    double *R2,
    double *RMSE,
    double *MSE,
    double *Re
);

double NSE(double *sim, double *obs, int counts);

double RootMeanSquareError(double *sim, double *obs, int counts);

double MeanSquaredError(double *sim, double *obs, int counts);

double RelativeError(double *sim, double *obs, int counts);

double R_squared(double *sim, double *obs, int counts);

#endif