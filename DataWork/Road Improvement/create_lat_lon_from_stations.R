#station to lat/lon


# Load Data ---------------------------------------------------------------
stations <- read.csv(file.path(data_file_path,"Road Improvement", "All Stations",
                               "stations.csv"))

r7r8 <- readRDS(file.path(data_file_path,"Project Roads", "R7_R8ab", 
                          "FinalData","r7_r8ab.RDS"))

#split into two roads
r7 <- r7r8[r7r8$road == "r7",]
r8 <- r7r8[r7r8$road != "r7",]

#transform projection
r7 <- spTransform(r7,CRS(UTM_IRQ))
r8 <- spTransform(r8,CRS(UTM_IRQ))


# #1. Divide Project Road in 10m segments ---------------------------------
##check length of r7
gLength(r7,byid = F)
gLength(r8,byid = F)

## r7 = 286976.5m, r8 = 223419.5m
r7_segment <- spsample(x = r7, n = 28698, type = "regular")
r8_segment <- spsample(x = r8, n = 22342, type = "regular")

#convert utm to lat/lon
r7_segment <- spTransform(r7_segment,CRS("+proj=longlat +datum=WGS84"))
r8_segment <- spTransform(r8_segment,CRS("+proj=longlat +datum=WGS84"))

##convert to dataframe
r7_segment_df <- as.data.frame(r7_segment)
colnames(r7_segment_df)[1] <- "Longitude"
colnames(r7_segment_df)[2] <- "Latitude"

r8_segment_df <- as.data.frame(r8_segment)
colnames(r8_segment_df)[1] <- "Longitude"
colnames(r8_segment_df)[2] <- "Latitude"


# Label the stations ------------------------------------------------------
stations <- seq(from = 0, to = 28)


