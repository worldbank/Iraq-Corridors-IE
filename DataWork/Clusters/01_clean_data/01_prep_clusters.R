#Prep Base Shapefile

# Load ADM Data ----------------------------------------------------------------

iraq_adm3 <- readRDS(file.path(data_file_path,"Globcover","FinalData","polygons.Rds"))
iraq_adm3$uid <- 1:nrow(iraq_adm3)

#### Blank
iraq_adm3_blank <- iraq_adm3
iraq_adm3_blank@data <- iraq_adm3_blank@data %>%
  dplyr::select(uid)

# Export -----------------------------------------------------------------------
saveRDS(iraq_adm3_blank, file.path(data_file_path,"Clusters", "FinalData",  
                                   "individual_files","irq_blank.Rds"))

saveRDS(iraq_adm3, file.path(data_file_path,"Clusters", "FinalData",  
                                "individual_files","irq_cluster_info.Rds"))




