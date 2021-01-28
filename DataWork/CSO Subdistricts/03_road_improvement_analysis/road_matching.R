#Iraq

#Find the distance between Baghdad and other roads in Iraq -- primary, secondary, trunk


# Load Data ---------------------------------------------------------------
r7r8_subdist <- readRDS(file.path(project_file_path, 
                                      "Data","CSO Subdistricts","FinalData", 
                                      "subdistrict_data_df_clean.Rds"))

irq_dist_baghdad <- readRDS(file.path(project_file_path, 
                            "Data", "CSO Subdistricts", "FinalData",  
                            "individual_files","irq_dist_cities.Rds")) %>% st_as_sf()

roads <- readOGR(dsn = file.path(project_file_path,
                       "Data", "OpenStreetMap", 
                       "RawData","shp_files"), layer = "gis_osm_roads_free_1")%>% st_as_sf()

iraq_adm3 <- readRDS(file.path(project_file_path, 
                               "Data", "CSO Subdistricts", "FinalData",  
                               "individual_files","irq_adm_info.Rds"))%>% st_as_sf()

grid_r7r8 <- readRDS(file.path(project_file_path, "Data", "VIIRS", "FinalData", 
                     "near_r78ab_roads", "Separate Files Per Variable",
                     "iraq_grid_panel_viirs.Rds"))

# Districts near r7r8 -----------------------------------------------------
#limit to the 20km buffer
r7r8_20km <- r7r8_subdist[which(r7r8_subdist$dist_r78_km <= 20),]

#find the maximum distance to Baghdad
max(r7r8_20km$distance_to_baghdad, na.rm = TRUE)
min(r7r8_20km$distance_to_baghdad, na.rm = TRUE)


# Filter by Distance to Baghdad -------------------------------------------
#limit to the range of 200km - 500km 
irq_dist_baghdad <- irq_dist_baghdad[which(irq_dist_baghdad$distance_to_baghdad <= 500 & 
                                             irq_dist_baghdad$distance_to_baghdad >= 200),]
#check the districts that overlap
unique(irq_dist_baghdad$uid)
list <- unique(r7r8_20km$uid) #create a list of those districts that overlap with r7r8

#remove districts that overlap with r7r8
irq_dist_baghdad$overlap_r7r8 <- ifelse(irq_dist_baghdad$uid %in% list,1,0)
irq_dist_nor7r8 <- irq_dist_baghdad[which(irq_dist_baghdad$overlap_r7r8 == 0),]

#transform roads data
roads <- st_transform(roads,UTM_IRQ)
irq_dist_nor7r8 <- st_transform(irq_dist_nor7r8, UTM_IRQ)

#select trunk/primary/secondary roads
roads_trunk <- roads[which(roads$fclass == "trunk"| roads$fclass == "primary"),]

cropped_dist <- st_crop(irq_dist_nor7r8,roads_trunk)
intersect_dist <- st_intersection(irq_dist_nor7r8,roads_trunk)

ggplot()+
  geom_sf(data = iraq_adm3, fill = "white", color = "gray")+
  geom_sf(data = cropped_dist, color = "white")+
  geom_sf(data = intersect_dist, aes(color = fclass))+
  theme_void()


# Filter by Pre-trends ----------------------------------------------------
viirs_grid <- readRDS(file.path(project_file_path, "Data", "CSO Subdistricts", 
                                  "FinalData", 
                                  "subdistrict_data_df.Rds"))


 names(viirs_grid)
matched_grid <- merge(viirs_grid,cropped_dist)
#subset the grid data
vars <- c("uid","distance_to_baghdad","viirs_mean","year","month","ADM3_EN","geometry")
matched_grid <- matched_grid[vars]

#create a pre-trends line
annual_viirs <-
  summaryBy(viirs_mean ~ year,
            data = matched_grid,
            FUN = median)



annual_viirs_r7r8 <- 
  summaryBy(avg_rad_df ~ year,
           data = grid_r7r8,
           FUN = median)

#pre-trends -- before r7r8 opened
annual_viirs <- annual_viirs[which(annual_viirs$year <2017),]
annual_viirs_r7r8 <- annual_viirs_r7r8[which(annual_viirs_r7r8$year <2017),]

#plot
ggplot()+
  geom_line(aes(x = year, y = viirs_mean.median, color = "matched roads"), data = annual_viirs)+
  geom_line(aes(x = year, y = avg_rad_df.median, color = "r7r8"), data = annual_viirs_r7r8)+
  labs(color = "Roads")+
  scale_colour_brewer(palette = "Set1")+
  theme_minimal()

# Parse out each road -----------------------------------------------------
 road_one <- intersect_dist[is.na(intersect_dist$name),]

ggplot()+
  geom_sf(data = iraq_adm3, fill = "white", color = "gray")+
  geom_sf(data = cropped_dist, color = "white")+
  geom_sf(data = road_one, aes(color = fclass))+
  theme_void()
