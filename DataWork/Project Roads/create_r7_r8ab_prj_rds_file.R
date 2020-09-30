# Create Spatial File of R7/R8ab Project Roads

# CHECKS ---------
roads <- readRDS(file.path(project_file_path,
                                 "Data", "OpenStreetMap", 
                                 "FinalData","iraq_roads_rds", 
                           "gis_osm_roads_free_1.Rds"))

coords <- read_delim(file.path(project_file_path,
                               "Data","Road Improvement","R7","R7-stations.txt"),
                     "\t", escape_double = FALSE, trim_ws = TRUE, skip = 2)

# Rename Variables --------------------------------------------------------
coords <- coords %>%
  dplyr::rename("lon" = "Easting (m)",
                "lat" = "Northing (m)")


names(coords)[names(coords) == "Easting (m)"] <- "lon"
names(coords)[names(coords) == "Northing (m)"] <- "lat"
names(coords)[names(coords) == "R7-Project Station"] <- "station"

coordinates(coords) <- ~lon+lat
proj4string(coords) <- CRS("+proj=utm +zone=38N +datum=WGS84 +units=m +ellps=WGS84") 
coords <- spTransform(coords,CRS("+proj=longlat +datum=WGS84"))


roads <- roads[grepl("trunk|motorway|primary", roads$fclass), ]
roads$name <- roads$name %>% as.character()
roads$ref <- roads$ref %>% as.character()

roads <- roads[roads$ref %in% "1",]

leaflet() %>%
  addTiles() %>%
  addPolylines(data = roads, popup = ~ref) %>%
  addCircles(data = coords, color = "red") 


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

