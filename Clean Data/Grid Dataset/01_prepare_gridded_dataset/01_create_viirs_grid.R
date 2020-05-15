# Iraq IE
# Create VIIRS Grid 

# Load Data --------------------------------------------------------------------
#### GADM
setwd(file.path(raw_data_file_path, "GADM"))
iraq <- getData("GADM", country = "IRQ", level = 0)

#### Roads
setwd(file.path(raw_data_file_path, "Roads", "primary_routes", "All"))
primary_routes <- readOGR(dsn=".", layer="primary_routes")
primary_routes <- primary_routes[primary_routes$ROAD_RUNWA == "Hard /Paved",]

#### VIIRS
viirs_avg_rad <- stack(file.path(raw_data_file_path, "viirs_monthly", "iraq_viirs_raw_monthly_start_201204_avg_rad.tif"))
viirs_cf_cvg <- stack(file.path(raw_data_file_path,  "viirs_monthly", "iraq_viirs_raw_monthly_start_201204_cf_cvg.tif"))

num_bands <- dim(viirs_avg_rad)[3]

# Prep Shapefiles that Limit Cells in Analysis ---------------------------------
#### Road Area
iraq_highways <- primary_routes[primary_routes$ROUTE_NUMB %in% 1:12,]
iraq_highways$in_road_buffer <- 1

iraq_highways_buff <- raster::aggregate(iraq_highways, by = "in_road_buffer")
iraq_highways_buff <- gBuffer(iraq_highways_buff, width=30/111.12)
iraq_highways_buff$in_road_buffer <- 1

#### Country
iraq$in_country <- 1
iraq <- subset(iraq, select=c(in_country))

# Determine which cells are in Analysis ----------------------------------------
#### Determine Cell in Analysis
raster_temp <- raster(file.path(raw_data_file_path, "viirs_monthly", "iraq_viirs_raw_monthly_start_201204_avg_rad.tif"), band=1)
raster_temp_coords <- coordinates(raster_temp) %>% as.data.frame
coordinates(raster_temp_coords) <- ~x+y
raster_temp_coords$id <- 1:length(raster_temp_coords)
crs(raster_temp_coords) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

raster_OVER_country <- over_chunks(raster_temp_coords, iraq, "sum", 11000)
raster_OVER_roads <- over_chunks(raster_temp_coords, iraq_highways_buff, "sum", 11000)

cell_in_analysis <- (raster_OVER_roads$in_road_buffer %in% 1) & (raster_OVER_country$in_country %in% 1)

# Coordinates ------------------------------------------------------------------
viirs_coords_in_iraq <- raster_temp_coords[cell_in_analysis,] %>% coordinates %>% as.data.frame
names(viirs_coords_in_iraq) <- c("lon","lat")

viirs_coords_in_iraq$id <- 1:nrow(viirs_coords_in_iraq)

num_obs_per_band <- nrow(viirs_coords_in_iraq)

# Extract Values to Dataframe --------------------------------------------------
extract_raster_value_in_country <- function(band_num, raster_file_path, cell_in_analysis, var_name){
  r <- raster(raster_file_path, band=band_num)
  r_values <- r[]
  r_values <- r_values[cell_in_analysis]
  #df_out <- as.data.frame(r_values)
  #names(df_out) <- var_name
  #df_out$id <- 1:nrow(df_out)
  #df_out$band_num <- band_num
  return(r_values)
}

avg_rad_df <- pbmclapply(1:num_bands, extract_raster_value_in_country, 
                         file.path(raw_data_file_path, "viirs_monthly", "iraq_viirs_raw_monthly_start_201204_avg_rad.tif"), 
                         cell_in_analysis, "viirs_rad", mc.cores=1) %>% unlist

cf_cvg_df <- pbmclapply(1:num_bands, extract_raster_value_in_country, 
                        file.path(raw_data_file_path, "viirs_monthly", "iraq_viirs_raw_monthly_start_201204_cf_cvg.tif"), 
                        cell_in_analysis, "viirs_cf_cvg", mc.cores=1) %>% unlist

id <- rep(1:num_obs_per_band, num_bands)
band <- rep(1:num_bands, each=num_obs_per_band)

iraq_grid_viirs <- data.frame(avg_rad_df=avg_rad_df, 
                              cf_cvg_df=cf_cvg_df, 
                              id=id, 
                              band=band)
iraq_grid_viirs <- merge(iraq_grid_viirs, viirs_coords_in_iraq, by="id")

# Month, Year ------------------------------------------------------------------
iraq_grid_viirs$month <- NA
iraq_grid_viirs$year <- NA

month <- 4
year <- 2012
for(band_num in 1:max(iraq_grid_viirs$band)){
  print(band_num)
  iraq_grid_viirs$month[iraq_grid_viirs$band %in% band_num] <- month
  iraq_grid_viirs$year[iraq_grid_viirs$band %in% band_num] <- year
  
  month <- month + 1
  if(month == 13){
    month <- 1
    year <- year + 1
  }
}

# Export -----------------------------------------------------------------------

# 1. Panel with VIIRS
iraq_grid_viirs_nolatlon <- subset(iraq_grid_viirs, select=-c(lat,lon,band))
saveRDS(iraq_grid_viirs_nolatlon, file=file.path(final_data_file_path, "VIIRS Grid","Separate Files Per Variable", "iraq_grid_panel_viirs.Rds"))
rm(iraq_grid_viirs_nolatlon)

# 2. Blank Panel
iraq_grid_viirs_blankpanel <- subset(iraq_grid_viirs, select=c(id,month,year, lat, lon))
saveRDS(iraq_grid_viirs_blankpanel, file=file.path(final_data_file_path,  "VIIRS Grid","Separate Files Per Variable", "iraq_grid_panel_blank.Rds"))
rm(iraq_grid_viirs_blankpanel)

# 3. Blank Cross Section
iraq_grid_viirs_blank <- iraq_grid_viirs[iraq_grid_viirs$band %in% 1,]
iraq_grid_viirs_blank <- subset(iraq_grid_viirs_blank, select=c(id, lat, lon))
saveRDS(iraq_grid_viirs_blank, file=file.path(final_data_file_path, "VIIRS Grid","Separate Files Per Variable", "iraq_grid_blank.Rds"))
rm(iraq_grid_viirs_blank)



