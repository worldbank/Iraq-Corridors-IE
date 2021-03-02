# Iraq IE
# Distance to Roads

#GRID_SAMPLE <- "near_girsheen_suheila_road"
#GRID_SAMPLE <- "near_r78ab_roads"
GRID_SAMPLE <- "near_zakho_road" #the old road operated before Girsheen - Suheila was constructed


# Load Data --------------------------------------------------------------------
# Grid
grid <- readRDS(file.path(project_file_path, 
                          "Data", "VIIRS", "FinalData", GRID_SAMPLE,
                          "Separate Files Per Variable", "iraq_grid_blank.Rds"))
coordinates(grid) <- ~lon+lat
crs(grid) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# Project Roads
#prj_rd_r78ab <- readRDS(file.path(project_file_path, "Data", "Project Roads", 
#                                  "R7_R8ab", "FinalData", "r7_r8ab.Rds"))
#prj_rd_gs <- readRDS(file.path(project_file_path, "Data", "Project Roads", "Girsheen-Suheila Road", 
#                               "FinalData", "gs_road_polyline.Rds"))


prj_rd_zakho_gs <- readRDS(file.path(project_file_path,"Data", "Project Roads",
                                "Zakho Road", "FinalData",
                                "zakho_road.Rds"))

# Prep Roads -------------------------------------------------------------------
## Buffer by small amount; needed for dissolving. Buffer by 1 meter
prj_rd_zakho_gs   <- gBuffer(prj_rd_zakho_gs,    width = .001/111.12, byid=T)

## Dissolve
prj_rd_zakho_gs$one <- 1
prj_rd_zakho_gs<- raster::aggregate(prj_rd_zakho_gs, by="one")

# Reproject --------------------------------------------------------------------
grid          <- spTransform(grid,          CRS(UTM_IRQ))
#prj_rd_r78ab  <- spTransform(prj_rd_r78ab, CRS(UTM_IRQ))
prj_rd_zakho_gs    <- spTransform(prj_rd_zakho_gs, CRS(UTM_IRQ))

# Calculate Distance -----------------------------------------------------------
#grid$dist_r78ab_road_km <- gDistance_chunks(grid, prj_rd_r78ab, 5000, 1) / 1000 # convert from meters to km
grid$dist_zakho_km   <- gDistance_chunks(grid, prj_rd_zakho_gs, 5000, 1) / 1000 # convert from meters to km

# Export -----------------------------------------------------------------------
saveRDS(grid@data, file=file.path(project_file_path, "Data", "VIIRS", "FinalData",
                                  GRID_SAMPLE,
                                  "Separate Files Per Variable", 
                                  "iraq_grid_dist_projectroads.Rds"))





