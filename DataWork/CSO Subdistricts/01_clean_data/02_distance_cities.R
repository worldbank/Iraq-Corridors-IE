# Extract Road Density

# Load Data --------------------------------------------------------------------
iraq_adm3 <- readRDS(file.path(project_file_path, 
                               "Data", "CSO Subdistricts", "FinalData",  
                               "individual_files","irq_blank.Rds"))

iraq_adm3 <- iraq_adm3 %>% spTransform(CRS(UTM_IRQ))

# Distance to Cities -----------------------------------------------------------
baghdad <- data.frame(name = "baghdad",
                      lat = 33.3152, 
                      lon = 44.3661)

coordinates(baghdad) <- ~lon+lat
crs(baghdad) <- CRS("+init=epsg:4326")
baghdad <- spTransform(baghdad, CRS(UTM_IRQ))

iraq_adm3$distance_to_baghdad <- gDistance(iraq_adm3, baghdad, byid = T) %>% 
  as.vector() %>%
  `/`(1000) # meters to kilometers

# Export -----------------------------------------------------------------------
saveRDS(iraq_adm3, file.path(project_file_path, 
                                   "Data", "CSO Subdistricts", "FinalData",  
                                   "individual_files","irq_dist_cities.Rds"))
