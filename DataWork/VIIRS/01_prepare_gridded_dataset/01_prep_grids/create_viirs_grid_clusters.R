#Iraq IE
#Clustering

GRID_PATH <- file.path(data_file_path,"VIIRS","RawData","annual")

# Load Data ---------------------------------------------------------------
grid_2012 <- raster(file.path(GRID_PATH,"irq_viirs_mean_2012.tif"))
grid_2013 <- raster(file.path(GRID_PATH,"irq_viirs_mean_2013.tif"))
grid_2014 <- raster(file.path(GRID_PATH,"irq_viirs_mean_2014.tif"))
grid_2015 <- raster(file.path(GRID_PATH,"irq_viirs_mean_2015.tif"))
grid_2016 <- raster(file.path(GRID_PATH,"irq_viirs_mean_2016.tif"))
grid_2017 <- raster(file.path(GRID_PATH,"irq_viirs_mean_2017.tif"))
grid_2018 <- raster(file.path(GRID_PATH,"irq_viirs_mean_2018.tif"))
grid_2019 <- raster(file.path(GRID_PATH,"irq_viirs_mean_2019.tif"))
grid_2020 <- raster(file.path(GRID_PATH,"irq_viirs_mean_2020.tif"))


iraq_adm <- readRDS(file.path(data_file_path, "CSO Subdistricts", "FinalData",  
                              "individual_files","irq_adm_info.Rds"))%>% st_as_sf()
# Convert values to 0 -----------------------------------------------------
grid_2012[][grid_2012[] < 1] <- 0
grid_2013[][grid_2013[] < 1] <- 0
grid_2014[][grid_2014[] < 1] <- 0
grid_2015[][grid_2015[] < 1] <- 0
grid_2016[][grid_2016[] < 1] <- 0
grid_2017[][grid_2017[] < 1] <- 0
grid_2018[][grid_2018[] < 1] <- 0
grid_2019[][grid_2019[] < 1] <- 0
grid_2020[][grid_2020[] < 1] <- 0


# Combine datasets --------------------------------------------------------
grid_2020 <- grid_2020
grid_2020[] <- as.numeric(grid_2012[] >= 1 | grid_2013[] >= 1| grid_2014[] >= 1 |
                          grid_2015[] >= 1 | grid_2016[] >= 1| grid_2017[] >= 1 |
                          grid_2018[] >= 1 | grid_2019[] >= 1| grid_2020[] >= 1)

grid_2020 <- clump(grid_2020, directions=8) #create 

hist(grid_2020)
plot(grid_2020) #plot


# Polygonize Clusters -----------------------------------------------------
grid_poly <- rasterToPolygons(grid_2020, 
                              na.rm=TRUE, 
                              digits=12, 
                              dissolve=F)



     