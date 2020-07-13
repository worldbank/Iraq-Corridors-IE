# Create Spatial File of R7/R8ab Project Roads

# Load Road Data ---------------------------------------------------------------
# Highways
primary_routes <- readOGR(dsn=file.path(project_file_path, "Data", "HDX Primary Roads", "RawData"), 
                          layer="primary_routes")
primary_routes <- primary_routes[primary_routes$ROAD_RUNWA %in% "Hard /Paved",]

# Restrict r7 to project area --------------------------------------------------
r7_northern_point <- data.frame(id = 1,
                                lat = 31.101247,
                                lon = 46.008721)
r7_southern_point <- data.frame(id = 1,
                                lat = 30.409683,
                                lon = 47.520057)

r7 <- primary_routes[primary_routes$ROUTE_NUMB %in% 8,]

r7_centroids <- gCentroid(r7, byid=T) %>% 
  coordinates %>% 
  as.data.frame %>%
  dplyr::rename(long = x) %>%
  dplyr::rename(lat = y)

r7_projectarea <- r7[(r7_centroids$lat < r7_northern_point$lat) & 
                       (r7_centroids$lat > r7_southern_point$lat),]
r7_projectarea$route <- "r7"
r7_projectarea <- raster::aggregate(r7_projectarea %>% gBuffer(width = 0.001/111, 
                                                               byid=T), 
                                    by="route")

# Restrict r8 to project area --------------------------------------------------
r8_projectarea <- primary_routes[primary_routes$ROUTE_NUMB %in% c(31),]
r8_projectarea$route <- "r8"
r8_projectarea <- raster::aggregate(r8_projectarea %>% gBuffer(width = 0.001/111, 
                                                               byid=T), 
                                    by="route")

# Append -----------------------------------------------------------------------
project_roads <- list(r7_projectarea, r8_projectarea) %>% do.call(what="rbind")

# Export -----------------------------------------------------------------------
## rds
saveRDS(project_roads, file.path(project_file_path, 
                                 "Data", "HDX Primary Roads", "FinalData", "r7_r8ab", 
                                 "r7_r8ab_prj_rd.Rds"))

## geojson
project_roads_sf <- st_as_sf(project_roads)
st_write(project_roads_sf, file.path(project_file_path, 
                                     "Data", "HDX Primary Roads", "FinalData", "r7_r8ab", 
                                     "r7_r8ab_prj_rd.geojson"))

