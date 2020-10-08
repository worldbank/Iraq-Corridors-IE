# Iraq IE
# Distance to Roads

# Load Data --------------------------------------------------------------------
grid <- readRDS(file.path(project_file_path, "Data", "VIIRS", "FinalData", GRID_SAMPLE, "iraq_viirs_grid_data.Rds"))

# DO STUFF

# Export -----------------------------------------------------------------------
saveRDS(grid, file.path(project_file_path, "Data", "VIIRS", "FinalData", GRID_SAMPLE, "iraq_viirs_grid_data_clean.Rds"))





