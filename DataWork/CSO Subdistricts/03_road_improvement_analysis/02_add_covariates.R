# Iraq IE
# Add covariates

# Loading Data set ---------------------------------------------------------
subdists <- readRDS(file.path(dsn = final_data_file_path ,"CSO Subdistricts", "FinalData", "subdistrict_timeinvariant_data_sp.Rds"))
ntl_subdist_monthly <- readRDS(file.path(dsn = final_data_file_path ,"CSO Subdistricts", "FinalData", "subdistrict_data_df.Rds"))
ntl_subdist_buffer  <- readRDS(file.path(dsn = final_data_file_path, "Cleaned Data for Preliminary Analysis", "FinalData", "ntl_subdist_buffer.Rds"))
lsms_df <- read_dta(file.path(final_data_file_path, "LSMS", "FinalData", "lsms_2012_merged_hh.dta"))
conflict_df <- read_excel(file.path(final_data_file_path,"ACLED","RawData","MiddleEast_2016-2018_Dec01.xlsx"))
settlement_sf <- st_read(file.path(final_data_file_path,"OCHA Populated Places", "RawData", "irq_pplp_ocha_20140722.shp"))


# Add NTL for month + year ------------------------------------------------

ntl_month_year <- 
  aggregate(viirs_mean ~ ADM3_EN+uid+year+month+viirs_time_id,
            data = ntl_subdist_monthly,
            FUN = sum) #aggregating data

ntl_subdist <- merge(ntl_subdist_buffer,ntl_month_year,byid="uid") #merging

remove(ntl_month_year,ntl_subdist_buffer,ntl_subdist_monthly)

# Road Improvement ----------------------------------------------
ntl_subdist <- 
  mutate(ntl_subdist,
         roadimprovement = year > 2014) 


# Change Population variable (use population growth to impute) -------------------------
##Function to apply
pop_est <- function(year,population){
  if (year == 2016){
    return(population*(1+2.5))
  }
  else if (year == 2017){
    return(population*((1+2.5)^2))
  }
  
  else if (year == 2018){
    return(population*((1+2.5)^3))
  }
  else if (year == 2019){
    return(population*((1+2.5)^4))
  }
  return(population)  
}

#!FIX ME - memory issue!
ntl_subdist$pop_new <- sapply(X = ntl_subdist$year, FUN = pop_est,population = ntl_subdist$population) 

# Distance to Baghdad -----------------------------------------------------

ntl_subdist <- st_transform(ntl_subdist, "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0") #transform to lat/long from metric system
baghdad <-data.frame(name = "baghdad",
                     lat = 33.3152, 
                     lon = 44.3661)

##take centroid of each shape
ntl_subdist <- ntl_subdist  %>% 
  mutate(lon = map_dbl(geometry, ~st_centroid(.x)[[1]]),
         lat = map_dbl(geometry, ~st_centroid(.x)[[2]]))

##calculate distance between sub-district and Baghdad
ntl_subdist$distance_to_baghdad <-
  sqrt((ntl_subdist$lon - baghdad$lon)^2 + (ntl_subdist$lat - baghdad$lat)^2)*111.12

remove(baghdad)

# Average Household Income from LSMS --------------------------------------------

## creating the household expenditure variable
lsms_df$average_hh_exp <- lsms_df$expenditure/lsms_df$hh_size

##sub-setting the data to include district, governorate and average exp
lsms_subset_df <-
  summaryBy(average_hh_exp ~ latitude + longitude, FUN = mean, data = lsms_df)

remove(lsms_df)

##indicates that the expenditure refers to 2012
lsms_subset_df$year<- 2012

##rename to merge with main data set
names(lsms_subset_df)[names(lsms_subset_df) == "longitude"] <- "lon"
names(lsms_subset_df)[names(lsms_subset_df) == "latitude"] <- "lat"

## remove columns with missing lat/lon
lsms_subset_df <- lsms_subset_df[!is.na(lsms_subset_df$lat),]
lsms_subset_df <- lsms_subset_df[!is.na(lsms_subset_df$lon),]

##convert to spdf
coordinates(lsms_subset_df) <- ~lon+lat

##ensure both polygon and coordinates have the same coordinate system
crs(lsms_subset_df) <- crs(subdists)

##overlaying location from lsms with polygon
df_poly <- over(lsms_subset_df,subdists)

## selecting the ADM3_EN column from this combined data frame
list <- select(df_poly,ADM3_EN,ADM2_EN,uid)
remove(df_poly)

##convert back to df
lsms_subset_df <- as.data.frame(lsms_subset_df)

##create a common ID for LSMS
lsms_subset_df$id <- 1:nrow(lsms_subset_df)
list$id <- 1:nrow(list)

##merge subset with list
lsms_subset_df <- left_join(lsms_subset_df,list,by="id")

##drop all if uid is NA
lsms_subset_df <- lsms_subset_df[!is.na(lsms_subset_df$uid),]

##aggregate at the sub-district level
lsms_subset_df <- 
  aggregate(average_hh_exp.mean ~ uid+year,
            data = lsms_subset_df,
            FUN = mean) #aggregating data

##final merge
ntl_subdist <- left_join(ntl_subdist,lsms_subset_df, by = c("uid", "year"))

remove(lsms_subset_df,list)

# Conflict ----------------------------------------------------------------

##subset the data
conflict_df_iraq <- conflict_df[which(conflict_df$COUNTRY == "Iraq"),names(conflict_df) %in% 
  c("YEAR","EVENT_TYPE","LOCATION", "LATITUDE", "LONGITUDE")]
remove(conflict_df)

##Create a count variable for conflict
conflict_df_iraq$no_of_conflicts <- 1

##aggregate by location
conflict_df_iraq <- 
  aggregate(no_of_conflicts ~ LONGITUDE + LATITUDE + LOCATION + YEAR,
            data = conflict_df_iraq,
            FUN = sum) #aggregating data

## rename to merge with main data set (subdists)
names(conflict_df_iraq)[names(conflict_df_iraq) == "LONGITUDE"] <- "lon"
names(conflict_df_iraq)[names(conflict_df_iraq) == "LATITUDE"] <- "lat"
names(conflict_df_iraq)[names(conflict_df_iraq) == "YEAR"] <- "year"

#convert to spdf
coordinates(conflict_df_iraq) <- ~lon+lat

##ensure both polygon and coordinates have the same coordinate system
crs(conflict_df_iraq) <- crs(subdists)

##overlaying location from lsms with polygon
df_poly <- over(conflict_df_iraq,subdists)

## selecting the ADM3_EN column from this combined data frame
list <- select(df_poly,ADM3_EN,ADM2_EN,uid)
remove(df_poly)

##converting back to data frame
conflict_df_iraq <- as.data.frame(conflict_df_iraq)

##create a common ID
conflict_df_iraq$id <- 1:nrow(conflict_df_iraq)
list$id <- 1:nrow(list)


##merge subset with list
conflict_df_iraq <- left_join(conflict_df_iraq,list,by="id")

##drop all if uid is NA
conflict_df_iraq <- conflict_df_iraq[!is.na(conflict_df_iraq$uid),]

##aggregate at the sub-district level
conflict_df_iraq <- 
  aggregate(no_of_conflicts ~ uid+year,
            data = conflict_df_iraq,
            FUN = sum) #aggregating data

##final merge
ntl_subdist <- left_join(ntl_subdist,conflict_df_iraq, by = c("uid", "year"))

remove(conflict_df_iraq,list)

# Settlement Data ------------------------------------------------------------

##subsetting the data
settlement_sf$no_of_settlements <- 1

##aggregate data by geometry
settlement_sf <- 
  aggregate(no_of_settlements ~ Latitude + Longitude + A1NameEn,
            data = settlement_sf,
            FUN = sum) #aggregating data

## rename to merge with main data set (subdists)
names(settlement_sf)[names(settlement_sf) == "Longitude"] <- "lon"
names(settlement_sf)[names(settlement_sf) == "Latitude"] <- "lat"

##convert to spdf
coordinates(settlement_sf) <- ~lon+lat

##ensure both polygon and coordinates have the same coordinate system
crs(settlement_sf) <- crs(subdists)

##overlaying location from settlement_sf with polygon
df_poly <- over(settlement_sf,subdists)

## selecting the ADM3_EN column from this combined data frame
list <- select(df_poly,ADM3_EN,ADM2_EN,uid)
remove(df_poly)

##converting back to data frame
settlement_sf <- as.data.frame(settlement_sf)

##create a common ID
settlement_sf$id <- 1:nrow(settlement_sf)
list$id <- 1:nrow(list)

##merge subset with list
settlement_sf <- left_join(settlement_sf,list,by="id")

##drop all if uid is NA
settlement_sf <- settlement_sf[!is.na(settlement_sf$uid),]

##Add variable to denote year of data
settlement_sf$year <- 2014

##aggregate at the sub-district level
settlement_sf <- 
  aggregate(no_of_settlements ~ uid + year,
            data = settlement_sf,
            FUN = sum) #aggregating data

##final merge
ntl_subdist <- left_join(ntl_subdist,settlement_sf, by = c("uid", "year"))

remove(settlement_sf,list)

#Export -----------------------------------------------------------------
saveRDS(ntl_subdist, file=file.path(final_data_file_path, "Cleaned Data for Preliminary Analysis", "FinalData", "ntl_subdist_final.Rds"))
remove(ntl_subdist,subdists)
