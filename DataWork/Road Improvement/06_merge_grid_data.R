#Merging grid data with road improvements


# Load Data ---------------------------------------------------------------
reports <- readRDS(file.path(data_file_path, "Road Improvement",  
                                       "R7","FinalData", "r7_station_to_latlon_final.Rds"))
grid <- readRDS(file.path(project_file_path, "Data", "VIIRS", 
                          "FinalData", "near_r78ab_roads", "viirs_grid_clean.Rds"))

grid_blank <- readRDS(file.path(data_file_path,"VIIRS", "FinalData", "near_r78ab_roads", 
                                "Separate Files Per Variable","iraq_grid_panel_blank.Rds"))


ji <- function(xy, origin=c(0,0), cellsize=c(1,1)) {
  t(apply(xy, 1, function(z) cellsize/2+origin+cellsize*(floor((z - origin)/cellsize))))
}
JI <- ji(cbind(reports$start_lon,reports$start_lat))
reports$X <- JI[, 1]
reports$Y <- JI[, 2]
reports$Cell <- paste(reports$X, reports$Y)
names(reports)

head(reports %>%
  select(c(r_id,road.x,month,year,start_lat,start_lon,end_lat,
           end_lon)))
