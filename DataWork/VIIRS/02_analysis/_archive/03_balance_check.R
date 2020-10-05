# Iraq IE
# Balance Check to grid level data

# Loading Data set ---------------------------------------------------------
ntl_pixel_random1 <- readRDS(file=file.path(final_data_file_path, "VIIRS", "FinalData", "03_iraq_viirs_random_sample_covar.Rds"))
other_roads <- readRDS(file=file.path(final_data_file_path, "OpenStreetMap", "FinalData", "iraq_roads_rds","gis_osm_roads_free_1.Rds"))

ntl_pixel_random1 <- st_as_sf(ntl_pixel_random1)



# Roads similar to R7/R8 --------------------------------------------------
other_roads <- st_as_sf(other_roads)
other_roads <- other_roads[other_roads$fclass %in% "trunk",]
trunk <- other_roads[other_roads$ref %in% "1",]

remove(other_roads)

##check the transformations by plotting ---!?!FIX ME -- transformations don't align in the map!?!
 ggplot()+
   geom_sf(data = ntl_pixel_random1, color = "grey") +
   geom_sf(data = trunk, size = 1) +
   coord_sf()

##transform to metric coordinate system
trunk_km  <- st_transform(trunk, "+proj=utm +zone=42N +datum=WGS84 +units=km")
ntl_pixel_random1_km <- st_transform(ntl_pixel_random1, "+proj=utm +zone=42N +datum=WGS84 +units=km")  

remove(trunk,ntl_pixel_random1)



# Create Balance Check Data -----------------------------------------------

##Need full dataset here
