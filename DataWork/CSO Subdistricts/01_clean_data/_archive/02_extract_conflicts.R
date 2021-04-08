## Extract Conflict Data

# Load Data --------------------------------------------------------------------
conflict_df <- read_excel(file.path(project_file_path,
                                    "Data", "ACLED","RawData",
                                    "MiddleEast_2016-2018_Dec01.xlsx"))

gtd_df <- read_excel(file.path(project_file_path,
                                         "Data", "Global Terrorism Database","RawData",
                                         "globalterrorismdb_0919dist.xlsx"))


iraq_adm3 <- readRDS(file.path(project_file_path, 
                               "Data", "CSO Subdistricts", "FinalData",  
                               "individual_files","irq_blank.Rds"))

iraq_adm3 <- iraq_adm3 %>% spTransform(CRS(UTM_IRQ))

# Extract Data ----------------------------------------------------------------
conflict_df <- conflict_df[which(conflict_df$COUNTRY == "Iraq"),names(conflict_df) %in% 
                                  c("YEAR","LOCATION", "LATITUDE", "LONGITUDE")] #subset the data


gtd_df <- gtd_df[which(gtd_df$country_txt == "Iraq"), names(gtd_df) %in%
                   c( "iyear", "imonth","latitude" ,"longitude")]

gtd_df <- gtd_df[(gtd_df$iyear > 2011) & (gtd_df$iyear < 2016), ]

# Cleaning ----------------------------------------------------------------
#ACLED 
conflict_df <- conflict_df %>% 
  dplyr::rename(lon = LONGITUDE,
                lat = LATITUDE, 
                year = YEAR,
                location = LOCATION)


conflict_df$no_of_conflicts <- 1 #Create a count variable for conflict
conflict_df <- 
  aggregate(no_of_conflicts ~ lon + lat + year,
            data = conflict_df,
            FUN = sum) #aggregating data by location

#GTD 
gtd_df <- gtd_df %>%
  dplyr::rename(year = iyear, 
                month = imonth, 
                lat = latitude, 
                lon = longitude)

gtd_df$no_of_conflicts <- 1

gtd_df <- 
  aggregate(no_of_conflicts ~ lon + lat + year,
            data = gtd_df,
            FUN = sum) #aggregating data by location


# Append datasets ---------------------------------------------------------
conflict <- rbind(conflict_df,gtd_df)

# Overlaying Conflict data w/ subdist -------------------------------------
coordinates(conflict) <- ~lon+lat
crs(conflict) <- CRS("+init=epsg:4326")
conflict <- spTransform(conflict, CRS(UTM_IRQ))

df_poly <- over(conflict,iraq_adm3) #overlay the conflict data on sub-districts 

conflict@data
conflict$uid <- df_poly$uid #extracting the unique id for sub-districts
conflict <- conflict[!is.na(conflict$uid),] #drop all obs in the row if uid is NA

conflict@data <- 
  aggregate(no_of_conflicts ~ uid + year,
            data = conflict@data,
            FUN = sum) #aggregating data


# Creating a unique ID ----------------------------------------------
conflict$conflict_id <- 1:nrow(conflict) #create a unique id


# Merging  ----------------------------------------------------------------
iraq_adm3@data <- merge(iraq_adm3@data, conflict@data, by = "uid") #merge with blank dtb

head(iraq_adm3@data) #check the merging
# Export ------------------------------------------------------------------
saveRDS(iraq_adm3, file.path(project_file_path, 
                             "Data", "CSO Subdistricts", "FinalData",  
                             "individual_files","irq_conflict.Rds"))



  
