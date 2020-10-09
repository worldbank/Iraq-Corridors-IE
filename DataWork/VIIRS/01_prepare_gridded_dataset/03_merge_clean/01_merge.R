# Iraq IE
# Distance to Roads

IN_PATH <- file.path(project_file_path, "Data", "VIIRS", "FinalData",
                     GRID_SAMPLE,
                     "Separate Files Per Variable")

# Load Data --------------------------------------------------------------------
panel_viirs <- readRDS(file.path(IN_PATH, "iraq_grid_panel_viirs.Rds")) %>% as.data.table

# Merge Cross Section Data -----------------------------------------------------
cross_section_data_names <- c("iraq_grid_dist_osm_roads.Rds",
                              "iraq_grid_dist_projectroads.Rds",
                              "iraq_grid_gadm.Rds")

for(data_name_i in cross_section_data_names){
  print(data_name_i)
  
  data_i <- readRDS(file.path(IN_PATH, data_name_i)) %>% as.data.table
  panel_viirs <- merge(panel_viirs, data_i, by="id")
  
  # Cleanup as memory intensive
  rm(data_i)
  gc()
  
}

# Merge Paenl Data -------------------------------------------------------------
panel_data_names <- c("iraq_grid_panel_ndvi.Rds")

for(data_name_i in panel_data_names){
  print(data_name_i)
  
  data_i <- readRDS(file.path(IN_PATH, data_name_i)) %>% as.data.table
  panel_viirs <- merge(panel_viirs, data_i, by=c("id", "month", "year"), all.x=T, all.y=F)
  
  # Cleanup as memory intensive
  rm(data_i)
  gc()
  
}

# Export -----------------------------------------------------------------------
saveRDS(panel_viirs, file.path(project_file_path, "Data", "VIIRS", "FinalData", GRID_SAMPLE,
                              "viirs_grid.Rds"))





