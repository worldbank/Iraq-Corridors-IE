# Extract Road Density

# Load Data --------------------------------------------------------------------
iraq_adm3 <- readRDS(file.path(project_file_path, 
                               "Data", "CSO Subdistricts", "FinalData",  
                               "individual_files","irq_blank.Rds"))

iraq_adm3 <- iraq_adm3 %>% spTransform(CRS(UTM_IRQ))

# Distance to r78am ------------------------------------------------------------
# Load/reproject
r78 <- readRDS(file.path(project_file_path, "Data",
                         "HDX Primary Roads", "FinalData","r7_r8ab",
                         "r7_r8ab_prj_rd.Rds")) 
r78 <- r78 %>% spTransform(CRS(UTM_IRQ))

# Dissolve
r78$id <- 1
r78 <- raster::aggregate(r78, by = "id")

# Calculate distance
iraq_adm3$dist_r78_km <- gDistance(iraq_adm3, r78, byid = T) %>% 
  as.vector() %>%
  `/`(1000) # meters to kilometers

# Export -----------------------------------------------------------------------
saveRDS(iraq_adm3, file.path(project_file_path, 
                                   "Data", "CSO Subdistricts", "FinalData",  
                                   "individual_files","irq_dist_r78_km.Rds"))
