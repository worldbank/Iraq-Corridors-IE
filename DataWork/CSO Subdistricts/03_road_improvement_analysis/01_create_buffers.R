# Iraq IE
# Create buffers of 5 , 10 , 20 km around R7/R8

# Loading Data set ---------------------------------------------------------
subdists <- readRDS(file.path(dsn = final_data_file_path ,"CSO Subdistricts", "FinalData", "subdistrict_timeinvariant_data_sp.Rds"))
roads <- readRDS(file.path(dsn = final_data_file_path,"HDX Primary Roads", "FinalData","r7_r8ab","r7_r8ab_prj_rd.Rds"))

# Convert sp to sf ---------------------------------------------------------

##convert to sf
roads     <- st_as_sf(roads, coords = c("longitude.x", "latitude.y"))
subdists  <- st_as_sf(subdists)

##ensure both coordinate systems are the same
st_crs(roads) <- st_crs(subdists)

##check the transformations by plotting
ggplot()+
  geom_sf(data = subdists, color = "grey") +
  geom_sf(data = roads, size = 1) +
  coord_sf()


##transform to metric coordinate system
roads_km    <- st_transform(roads, "+proj=utm +zone=42N +datum=WGS84 +units=km")
subdists_km <- st_transform(subdists, "+proj=utm +zone=42N +datum=WGS84 +units=km")

remove(roads,subdists)
# Create 5 km buffer ----------------------------------------------
roads_buffer_5km <- st_buffer(roads_km, 5)
roads_subdists_5km <- st_intersection (roads_buffer_5km,subdists_km)
remove(roads_buffer_5km)

##check the number of sub-districts that overlap
dim(roads_subdists_5km)

##plot
ggplot()+
  geom_sf(data = subdists_km, color = "grey") +
  geom_sf(data = roads_subdists_5km, fill = "red", color ="black")+
  coord_sf()


##create dummy and add it to the main shape file
subdist <- unique(roads_subdists_5km$uid)
subdists_km$treat_5km <-
  ifelse(subdists_km$uid %in% subdist,1,0)

remove(subdist,roads_subdists_5km)
# Create 10 km buffer ----------------------------------------------
roads_buffer_10km <- st_buffer(roads_km, 10)
roads_subdists_10km <- st_intersection (roads_buffer_10km,subdists_km)
remove(roads_buffer_10km)

##check the number of sub-districts that overlap
dim(roads_subdists_10km)

##plot
ggplot()+
  geom_sf(data = subdists_km, color = "grey") +
  geom_sf(data = roads_subdists_10km, fill = "red", color ="black")+
  coord_sf()


##create dummy and add it to the main shape file
subdist <- unique(roads_subdists_10km$uid)
subdists_km$treat_10km <-
  ifelse(subdists_km$uid %in% subdist,1,0)

remove(subdist,roads_subdists_10km)
# Create 20 km buffer ----------------------------------------------
roads_buffer_20km <- st_buffer(roads_km, 20)
roads_subdists_20km <- st_intersection (roads_buffer_20km,subdists_km)
remove(roads_buffer_20km)

##check the number of sub-districts that overlap
dim(roads_subdists_20km)


##plot
ggplot()+
  geom_sf(data = subdists_km,color = "grey") +
  geom_sf(data = roads_subdists_20km, fill = "red", color ="black")+
  coord_sf()


##create dummy and add it to the main shape file
subdist <- unique(roads_subdists_20km$uid)

subdists_km$treat_20km <-
  ifelse(subdists_km$uid %in% subdist, 1,0)

remove(subdist,roads_subdists_20km)
#Export -----------------------------------------------------------------
saveRDS(subdists_km, file=file.path(final_data_file_path, "Cleaned Data for Preliminary Analysis", "FinalData", "ntl_subdist_buffer.Rds"))
remove(roads_km,subdists_km)
