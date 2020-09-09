# Iraq IE
# Balance checks

# Loading Data set ---------------------------------------------------------
subdist_buffer <- readRDS(file=file.path(final_data_file_path, "Cleaned Data for Preliminary Analysis", "FinalData", "ntl_subdist_final.Rds"))
other_roads <- readRDS(file=file.path(final_data_file_path, "OpenStreetMap", "FinalData", "iraq_roads_rds","gis_osm_roads_free_1.Rds"))



# Roads similar to R7/R8 --------------------------------------------------
other_roads <- st_as_sf(other_roads)
other_roads <- other_roads[other_roads$fclass %in% "trunk",]
trunk <- other_roads[other_roads$ref %in% "1",]

##removing southern part of the road since it overlaps with treatment
trunk

remove(other_roads)

##check the transformations by plotting
ggplot()+
   geom_sf(data = subdist_buffer, color = "grey") +
   geom_sf(data = trunk, size = 1) +
   coord_sf()

##transform to metric coordinate system
trunk_km  <- st_transform(trunk, "+proj=utm +zone=42N +datum=WGS84 +units=km")
subdist_buffer_km <- st_transform(subdist_buffer, "+proj=utm +zone=42N +datum=WGS84 +units=km")          

remove(trunk,subdist_buffer)

# Create 5 km buffer ----------------------------------------------
trunk_buffer_5km <- st_buffer(trunk_km,5)
trunk_subdist_5km <- st_intersection(trunk_buffer_5km,subdist_buffer_km)
remove(trunk_buffer_5km)

##check the number of sub-districts that overlap
dim(trunk_subdist_5km)

##plot
# ggplot()+
#   geom_sf(data = subdist_buffer_km, color = "grey") +
#   geom_sf(data = trunk_subdist_5km, fill = "red", color ="black")+
#   geom_sf(data = trunk_km, size = 1,) +
#   coord_sf()

##create dummy and add it to the main shape file
subdist <- unique(trunk_subdist_5km$uid)
subdist_buffer_km$control_5km <- 
  ifelse(subdist_buffer_km$uid %in% subdist,1,0)

# Create 10 km buffer ----------------------------------------------
trunk_buffer_10km <- st_buffer(trunk_km,10)
trunk_subdist_10km <- st_intersection(trunk_buffer_10km,subdist_buffer_km)
remove(trunk_buffer_10km)

# ##plot
# ggplot()+
#   geom_sf(data = subdist_buffer_km, color = "grey") +
#   geom_sf(data = trunk_subdist_10km, fill = "red", color ="black")+
#   geom_sf(data = trunk_km, size = 1,) +
#   coord_sf()

##create dummy and add it to the main shape file
subdist <- unique(trunk_subdist_10km$uid)
subdist_buffer_km$control_10km <- 
  ifelse(subdist_buffer_km$uid %in% subdist,1,0)

# Create 20 km buffer ----------------------------------------------
trunk_buffer_20km <- st_buffer(trunk_km,20)
trunk_subdist_20km <- st_intersection(trunk_buffer_20km,subdist_buffer_km)
remove(trunk_buffer_20km)

# ##plot
# ggplot()+
#   geom_sf(data = subdist_buffer_km, color = "grey") +
#   geom_sf(data = trunk_subdist_20km, fill = "red", color ="black")+
#   geom_sf(data = trunk_km, size = 1,) +
#   coord_sf()

##create dummy and add it to the main shape file
subdist <- unique(trunk_subdist_20km$uid)
subdist_buffer_km$control_20km <- 
  ifelse(subdist_buffer_km$uid %in% subdist,1,0)


# Create Balance Check Data -----------------------------------------------------------

subdist_buffer_km$treat <-
  ifelse(subdist_buffer_km$treat_5km == 1 | subdist_buffer_km$treat_10km == 1 |subdist_buffer_km$treat_20km == 1,1,0)
subdist_buffer_km$control <-
  ifelse(subdist_buffer_km$control_5km == 1 | subdist_buffer_km$control_10km == 1 |subdist_buffer_km$control_20km == 1,1,0)

##keep only those subdists that are either in treat or control
balance_df <- subdist_buffer_km[!(subdist_buffer_km$treat == 0 & subdist_buffer_km$control == 0),]
balance_df <- balance_df[!(balance_df$year > 2014),]
unique(balance_df$ADM3_EN) ## Contains a total of 61 sub-districts for this balance check
remove(subdist_buffer_km,trunk_km,trunk_subdist_5km,trunk_subdist_10km,trunk_subdist_20km)

names(balance_df)
balance_df <- subset(balance_df,select= c("population","area_km2","road_length_km_primary","ADM3_EN",
                                          "distance_to_baghdad","average_hh_exp.mean","no_of_conflicts",
                                          "no_of_settlements","treat", "viirs_mean"))
balance_df <- st_as_sf(balance_df)
balance_df <- balance_df %>% 
  st_drop_geometry()

##replace NA with 0
balance_df[is.na(balance_df)] <- 0


# Balance Check -----------------------------------------------------------
##creating covariates to test for balance


#remove those too close to Baghdad
balance_df <- balance_df[!(balance_df$distance_to_baghdad < 30),] ##too close


covs <- subset(balance_df, select = c(population,area_km2,road_length_km_primary,
                                      distance_to_baghdad,average_hh_exp.mean))

W.out <- weightit(treat ~ covs, data = balance_df,
                  method = "ps", estimand = "ATT")

bal.plot(W.out, var.name = "population", which = "unadjusted", hjust = 0.5)

bal.plot(W.out, var.name = "average_hh_exp.mean", which = "unadjusted")


