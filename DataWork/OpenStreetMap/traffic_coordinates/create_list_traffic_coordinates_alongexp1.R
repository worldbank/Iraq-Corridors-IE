#Iraq IE

#Extract points for traffic analysis


# Load Data --------------------------------------------------------------------
roads <- readRDS(file.path(project_file_path,
                           "Data", "OpenStreetMap", 
                           "FinalData","iraq_roads_rds", 
                           "gis_osm_roads_free_1.Rds"))


# Extract Expressway 1 ----------------------------------------------------
exp1 <- roads[which(roads$fclass == "trunk"),]
exp1 <- roads[which(roads$ref == "1"|roads$ref == "NA"),]


# Convert to Centroids ----------------------------------------------------
#32.1394816,39.824116, 37.1404947,42.5703336
exp1@data <- exp1 %>% 
  gCentroid(byid = T)%>%
  coordinates() %>%
  as.data.frame() %>%
  dplyr::rename(lon_centroid = x, 
                lat_centroid = y) %>%
  bind_cols(exp1@data)



# Trimming the Road -------------------------------------------------------
exp1_sub <- exp1[which(exp1$lon_centroid > 42 & exp1$lon_centroid > 39.8),]

#reorder the coordinates and remove a section
exp1_sub <- exp1_sub[order(exp1_sub$lat_centroid),]
exp1_sub <- exp1_sub[-c(119:250),]


#check
leaflet() %>%
  addTiles() %>%
  addPolylines(data = exp1_sub)


# Creating 30km segments --------------------------------------------------
#re-project to UTM
crs(exp1_sub) <- CRS("+init=epsg:4326")
exp1_sub <- spTransform(exp1_sub, CRS(UTM_IRQ))

#create segments
numOfPoints  <-  gLength(exp1_sub) / 30000
pts <- spsample(exp1_sub, n = numOfPoints, type = "regular")

#re-project back to lat/lon
pts <- spTransform(pts, CRS("+proj=longlat +datum=WGS84"))

#convert to dataframe
pts <- as.data.frame(pts)

#rename columns
names(pts)[names(pts) == 'coords.x1'] <- 'lon'
names(pts)[names(pts) == 'coords.x2'] <- 'lat'






