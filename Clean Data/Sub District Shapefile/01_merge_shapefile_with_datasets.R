# Add Population to Subdistrict Shapefile

# FUNCTIONS ====================================================================

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

# PROCESS DATA =================================================================

# Load ADM Data ----------------------------------------------------------------
#### ADM 3
iraq_adm3 <- readOGR(dsn = file.path(raw_data_file_path, "Sub District Shapefile"),
        layer = "irq_admbnda_adm3_cso_20190603")
iraq_adm3$uid <- 1:nrow(iraq_adm3)

iraq_adm3_utm <- spTransform(iraq_adm3, CRS(UTM_IRQ))

# Population -------------------------------------------------------------------
population <- raster(file.path(raw_data_file_path, "Population density", "IRQ_ppp_v2b_2015_UNadj.tif"))
population_vl <- velox(population)
iraq_adm3$population <- population_vl$extract(sp = iraq_adm3, fun=function(x) sum(x, na.rm=T)) %>% as.vector()

# Area km^2 --------------------------------------------------------------------
iraq_adm3$area_km2 <- as.vector(gArea(iraq_adm3_utm, byid=T) / 1000^2) 

# Road Density -----------------------------------------------------------------
roads <- readRDS(file.path(final_data_file_path, "OpenStreetMap", "rds", "gis_osm_roads_free_1_speeds.Rds"))
roads <- spTransform(roads, CRS(UTM_IRQ))

roads_primary <- roads[grepl("primary|secondary|motorway|trunk", roads$fclass),]
iraq_adm3$road_length_km_primary <- calc_road_length(roads_primary, iraq_adm3_utm)

# Nighttime Lights -------------------------------------------------------------
viirs_all <- raster(file.path(raw_data_file_path, "viirs_monthly", "iraq_viirs_raw_monthly_start_201204_avg_rad.tif"))
viirs_stacked_df <- lapply(1:93, function(i){
  
  print(i)

  viirs <- raster(file.path(raw_data_file_path, "viirs_monthly", "iraq_viirs_raw_monthly_start_201204_avg_rad.tif"), i) %>% velox()
  
  viirs_mean <- viirs$extract(sp = iraq_adm3, fun=function(x) mean(x, na.rm=T))
  
  viirs_df <- data.frame(viirs_mean = viirs_mean,
                         uid = iraq_adm3$uid,
             viirs_time_id = i)
  
  return(viirs_df)
}) %>% bind_rows()

#### Add year / month
year <- 2012
month <- 4
viirs_stacked_df$year <- NA
viirs_stacked_df$month <- NA
for(i in unique(viirs_stacked_df$viirs_time_id)){
  
  viirs_stacked_df$year[viirs_stacked_df$viirs_time_id %in% i]  <- year 
  viirs_stacked_df$month[viirs_stacked_df$viirs_time_id %in% i] <- month 
  
  month <- month + 1
  
  if(month == 13){
    month <- 1
    year <- year + 1
  }
}

#### Add Data
iraq_adm3_df <- merge(iraq_adm3@data, viirs_stacked_df, by = "uid")

# Export -----------------------------------------------------------------------
saveRDS(iraq_adm3, file.path(final_data_file_path, "subdistrict_data", "subdistrict_timeinvariant_data_sp.Rds"))
saveRDS(iraq_adm3_df, file.path(final_data_file_path, "subdistrict_data", "subdistrict_data_df.Rds"))




