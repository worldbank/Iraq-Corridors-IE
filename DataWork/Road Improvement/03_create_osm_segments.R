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
 

r7_segment <- spsample(x = r7, n = gLength(r7,byid = F)/10, type = "regular")
r8a_segment <- spsample(x = r8a, n = gLength(r8a,byid = F)/10 , type = "regular")
r8b_segment <- spsample(x = r8b, n = gLength(r8b,byid = F) /10, type = "regular")

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
stations_labels_r7 <- seq(from = 0, to = nrow(r7_segment_df) - 1 , by = 1)
r7_segment_df$dist_to_osm_origin_kms <- round((stations_labels_r7/1000),digits = 2)

##r8a
stations_labels_r8a <- seq(from = 0, to = nrow(r8a_segment_df) - 1 , by = 1)
r8a_segment_df$dist_to_osm_origin_kms <-  round((stations_labels_r8a/1000),digits = 2)

##r8b
stations_labels_r8b <- seq(from = 0, to = nrow(r8b_segment_df) - 1, by = 1)
r8b_segment_df$dist_to_osm_origin_kms <-  round((stations_labels_r8b/1000),digits = 2)

rm(r7,r7_segment,r8a,r8a_segment,r8b,r8b_segment)


# Combine dataframes ------------------------------------------------------
osm <- rbind(r7_segment_df,r8a_segment_df,r8b_segment_df)


# Export ------------------------------------------------------------------
saveRDS(osm, file.path(data_file_path, "Road Improvement",  
                                   "osm_segments.Rds"))





