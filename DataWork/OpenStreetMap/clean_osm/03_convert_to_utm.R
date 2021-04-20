# Convert Road Network to UTM Projection

# Sometimes we need to use the road network that is projected (not WGS84). It takes
# a long time for code to project the file. Consequently, we project and save
# the file here, to avoid needing to do that in the code later on.

roads <- readRDS(file.path(data_file_path, "OpenStreetMap", "FinalData", "iraq_roads_rds", "gis_osm_roads_free_1_speeds.Rds"))
roads <- spTransform(roads, CRS(UTM_IRQ))
saveRDS(roads, file.path(data_file_path, "OpenStreetMap", "FinalData", "iraq_roads_rds", "gis_osm_roads_free_1_speeds_utm.Rds"))



