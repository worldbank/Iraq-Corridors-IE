# Add Speed Limits to OSM
# Fit with Iraq Case

#### Road Shapefile
roads <- readRDS(file.path(data_file_path, "OpenStreetMap", "FinalData", "iraq_roads_rds", "gis_osm_roads_free_1.Rds"))

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

# Speed limits before/after Girsheen road --------------------------------------
roads$girsheen_suheila_rd <- 0
roads$girsheen_suheila_rd[roads$osm_id %in% c(781158362, 
                                              790226269, 
                                              793871886, 
                                              781158363, 
                                              781158364, 
                                              787896734, 
                                              781158361, 
                                              793871885)] <- 1

roads$speed_limit_gs_before <- roads$speed_limit
roads$speed_limit_gs_after <- roads$speed_limit
roads$speed_limit_gs_before[roads$girsheen_suheila_rd == 0] <- 0
roads$speed_limit_gs_after[roads$girsheen_suheila_rd == 1] <- 50

# Export -----------------------------------------------------------------------
saveRDS(roads, file.path(data_file_path, "OpenStreetMap", "FinalData", "iraq_roads_rds", "gis_osm_roads_free_1_speeds.Rds"))




