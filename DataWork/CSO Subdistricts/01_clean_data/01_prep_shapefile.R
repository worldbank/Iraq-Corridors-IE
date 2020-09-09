# Prep Base Shapefile

# Load ADM Data ----------------------------------------------------------------
iraq_adm3 <- readOGR(dsn = file.path(project_file_path, "Data", "CSO Subdistricts", "RawData"),
                     layer = "irq_admbnda_adm3_cso_20190603")
iraq_adm3$uid <- 1:nrow(iraq_adm3)

#### Blank
iraq_adm3_blank <- iraq_adm3
iraq_adm3_blank@data <- iraq_adm3_blank@data %>%
  dplyr::select(uid)

# Export -----------------------------------------------------------------------
saveRDS(iraq_adm3_blank, file.path(project_file_path, 
                             "Data", "CSO Subdistricts", "FinalData",  
                            "individual_files","irq_blank.Rds"))

saveRDS(iraq_adm3, file.path(project_file_path, 
                                   "Data", "CSO Subdistricts", "FinalData",  
                                   "individual_files","irq_adm_info.Rds"))




