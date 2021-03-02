#Iraq IE
# Create Spatial File of Zakho Road -- Road used before Girsheen Suheila opened to the public


# Loading Data ------------------------------------------------------------
roads <- readRDS(file.path(project_file_path,
                           "Data", "OpenStreetMap", 
                           "FinalData","iraq_roads_rds", 
                           "gis_osm_roads_free_1.Rds"))

roads <- roads[which(roads$fclass == "trunk" & roads$ref!= "DZ430"),]

# Convert to Centroids ----------------------------------------------------
roads@data <- roads %>% 
  gCentroid(byid = T)%>%
  coordinates() %>%
  as.data.frame() %>%
  dplyr::rename(lon_centroid = x, 
                lat_centroid = y) %>%
  bind_cols(roads@data)


roads$ref
# Subset Roads -----------------------------------------------------------------
#36.9944909,42.4674732,   37.138915,42.6726253   36.993133,42.6393873,
roads <- roads[which(roads$lat_centroid >37.02 & roads$lon_centroid > 42.5),]


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
                             "Data", "Project Roads", "Zakho Road",
                             "FinalData",
                             "zakho_road.Rds"))

## geojson
roads_sf<- st_as_sf(roads)
st_write(roads_sf, file.path(project_file_path, 
                                 "Data", "Project Roads", "Zakho Road",
                                 "FinalData",
                                 "zakho_road.geojson"),
         delete_dsn = T)


