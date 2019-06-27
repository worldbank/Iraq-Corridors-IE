# Iraq IE
# Master Rscript

# TODO: This needs to be updated to include other r8 portion

# Load Road Data ---------------------------------------------------------------
# Highways
setwd(file.path(raw_data_file_path, "Roads", "primary_routes", "All"))
primary_routes <- readOGR(dsn=".", layer="primary_routes")
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
r7_projectarea <- raster::aggregate(r7_projectarea, by="route")

# Restrict r8 to project area --------------------------------------------------
r8_projectarea <- primary_routes[primary_routes$ROUTE_NUMB %in% c(31),]
r8_projectarea$route <- "r8"
r8_projectarea <- raster::aggregate(r8_projectarea, by="route")

# Append and Export ------------------------------------------------------------
project_roads <- list(r7_projectarea, r8_projectarea) %>% do.call(what="rbind")
project_roads_sf <- st_as_sf(project_roads)
st_write(project_roads_sf, file.path(final_data_file_path, "Project Roads", "project_roads.geojson"))

