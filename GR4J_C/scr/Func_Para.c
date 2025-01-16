#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#include "def_constants.h"
#include "def_structs.h"
#include "Func_Para.h"

int Para_sim_parse(
    char *input,
    ST_PARA_SIM *output
)
{
    // Make a copy of the input string because strtok modifies the string
    char *input_copy = strdup(input);
    if (input_copy == NULL) {
        fprintf(stderr, "Memory allocation failed.\n");
        return -1; // Indicate error
    }

    // Tokenize the string using ";" as the delimiter
    char *token = strtok(input_copy, ";");
    double values[4]; // Array to store the parsed values
    int count = 0;    // Counter for the number of values parsed

    while (token != NULL && count < 4) {
        // Convert the token to a double
        char *endptr;
        values[count] = strtod(token, &endptr);

        // Check if the conversion was successful
        if (*endptr != '\0') {
            fprintf(stderr, "Invalid numeric value: %s\n", token);
            free(input_copy);
            // return -1; // Indicate error
            exit(-1);
        }

        count++;
        token = strtok(NULL, ";"); // Get the next token
    }

    // Free the copied input string
    free(input_copy);

    // Check if exactly 4 values were parsed
    if (count != 4) {
        fprintf(stderr, "Invalid number of values. Expected 4, got %d in %s.\n", count, input);
        exit(-1);
        // return -1; // Indicate error
    }

    // Assign the parsed values to the structure fields
    output->x1 = values[0];
    output->x2 = values[1];
    output->x3 = values[2];
    output->x4 = values[3];

    return 0; // Indicate success
}


int Para_snow_parse(
    char *input,
    ST_PARA_SNOW *output
)
{
    // Make a copy of the input string because strtok modifies the string
    char *input_copy = strdup(input);
    if (input_copy == NULL) {
        fprintf(stderr, "Memory allocation failed.\n");
        return -1; // Indicate error
    }

    // Tokenize the string using ";" as the delimiter
    char *token = strtok(input_copy, ";");
    double values[7]; // Array to store the parsed values
    int count = 0;    // Counter for the number of values parsed

    while (token != NULL && count < 7) {
        // Convert the token to a double
        char *endptr;
        values[count] = strtod(token, &endptr);

        // Check if the conversion was successful
        if (*endptr != '\0') {
            fprintf(stderr, "Invalid numeric value: %s\n", token);
            free(input_copy);
            // return -1; // Indicate error
            exit(-1);
        }

        count++;
        token = strtok(NULL, ";"); // Get the next token
    }

    // Free the copied input string
    free(input_copy);

    // Check if exactly 7 values were parsed
    if (count != 7) {
        fprintf(stderr, "Invalid number of values. Expected 7, got %d in %s.\n", count, input);
        exit(-1);
        // return -1; // Indicate error
    }

    // Assign the parsed values to the structure fields
    output->Trs = values[0];
    output->Tmlt = values[1];
    output->SNO50 = values[2];
    output->SNO100 = values[3];
    output->Ls = values[4];
    output->Bmlt6 = values[5];
    output->Bmlt12 = values[6];
    
    return 0; // Indicate success
}



