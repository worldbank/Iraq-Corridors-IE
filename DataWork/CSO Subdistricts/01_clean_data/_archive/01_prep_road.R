#Check which road overlaps with R7/R8


# Load Data ---------------------------------------------------------------
roads <- readOGR(dsn = file.path(project_file_path,
                           "Data", "OpenStreetMap", 
                           "RawData","shp_files"), layer = "gis_osm_roads_free_1")

coords <- read_delim(file.path(project_file_path,
                               "Data","Road Improvement","R7","R7-stations.txt"),
                     "\t", escape_double = FALSE, trim_ws = TRUE, skip = 2)

iraq_adm3 <- readRDS(file.path(project_file_path, 
                               "Data", "CSO Subdistricts", "FinalData",  
                               "individual_files","irq_adm_info.Rds"))


# Rename Variables --------------------------------------------------------
names(coords)[names(coords) == "Easting (m)"] <- "lon"
names(coords)[names(coords) == "Northing (m)"] <- "lat"
names(coords)[names(coords) == "R7-Project Station"] <- "station"

coordinates(coords) <- ~lon+lat
proj4string(coords) <- CRS("+proj=utm +zone=38N +datum=WGS84 +units=m +ellps=WGS84") 
coords <- spTransform(coords,CRS("+proj=longlat +datum=WGS84"))

# Overlay roads on stations to identify the road --------------------------
roads <- roads[roads$fclass == "trunk",]

over(coords,roads) ##Check

# Plot --------------------------------------------------------------------
iraq_adm3_sf <- st_as_sf(iraq_adm3)
roads_sf <- st_as_sf(roads)
coords_sf <- st_as_sf(coords)


p <- ggplot() +
  geom_sf(data = iraq_adm3_sf, color = "grey50", fill = NA) +
  geom_sf(data = roads_sf, color = "blue", fill = NA) +
  #geom_sf(data = coords_sf) +
  theme_classic()

p1 <- ggplot() +
  geom_sf(data = iraq_adm3_sf, color = "grey50", fill = NA) +
  geom_sf(data = roads_sf, color = "blue", fill = NA) +
  geom_sf(data = coords_sf) +
  theme_classic()

print(p1)
