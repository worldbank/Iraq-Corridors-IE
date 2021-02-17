# Extract Road Density

calc_road_length_i <- function(i, roads, adm){
  
  print(i)
  
  roads_i <- raster::intersect(roads, adm[i,])
  
  if(is.null(roads_i)){
    roads_i_length_km <- 0
  } else{
    roads_i_length_km <- as.vector(gLength(roads_i, byid=T) / 1000) %>% sum()
  }
  
  return(roads_i_length_km)
  
}

calc_road_length <- function(roads, adm){
  
  out <- lapply(1:nrow(adm), calc_road_length_i, roads, adm) %>% unlist()
  
  return(out)
}

# Load Data --------------------------------------------------------------------
iraq_adm3 <- readRDS(file.path(project_file_path, 
                               "Data", "CSO Subdistricts", "FinalData",  
                               "individual_files","irq_blank.Rds"))

iraq_adm3 <- iraq_adm3 %>% spTransform(CRS(UTM_IRQ))

# Extract Data -----------------------------------------------------------------
roads <- readRDS(file.path(project_file_path, "Data", "OpenStreetMap", "FinalData", 
                           "iraq_roads_rds", "gis_osm_roads_free_1_speeds.Rds"))
roads <- spTransform(roads, CRS(UTM_IRQ))

roads_primary <- roads[grepl("primary|secondary|motorway|trunk", roads$fclass),]
iraq_adm3$road_length_km_primary <- calc_road_length(roads_primary, iraq_adm3)

# Export -----------------------------------------------------------------------
saveRDS(iraq_adm3, file.path(project_file_path, 
                                   "Data", "CSO Subdistricts", "FinalData",  
                                   "individual_files","irq_road_length_km.Rds"))
