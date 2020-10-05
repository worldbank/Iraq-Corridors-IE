# Iraq IE
# Distance to Roads

# Load Data --------------------------------------------------------------------
# Grid
grid <- readRDS(file.path(project_file_path, 
                          "Data", "VIIRS", "FinalData",
                          "Separate Files Per Variable", "iraq_grid_blank.Rds"))
coordinates(grid) <- ~lon+lat
crs(grid) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# Project Roads
project_roads <- readRDS(file.path(project_file_path, 
                                   "Data", "Project Roads","R7_R8ab", 
                                   "FinalData","r7_r8ab.Rds")) 
project_roads$one <- 1
project_roads <- raster::aggregate(project_roads, by="one")

# Reproject --------------------------------------------------------------------
grid          <- spTransform(grid,          CRS(UTM_IRQ))
project_roads <- spTransform(project_roads, CRS(UTM_IRQ))

# Calculate Distance -----------------------------------------------------------
grid$distance_project_roads <- gDistance_chunks(grid, project_roads, 5000, 1) / 1000 # convert from meters to km

# Export -----------------------------------------------------------------------
saveRDS(grid@data, file=file.path(project_file_path, "Data", "VIIRS", "FinalData",
                                  "Separate Files Per Variable", "iraq_grid_dist_projectroads.Rds"))





