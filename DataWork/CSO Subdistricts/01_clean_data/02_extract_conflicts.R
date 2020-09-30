## Extract Conflict Data

# Load Data --------------------------------------------------------------------
conflict_df <- read_excel(file.path(project_file_path,
                                    "Data", "ACLED","RawData",
                                    "MiddleEast_2016-2018_Dec01.xlsx"))
subdists <- readRDS(file.path(project_file_path ,"Data", "CSO Subdistricts", 
                              "FinalData", "subdistrict_timeinvariant_data_sp.Rds"))

iraq_adm3 <- readRDS(file.path(project_file_path, 
                               "Data", "CSO Subdistricts", "FinalData",  
                               "individual_files","irq_blank.Rds"))

# Extract Data ----------------------------------------------------------------
conflict_df <- conflict_df[which(conflict_df$COUNTRY == "Iraq"),names(conflict_df) %in% 
                                  c("YEAR","EVENT_TYPE","LOCATION", "LATITUDE", "LONGITUDE")] #subset the data


# Cleaning ----------------------------------------------------------------
names(conflict_df)[names(conflict_df) == "LONGITUDE"] <- "lon"
names(conflict_df)[names(conflict_df) == "LATITUDE"] <- "lat"
names(conflict_df)[names(conflict_df) == "YEAR"] <- "year"
names(conflict_df)[names(conflict_df) == "LOCATION"] <- "location"

conflict_df$no_of_conflicts <- 1 #Create a count variable for conflict
conflict_df <- 
  aggregate(no_of_conflicts ~ lon + lat + year,
            data = conflict_df,
            FUN = sum) #aggregating data by location


# Overlaying Conflict data w/ subdist -------------------------------------
coordinates(conflict_df) <- ~lon+lat
crs(conflict_df) <- crs(subdists)#assigning the same crs


df_poly <- over(conflict_df,subdists) #overlay the conflict data on sub-districts 
conflict_df <- as.data.frame(conflict_df)


conflict_df$uid <- df_poly$uid #extracting the unique id for sub-districts
conflict_df <- conflict_df[!is.na(conflict_df$uid),] #drop all obs in the row if uid is NA

conflict_df <- 
  aggregate(no_of_conflicts ~ uid+year,
            data = conflict_df,
            FUN = sum) #aggregating data


# Creating a unique ID ----------------------------------------------
conflict_df$conflict_id <- 1:nrow(conflict_df) #create a unique id


# Merging  ----------------------------------------------------------------
iraq_adm3@data <- merge(iraq_adm3@data, conflict_df, by = "uid") #merge with blank dtb

head(iraq_adm3@data) #check the merging
# Export ------------------------------------------------------------------
saveRDS(iraq_adm3, file.path(project_file_path, 
                             "Data", "CSO Subdistricts", "FinalData",  
                             "individual_files","irq_conflict.Rds"))


