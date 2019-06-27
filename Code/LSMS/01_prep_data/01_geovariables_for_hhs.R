
start.time.script <- Sys.time()

# Load HH Data -----------------------------------------------------------------
iraq.hh <- read.dta13(file.path(raw_data_file_path, "LSMS","IRQ_2012_IHSES_v01_M_Stata8","2012ihses00_cover_page.dta"))
iraq.hh <- subset(iraq.hh, select=c(cluster,hh,q00_18,q00_19))
iraq.hh <- iraq.hh[!is.na(iraq.hh$q00_18),]
iraq.hh <- iraq.hh[!is.na(iraq.hh$q00_19),]
coordinates(iraq.hh) <- ~q00_19+q00_18
crs(iraq.hh) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# Extract ADM Data -------------------------------------------------------------
iraq <- getData('GADM', country='IRQ', level=2)
iraq.hh_OVER_iraq <- over(iraq.hh, iraq)
iraq.hh$NAME_0 <- iraq.hh_OVER_iraq$NAME_0
iraq.hh$NAME_1 <- iraq.hh_OVER_iraq$NAME_1
iraq.hh$NAME_2 <- iraq.hh_OVER_iraq$NAME_2
iraq.hh$ID_0 <- iraq.hh_OVER_iraq$ID_0
iraq.hh$ID_1 <- iraq.hh_OVER_iraq$ID_1
iraq.hh$ID_2 <- iraq.hh_OVER_iraq$ID_2

# Only keep observations in Iraq
iraq.hh <- iraq.hh[!is.na(iraq.hh$ID_0),]

# Extract VIIRS Data -----------------------------------------------------------
viirs.2012 <- raster(file.path(raw_data_file_path,"NTL Rasters Annual Avg","viirs2012.tif"))
viirs.2013 <- raster(file.path(raw_data_file_path,"NTL Rasters Annual Avg","viirs2013.tif"))
viirs.2014 <- raster(file.path(raw_data_file_path,"NTL Rasters Annual Avg","viirs2014.tif"))
viirs.2015 <- raster(file.path(raw_data_file_path,"NTL Rasters Annual Avg","viirs2015.tif"))
viirs.2016 <- raster(file.path(raw_data_file_path,"NTL Rasters Annual Avg","viirs2016.tif"))
viirs.2017 <- raster(file.path(raw_data_file_path,"NTL Rasters Annual Avg","viirs2017.tif"))

iraq.hh$viirs_2012 <- extract(viirs.2012, iraq.hh)
iraq.hh$viirs_2013 <- extract(viirs.2013, iraq.hh)
iraq.hh$viirs_2014 <- extract(viirs.2014, iraq.hh)
iraq.hh$viirs_2015 <- extract(viirs.2015, iraq.hh)
iraq.hh$viirs_2016 <- extract(viirs.2016, iraq.hh)
iraq.hh$viirs_2017 <- extract(viirs.2017, iraq.hh)

# Extract Distance to Road -----------------------------------------------------
project_roads <- st_read(file.path(final_data_file_path, "Project Roads", "project_roads.geojson")) %>% as("Spatial")
project_roads$one <- 1
project_roads <- raster::aggregate(project_roads, by="one")

iraq.hh$distance_project_roads <- gDistance_chunks(iraq.hh, project_roads, 5000, 1) * 111.12

# Export -----------------------------------------------------------------------
iraq.hh_df <- iraq.hh@data
write_dta(iraq.hh_df, file.path(final_data_file_path, "LSMS", "Individual Files", "geodata.dta"))

# Script Time - - - - - - - - - - - - - - -
end.time.script <- Sys.time()
print(end.time.script - start.time.script)

