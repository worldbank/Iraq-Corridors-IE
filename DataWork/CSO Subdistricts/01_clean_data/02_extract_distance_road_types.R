# Extract Road Density

# Load Data --------------------------------------------------------------------
iraq_adm3 <- readRDS(file.path(project_file_path, 
                               "Data", "CSO Subdistricts", "FinalData",  
                               "individual_files","irq_blank.Rds"))

iraq_adm3 <- iraq_adm3 %>% spTransform(CRS(UTM_IRQ))

# Extract Data -----------------------------------------------------------------
roads <- readRDS(file.path(project_file_path, "Data", "OpenStreetMap", "FinalData", 
                           "iraq_roads_rds", "gis_osm_roads_free_1_speeds.Rds"))
roads <- spTransform(roads, CRS(UTM_IRQ))
roads$id <- 1

## Subset and dissolve
# Dissolving helps with efficienty of distance calculation. Aggregate only works 
# on polygons, so buffer by 1 meter before dissolving
roads_primary   <- roads[grepl("primary", roads$fclass),]   %>% 
  gBuffer(width = 1, byid = T) %>%
  raster::aggregate(by = "id")

roads_secondary <- roads[grepl("secondary", roads$fclass),]   %>% 
  gBuffer(width = 1, byid = T) %>%
  raster::aggregate(by = "id")

roads_motorway  <- roads[grepl("motorway", roads$fclass),]   %>% 
  gBuffer(width = 1, byid = T) %>%
  raster::aggregate(by = "id")

roads_trunk     <- roads[grepl("trunk", roads$fclass),]   %>% 
  gBuffer(width = 1, byid = T) %>%
  raster::aggregate(by = "id")

## Distance
iraq_adm3$dist_roads_primary_km <- gDistance(iraq_adm3, roads_primary, byid = T) %>%
  as.vector() %>%
  `/`(1000) # meters to kilometers

iraq_adm3$dist_roads_secondary_km <- gDistance(iraq_adm3, roads_secondary, byid = T) %>%
  as.vector() %>%
  `/`(1000) # meters to kilometers

iraq_adm3$dist_roads_motorway_km <- gDistance(iraq_adm3, roads_motorway, byid = T) %>%
  as.vector() %>%
  `/`(1000) # meters to kilometers

iraq_adm3$dist_roads_trunk_km <- gDistance(iraq_adm3, roads_trunk, byid = T) %>%
  as.vector() %>%
  `/`(1000) # meters to kilometers

# Export -----------------------------------------------------------------------
saveRDS(iraq_adm3, file.path(project_file_path, 
                                   "Data", "CSO Subdistricts", "FinalData",  
                                   "individual_files","irq_dist_road_type.Rds"))
