# Create Spatial File of R7/R8ab Project Roads

# Load Data --------------------------------------------------------------------
roads <- readRDS(file.path(project_file_path,
                           "Data", "OpenStreetMap", 
                           "FinalData","iraq_roads_rds", 
                           "gis_osm_roads_free_1.Rds"))

stations <- read.csv(file.path(project_file_path, "Data", "Road Improvement", 
                               "All Stations", "stations.csv"))

# Subset Roads -----------------------------------------------------------------

## Subset and add centroid
# Roads are motorways - subset not to make adding centroids quicker
roads <- roads[roads$ref %in% c("1", "31"),]
roads@data <- roads %>% 
  gCentroid(byid = T) %>% 
  coordinates() %>%
  as.data.frame() %>%
  dplyr::rename(lon_centroid = x, 
                lat_centroid = y) %>%
  bind_cols(roads@data)

## Break roads into route 1 and 31, and stations along each
roads_ref_1 <- roads[roads$ref %in% "1",]
roads_ref_31 <- roads[roads$ref %in% "31",]

stations_1 <- stations[stations$road %in% c("r7", "r8b"),]
stations_31 <- stations[stations$road %in% c("r8a"),]

# r7 and r8b -------------------------------------------------------------------
## Project Road portion or route 1
roads_ref_1_prj <- roads_ref_1[roads_ref_1$lat_centroid >= min(stations_1$lat) &
                                 roads_ref_1$lat_centroid <= max(stations_1$lat),]

## Split by r7/r8
lat_station_end <- stations_1$lat[stations_1$station %in% "0+400"]

split_extent_r7 <- extent(roads_ref_1_prj)
split_extent_r8b <- extent(roads_ref_1_prj)

split_extent_r7@ymin <- lat_station_end
split_extent_r8b@ymax <- lat_station_end

split_extent_r7 <- as(split_extent_r7, 'SpatialPolygons')  
split_extent_r8b <- as(split_extent_r8b, 'SpatialPolygons')  

split_extent_r7$id <- 1
split_extent_r8b$id <- 1

r7 <- raster::intersect(roads_ref_1_prj, split_extent_r7)
r8b <- raster::intersect(roads_ref_1_prj, split_extent_r8b)

# r8a --------------------------------------------------------------------------
# Just need to restrict to motorway, then lines up
r8a <- roads_ref_31[roads_ref_31$fclass %in% "motorway",]
r8a$id <- 1 # temp variable so variables same for all roads

# Clean and append -------------------------------------------------------------
r7$road <- "r7"
r8b$road <- "r8b"
r8a$road <- "r8a"

prj_roads <- list(r7, r8a, r8b) %>% 
  do.call(what = "rbind")

prj_roads@data <- prj_roads@data %>%
  dplyr::select(road, osm_id, fclass) %>%
  mutate(source = "OpenStreetMap")


# Export -----------------------------------------------------------------------
## rds
saveRDS(prj_roads, file.path(project_file_path, 
                             "Data", "Project Roads", "R7_R8ab",
                             "FinalData",
                             "r7_r8ab.Rds"))

## geojson
prj_roads_sf <- st_as_sf(prj_roads)
st_write(prj_roads_sf, file.path(project_file_path, 
                                 "Data", "Project Roads", "R7_R8ab",
                                 "FinalData",
                                 "r7_r8ab.geojson"),
         delete_dsn = T)


#### CHECK =====================================================================
leaflet() %>%
  addTiles() %>%
  addPolylines(data = prj_roads[prj_roads$road %in% "r7",], color = "blue") %>%
  addCircles(data = stations[stations$road %in% "r7",], color = "yellow")

leaflet() %>%
  addTiles() %>%
  addPolylines(data = prj_roads[prj_roads$road %in% "r8a",], color = "blue") %>%
  addCircles(data = stations[stations$road %in% "r8a",], color = "yellow")

leaflet() %>%
  addTiles() %>%
  addPolylines(data = prj_roads[prj_roads$road %in% "r8b",], color = "blue") %>%
  addCircles(data = stations[stations$road %in% "r8b",], color = "yellow")


