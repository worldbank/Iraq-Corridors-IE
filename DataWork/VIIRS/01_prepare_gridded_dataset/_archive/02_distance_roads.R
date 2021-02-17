# Iraq IE
# Distance to Primary Roads

# Load Data --------------------------------------------------------------------
# Grid
grid <- readRDS(file.path(project_file_path, "Data", "VIIRS", 
                          "FinalData","Separate Files Per Variable", 
                          "iraq_grid_blank.Rds"))
coordinates(grid) <- ~lon+lat
crs(grid) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# Highways
primary_routes <- readOGR(dsn=file.path(project_file_path, "Data", "HDX Primary Roads", "RawData"), 
                          layer="primary_routes")
primary_routes <- primary_routes[primary_routes$ROAD_RUNWA == "Hard /Paved",]
primary_routes$one <- 1

# Reproject --------------------------------------------------------------------
grid           <- spTransform(grid,          CRS(UTM_IRQ))
primary_routes <- spTransform(primary_routes, CRS(UTM_IRQ))

# Calculate Distance -----------------------------------------------------------
# Distance All Routes
#for(route_num in c(1,2,3,4,5,6,7,8,9,10,12)){
#  print("* ----------------- *")
#  print(paste0("Route Number: ",route_num))
#  
#  primary_routes_rte_i <- raster::aggregate(primary_routes[primary_routes$ROUTE_NUMB %in% route_num,], by="one")
#  grid[[paste0("distance_route_", route_num)]] <- gDistance_chunks(grid, primary_routes_rte_i, 5000, 1) * 111.12
#}

primary_routes <- raster::aggregate(primary_routes %>% gBuffer(width = 0.0001, byid=T), by="one")
grid$distance_primary_route <- gDistance_chunks(grid, primary_routes, 5000, 1) / 1000

# Export -----------------------------------------------------------------------
saveRDS(grid@data, file=file.path(project_file_path, "Data", "VIIRS", "FinalData",
                                  "Separate Files Per Variable", "iraq_grid_dist_primaryroads.Rds"))





