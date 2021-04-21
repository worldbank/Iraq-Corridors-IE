#extract distance near zakho road
# Load Data --------------------------------------------------------------------
iraq_adm3 <- readRDS(file.path(project_file_path, 
                               "Data", "CSO Subdistricts", "FinalData",  
                               "individual_files","irq_blank.Rds"))

iraq_adm3 <- iraq_adm3 %>% spTransform(CRS(UTM_IRQ))

# Distance to r78am ------------------------------------------------------------
# Load/reproject
zakho <- readRDS(file.path(project_file_path, "Data",
                        "Project Roads", "Zakho Road", "FinalData",
                        "zakho_road.Rds")) 
zakho <- zakho %>% spTransform(CRS(UTM_IRQ))

# Dissolve
zakho$id <- 1
zakho <- raster::aggregate(zakho, by = "id")

# Calculate distance
iraq_adm3$dist_gs_km <- gDistance(iraq_adm3, gs, byid = T) %>% 
  as.vector() %>%
  `/`(1000) # meters to kilometers

# Export -----------------------------------------------------------------------
saveRDS(iraq_adm3, file.path(project_file_path, 
                             "Data", "CSO Subdistricts", "FinalData",  
                             "individual_files","irq_dist_zakho_km.Rds"))
