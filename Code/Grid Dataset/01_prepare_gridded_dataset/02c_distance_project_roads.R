# Iraq IE
# Distance to Roads

# Load Data --------------------------------------------------------------------
# Grid
grid <- readRDS(file.path(final_data_file_path,  "VIIRS Grid","Separate Files Per Variable", "iraq_grid_blank.Rds"))
coordinates(grid) <- ~lon+lat
crs(grid) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# Project Roads
project_roads <- st_read(file.path(final_data_file_path, "Project Roads", "project_roads.geojson")) %>% as("Spatial")
project_roads$one <- 1
project_roads <- raster::aggregate(project_roads, by="one")

# Calculate Distance -----------------------------------------------------------
grid$distance_project_roads <- gDistance_chunks(grid, project_roads, 5000, 1) * 111.12

# Export -----------------------------------------------------------------------
saveRDS(grid@data, file=file.path(final_data_file_path, "VIIRS Grid", "Separate Files Per Variable", "iraq_grid_dist_projectroads.Rds"))





