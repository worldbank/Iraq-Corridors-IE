#Extract Road Improvement Data

# Load Road Improvement Data ----------------------------------------------
road_improve <- read_excel(file.path(project_file_path, 
                           "Project Documents","DIME Notes from Reports",
                           "1_road_improvement_data.xlsx"), sheet = "R7")

coords <- read_delim(file.path(project_file_path,
                     "Data","Road Improvement","R7","R7-stations.txt"),
                     "\t", escape_double = FALSE, trim_ws = TRUE, skip = 2)

iraq_adm3 <- readRDS(file.path(project_file_path, 
                               "Data", "CSO Subdistricts", "FinalData",  
                               "individual_files","irq_adm_info.Rds"))

iraq_adm3 <- st_as_sf(iraq_adm3)
iraq_cropped <- st_crop(iraq_adm3, xmin = 45, xmax = 49,
                          ymin = 30, ymax = 32)

roads <- readRDS(file.path(project_file_path,
                           "Data", "HDX Primary Roads", "FinalData",
                           "r7_r8ab","r7_r8ab_prj_rd.Rds"))
roads <- st_as_sf(roads)
road_r7 <- roads[1,]

remove(iraq_adm3,roads)

# Rename Variables --------------------------------------------------------
names(coords)[names(coords) == "Easting (m)"] <- "lon"
names(coords)[names(coords) == "Northing (m)"] <- "lat"
names(coords)[names(coords) == "R7-Project Station"] <- "station"


# Transform UTM to Lat/Lon ------------------------------------------------

utms <- SpatialPoints(coords[, c("lon", "lat")], proj4string=CRS("+proj=utm +zone=38N")) #create UTM matrix
longlats <- spTransform(utms, CRS("+proj=longlat")) #transform
crs(longlats) <- crs(iraq_cropped)
crs(longlats) <- crs(road_r7)
longlats <- as.data.frame(longlats)

coords$lon_new <- longlats$lon
coords$lat_new <- longlats$lat

remove(utms,longlats)

# Plots -------------------------------------------------------------------
label <- c("1+753","9+433","131+419")
coords$station_lab <- ifelse(coords$station %in% label,
                            ifelse(coords$X9 %in% NA,paste(coords$station),paste(coords$X9,"-",coords$station)),NA)


p <- ggplot() +
    geom_sf(data = iraq_cropped, color = "grey50", fill = NA) +
    geom_sf(data = road_r7, color = "blue", fill = NA, aes(colour = route)) +
    geom_point(data = coords, aes(x=lon_new, y=lat_new),
               color = ifelse(coords$station_lab %in% NA,"grey50", "red")) +
    geom_text_repel(data = coords, aes(x=lon_new, y=lat_new, label = station_lab),
                    size = 3, lineheight = 1, color = "red", hjust = -0.4, vjust = -0.4) +
    labs(title = "Road Improvement Stations - R7") +
    theme_classic()

png(file.path(project_file_path,"Figures","R7-stations.png"))
print(p)
dev.off()

    




