# Merge files

INDIV_FILE_PATH <- file.path(project_file_path, 
                             "Data", "CSO Subdistricts", "FinalData",  
                             "individual_files")

## Time invariant data
time_invariant_data_names <- c("irq_adm_info.Rds",
                         "irq_area.Rds",
                         "irq_dist_cities.Rds",
                         "irq_dist_r78_km.Rds",
                         "irq_dist_gs_km.Rds",
                         "irq_market_access.Rds",
                         "irq_population.Rds",
                         "irq_road_length_km.Rds")


# Merge Time Invariant ---------------------------------------------------------
#### Merge Data
data_time_invar_df <- time_invariant_data_names %>%
  lapply(function(name_i){
    
    # Load
    data_i <- readRDS(file.path(INDIV_FILE_PATH, name_i))
    
    # If Spatial Polygon, make df
    if(class(data_i) %in% "SpatialPolygonsDataFrame") data_i <- data_i@data
    
    return(data_i)
  }) %>% 
  reduce(left_join, by = "uid")

#### Merge with SpatialDataFrame
data_time_invar_sdf <- readRDS(file.path(INDIV_FILE_PATH, "irq_blank.Rds"))
data_time_invar_sdf <- merge(data_time_invar_sdf, data_time_invar_df, by = "uid")

#### Export
saveRDS(data_time_invar_sdf, file.path(project_file_path, "Data", "CSO Subdistricts", 
                                       "FinalData", 
                                       "subdistrict_timeinvariant_data_sp.Rds"))

# Merge with VIIRS -------------------------------------------------------------
viirs_df <- readRDS(file.path(INDIV_FILE_PATH, "irq_viirs_monthly.Rds"))
viirs_df <- merge(viirs_df, data_time_invar_df, by = "uid")



#### Export
saveRDS(viirs_df, file.path(project_file_path, "Data", "CSO Subdistricts", 
                            "FinalData", 
                            "subdistrict_data_df.Rds"))


