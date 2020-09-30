# Clean R7 Stations

# Load Data --------------------------------------------------------------------
r8_stations <- read_delim(file.path(project_file_path,
                                    "Data","Road Improvement","R8", "RawData","R8-stations.txt"),
                          "\t", escape_double = FALSE, trim_ws = TRUE, skip = 3)

# Split into side A/B, Rename, Append ------------------------------------------

# Different columns for r8a and r8b
r8_stations_a <- r8_stations %>%
  dplyr::select("N/N", "Station", "N", "E", "Elev.", "Name") %>%
  dplyr::rename("no" = "N/N",
                "station" = "Station", 
                "lat" = "N",
                "lon" = "E", 
                "elevation_m" = "Elev.", 
                "section" = "Name") %>%
  mutate(road = "r8a") %>%
  filter(!is.na(station))

r8_stations_b <- r8_stations %>%
  dplyr::select("No", "Station_1", "N_1", "E_1", "Elev._1", "Name_1") %>%
  dplyr::rename("no" = "No",
                "station" = "Station_1", 
                "lat" = "N_1",
                "lon" = "E_1", 
                "elevation_m" = "Elev._1", 
                "section" = "Name_1") %>%
  mutate(road = "r8b") %>%
  filter(!is.na(station))

r8_stations <- bind_rows(r8_stations_a,
                         r8_stations_b)

# Coordinates to WGS84 ---------------------------------------------------------
coordinates(r8_stations) <- ~lon+lat
proj4string(r8_stations) <- CRS("+proj=utm +zone=38N +datum=WGS84 +units=m +ellps=WGS84") 
r8_stations <- spTransform(r8_stations, CRS("+proj=longlat +datum=WGS84"))
r8_stations <- r8_stations %>% as.data.frame()

# Export -----------------------------------------------------------------------
write.csv(r8_stations, file.path(project_file_path, "Data", "Road Improvement", 
                                 "R8", "FinalData", "R8-stations.csv"), row.names = F)


