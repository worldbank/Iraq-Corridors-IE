# Add Speed Limits to OSM
# Fit with Iraq Case

#### Road Shapefile
roads <- readRDS(file.path(final_data_file_path, "OpenStreetMap", "rds", "gis_osm_roads_free_1.Rds"))

# Add Assumed Speed Limits to Roads --------------------------------------------
# Define speed limits how GOSTNETs defines them.
roads$speed_limit <- NA 
roads$speed_limit[roads$fclass %in% "residential"] <- 20
roads$speed_limit[roads$fclass %in% "primary"] <- 40
roads$speed_limit[roads$fclass %in% "primary_link"] <- 35
roads$speed_limit[roads$fclass %in% "motorway"] <- 50
roads$speed_limit[roads$fclass %in% "motorway_link"] <- 45
roads$speed_limit[roads$fclass %in% "trunk"] <- 40
roads$speed_limit[roads$fclass %in% "trunk_link"] <- 35
roads$speed_limit[roads$fclass %in% "secondary"] <- 30
roads$speed_limit[roads$fclass %in% "secondary_link"] <- 25
roads$speed_limit[roads$fclass %in% "tertiary"] <- 30
roads$speed_limit[roads$fclass %in% "tertiary_link"] <- 25
roads$speed_limit[roads$fclass %in% "unclassified"] <- 20
roads$speed_limit[roads$fclass %in% c("living_street", "service")] <- 20 # not sure about these

roads <- roads[!is.na(roads$speed_limit),]

saveRDS(roads, file.path(final_data_file_path, "OpenStreetMap", "rds", "gis_osm_roads_free_1_speeds.Rds"))
