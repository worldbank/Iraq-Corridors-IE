#extract distance_gs

# Load Data --------------------------------------------------------------------
iraq_adm3 <- readRDS(file.path(project_file_path, 
                               "Data", "CSO Subdistricts", "FinalData",  
                               "individual_files","irq_blank.Rds"))

iraq_adm3 <- iraq_adm3 %>% spTransform(CRS(UTM_IRQ))

# Distance to r78am ------------------------------------------------------------
# Load/reproject
gs <- readRDS(file.path(project_file_path, "Data",
                         "Project Roads", "Girsheen-Suheila Road", "FinalData",
                        "gs_road_polyline.Rds")) 
gs <- gs %>% spTransform(CRS(UTM_IRQ))

# Dissolve
gs$id <- 1
gs <- raster::aggregate(gs, by = "id")

# Calculate distance
iraq_adm3$dist_gs_km <- gDistance(iraq_adm3, gs, byid = T) %>% 
  as.vector() %>%
  `/`(1000) # meters to kilometers

# Export -----------------------------------------------------------------------
saveRDS(iraq_adm3, file.path(project_file_path, 
                             "Data", "CSO Subdistricts", "FinalData",  
                             "individual_files","irq_dist_gs_km.Rds"))
