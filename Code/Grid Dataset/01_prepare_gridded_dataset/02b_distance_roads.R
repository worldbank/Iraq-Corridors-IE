# Iraq IE
# Distance to Roads

# Load Data --------------------------------------------------------------------
# Grid
grid <- readRDS(file.path(final_data_file_path,  "VIIRS Grid","Separate Files Per Variable", "iraq_grid_blank.Rds"))
coordinates(grid) <- ~lon+lat
crs(grid) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# Highways
setwd(file.path(raw_data_file_path, "Roads", "primary_routes", "All"))
primary_routes <- readOGR(dsn=".", layer="primary_routes")
primary_routes <- primary_routes[primary_routes$ROAD_RUNWA == "Hard /Paved",]
primary_routes$one <- 1

# Calculate Distance -----------------------------------------------------------
# Distance All Routes
#for(route_num in c(1,2,3,4,5,6,7,8,9,10,12)){
#  print("* ----------------- *")
#  print(paste0("Route Number: ",route_num))
#  
#  primary_routes_rte_i <- raster::aggregate(primary_routes[primary_routes$ROUTE_NUMB %in% route_num,], by="one")
#  grid[[paste0("distance_route_", route_num)]] <- gDistance_chunks(grid, primary_routes_rte_i, 5000, 1) * 111.12
#}

primary_routes <- raster::aggregate(primary_routes, by="one")
grid$distance_primary_route <- gDistance_chunks(grid, primary_routes, 5000, 1) * 111.12

# Export -----------------------------------------------------------------------
saveRDS(grid@data, file=file.path(final_data_file_path, "VIIRS Grid", "Separate Files Per Variable", "iraq_grid_dist_primaryroads.Rds"))





