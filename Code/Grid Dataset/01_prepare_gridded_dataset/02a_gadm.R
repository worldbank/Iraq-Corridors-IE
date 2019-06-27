# Iraq IE
# Distance to Roads

# Load Data --------------------------------------------------------------------
# Grid
grid <- readRDS(file.path(final_data_file_path,  "VIIRS Grid","Separate Files Per Variable", "iraq_grid_blank.Rds"))
coordinates(grid) <- ~lon+lat
crs(grid) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# Iraq GADM
setwd(file.path(raw_data_file_path, "GADM"))
iraq_adm3 <- getData('GADM', country='IRQ', level=2)

# Extract Data -----------------------------------------------------------------
grid_OVER_iraq_adm3 <- over(grid, iraq_adm3)
grid$GADM_ID_0 <- grid$ID_0
grid$GADM_ID_1 <- grid$ID_1
grid$GADM_ID_2 <- grid$ID_2

# Export -----------------------------------------------------------------------
saveRDS(grid@data, file=file.path(final_data_file_path, "VIIRS Grid", "Separate Files Per Variable", "iraq_grid_gadm.Rds"))


