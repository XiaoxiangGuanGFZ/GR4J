## The GR4J hydrological model

## Introduction

It is a program written in C for hydrological simulation with GR4J model.
It is a conceptual and lumped hydrological model for runoff simulation. 

### file structure

- `scr`: the c source code files and header files, together with a `CMakeLists.txt` file for compiling and building the executable with `CMake` tool.
- `data`: contains example data file `example_data.csv` and program configuration file `gp.txt`
- `doc`: a technical document, where the HBV model structure and parameters are documented.
- `README.md`: what you see right now.

## How-To-Use

### compile 
navigate to `scr` directory in command-line or shell environment, and then call `CMake` tool to compile and build the executable. Use the following commands to compile: 

```sh
cd ./GR4J_C/scr/
mkdir build
cd build
cmake ..
make
```

then in command-line to run the program:

```sh
./GR4J.exe ../../data/gp.txt
```

the configure file `gp.txt` contains some field-value pairs to controls the behaviors of the program.

### program configure file `gp.txt`

The configuration file `gp.txt` gives the key arguments for program running, including the file paths and names to data file and simulation output file, the parameters of GR4J and a snow module, and the simulation length (steps).

see `./data/gp.txt` for an example.

```txt
FP_DATA,D:/GR4J_C/data/example_data.csv
FP_OUT,D:/GR4J_C/data/example_sim.csv

# to switch off snow module, set PARA_SNOW, FALSE
# snow paras (PARA_SNOW): Trs; Tmlt; SNO50; SNO100; Ls; Bmlt6; Bmlt12
PARA_SNOW,-2.839919;-1.18136;0.99998;404.5257;0.999995;0.77293;0.90524

# GR4J paras (PARA_SIM): INSC; COEFF; SMSC; SUB; SQ; SQ; CRAK; Kg
PARA_SIM,650.9238;-3.9193;68.3037;1.15750

# ATTENTION: the parameters values are separated by semicolon (;)

FLAG_OBS,TRUE
FLAG_MUTE,FALSE
CALC_N,13514

```

### data file preparation
For HBV model simulation, the following weather variables are required: air temperature, precipitation and potential evapotranspiration. The observed runoff is optional, which could be placed on the last column and the field `FLAG_OBS` then could be set as `TRUE` in the configure file `gp.txt`. If no observed runoff is available, `FLAG_OBS` must be `FALSE`.

The variables should be put in a comma-delimited text file, and here is an example data file:

```
y,m,d,Prec,Ep,Tavg,Tmax,Runoff
1981,1,1,7.21,0,-3.5,0,1.0502
1981,1,2,15.47,0,-2.1,-0.5,1.0312
1981,1,3,14.18,0.05,1.9,4.1,2.1829
1981,1,4,36.08,0.08,0.5,3.5,8.9265
1981,1,5,13.72,0.49,-3.5,-2.6,4.932
1981,1,6,21.26,0.16,-3.8,-2.3,2.8194
...
```

### program output

the simulated runof, together with some sub-process variables, is returned from the program. See `./data/example_sim.csv` for an example.

The progam log is printed to the screen when `FLAG_MUTE` in `gp.txt` is set as `FALSE`.

If `FLAG_OBS` is `TRUE`, in the end the program will print the calculated Nash–Sutcliffe efficiency coefficient (NSE) in the screen.


## Contact

[Xiaoxiang Guan](guan@gfz-potsdam.de)


