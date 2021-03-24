#Iraq IE
#Clustering

GRID_PATH <- file.path(data_file_path,"VIIRS","RawData","annual")

# Load Data ---------------------------------------------------------------
grid_2012 <- raster(file.path(GRID_PATH,"irq_viirs_mean_2012.tif"))



# Create Clusters ---------------------------------------------------------
grid_clumps <- clump(grid_2012, directions=8)
grid_poly <- rasterToPolygons(grid_clumps, dissolve=TRUE)
plot(grid_poly, col = seq_along(grid_poly))