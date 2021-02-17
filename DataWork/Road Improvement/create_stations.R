#Iraq IE
#Conversion of Stations to Lat/Long


# Load Data ---------------------------------------------------------------
stations <- read.csv(file.path(project_file_path, 
                               "Data", "Road Improvement", 
                               "All Stations", "stations.csv"))

reports <- read.csv(file.path(project_file_path, 
                              "Project Documents", "DIME Notes from Reports", 
                              "1_road_improvement_data_v1.csv"))

r7r8 <- readRDS(file.path(project_file_path, 
                             "Data", "Project Roads", "R7_R8ab",
                             "FinalData",
                             "r7_r8ab.Rds"))

iraq_adm <- readRDS(file.path(project_file_path, 
                     "Data", "CSO Subdistricts", "FinalData",  
                     "individual_files","irq_adm_info.Rds"))%>% st_as_sf()


# Coordinates to WGS84 ---------------------------------------------------------
coordinates(stations) <- ~lon+lat
proj4string(stations) <- CRS("+proj=utm +zone=38N +datum=WGS84 +units=m +ellps=WGS84") 
stations <- spTransform(stations, CRS("+proj=longlat +datum=WGS84"))
stations <- spTransform(stations,CRS(UTM_IRQ))
stations_sf <- st_as_sf(stations)


# Subset Road & Stations for R7-------------------------------------------------------------
r7 <- r7r8[which(r7r8$road == "r7"),]
r7_stations <- stations_sf[which(stations$road == "r7"),]


# Break r7 stations into two segments -------------------------------------
##Since the station has two origins
r7_stations_1 <- r7_stations[1:20,]
r7_stations_2 <- r7_stations[21:nrow(r7_stations),]


# Measure the distance ----------------------------------------------------
r7 <- spTransform(r7, CRS(UTM_IRQ)) #transform to mercator

#measure length of the road
gLength(r7, byid = FALSE)%>% 
  as.vector() %>%
  `/`(1000) # meters to kilometers

# Create line segments for 1km along r7 -----------------------------------
r7_segments <- spsample(r7, n = 287, type = "regular")
r7_segments_sf <- st_as_sf(r7_segments)

#clipping the line


#plot
ggplot()+
  geom_sf(data = iraq_adm)+
  geom_sf(data = r7_segments_sf)


#Break into two segments

r7_segments_sf_1 <- r7_segments_sf[which(r7_segments_sf$Y < 919637.509132235),]

r7_segments_sf$stationID <- "" # initialize with empty string
r7_segments_sf$stationID[r7_segments_sf$lat > VALUE & r7_segments_sf$lon > VALUE] <- paste0(i:SOMETHINGHERE,"+000")

for (i in 1:nrow(r7_segments_sf)){
  if (r7_segments_sf$geometry == ){
    r7_segments_sf$stationID[i] <- paste0(0,"+000")
  }
  else {
  r7_segments_sf$stationID[i] <- paste0(i,"+000")
}}



# Plot Stations (from project team) ---------------------------------------
ggplot(stations_1, aes(x= lon, y= lat,label=station)) +
  geom_point(size = 2,alpha = 0.6) +
  theme_bw()+
  geom_text(aes(label=station),hjust=1, vjust=2, size = 1.9)
