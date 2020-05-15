# Add Population to Subdistrict Shapefile

WALKING_SPEED <- 5
RESOLUTION_KM <- 3

# Load Data --------------------------------------------------------------------
#### ADM3 Populations
iraq_adm3 <- readRDS(file.path(final_data_file_path, "subdistrict_data", "subdistrict_timeinvariant_data_sp.Rds"))

#### Road Shapefile
roads <- readRDS(file.path(final_data_file_path, "OpenStreetMap", "rds", "gis_osm_roads_free_1_speeds.Rds"))

# Reproject to UTM -------------------------------------------------------------
# We do this now, as opposed to at the beginning of the script, because now the
# roads polyline is smaller

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

# Make Transition Layer --------------------------------------------------------
#### Make blank raster
r <- raster(xmn=iraq_adm3@bbox[1,1], 
            xmx=iraq_adm3@bbox[1,2], 
            ymn=iraq_adm3@bbox[2,1], 
            ymx=iraq_adm3@bbox[2,2], 
            crs=UTM_IRQ, 
            resolution = 3*1000)

#### Sort by Speed
# If multiple polylines interesect with a cell, velox uses the last polygon from
# the spatial polygons dataframe. Consequently, we sort by speeds from slowest to
# fastest so that velox uses the fastest speed.
roads <- roads[order(roads$speed_limit),] 

#### Rasterize Speeds
roads_r <- r
roads_r[] <- 0
roads_r_vx <- velox(roads_r)
roads_r_vx$rasterize(roads, field="speed_limit", background=WALKING_SPEED) # background should be walking speed (5km/hr); https://en.wikipedia.org/wiki/Preferred_walking_speed
roads_r <- roads_r_vx$as.RasterLayer()

#### Make Transition Layer
cost_t <- transition(roads_r, function(x) sum(x), directions=8)
cost_t <- geoCorrection(cost_t, type="c")

# Calculate Travel Times -------------------------------------------------------
tt_df <- lapply(1:nrow(iraq_adm3_df), function(i){
  if((i %% 10) == 0) print(i)
  
  tt <- costDistance(cost_t,
                     iraq_adm3_df[i,],
                     iraq_adm3_df) %>% as.numeric()
  
  tt <- tt * RESOLUTION_KM # to get more accurate travel time???? TODO
  
  df_out <- data.frame(dest_uid = iraq_adm3_df$uid,
                       travel_time = tt)
  df_out$distance_meters <- gDistance(iraq_adm3_df[i,], iraq_adm3_df, byid = T) %>% as.numeric()
  
  df_out$orig_uid <- iraq_adm3_df$uid[i]
  return(df_out)
}) %>% bind_rows()

# Calcualte Market Access ------------------------------------------------------
# Calculate market access using travel time, linear distance. Use all locations
# and exclude locations within 100 kilometers.

#### Merge in Population
iraq_adm3_data <- iraq_adm3@data %>%
  dplyr::select(uid, population, road_length_km_primary, area_km2) %>%
  dplyr::rename(dest_uid = uid,
                dest_population = population,
                dest_road_length_km_primary = road_length_km_primary,
                area_km2 = area_km2)

tt_df <- merge(tt_df, iraq_adm3_data, by = "dest_uid")

#### Remove rows where dest_uid == orig_uid
tt_df <- tt_df[tt_df$dest_uid != tt_df$orig_uid,]

#### Calculate Market Access
MA_df <- tt_df %>% 
  group_by(orig_uid) %>%
  summarise(
    MA_tt_theta1  = sum(dest_population / (travel_time^1)),
    MA_tt_theta3_8  = sum(dest_population / (travel_time^3.8)),
    MA_tt_theta5  = sum(dest_population / (travel_time^5)),
    MA_tt_theta10 = sum(dest_population / (travel_time^10)),
    MA_tt_theta15 = sum(dest_population / (travel_time^15)),
    MA_tt_theta20 = sum(dest_population / (travel_time^20)),
    
    MA_dist_theta1  = sum(dest_population / (distance_meters^1)),
    MA_dist_theta3_8  = sum(dest_population / (distance_meters^3.8)),
    MA_dist_theta5  = sum(dest_population / (distance_meters^5)),
    MA_dist_theta10 = sum(dest_population / (distance_meters^10)),
    MA_dist_theta15 = sum(dest_population / (distance_meters^15)),
    MA_dist_theta20 = sum(dest_population / (distance_meters^20)),
    
    MA_rdlength_theta1  = sum(dest_road_length_km_primary / (distance_meters^1)),
    MA_rdlength_theta3_8  = sum(dest_road_length_km_primary / (distance_meters^3.8)),
    MA_rdlength_theta5  = sum(dest_road_length_km_primary / (distance_meters^5)),
    MA_rdlength_theta10 = sum(dest_road_length_km_primary / (distance_meters^10)),
    MA_rdlength_theta15 = sum(dest_road_length_km_primary / (distance_meters^15)),
    MA_rdlength_theta20 = sum(dest_road_length_km_primary / (distance_meters^20))
  )

#### Calculate Market Access - Excluding observations within 100 kilometers
MA_exclude10km_df <- tt_df[tt_df$distance_meters > 10*1000,] %>% 
  group_by(orig_uid) %>%
  summarise(
    MA_tt_theta1_exclude10km  = sum(dest_population / (travel_time^1)),
    MA_tt_theta3_8_exclude10km  = sum(dest_population / (travel_time^3.8)),
    MA_tt_theta5_exclude10km  = sum(dest_population / (travel_time^5)),
    MA_tt_theta10_exclude10km = sum(dest_population / (travel_time^10)),
    MA_tt_theta15_exclude10km = sum(dest_population / (travel_time^15)),
    MA_tt_theta20_exclude10km = sum(dest_population / (travel_time^20)),
    
    MA_dist_theta1_exclude10km  = sum(dest_population / (distance_meters^1)),
    MA_dist_theta3_8_exclude10km  = sum(dest_population / (distance_meters^3.8)),
    MA_dist_theta5_exclude10km  = sum(dest_population / (distance_meters^5)),
    MA_dist_theta10_exclude10km = sum(dest_population / (distance_meters^10)),
    MA_dist_theta15_exclude10km = sum(dest_population / (distance_meters^15)),
    MA_dist_theta20_exclude10km = sum(dest_population / (distance_meters^20)),
    
    MA_rdlength_theta1_exclude10km  = sum(dest_road_length_km_primary / (distance_meters^1)),
    MA_rdlength_theta3_8_exclude10km  = sum(dest_road_length_km_primary / (distance_meters^3.8)),
    MA_rdlength_theta5_exclude10km  = sum(dest_road_length_km_primary / (distance_meters^5)),
    MA_rdlength_theta10_exclude10km = sum(dest_road_length_km_primary / (distance_meters^10)),
    MA_rdlength_theta15_exclude10km = sum(dest_road_length_km_primary / (distance_meters^15)),
    MA_rdlength_theta20_exclude10km = sum(dest_road_length_km_primary / (distance_meters^20))
  )

#### Calculate Market Access - Excluding observations within 100 kilometers
MA_exclude100km_df <- tt_df[tt_df$distance_meters > 100*1000,] %>% 
  group_by(orig_uid) %>%
  summarise(MA_tt_theta1_exclude100km  = sum(dest_population / (travel_time^1)),
            MA_tt_theta3_8_exclude100km  = sum(dest_population / (travel_time^3.8)),
            MA_tt_theta5_exclude100km  = sum(dest_population / (travel_time^5)),
            MA_tt_theta10_exclude100km = sum(dest_population / (travel_time^10)),
            MA_tt_theta15_exclude100km = sum(dest_population / (travel_time^15)),
            MA_tt_theta20_exclude100km = sum(dest_population / (travel_time^20)),
            
            MA_dist_theta1_exclude100km  = sum(dest_population / (distance_meters^1)),
            MA_dist_theta3_8_exclude100km  = sum(dest_population / (distance_meters^3.8)),
            MA_dist_theta5_exclude100km  = sum(dest_population / (distance_meters^5)),
            MA_dist_theta10_exclude100km = sum(dest_population / (distance_meters^10)),
            MA_dist_theta15_exclude100km = sum(dest_population / (distance_meters^15)),
            MA_dist_theta20_exclude100km = sum(dest_population / (distance_meters^20)),
            
            MA_rdlength_theta1_exclude100km  = sum(dest_road_length_km_primary / (distance_meters^1)),
            MA_rdlength_theta3_8_exclude100km  = sum(dest_road_length_km_primary / (distance_meters^3.8)),
            MA_rdlength_theta5_exclude100km  = sum(dest_road_length_km_primary / (distance_meters^5)),
            MA_rdlength_theta10_exclude100km = sum(dest_road_length_km_primary / (distance_meters^10)),
            MA_rdlength_theta15_exclude100km = sum(dest_road_length_km_primary / (distance_meters^15)),
            MA_rdlength_theta20_exclude100km = sum(dest_road_length_km_primary / (distance_meters^20))
            )


MA_df <- merge(MA_df, MA_exclude10km_df, by = "orig_uid", all = T)
MA_df <- merge(MA_df, MA_exclude100km_df, by = "orig_uid", all = T)

# Export -----------------------------------------------------------------------
# Merge back with data
MA_df <- MA_df %>% 
  dplyr::rename(uid = orig_uid)
iraq_adm3 <- merge(iraq_adm3, MA_df, by="uid")
iraq_adm3 <- spTransform(iraq_adm3, CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))

saveRDS(iraq_adm3, file.path(final_data_file_path, "subdistrict_data", "subdistrict_population_marketaccess.Rds"))

