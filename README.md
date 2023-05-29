# GR4J hydrological modelling
## About GR4J Model 
The GR4J model is a catchment water balance model that relates runoff to rainfall and evapotranspiration using daily data. 
The model contains two water stores and has four parameters.

- See `./documents/GR4J模型计算说明.pdf` for detailed model concepts and algorithm.

- Visit the website [GR4J-SRG](https://wiki.ewater.org.au/display/SD41/GR4J+-+SRG#:~:text=The%20GR4J%20model%20is%20a,stores%20and%20has%20four%20parameters.)
for the history and development of the GR4J model.
## About the software (how to use)
### Web-based version
`./scr/app.R` is a Web-based application developed by using R project and [Shiny (version 1.7.4)](https://shiny.posit.co/) package. Several other R packages are required as well. Before launching this web-based application, the required packages should be ready. See the first several commands in app.r for the packages required. This app doesn't have a tutorial here (yet), as the GUI of the app is straightforward and the main functions about this app focus on the GR4J hydrological modelling and parameter optimization.

### Source code version
`./scr/SCEUA-GR4J.R` is here the interactive script for handy alternative to `./scr/app.R`. It is up to you to do some modification or experiments about parameter optimization method (SCE-UA) or GR4J model. 

## Data preparation
GR4J is a daily hydrological model, and the required variables include precipitation (prec) [mm], potential evapotransporation (pet) [mm] and observed streamflow (Qobs) [m3/s] at the **daily** step. The CSV is the suggested format to prepare the input data for both web-based and source-code versions (see data example here `DATA_Area4766_1982-2002.csv`, where 4766 is the area for the exemplary catchment, with the unit of km2). 

Within the data file, there should be 6 columns. The first 3 columns indicate the date (year, month, and day). The last 3 columns are prec, pet, and Qobs respectively. 

## If you want to waste your time
[1]Guan, X.; Zhang, J.; Yang, Q.; Tang, X.; Liu, C.; Jin, J.; Liu, Y.; Bao, Z.; Wang, G. Evaluation of Precipitation Products by Using Multiple Hydrological Models over the Upper Yellow River Basin, China. Remote Sens. 2020, 12, 4023. https://doi.org/10.3390/rs12244023

[2]Guan, X.; Zhang, J.; Elmahdi, A.; Li, X.; Liu, J.; Liu, Y.; Jin, J.; Liu, Y.; Bao, Z.; Liu, C.; He, R.; Wang, G. The Capacity of the Hydrological Modeling for Water Resource Assessment under the Changing Environment in Semi-Arid River Basins in China. Water 2019, 11, 1328. https://doi.org/10.3390/w11071328

## Author
[Xiaoxiang Guan](https://www.gfz-potsdam.de/staff/guan.xiaoxiang/sec44)