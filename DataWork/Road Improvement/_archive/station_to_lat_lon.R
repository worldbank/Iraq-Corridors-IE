#Iraq IE
#Stationing


# Load Data ---------------------------------------------------------------
stations <- read.csv(file.path(data_file_path,"Road Improvement", "All Stations",
                               "stations.csv"))

r7r8 <- readRDS(file.path(data_file_path,"Project Roads", "R7_R8ab", 
                          "FinalData","r7_r8ab.RDS"))

# Convert stations to distances -------------------------------------------
wordstoremove <- c("-C", "-L", "-R","L","\\(|T1\\)")
stations1 <- as.data.frame(sapply(stations, function(x) 
  gsub(paste0(wordstoremove, collapse = '|'), '', x, ignore.case = T)))

##convert to km
stations1$dist_to_origin_kms <- gsub("+",".",stations1$station, fixed = T)


# Convert r7r8 into points every 10m --------------------------------------

##Convert to points
ptsr7r8 <- as(r7r8, "SpatialPointsDataFrame")
points_r7r8 <- data.frame(Longitude = coordinates(ptsr7r8)[,1], 
                      Latitude = coordinates(ptsr7r8)[,2],
                      Road = ptsr7r8$road)

##calculate distance between points
points_r7r8$distance_km[2:nrow(points_r7r8)] <- sapply(2:nrow(points_r7r8), function(x) 
                                              distm(points_r7r8[x-1,c('Longitude', 'Latitude')],
                                                    points_r7r8[x,c('Longitude', 'Latitude')], 
                                                    fun = distHaversine))
##convert to km
points_r7r8$distance_km <- (points_r7r8$distance_km)/1000

##format to three decimal places
points_r7r8[,'distance_km'] <- format(round(points_r7r8[,'distance_km'],2),nsmall=2)
points_r7r8[1,4] <- 0
points_r7r8[,'distance_km'] <- as.numeric(points_r7r8[,'distance_km'])

#create a variable with distance to origin
points_r7r8[,"dist_to_origin_km"] <- cumsum(points_r7r8$distance_km)

