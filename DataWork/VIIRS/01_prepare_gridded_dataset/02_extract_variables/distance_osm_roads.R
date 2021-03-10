# Iraq IE
# Distance to Primary Roads

GRID_SAMPLE <- "near_girsheen_suheila_road"
#GRID_SAMPLE <- "near_r78ab_roads"
#GRID_SAMPLE <- "near_zakho_road" #the old road operated before Girsheen - Suheila was constructed


# Load Data --------------------------------------------------------------------
# Grid
grid <- readRDS(file.path(project_file_path, "Data", "VIIRS", "FinalData", 
                          GRID_SAMPLE, "Separate Files Per Variable", 
                          "iraq_grid_blank.Rds"))
coordinates(grid) <- ~lon+lat
crs(grid) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# Highways
osm_roads <- readRDS(file.path(project_file_path, "Data", "OpenStreetMap", 
                               "FinalData", "iraq_roads_rds",
                               "gis_osm_roads_free_1.Rds"))

osm_roads_trunk <- osm_roads[grepl("trunk", osm_roads$fclass),]
osm_roads_motorway <- osm_roads[grepl("motorway", osm_roads$fclass),]


# Reproject --------------------------------------------------------------------
grid               <- spTransform(grid,               CRS(UTM_IRQ))
osm_roads_trunk    <- spTransform(osm_roads_trunk,    CRS(UTM_IRQ))
osm_roads_motorway <- spTransform(osm_roads_motorway, CRS(UTM_IRQ))

# Prep Roads -------------------------------------------------------------------
## Buffer
osm_roads_trunk    <- osm_roads_trunk %>% gBuffer(width = 0.001, byid=T)
osm_roads_motorway <- osm_roads_motorway %>% gBuffer(width = 0.001, byid=T)

## Dissolve
osm_roads_trunk$one <- 1
osm_roads_trunk <- raster::aggregate(osm_roads_trunk, by = "one")

osm_roads_motorway$one <- 1
osm_roads_motorway <- raster::aggregate(osm_roads_motorway, by = "one")

# Calc Distance ----------------------------------------------------------------
grid$dist_osm_trunk_km    <- gDistance_chunks(grid, osm_roads_trunk,    5000, 1) / 1000
grid$dist_osm_motorway_km <- gDistance_chunks(grid, osm_roads_motorway, 5000, 1) / 1000

# Export -----------------------------------------------------------------------
saveRDS(grid@data, file=file.path(project_file_path, "Data", "VIIRS", "FinalData",
                                  GRID_SAMPLE,
                                  "Separate Files Per Variable", 
                                  "iraq_grid_dist_osm_roads.Rds"))





