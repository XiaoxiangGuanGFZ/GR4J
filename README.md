# GR4J hydrological model
## Model introduction
The GR4J model is a catchment water balance model that relates runoff to rainfall and evapotranspiration using daily data. 
The model contains two stores and has four parameters.

See documents/GR4J模型计算说明.pdf for detailed model concept and algorithm.

See the website [GR4J-SRG](https://wiki.ewater.org.au/display/SD41/GR4J+-+SRG#:~:text=The%20GR4J%20model%20is%20a,stores%20and%20has%20four%20parameters.)
for the history and development of the GR4J model.
## Software introducion
It is a Web-based application developed by R project and Shiny package. Naturally, several other R packages are also loaded in the 
software. Before launching the web-based application, the required packages should be ready. See the first several commands in app.r for the 
packages required. 

This app doesn't have a tutorial here (yet), as the GUI of the app is straightforward and the main functions about this app focus
on the hydrological modelling.
## Data preparation
GR4J is a daily hydrological model, and the required variables include precipitation (prec) [mm], potential evapotransporation (pet) [mm] and observed streamflow (Qobs)
[m3/s]. The CSV is the suggested format to store the model data (see example DATA_Area4766_1982-2002.csv). 

Within the data file, there should be 6 columns. The first 3 columns indicate the date (yy, mm, and dd). The last 3 columns are prec, pet, and Qobs respectively. 
## Reference
[1]Edijatno, N. O. Nascimento, X. Yang, Z. Makhlouf, and C. Michel (1999), GR3J: a daily watershed model with three free parameters, Hydrol. Sci. J., 44, 263-277.

[2]Perrin, C., C. Michel, and V. Andréassian (2001), Does a large number of parameters enhance model performance? Comparative assessment of common catchment model structures on 429 catchments, J. Hydrol., 242(3-4), 275-301.

[3]Vaze, J., Chiew, F. H. S., Perraud, JM., Viney, N., Post, D. A., Teng, J., Wang, B., Lerat, J., Goswami, M., 2011. Rainfall-runoff modelling across southeast Australia: datasets, models and results. Australian Journal of Water Resources, Vol 14, No 2, pp. 101-116.

[4]Guan, X.; Zhang, J.; Yang, Q.; Tang, X.; Liu, C.; Jin, J.; Liu, Y.; Bao, Z.; Wang, G. Evaluation of Precipitation Products by Using Multiple Hydrological Models over the Upper Yellow River Basin, China. Remote Sens. 2020, 12, 4023. https://doi.org/10.3390/rs12244023

[5]Guan, X.; Zhang, J.; Elmahdi, A.; Li, X.; Liu, J.; Liu, Y.; Jin, J.; Liu, Y.; Bao, Z.; Liu, C.; He, R.; Wang, G. The Capacity of the Hydrological Modeling for Water Resource Assessment under the Changing Environment in Semi-Arid River Basins in China. Water 2019, 11, 1328. https://doi.org/10.3390/w11071328

## Author
[Xiaoxiang Guan](https://www.gfz-potsdam.de/staff/guan.xiaoxiang/sec44)