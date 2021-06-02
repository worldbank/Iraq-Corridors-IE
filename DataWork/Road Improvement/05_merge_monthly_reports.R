#Iraq IE
##Description: In this script we merge the road improvements recorded from the monthly reports
##and convert them to lat/lon to create a panel data set. Steps
#1. In the monthly reports csv, convert stations to distance from origin. For example, 
#1+000 refers to 1km from the origin
#2. Merge this column with a similar column in the csv that records distance from origin. 
#Note: In the report, road improvements are recorded in two ways. Either as stations or distances
#from origin. 
#3. Merge datasets r7, r8a and r8b with the reports datasets to add lat/lon



# Load Data ---------------------------------------------------------------
r7 <- readRDS(file.path(data_file_path, "Road Improvement",  
                "R7","FinalData", "r7_station_to_latlon.Rds"))

r8a <- readRDS(file.path(data_file_path, "Road Improvement",  
                        "R8","FinalData", "r8a_station_to_latlon.Rds"))

r8b <- readRDS(file.path(data_file_path, "Road Improvement",  
                         "R8","FinalData", "r8b_station_to_latlon.Rds"))

reports <- read.csv(file.path(data_file_path, "Road Improvement",  
                              "R7","RawData", "r7_monthly_reports.csv"))

# Cleaning Reports Data ---------------------------------------------------

# 0. Remove empty columns -------------------------------------------------

emptycols <- colSums(is.na(reports)) == nrow(reports)
reports <- reports[!emptycols] #remove empty columns
reports <- rename(reports,c("ï..r_id" = "r_id")) #rename


# 1. Convert stations to Distance from Origin -----------------------------
reports$start <- as.numeric(gsub("+",".",reports$station_from, fixed = T))
reports$end <- as.numeric(gsub("+",".",reports$station_to, fixed = T))


# 2. Merge with other column recording Distance from Origin ---------------
reports <- mutate(reports,
                  dist_from_origin_kms = ifelse(is.na(dist_from_origin),start,dist_from_origin),
                  dist_to_kms = ifelse(is.na(dist_to),end,dist_to))

# 3. Add columns for Lat/Lon ----------------------------------------------

##starting point of road improvement
reports <- merge(reports,r7,by.x = c("dist_from_origin_kms"),by.y = "dist_to_origin_kms")
reports <- rename(reports,c("Latitude" = "start_lat",
                            "Longitude"= "start_lon"))

##ending point of road improvement
reports <- merge(reports,r7,by.x = c("dist_to_kms"), by.y = "dist_to_origin_kms",
                 all.x = TRUE)
reports <- rename(reports,c("Latitude" = "end_lat",
                            "Longitude"= "end_lon"))

names(reports)

# 4. Cleaning Dataset -----------------------------------------------------
keepvars <- c("r_id","road.x","page_number","month","year",
              "station_from","start_lat","start_lon","station_to",
              "end_lat","end_lon","pavement","street_furniture",
              "dist_from_origin_kms","dist_to_kms","notes")
reports <- reports[keepvars]
reports <- reports[order(reports$r_id),] #sort by id


# 5. Export ---------------------------------------------------------------
saveRDS(reports, file.path(data_file_path, "Road Improvement",  
                                 "R7","FinalData", "r7_station_to_latlon_final.Rds"))
# Plot --------------------------------------------------------------------

##highlight improvements for 2017
reports_2017 <- reports[which(reports$year == 2017),]
height = 7
width = 6

ggplot()+
  geom_line(aes(x = Longitude, y = Latitude), data = r7)+
  geom_line(aes(x = Longitude, y = Latitude), data = r8a)+
  geom_line(aes(x = Longitude, y = Latitude), data = r8b)+
  geom_point(aes(x = end_lon, y = end_lat, color = "road upgrades"), 
               data = reports_2017)+
  geom_point(aes(x = start_lon, y = start_lat, color = "road upgrades"), 
               data = reports_2017)+
  labs(color = "", title = "Road Upgrades in 2017")+
  theme_minimal()
  #ggsave(file.path(data_file_path, "Road Improvement", "R7",
                   #"Outputs","road_upgrades_r7_2017.png"))




