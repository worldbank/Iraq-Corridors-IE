# Extract Area

# Load Data --------------------------------------------------------------------
iraq_adm3 <- readRDS(file.path(data_file_path,"Clusters","FinalData",  
                               "individual_files","irq_blank.Rds"))

iraq_adm3 <- iraq_adm3 %>% spTransform(CRS(UTM_IRQ))

# Area km^2 --------------------------------------------------------------------
iraq_adm3$area_km2 <- as.vector(gArea(iraq_adm3, byid=T) / 1000^2) 

# Export -----------------------------------------------------------------------
saveRDS(iraq_adm3, file.path(data_file_path,"Clusters","FinalData",  
                             "individual_files","irq_area.Rds"))

