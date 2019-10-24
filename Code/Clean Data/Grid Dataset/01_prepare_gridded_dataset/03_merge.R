# Iraq IE
# Distance to Roads

# Load Data --------------------------------------------------------------------
panel_viirs <- readRDS(file.path(final_data_file_path, "VIIRS Grid","Separate Files Per Variable", "iraq_grid_panel_viirs.Rds")) %>% as.data.table

# Merge ------------------------------------------------------------------------
gadm <- readRDS(file.path(final_data_file_path, "VIIRS Grid", "Separate Files Per Variable", "iraq_grid_gadm.Rds")) %>% as.data.table
viirs_grid <- merge(panel_viirs, gadm, by="id")
rm(panel_viirs)
rm(gadm)
gc()

dist_primaryroads <- readRDS(file.path(final_data_file_path, "VIIRS Grid", "Separate Files Per Variable", "iraq_grid_dist_primaryroads.Rds")) %>% as.data.table
viirs_grid <- merge(viirs_grid, dist_primaryroads, by="id")
rm(dist_primaryroads)
gc()

dist_project_roads <- readRDS(file.path(final_data_file_path, "VIIRS Grid", "Separate Files Per Variable", "iraq_grid_dist_projectroads.Rds")) %>% as.data.table
viirs_grid <- merge(viirs_grid, dist_project_roads, by="id")
rm(dist_project_roads)
gc()

# Export -----------------------------------------------------------------------
saveRDS(viirs_grid, file=file.path(final_data_file_path, "VIIRS Grid", "iraq_viirs_grid_data.Rds"))
write.csv(viirs_grid, file=file.path(final_data_file_path, "VIIRS Grid", "iraq_viirs_grid_data.csv"), row.names=F)
write.csv(viirs_grid[viirs_grid$year %in% 2012,], file=file.path(final_data_file_path, "VIIRS Grid", "iraq_viirs_grid_data_2012.csv"), row.names=F)





