# Create Grid to Download Sentinel Data

# Load Roads -------------------------------------------------------------------
r78_df <- readRDS(file.path(project_file_path, "Data", "Project Roads", "R7_R8ab", "FinalData", "r7_r8ab.Rds"))
gs_sp <- readRDS(file.path(project_file_path, "Data", "Project Roads", "Girsheen-Suheila Road", "FinalData", "gs_road_polyline.Rds"))

r78_df <- spTransform(r78_df, CRS("+init=epsg:4326"))
gs_sp  <- spTransform(gs_sp, CRS("+init=epsg:4326"))

gs_sp_buff  <- gBuffer(gs_sp, width = 30/111.12, byid=F)
r78_df_buff <- gBuffer(r78_df, width = 30/111.12, byid=F)

gs_sp_buff$road_name <- "Girsheen-Suheila"
r78_df_buff$road_name <- "R78ab"

ext_right <- extent(r78_df_buff)
ext_right@xmin <- 46.88664

ext_left <- extent(r78_df_buff)
ext_left@xmax <- 46.88664

r78_df_buff_left <- crop(r78_df_buff, ext_left)
r78_df_buff_right <- crop(r78_df_buff, ext_right)

r78_df_buff <- rbind(r78_df_buff_left, r78_df_buff_right)

grid <- rbind(gs_sp_buff, r78_df_buff)

grid$id <- 1:nrow(grid)

writeOGR(obj = grid,
         driver = "ESRI Shapefile",
         layer = "irq_roads_grid_30km",
         dsn = file.path(project_file_path, "Data", "Sentinel",
                         "grid_near_roads"),
         overwrite_layer = T)

st_write(grid %>% st_as_sf(),
         file.path(project_file_path, "Data", "Sentinel",
                   "grid_near_roads", "irq_roads_grid_30km.geojson"))


