# Iraq IE
# Distance to Cities

# Load Data --------------------------------------------------------------------
# Grid
grid <- readRDS(file.path(project_file_path, "Data", "VIIRS", "FinalData", GRID_SAMPLE, 
                          "Separate Files Per Variable", "iraq_grid_blank.Rds"))
coordinates(grid) <- ~lon+lat
crs(grid) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# Cities
cities_df <- bind_rows(data.frame(lat = 33.333333, lon = 44.383333, name = "Baghdad"),
                       data.frame(lat = 30.5, lon = 47.816667, name = "Basra"))
coordinates(cities_df) <- ~lon+lat
crs(cities_df) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# Project ----------------------------------------------------------------------
grid      <- spTransform(grid,      CRS(UTM_IRQ))
cities_df <- spTransform(cities_df, CRS(UTM_IRQ))

# Distance ---------------------------------------------------------------------
for(i in 1:nrow(cities_df)){
  cities_df_i <- cities_df[i,]
  
  name_i <- cities_df_i$name %>% tolower()
  
  grid[[paste0("dist_",name_i,"_km")]] <- as.vector(gDistance_chunks(grid, cities_df_i, 5000)) / 1000 # to km
}

# Export -----------------------------------------------------------------------
saveRDS(grid@data, file=file.path(project_file_path, "Data", "VIIRS", "FinalData",
                                  GRID_SAMPLE,
                                  "Separate Files Per Variable", "iraq_grid_dist_cities.Rds"))





