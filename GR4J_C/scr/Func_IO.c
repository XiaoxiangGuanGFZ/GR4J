#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "def_constants.h"
#include "def_structs.h"
#include "Func_IO.h"


void import_global(
    char fname[], ST_GP *p_gp)
{
    /**************
     * import the global parameters
     *
     * -- Parameters:
     *      fname: a string (1-D character array), file path and name of the global parameters
     * -- Output:
     *      return a structure containing the key fields
     * ********************/

    char row[MAXCHAR];
    FILE *fp;
    char *token;
    char *token2;
    int i;

    if ((fp = fopen(fname, "r")) == NULL)
    {
        printf("cannot open global parameter file: %s\n", fname);
        exit(1);
    }
    while (fgets(row, MAXCHAR, fp) != NULL)
    {
        // the fgets() function comes from <stdbool.h>
        // Reads characters from stream and stores them as a C string

        /***
         * removeLeadingSpaces():
         * remove all the leading white spaces in the string if exist,
         * otherwise do nothing!
         */
        removeLeadingSpaces(row);

        if (row != NULL && strlen(row) > 1)
        {
            /*non-empty row(string)*/
            if (row[0] != '#')
            {
                /* the first character of row should not be # */
                for (i = 0; i < strlen(row); i++)
                {
                    /* remove (or hide) all the characters after # */
                    if (row[i] == '#')
                    {
                        row[i] = '\0';
                        break;
                    }
                }
                // puts(row);
                /*assign the values to the parameter structure: key-value pairs*/
                token = strtok(row, ",");       // the first column: key
                token2 = strtok(NULL, ",\r\n"); // the second column: value
                // printf("token: %s\n", token);
                /********
                 * file paths and file names
                 * *****/
                if (strncmp(token, "FP_DATA", 7) == 0)
                {
                    strcpy(p_gp->FP_DATA, token2);
                }
                else if (strncmp(token, "FP_OUT", 6) == 0)
                {
                    strcpy(p_gp->FP_OUT, token2);
                }
                else if (strncmp(token, "PARA_SNOW", 9) == 0)
                {
                    strcpy(p_gp->PARA_SNOW, token2);
                }
                else if (strncmp(token, "PARA_SIM", 8) == 0)
                {
                    strcpy(p_gp->PARA_SIM, token2);
                }
                else if (strncmp(token, "CALC_N", 5) == 0)
                {
                    p_gp->CALC_N = atoi(token2);
                }
                else if (strncmp(token, "FLAG_OBS", 8) == 0)
                {
                    strcpy(p_gp->FLAG_OBS, token2);
                }
                else if (strncmp(token, "FLAG_MUTE", 9) == 0)
                {
                    strcpy(p_gp->FLAG_MUTE, token2);
                }
                else
                {
                    printf("Error in opening global parameter file: unrecognized parameter field: %s\n", token);
                    exit(1);
                }
            }
        }
    }
    fclose(fp);
}

void removeLeadingSpaces(char *str)
{
    if (str != NULL)
    {
        int i, j = 0;
        int len = strlen(str);
        // Find the first non-space character
        for (i = 0; i < len && isspace(str[i]); i++)
        {
            // Do nothing, just iterate until the first non-space character is found
        }
        // Shift the string to remove leading spaces
        for (; i < len; i++)
        {
            str[j++] = str[i];
        }
        // Null-terminate the modified string
        str[j] = '\0';
    }
}


void import_data(
    char FP_DATA[],
    int CALC_N,
    ST_DATE *ts_date,
    ST_VAR_IN *p_vars_in)
{
    FILE *fp;
    if ((fp = fopen(FP_DATA, "r")) == NULL)
    {
        printf("Cannot open data file: %s\n", FP_DATA);
        exit(1);
    }
    char *token;
    char row[MAXCHAR];
    char row_first[MAXCHAR];
    int i = 0; // record the number of rows in the data file
    fgets(row_first, MAXCHAR, fp); // skip the first row
    // printf("%s\n", row_first);
    while (fgets(row, MAXCHAR, fp) != NULL && i < CALC_N)
    {
        (ts_date + i)->y = atoi(strtok(row, ",")); 
        (ts_date + i)->m = atoi(strtok(NULL, ","));
        (ts_date + i)->d = atoi(strtok(NULL, ","));
        (p_vars_in + i)->Prec = atof(strtok(NULL, ","));
        (p_vars_in + i)->Epot = atof(strtok(NULL, ","));
        (p_vars_in + i)->Tair = atof(strtok(NULL, ","));
        (p_vars_in + i)->Tmax = atof(strtok(NULL, ","));
        if (flag_obs == 1)
        {
            (p_vars_in + i)->Qobs = atof(strtok(NULL, ","));
        }
        i++;
    }
    fclose(fp);
    if (i > CALC_N)
    {
        printf("conflict numbers of lines in data file: %s\n", FP_DATA);
        exit(1);
    }
}

// Function to check if a year is a leap year
int is_leap_year(int year)
{
    int an = 0;
    if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0))
    {
        an = 1;
    }
    return (an);
}

// Function to calculate the day number in the year
int calculate_day_number(
    int y,
    int m,
    int d)
{
    int dn;
    // Array to store the number of days in each month
    int days_in_month[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    // Adjust February for leap years
    if (is_leap_year(y) == 1)
    {
        days_in_month[1] = 29; // February has 29 days in a leap year
    }
    // Calculate the day number
    dn = 0;
    for (int i = 0; i < m - 1; i++)
    {
        dn += days_in_month[i]; // Add days of previous months
    }
    dn += d; // Add the day of the month
    return (dn);
}


void Write_sim2csv(
    char *FP_OUT,
    ST_DATE *ts_date,
    ST_VAR_IN *p_vars_in,
    ST_VAR_SNOW *p_vars_snow,
    ST_VAR_GR4J *p_vars_sim,
    int CALC_N)
{
    FILE *pf_out;
    if ((pf_out = fopen(FP_OUT, "w")) == NULL)
    {
        printf("Failed to create / open output file: %s\n", FP_OUT);
        exit(1);
    }

    fprintf(pf_out, "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s",
            "y", "m", "d", 
            "Rainfall", "Snowfall", "SNO", "SNOmlt", "Tsnow", "Pn", "Ps", 
            "Pr", "En",
            "Es", "S", "R",
            "Q1", "Q9", "Qr", "Qd", "Qsim"
            );
    if (flag_obs == 1)
    {
        fprintf(pf_out, ",%s\n", "Qobs");
    } else {
        fprintf(pf_out, "\n");
    }
    
    for (size_t i = 0; i < CALC_N; i++)
    {
        fprintf(pf_out, "%d,%d,%d,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f",
                (ts_date + i)->y, (ts_date + i)->m, (ts_date + i)->d,
                (p_vars_snow + i)->Rainfall,
                (p_vars_snow + i)->Snowfall,
                (p_vars_snow + i)->SNO,
                (p_vars_snow + i)->SNOmlt,
                (p_vars_snow + i)->Tsnow,
                (p_vars_sim + i)->Pn,
                (p_vars_sim + i)->Ps,
                (p_vars_sim + i)->Pr,
                (p_vars_sim + i)->En,
                (p_vars_sim + i)->Es,
                (p_vars_sim + i)->S,
                (p_vars_sim + i)->R,
                (p_vars_sim + i)->Q1,
                (p_vars_sim + i)->Q9,
                (p_vars_sim + i)->Qr,
                (p_vars_sim + i)->Qd,
                (p_vars_sim + i)->Q
                );
        if (flag_obs == 1)
        {
            fprintf(pf_out, ",%.2f\n", (p_vars_in + i)->Qobs);
        } else {
            fprintf(pf_out, "\n");
        }
    }
    fclose(pf_out);
}


