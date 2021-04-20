#Calculate market access
WALKING_SPEED <- 5
RESOLUTION_KM <- 3

# Load Data ---------------------------------------------------------------

iraq_adm3 <- file.path(data_file_path,"Clusters", "FinalData",  
                          "individual_files","irq_blank.Rds")

iraq_pop <- readRDS(file.path(data_file_path,"Clusters", 
                              "FinalData", "individual_files",
                              "irq_population.Rds"))

iraq_road_length <- readRDS(file.path(data_file_path,"Clusters", 
                                      "FinalData", "individual_files",
                                      "irq_road_length_km.Rds"))

iraq_area <- readRDS(file.path(data_file_path,"Clusters", 
                               "FinalData", "individual_files",
                               "irq_area.Rds"))

iraq_adm3 <- merge(iraq_pop, iraq_road_length@data, by = "uid")
iraq_adm3 <- merge(iraq_adm3, iraq_area@data, by = "uid")

####Road Shapefile
roads <- readRDS(file.path(data_file_path, "OpenStreetMap",
                           "FinalData", "iraq_roads_rds", 
                           "gis_osm_roads_free_1_speeds.Rds"))

# Reproject to UTM -------------------------------------------------------------
roads <- spTransform(roads, CRS(UTM_IRQ))
iraq_adm3 <- spTransform(iraq_adm3, CRS(UTM_IRQ))

# Prepare Points File to Calculate Speeds --------------------------------------
iraq_adm3_coords <- coordinates(iraq_adm3) %>%
  as.data.frame() %>%
  dplyr::rename(long = V1,
                lat = V2)
iraq_adm3_df <- bind_cols(iraq_adm3@data, iraq_adm3_coords)
coordinates(iraq_adm3_df) <- ~long+lat
crs(iraq_adm3_df) <- CRS(UTM_IRQ)



# LOOP THROUGH SPEED LIMITS ====================================================
# Loop through different definitons of speed limits
for (speed_limit_var in c("speed_limit", "speed_limit_gs_before", "speed_limit_gs_after")){
  print(paste(speed_limit_var, "============================================="))
  
  # 1. Create Travel Time Matrix -----------------------------------------------
  ## Raster of Road Speeds
  roads_r <- rasterize_roads(road_sdf = roads,
                             speed_var = speed_limit_var,
                             extent_sdf = iraq_adm3,
                             pixel_size_km = RESOLUTION_KM,
                             walking_speed = WALKING_SPEED,
                             pixel_var = "time_to_cross",
                             restrict_to_extent = T)
  
  ## Transition Object
  cost_t <- transition(roads_r, function(x) 1/mean(x), directions=8)
  
  ## Travel Time Matrix
  tt_df <- make_travel_time_matrix(points_sdf = iraq_adm3_df,
                                   uid_name = "uid",
                                   cost_t = cost_t)
  
  # 2. Merge in market variables to travel time matrix -------------------------
  iraq_adm3_data <- iraq_adm3@data %>%
    dplyr::select(uid, population, road_length_km_primary, area_km2) %>%
    dplyr::rename(dest_uid = uid,
                  pop = population,
                  rdlength = road_length_km_primary,
                  area = area_km2)
  
  tt_df <- merge(tt_df, iraq_adm3_data, by = "dest_uid")
  
  ## Remove rows where dest_uid == orig_uid
  tt_df <- tt_df[tt_df$dest_uid != tt_df$orig_uid,]
  
  tt_df$distance_km <- tt_df$distance_meters / 1000
  
  # 3. Calculate market access -------------------------------------------------
  # (1) Loop through different parameters, (2) store dataframes list, (3) merge
  # all dataframes in list together
  ma_df_list <- list()
  
  i <- 1
  for(theta in c(1, 3.8, 8)){
    for(exclude_km in c(0,10, 20, 50, 100)){
      for(market_var in c("pop", "rdlength")){
        for(travel_cost_var in c("travel_time", "distance_km")){
          
          ma_df_i <- calc_ma_from_tt(tt_df           = tt_df,
                                     orig_uid_var    = "orig_uid",
                                     market_var      = market_var,
                                     travel_cost_var = travel_cost_var,
                                     theta           = theta,
                                     exclude_km      = exclude_km)
          ma_df_list[[i]] <- ma_df_i
          i <- i + 1
          
        }
      }
    }
  }
  
  ma_df_all <- ma_df_list %>% reduce(left_join, by = "orig_uid")

  ## Rename variables: (1) uid and (2) MA with speed limit type
  ma_df_all <- ma_df_all %>% 
    dplyr::rename(uid = orig_uid) %>%
    rename_at(vars(-uid), ~ paste0(., paste0('_', speed_limit_var)))
  
  # 4. Export ------------------------------------------------------------------
  saveRDS(ma_df_all, file.path(data_file_path, "Clusters", "FinalData",
                               "individual_files",  
                               paste0("irq_market_access_",speed_limit_var,".Rds")))
}
