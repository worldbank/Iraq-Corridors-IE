# Extract Area

# Load Data --------------------------------------------------------------------
iraq_adm3 <- readRDS(file.path(data_file_path, "Clusters", "FinalData",  
                               "individual_files","irq_blank.Rds"))

# Extract VIIRS ----------------------------------------------------------------
viirs_all <- raster(file.path(project_file_path, "Data", "VIIRS", "RawData", "monthly", 
                              "iraq_viirs_raw_monthly_start_201204_avg_rad.tif"))


viirs_stacked_df <- lapply(1:93, function(i){
  
  print(i)
  
  viirs <- raster(file.path(project_file_path, "Data", "VIIRS", "RawData", "monthly", 
                            "iraq_viirs_raw_monthly_start_201204_avg_rad.tif"), i) %>% velox()
  
  viirs_mean <- viirs$extract(sp = iraq_adm3, fun=function(x) mean(x, na.rm=T))
  
  viirs_df <- data.frame(viirs_mean = viirs_mean,
                        uid = iraq_adm3$uid,
                         viirs_time_id = i)
  
  return(viirs_df)
}) %>% bind_rows()

#### Add year / month
year <- 2012
month <- 4
viirs_stacked_df$year <- NA
viirs_stacked_df$month <- NA
for(i in unique(viirs_stacked_df$viirs_time_id)){
  
  viirs_stacked_df$year[viirs_stacked_df$viirs_time_id %in% i]  <- year 
  viirs_stacked_df$month[viirs_stacked_df$viirs_time_id %in% i] <- month 
  
  month <- month + 1
  
  if(month == 13){
    month <- 1
    year <- year + 1
  }
}

#### Add Data
iraq_adm3_df <- merge(iraq_adm3@data, viirs_stacked_df, by = "uid")


# Export -----------------------------------------------------------------------
saveRDS(iraq_adm3_df, file.path(data_file_path,"Clusters","FinalData",  
                                "individual_files",
                                "irq_viirs_monthly.Rds"))
