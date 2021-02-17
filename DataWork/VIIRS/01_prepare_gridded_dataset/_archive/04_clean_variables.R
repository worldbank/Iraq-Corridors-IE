# Iraq IE
# Distance to Roads

# Load Data --------------------------------------------------------------------
viirs_grid <- readRDS(file.path(project_file_path, "Data", "VIIRS", 
                          "FinalData", "iraq_viirs_grid_data.Rds"))


# Subset the data set ------------------------------------------------------
distance_from_road <- 50 ## subset if distance from project roads is less than or equal to 50 kms
viirs_grid <- viirs_grid[viirs_grid$distance_project_roads <= distance_from_road,]


# Create an ID for month-year ---------------------------------------------
viirs_grid <- viirs_grid[order(year, month),]
viirs_grid <- mutate(viirs_grid, viirs_time_id = paste(month, year, sep = "/"))

# Transformation of viirs_mean --------------------------------------------
viirs_grid$transformed_avg_rad_df <- 
  log(viirs_grid$avg_rad_df +sqrt((viirs_grid$avg_rad_df)^2+1)) # transformation from one paper (IZA)

# Road Improvement --------------------------------------------------------
viirs_grid$road_improvement <- 
  ifelse(viirs_grid$year > 2015, 1,0)

# Export -----------------------------------------------------------------------
saveRDS(viirs_grid, file.path(project_file_path, "Data", "VIIRS", 
                              "FinalData", "iraq_viirs_grid_data_clean_subset.Rds"))





