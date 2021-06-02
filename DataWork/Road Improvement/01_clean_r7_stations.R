# Clean R7 Stations

# Load Data --------------------------------------------------------------------
r7_stations <- read_delim(file.path(project_file_path,
                                    "Data","Road Improvement","R7", "RawData","R7-stations.txt"),
                          "\t", escape_double = FALSE, trim_ws = TRUE, skip = 2)

# Rename Variables -------------------------------------------------------------
r7_stations <- r7_stations %>%
  dplyr::rename("no" = "No.",
                "lon" = "Easting (m)",
                "lat" = "Northing (m)",
                "station" = "R7-Project Station",
                "bench_mark_id" = "Bench Mark ID",
                "elevation_m" = "Elevation (m)",
                "section" = "Section",
                "notes" = "Notes : Description  on the DWG") %>%
  dplyr::select(lon, lat, station, bench_mark_id, elevation_m,
                section, notes) %>%
  mutate(road = "r7")

# Coordinates to WGS84 ---------------------------------------------------------
coordinates(r7_stations) <- ~lon+lat
proj4string(r7_stations) <- CRS("+proj=utm +zone=38N +datum=WGS84 +units=m +ellps=WGS84") 
r7_stations <- spTransform(r7_stations, CRS("+proj=longlat +datum=WGS84"))
r7_stations <- r7_stations %>% as.data.frame()

# Export -----------------------------------------------------------------------
write.csv(r7_stations, file.path(project_file_path, "Data", "Road Improvement", 
                                 "R7", "FinalData", "R7-stations.csv"), row.names = F)


