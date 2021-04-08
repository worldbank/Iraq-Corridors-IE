## Extract LSMS Data -- Household Expenditure

# Load Data --------------------------------------------------------------------
lsms_df <- read_dta(file.path(project_file_path, 
                              "Data","LSMS", "FinalData", 
                              "lsms_2012_merged_hh.dta"))

subdists <- readRDS(file.path(project_file_path ,"Data", "CSO Subdistricts", 
                              "FinalData", "subdistrict_timeinvariant_data_sp.Rds"))

iraq_adm3 <- readRDS(file.path(project_file_path, 
                               "Data", "CSO Subdistricts", "FinalData",  
                               "individual_files","irq_blank.Rds"))

# Creating the Household Expenditure var ----------------------------------
lsms_df$avg_hh_exp <- lsms_df$expenditure/lsms_df$hh_size
lsms_df <-
  summaryBy(avg_hh_exp ~ latitude + longitude, 
            FUN = mean, data = lsms_df)

# Cleaning ----------------------------------------------------------------
lsms_df$year<- 2012 #add the year this data was collected

names(lsms_df)[names(lsms_df) == "longitude"] <- "lon"
names(lsms_df)[names(lsms_df) == "latitude"] <- "lat"

lsms_df <- lsms_df[!is.na(lsms_df$lon),] #drop all obs in the row if lon/lat is NA


# Overlaying lsms data on subdists ----------------------------------------
coordinates(lsms_df) <- ~lon+lat
crs(lsms_df) <- crs(subdists)

df_poly <- over(lsms_df,subdists) #overlaying
lsms_df <- as.data.frame(lsms_df)

lsms_df$uid <- df_poly$uid #extracting the unique id for sub-districts
lsms_df <- lsms_df[!is.na(lsms_df$uid),] #drop all obs in the row if uid is NA

lsms_df <- 
  aggregate(avg_hh_exp.mean ~ uid+year,
            data = lsms_df,
            FUN = mean) #aggregating data

# Creating a unique ID ----------------------------------------------
lsms_df$hhexp_id <- 1:nrow(lsms_df) #create a unique id

# Merging  ----------------------------------------------------------------
iraq_adm3@data <- merge(iraq_adm3@data, lsms_df, by = "uid") #merge with blank dtb

head(iraq_adm3@data) #check the merging

# Export ------------------------------------------------------------------
saveRDS(iraq_adm3, file.path(project_file_path, 
                             "Data", "CSO Subdistricts", "FinalData",  
                             "individual_files","irq_hhexp.Rds"))



