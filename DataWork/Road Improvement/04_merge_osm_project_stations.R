# Create lat/lon from stations
#Step 1 : Clean the stations file
#Step 2 : Create variable for distance from project origin
#Step 3 : Merge project stations and osm data using the nearest lat/lon function



# Load Data ---------------------------------------------------------------
stations <- read.csv(file.path(data_file_path,"Road Improvement", "All Stations",
                               "stations.csv"))

osm <- readRDS(file.path(data_file_path,"Road Improvement", "osm_segments.Rds"))

# Step 1 : Clean the file -------------------------------------------------
wordstoremove <- c("-C", "-L","R","-R","L","\\(|T1\\)")
stations <- as.data.frame(sapply(stations, function(x) 
  gsub(paste0(wordstoremove, collapse = '|'), '', x, ignore.case = T)))

##rename roads
stations$road <- ifelse(stations$road %in% c('7'), "r7", stations$road)
stations$road <- ifelse(stations$road %in% c('8a'), "r8a", stations$road)
stations$road <- ifelse(stations$road %in% c('8b'), "r8b", stations$road)


# Step 2: Create the variable for distance from project origin ------------
#convert to km
stations$dist_to_project_origin_kms <- round(as.numeric(gsub("+",".",stations$station, fixed = T)),digits = 2)


#convert to sf
stations <- st_as_sf(stations,coords = c("lon","lat"), crs = UTM_IRQ)
osm <- st_as_sf(osm,coords = c("Longitude","Latitude"), crs = UTM_IRQ)

# Step 4: Merging osm and project data ------------------------------------
test <- st_nn(stations,osm,returnDist = T, k = 1)


stations <- st_join(stations,osm,st_nn, k = 1)
stations$diff <- stations$dist_to_project_origin_kms - stations$dist_to_osm_origin_kms

stations <- stations %>%
  arrange(road.x, dist_to_project_origin_kms)


