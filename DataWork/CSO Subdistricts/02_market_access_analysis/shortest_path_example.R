# Example of Shortest Paths

# Load Data --------------------------------------------------------------------
iraq_adm3 <- readRDS(file.path(project_file_path, "Data", "CSO Subdistricts", 
                               "FinalData", "subdistrict_timeinvariant_data_sp.Rds"))
roads <- readRDS(file.path(project_file_path, "Data", "OpenStreetMap", 
                           "FinalData", "iraq_roads_rds", "gis_osm_roads_free_1_speeds.Rds"))

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

# Figure -----------------------------------------------------------------------
roads_r_spdf <- as(roads_r, "SpatialPixelsDataFrame")
roads_r_df <- as.data.frame(roads_r_spdf)
colnames(roads_r_df) <- c("value", "x", "y")
roads_r_df$value <- factor(roads_r_df$value)
roads_r_df$value[roads_r_df$value %in% 5] <- NA

p_speed <- ggplot() +
  geom_tile(data=roads_r_df, aes(x=x, y=y, fill=value), alpha=1) +
  labs(fill = "Speed\nLimit",
       title = "Speeds on\nGridded Surface") + 
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5)) + 
  coord_quickmap()

path <- shortestPath(cost_t,
                     iraq_adm3_df[iraq_adm3_df$ADM3_EN %in% "Baghdad Al-Jedeeda",],
                     iraq_adm3_df,
                     output = "SpatialLines")
path$id <- 1:length(path)

iraq_adm3_df_coords <- coordinates(iraq_adm3_df) %>%
  as.data.frame()

for(i in 1:nrow(path)){
  
  if(i == 113) next()
  print(i)
  
  path_i <- path[i,]
  iraq_adm3_df_coords_i <- iraq_adm3_df_coords[c(i,113),] # 113 is Baghdad

  p_speed_path <- ggplot() +
    geom_tile(data=roads_r_df, aes(x=x, y=y, fill=value), alpha=1) +
    geom_path(data=path_i, aes(x=long, y=lat, group=group)) +
    geom_point(data=iraq_adm3_df_coords_i, aes(x=long, y=lat)) +
    labs(fill = "Speed\nLimit",
         title = "Shortest Paths from\nBaghdad to All Sub-Districts") + 
    theme_void() +
    theme(plot.title = element_text(hjust = 0.5)) + 
    coord_quickmap()
  
  ggsave(p_speed_path, filename = file.path(project_file_path, "Data", "CSO Subdistricts", 
                                            "Outputs", "figures",
                                            "shortest_path_figures", 
                                            paste0("shortest_path_example_",i,".png")), 
         height = 4, width = 10)
  
}




