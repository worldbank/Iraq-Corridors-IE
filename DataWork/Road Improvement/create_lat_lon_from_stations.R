#station to lat/lon


# Load Data ---------------------------------------------------------------
stations <- read.csv(file.path(data_file_path,"Road Improvement", "All Stations",
                               "stations.csv"))

r7r8 <- readRDS(file.path(data_file_path,"Project Roads", "R7_R8ab", 
                          "FinalData","r7_r8ab.Rds"))




# 1. Split into separate roads --------------------------------------------
r7 <- r7r8[r7r8$road == "r7",]
r8a <- r7r8[r7r8$road == "r8a",]
r8b <- r7r8[r7r8$road == "r8b",]
r8b <- subset(r8b, osm_id!= 754433876) #since there is an overlap between the shapefiles


# 2. Convert spdf into points ---------------------------------------------
##r7
r7@data <- r7 %>%
  gCentroid(byid = T) %>%
  coordinates() %>%
  as.data.frame() %>%
  dplyr::rename(lon_centroid = x,
                lat_centroid = y) %>%
  bind_cols(r7@data)

##r8a
r8a@data <- r8a %>%
  gCentroid(byid = T) %>%
  coordinates() %>%
  as.data.frame() %>%
  dplyr::rename(lon_centroid = x,
                lat_centroid = y) %>%
  bind_cols(r8a@data)

##r8b
r8b@data <- r8b %>%
  gCentroid(byid = T) %>%
  coordinates() %>%
  as.data.frame() %>%
  dplyr::rename(lon_centroid = x,
                lat_centroid = y) %>%
  bind_cols(r8b@data)


  # Order the polylines -----------------------------------------------------
r7 <- osrmRoute(c(46.017104,31.084715),c(47.163739 ,30.565979), sp = TRUE)
r8a <- osrmRoute(c(47.46856,30.46906),c(47.74208,30.54142), sp = TRUE)
r8b <- osrmRoute(c(47.163739,30.565979),c(47.72082,30.13216), sp = TRUE)

#transform projection
r7  <- spTransform(r7,CRS(UTM_IRQ))
r8a <- spTransform(r8a,CRS(UTM_IRQ))
r8b <- spTransform(r8b,CRS(UTM_IRQ))

# #1. Divide Project Road in 10m segments ---------------------------------
##check length of r7
r7_length <- gLength(r7,byid = F)
r8a_length <- gLength(r8a,byid = F)
r8b_length <- gLength(r8b,byid = F)

r7_segment <- spsample(x = r7, n = r7_length, type = "regular")
r8a_segment <- spsample(x = r8a, n = r8a_length , type = "regular")
r8b_segment <- spsample(x = r8b, n = r8b_length, type = "regular")

#convert utm to lat/lon
r7_segment <- spTransform(r7_segment,CRS("+proj=longlat +datum=WGS84"))
r8a_segment <- spTransform(r8a_segment,CRS("+proj=longlat +datum=WGS84"))
r8b_segment <- spTransform(r8b_segment,CRS("+proj=longlat +datum=WGS84"))

##convert to dataframe
r7_segment_df <- as.data.frame(r7_segment)
colnames(r7_segment_df)[1] <- "Longitude"
colnames(r7_segment_df)[2] <- "Latitude"
r7_segment_df$road <- "r7"

r8a_segment_df <- as.data.frame(r8a_segment)
colnames(r8a_segment_df)[1] <- "Longitude"
colnames(r8a_segment_df)[2] <- "Latitude"
r8a_segment_df$road <- "r8a"

r8b_segment_df <- as.data.frame(r8b_segment)
colnames(r8b_segment_df)[1] <- "Longitude"
colnames(r8b_segment_df)[2] <- "Latitude"
r8b_segment_df$road <- "r8b"



# Label the stations ------------------------------------------------------
##r7
stations_labels_r7 <- seq(from = 0, to = nrow(r7_segment_df) - 1, by = 1)
r7_segment_df$dist_to_origin_kms <- (stations_labels_r7/1000)

##r8a
stations_labels_r8a <- seq(from = 0, to = nrow(r8a_segment_df) - 1 , by = 1)
r8a_segment_df$dist_to_origin_kms <- (stations_labels_r8a/1000)

##r8b
stations_labels_r8b <- seq(from = 0, to = nrow(r8b_segment_df) - 1, by = 1)
r8b_segment_df$dist_to_origin_kms <- (stations_labels_r8b/1000)


# Convert stations to distances -------------------------------------------
wordstoremove <- c("-C", "-L","R","-R","L","\\(|T1\\)")
stations1 <- as.data.frame(sapply(stations, function(x) 
  gsub(paste0(wordstoremove, collapse = '|'), '', x, ignore.case = T)))

#convert to km
stations1$dist_to_origin_kms <- as.numeric(gsub("+",".",stations1$station, fixed = T))

##rename roads
stations1$road <- ifelse(stations1$road %in% c('7'), "r7", stations1$road)
stations1$road <- ifelse(stations1$road %in% c('8a'), "r8a", stations1$road)
stations1$road <- ifelse(stations1$road %in% c('8b'), "r8b", stations1$road)

##separate station dataframes
stations1_r7 <- stations1[stations1$road == "r7",]
stations1_r8a <- stations1[stations1$road == "r8a",]
stations1_r8b <- stations1[stations1$road == "r8b",]


# Merging Dataframes ------------------------------------------------------
merged_r7 <- merge(r7_segment_df,stations1_r7, by = c("dist_to_origin_kms"))
merged_r8a <- merge(r8a_segment_df,stations1_r8a, by = c("dist_to_origin_kms"))
merged_r8b <- merge(r8b_segment_df,stations1_r8b, by = c("dist_to_origin_kms"))



# Export ------------------------------------------------------------------

saveRDS(r7_segment_df, file.path(data_file_path, "Road Improvement",  
                                   "R7","FinalData", "r7_station_to_latlon.Rds"))
saveRDS(r8a_segment_df, file.path(data_file_path, "Road Improvement",  
                             "R8","FinalData", "r8a_station_to_latlon.Rds"))
saveRDS(r8b_segment_df, file.path(data_file_path, "Road Improvement",  
                             "R8","FinalData", "r8b_station_to_latlon.Rds"))


## check
r7r8_sf <- st_as_sf(r7r8)
height = 9
width = 8
ggplot()+
  geom_sf(data = r7r8_sf)+
  geom_point(aes(x = 46.01851, y = 31.08096, color = "OSM(400m from Origin)"))+
  geom_point(aes(x = 46.0387271629726, y = 30.9657403844468, color = "Project(400m from Origin)"))+
  labs(color = "end points")+
  theme_minimal()+
  ggsave(file.path(data_file_path,"Road Improvement","diff_in_sources.png"))



