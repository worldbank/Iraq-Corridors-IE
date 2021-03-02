# Iraq IE
# Distance to Roads

GRID_SAMPLE <- "near_girsheen_suheila_road"
#GRID_SAMPLE <- "near_r78ab_roads"
#GRID_SAMPLE <- "near_zakho_road" #the old road operated before Girsheen - Suheila was constructed


# Load Data --------------------------------------------------------------------
grid <- readRDS(file.path(project_file_path, "Data", "VIIRS", "FinalData", GRID_SAMPLE, "viirs_grid.Rds"))

# Create variables -------------------------------------------------------------
grid$year_month <- paste0(grid$year, "-", grid$month, "-01") %>% 
  ymd() # %>% substring(1,6) ## keep as date variable; less memory intensive than string/factor

# Export -----------------------------------------------------------------------
saveRDS(grid, file.path(project_file_path, "Data", "VIIRS", "FinalData", GRID_SAMPLE, "viirs_grid_clean.Rds"))





