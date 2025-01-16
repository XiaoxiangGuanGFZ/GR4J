


#include <math.h>
#include "Func_Metrics.h"

void Metrics(
    double *sim, double *obs, int counts,
    double *nse,
    double *R2,
    double *RMSE,
    double *MSE,
    double *Re
)
{
    *nse = NSE(sim, obs, counts);
    *R2 = R_squared(sim, obs, counts);
    *RMSE = RootMeanSquareError(sim, obs, counts);
    *MSE = MeanSquaredError(sim, obs, counts);
    *Re = RelativeError(sim, obs, counts);
}

double NSE(double *sim, double *obs, int counts) {
    double mean_obs = 0.0;
    double numerator = 0.0;
    double denominator = 0.0;

    // Calculate the mean of observed values
    for (int i = 0; i < counts; i++) {
        mean_obs += obs[i];
    }
    mean_obs /= counts;

    // Calculate numerator and denominator for NSE
    for (int i = 0; i < counts; i++) {
        numerator += pow(obs[i] - sim[i], 2);
        denominator += pow(obs[i] - mean_obs, 2);
    }

    return 1.0 - (numerator / denominator);
}

double RootMeanSquareError(double *sim, double *obs, int counts) {
    double sum_sq_diff = 0.0;

    for (int i = 0; i < counts; i++) {
        sum_sq_diff += pow(sim[i] - obs[i], 2);
    }

    return sqrt(sum_sq_diff / counts);
}


double MeanSquaredError(double *sim, double *obs, int counts) {
    double sum_sq_diff = 0.0;

    for (int i = 0; i < counts; i++) {
        double diff = sim[i] - obs[i];
        sum_sq_diff += diff * diff;
    }

    return sum_sq_diff / counts;
}


double RelativeError(double *sim, double *obs, int counts) {
    double sum_abs_diff = 0.0;
    double sum_abs_obs = 0.0;

    for (int i = 0; i < counts; i++) {
        sum_abs_diff += fabs(sim[i] - obs[i]);
        sum_abs_obs += fabs(obs[i]);
    }

    return sum_abs_diff / sum_abs_obs;
}

double R_squared(double *sim, double *obs, int counts) {
    double mean_sim = 0.0, mean_obs = 0.0;
    double numerator = 0.0;
    double denominator_sim = 0.0;
    double denominator_obs = 0.0;

    // Calculate the means of simulated and observed values
    for (int i = 0; i < counts; i++) {
        mean_sim += sim[i];
        mean_obs += obs[i];
    }
    mean_sim /= counts;
    mean_obs /= counts;

    // Calculate numerator and denominators for R²
    for (int i = 0; i < counts; i++) {
        numerator += (sim[i] - mean_sim) * (obs[i] - mean_obs);
        denominator_sim += pow(sim[i] - mean_sim, 2);
        denominator_obs += pow(obs[i] - mean_obs, 2);
    }

    return pow(numerator / sqrt(denominator_sim * denominator_obs), 2);
}

