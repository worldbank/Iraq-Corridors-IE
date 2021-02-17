# Iraq IE
# Create buffers of 5 , 10 , 20 km around R7/R8 for grid-level analysis

# Loading Data set ---------------------------------------------------------

ntl_grid_lat_lon <- readRDS(file=file.path(final_data_file_path,  "VIIRS","FinalData" ,"Separate Files Per Variable", "iraq_grid_blank.Rds"))
ntl_grid_names <- readRDS(file=file.path(final_data_file_path,  "VIIRS","FinalData" ,"Separate Files Per Variable", "iraq_grid_gadm.Rds"))
shp3 <- readRDS(file.path(dsn = final_data_file_path ,"GADM", "RawData", "gadm36_IRQ_2_sp.rds"))
ntl_pixel <- readRDS(file=file.path(final_data_file_path,  "VIIRS","FinalData" ,"iraq_viirs_grid_data_clean.Rds"))


# Sub-setting the grid data -----------------------------------------------
grid <- shp3@data #Check governorates to drop


##subset the unique governorates within the grid level data set using sub-districts from above
ntl_grid_names <- ntl_grid_names[!(ntl_grid_names$GADM_ID_1 == "IRQ.1_1" |ntl_grid_names$GADM_ID_1 == "IRQ.6_1"|
                                   ntl_grid_names$GADM_ID_1 == "IRQ.7_1"| ntl_grid_names$GADM_ID_1 == "IRQ.8_1"|
                                   ntl_grid_names$GADM_ID_1 == "IRQ.9_1"| ntl_grid_names$GADM_ID_1 == "IRQ.10_1"|
                                   ntl_grid_names$GADM_ID_1 == "IRQ.12_1"|ntl_grid_names$GADM_ID_1 == "IRQ.13_1"|
                                   ntl_grid_names$GADM_ID_1 == "IRQ.14_1"|ntl_grid_names$GADM_ID_1 == "IRQ.16_1"|
                                   ntl_grid_names$GADM_ID_1 == "IRQ.17_1"|ntl_grid_names$GADM_ID_1 == "IRQ.18_1"),]

remove(grid,shp3)

##keeping those observations that match the grid_names data set
ntl_grid_lat_lon <- ntl_grid_lat_lon[(ntl_grid_lat_lon$id %in% ntl_grid_names$id),]

remove(ntl_grid_names)
# Add lat/lon to data set -------------------------------------------------
##merging lat/lon data with pixel data
ntl_pixel <- ntl_pixel[(ntl_pixel$id %in% ntl_grid_lat_lon$id),]
ntl_pixel <- left_join(ntl_pixel,ntl_grid_lat_lon)
ntl_pixel <- as.data.frame(ntl_pixel)

remove(ntl_grid_lat_lon)

# Overlay subdists shape file to get sub-district names ---------------------------------------------------------
subdists <- readRDS(file.path(final_data_file_path ,"CSO Subdistricts", "FinalData", "subdistrict_timeinvariant_data_sp.Rds"))

coordinates(ntl_pixel) <- ~lon+lat
crs(ntl_pixel) <- crs(subdists) #ensuring the coordinate-systems match

##overlaying
df_poly <- over(ntl_pixel, subdists)
names(df_poly)

## selecting the ADM3_EN column from this combined data frame
list <- select(df_poly,ADM3_EN,ADM2_EN,ADM1_EN,uid)
remove(df_poly, subdists)


##create new merge id
ntl_pixel <- as.data.frame(ntl_pixel)
ntl_pixel$id_merge <- 1:nrow(ntl_pixel)
list$id_merge <- 1:nrow(list)

##merge subset with list
##Note: In this merge, there were some other districts(Wassit) that overlapped with the data set besides Thi-Qar, Al-Basrah and Al- Muthannia
ntl_pixel <- merge(ntl_pixel,list,by="id_merge") 

remove(list)
## remove Wassit, since it was removed from the original data set
ntl_pixel <- ntl_pixel[!(ntl_pixel$ADM1_EN == "Wassit"),]
ntl_pixel <- ntl_pixel[complete.cases(ntl_pixel),] # removing rows that are missing altogether

##dropping unnecessary variables
ntl_pixel <- subset(ntl_pixel, select = -c(id_merge,GADM_ID_0,GADM_ID_1,GADM_ID_2))


##Add buffers from the sub-district data set
subdists_km <- readRDS(file=file.path(final_data_file_path, "Cleaned Data for Preliminary Analysis", "FinalData", "ntl_subdist_buffer.Rds"))
names(subdists_km)

##subset the data
subdists_km <- subset(subdists_km, select = c(uid,treat_5km,treat_10km,treat_20km))

##merge with pixel data
ntl_pixel <- left_join(ntl_pixel,subdists_km)

##remove those observations that do not fall under any of the 5,10,20km buffers
ntl_pixel <- ntl_pixel[!(ntl_pixel$treat_5km == 0 & ntl_pixel$treat_10km == 0 & ntl_pixel$treat_20km == 0),]


##selecting a random sample (10% of each sub-district) for ease of coding
n <- round(0.1*nrow(ntl_pixel[ntl_pixel$uid,])) #10% from each sub-district
ntl_pixel_random <- sample_n(ntl_pixel,n)

remove(subdists_km)

#Export -----------------------------------------------------------------
saveRDS(ntl_pixel, file=file.path(final_data_file_path, "VIIRS", "FinalData", "01_iraq_viirs_buffer.Rds"))
saveRDS(ntl_pixel_random, file=file.path(final_data_file_path, "VIIRS", "FinalData", "02_iraq_viirs_random_sample.Rds"))
