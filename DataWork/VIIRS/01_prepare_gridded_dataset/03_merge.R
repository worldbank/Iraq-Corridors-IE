# Iraq IE
# Distance to Roads

# Load Data --------------------------------------------------------------------
panel_viirs <- readRDS(file.path(project_file_path, "Data", "VIIRS", "FinalData",
                                 "Separate Files Per Variable", 
                                 "iraq_grid_panel_viirs.Rds")) %>% as.data.table

# Merge ------------------------------------------------------------------------
gadm <- readRDS(file.path(project_file_path, "Data", "VIIRS", "FinalData",
                          "Separate Files Per Variable", 
                          "iraq_grid_gadm.Rds")) %>% as.data.table
viirs_grid <- merge(panel_viirs, gadm, by="id")
rm(panel_viirs)
rm(gadm)
gc()

dist_primaryroads <- readRDS(file.path(project_file_path, "Data", "VIIRS", "FinalData",
                                       "Separate Files Per Variable", 
                                       "iraq_grid_dist_primaryroads.Rds")) %>% as.data.table
viirs_grid <- merge(viirs_grid, dist_primaryroads, by="id")
rm(dist_primaryroads)
gc()

dist_project_roads <- readRDS(file.path(project_file_path, "Data", "VIIRS", "FinalData",
                                        "Separate Files Per Variable", 
                                        "iraq_grid_dist_projectroads.Rds")) %>% as.data.table
viirs_grid <- merge(viirs_grid, dist_project_roads, by="id")
rm(dist_project_roads)
gc()

# Export -----------------------------------------------------------------------
saveRDS(viirs_grid, file.path(project_file_path, "Data", "VIIRS", "FinalData", "iraq_viirs_grid_data.Rds"))





