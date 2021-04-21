#station to lat/lon


# Load Data ---------------------------------------------------------------
stations <- read.csv(file.path(data_file_path,"Road Improvement", "All Stations",
                               "stations.csv"))

r7r8 <- readRDS(file.path(data_file_path,"Project Roads", "R7_R8ab", 
                          "FinalData","r7_r8ab.RDS"))

#split into two roads
r7 <- r7r8[r7r8$road == "r7",]
r8 <- r7r8[r7r8$road != "r7",]

#transform projection
r7 <- spTransform(r7,CRS(UTM_IRQ))
r8 <- spTransform(r8,CRS(UTM_IRQ))


# #1. Divide Project Road in 10m segments ---------------------------------
##check length of r7
gLength(r7,byid = F)
gLength(r8,byid = F)

## r7 = 286976.5m, r8 = 223419.5m
r7_segment <- spsample(x = r7, n = 28697, type = "regular")
r8_segment <- spsample(x = r8, n = 22342, type = "regular")

#convert utm to lat/lon
r7_segment <- spTransform(r7_segment,CRS("+proj=longlat +datum=WGS84"))
r8_segment <- spTransform(r8_segment,CRS("+proj=longlat +datum=WGS84"))

##convert to dataframe
r7_segment_df <- as.data.frame(r7_segment)
colnames(r7_segment_df)[1] <- "Longitude"
colnames(r7_segment_df)[2] <- "Latitude"

r8_segment_df <- as.data.frame(r8_segment)
colnames(r8_segment_df)[1] <- "Longitude"
colnames(r8_segment_df)[2] <- "Latitude"


# Label the stations ------------------------------------------------------
##r7
stations_labels_r7 <- seq(from = 0, to = 286950, by = 10)
r7_segment_df$dist_to_origin_kms <- (stations_labels_r7/1000)

##r8
stations_labels_r8ab <- seq(from = 0, to = 223400, by = 10)
r8_segment_df$dist_to_origin_kms <- (stations_labels_r8ab/1000)

# Convert stations to distances -------------------------------------------
wordstoremove <- c("-C", "-L","R","-R","L","\\(|T1\\)")
stations1 <- as.data.frame(sapply(stations, function(x) 
  gsub(paste0(wordstoremove, collapse = '|'), '', x, ignore.case = T)))

##convert to km
stations1$dist_to_origin_kms <- round_any(as.numeric(gsub("+",".",stations1$station, fixed = T)),.100)

##rename roads
stations1$road <- ifelse(stations1$road %in% c('7'), "r7", stations1$road)
stations1$road <- ifelse(stations1$road %in% c('8a'), "r8a", stations1$road)
stations1$road <- ifelse(stations1$road %in% c('8b'), "r8b", stations1$road)

##separate station dataframes
stations1_r7 <- stations1[stations1$road == "r7",]
stations1_r8 <- stations1[stations1$road == "r8a"|stations1$road == "r8b",]

# Merging Dataframes ------------------------------------------------------
merged <- merge(r7_segment_df,stations1_r7, by = c("dist_to_origin_kms"))


# Plot --------------------------------------------------------------------
r7r8_sf <- st_as_sf(r7r8)
height = 7
width = 8
ggplot()+
  geom_sf(data = r7r8_sf, color = "black")+
  geom_point(aes(x = 46.43817, y = 30.68142,color = "OSM(400m from Origin)"))+
  geom_point(aes(x = 46.0387271629726, y = 30.9657403844468, color = "Project Team (400m from Origin)"))+
  labs(x = "",
       y = "",
       color = "source",
       title = "Points 400m from Origin (OSM & Project Team Data")+
  theme_minimal()+
  ggsave(file.path(project_file_path, "Data", "Road Improvement", 
                           "diff_dist_from_origin.png"), 
                 height=height, width=width)


#convert r78 to points
r7r8@data <- r7r8 %>% 
  gCentroid(byid = T) %>% 
  coordinates() %>%
  as.data.frame() %>%
  dplyr::rename(lon_centroid = x, 
                lat_centroid = y) %>%
  bind_cols(r7r8@data)

pts_r7r8 <- st_as_sf(r7r8)


ggplot()+
  geom_sf(data = r7r8_sf, color = "black")+
  geom_point(aes(x =pts_r7r8$lon_centroid[1] , y = pts_r7r8$lat_centroid[1], color ="osm_start_point"))+
  geom_point(aes(x =pts_r7r8$lon_centroid[64] , y = pts_r7r8$lat_centroid[64],color = "osm_end_point"))+
  labs(x = "",
       y = "",
       color = "source",
       title = "Differences between OSM and Station List")+
  theme_minimal()+
 ggsave(file.path(project_file_path, "Data", "Road Improvement", 
                   "difference_in_sources.png"), 
         height=height, width=width)
