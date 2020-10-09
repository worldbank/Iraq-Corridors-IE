# Iraq IE
# Extract GADM

# Load Data --------------------------------------------------------------------
# Grid
grid <- readRDS(file.path(project_file_path, "Data", "VIIRS", "FinalData",
                          GRID_SAMPLE,
                          "Separate Files Per Variable", "iraq_grid_blank.Rds"))
coordinates(grid) <- ~lon+lat
crs(grid) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# Iraq GADM
iraq_adm2 <- readRDS(file.path(project_file_path, "Data", "GADM", "RawData", "gadm36_IRQ_2_sp.rds"))

# Prep GADM --------------------------------------------------------------------
# Make IDs numeric, as uses less memory
iraq_adm2$GID_1 <- iraq_adm2$GID_1 %>% as.factor() %>% as.numeric()
iraq_adm2$GID_2 <- iraq_adm2$GID_2 %>% as.factor() %>% as.numeric()

# Extract Data -----------------------------------------------------------------
grid_OVER_iraq_adm2 <- over(grid, iraq_adm2)
grid$GADM_ID_1 <- grid_OVER_iraq_adm2$GID_1
grid$GADM_ID_2 <- grid_OVER_iraq_adm2$GID_2

# Export -----------------------------------------------------------------------
saveRDS(grid@data, file=file.path(project_file_path, "Data", "VIIRS", "FinalData",
                                  GRID_SAMPLE,
                                  "Separate Files Per Variable", "iraq_grid_gadm.Rds"))

