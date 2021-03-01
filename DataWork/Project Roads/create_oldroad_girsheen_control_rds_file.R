#Iraq IE
# Create Spatial File of Old Girsheen-Suheila Project Road


# Loading Data ------------------------------------------------------------
roads <- readRDS(file.path(project_file_path, "Data", "Project Roads", "Control_Roads",
                           "FinalData","highway2.Rds"))

# Subset Roads -----------------------------------------------------------------
#36.3755205,42.6536686

roads <- roads[which(roads$lat_centroid >36.84 & roads$lon_centroid < 42.95),]


#check
leaflet() %>%
  addTiles() %>%
  addPolylines(data = roads, color = "blue")


# Clean -------------------------------------------------------------------

roads@data <- roads@data %>%
  dplyr::select(lat_centroid, lon_centroid,osm_id, fclass) %>%
  mutate(source = "OpenStreetMap")
# Export -----------------------------------------------------------------------
## rds
saveRDS(roads, file.path(project_file_path, 
                             "Data", "Project Roads", "Girsheen-Suheila Road",
                             "FinalData",
                             "oldroad_girsheen.Rds"))

## geojson
roads_sf<- st_as_sf(roads)
st_write(roads_sf, file.path(project_file_path, 
                                 "Data", "Project Roads", "Girsheen-Suheila Road",
                                 "FinalData",
                                 "oldroad_girsheen.geojson"),
         delete_dsn = T)


