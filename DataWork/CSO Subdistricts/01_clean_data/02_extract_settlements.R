## Extract Settlement Data

# Load Data --------------------------------------------------------------------
settlement_sf <- st_read(file.path(project_file_path,
                                   "Data" , "OCHA Populated Places", "RawData", 
                                   "irq_pplp_ocha_20140722.shp"))

subdists <- readRDS(file.path(project_file_path ,"Data", "CSO Subdistricts", 
                              "FinalData", "subdistrict_timeinvariant_data_sp.Rds"))

iraq_adm3 <- readRDS(file.path(project_file_path, 
                               "Data", "CSO Subdistricts", "FinalData",  
                               "individual_files","irq_blank.Rds"))

# Extract Data ----------------------------------------------------------------
settlement_sf$no_of_settlements <- 1


settlement_sf <- 
  aggregate(no_of_settlements ~ Latitude + Longitude,
            data = settlement_sf,
            FUN = sum) #aggregating data

names(settlement_sf)[names(settlement_sf) == "Longitude"] <- "lon"
names(settlement_sf)[names(settlement_sf) == "Latitude"] <- "lat"


# Overlaying on subdists --------------------------------------------------
coordinates(settlement_sf) <- ~lon+lat
crs(settlement_sf) <- crs(subdists)

df_poly <- over(settlement_sf,subdists) #overlaying
settlement_sf <- as.data.frame(settlement_sf)
settlement_sf$year <- 2014 #data collected in 2014

settlement_sf$uid <- df_poly$uid #extracting the unique id for sub-districts
settlement_sf <- settlement_sf[!is.na(settlement_sf$uid),] #drop all obs in the row if uid is NA

settlement_sf <- 
  aggregate(no_of_settlements ~ uid + year,
            data = settlement_sf,
            FUN = sum) #aggregating data

# Creating a unique ID ----------------------------------------------
settlement_sf$settlement_id <- 1:nrow(settlement_sf) #create a unique id

# Merging  ----------------------------------------------------------------
iraq_adm3@data <- merge(iraq_adm3@data, settlement_sf, by = "uid") #merge with blank dtb

head(iraq_adm3@data) #check the merging
# Export ------------------------------------------------------------------
saveRDS(iraq_adm3, file.path(project_file_path, 
                             "Data", "CSO Subdistricts", "FinalData",  
                             "individual_files","irq_settlement.Rds"))
