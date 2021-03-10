#Iraq IE
#Create Project Road - Highway 3 - connects to Turkey


# Loading Data ------------------------------------------------------------
roads <- readRDS(file.path(project_file_path,
                           "Data", "OpenStreetMap", 
                           "FinalData","iraq_roads_rds", 
                           "gis_osm_roads_free_1.Rds"))

roads <- roads[which(roads$fclass == "trunk" & roads$ref != "D430" & roads$ref != "TC2" & 
                       roads$ref != "715" & roads$ref != "DE150" & roads$ref != "2"),]


# Subset Highway  --------------------------------------------------------
roads@data <- roads %>% 
  gCentroid(byid = T)%>%
  coordinates() %>%
  as.data.frame() %>%
  dplyr::rename(lon_centroid = x, 
                lat_centroid = y) %>%
  bind_cols(roads@data)

# Baghdad - Kirkuk - Irbil - Dohuk - Zakhu

roads <- roads[which(roads$lat_centroid > 34 & roads$lat_centroid < 37.2),]
roads <- roads[which(roads$lon_centroid > 42.4 & roads$lon_centroid < 43.94),]



#check road
leaflet() %>% 
  addTiles() %>% 
  addPolylines(data = roads)


# Clean  ------------------------------------------------------------------
roads@data <- roads@data %>%
  dplyr::select("lon_centroid","lat_centroid","osm_id","fclass") %>%
  mutate(source = "OpenStreetMap")

# Export -----------------------------------------------------------------------
# rds
saveRDS(roads, file.path(project_file_path,"Data", "Project Roads", "Control_Roads",
                         "FinalData","highway2.Rds"))



# Plot Roads --------------------------------------------------------------

highway1 <- readRDS(file.path(project_file_path, "Data", "Project Roads",
                              "Control_Roads", "FinalData", "highway1.Rds"))


highway3 <- readRDS(file.path(project_file_path, "Data", "Project Roads",
                              "Control_Roads", "FinalData", "highway3.Rds"))

#check road
leaflet() %>% 
  addTiles() %>% 
  addPolylines(data = highway3)
