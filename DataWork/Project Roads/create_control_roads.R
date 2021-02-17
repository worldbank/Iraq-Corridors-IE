#Matching Roads


# Loading Data ------------------------------------------------------------
iraq_sd <- readRDS(file.path(project_file_path,
                                          "Data","CSO Subdistricts","FinalData",
                                          "subdistrict_timeinvariant_data_sp.Rds")) %>% st_as_sf()

iraq_adm <- readRDS(file.path(project_file_path, 
                              "Data", "CSO Subdistricts", "FinalData",  
                              "individual_files","irq_blank.Rds")) %>% st_as_sf()
iraq_adm <- st_transform(iraq_adm, UTM_IRQ)

primary_routes <- st_read(file.path(project_file_path,"Data", "HDX Primary Roads", "RawData",
                                    "primary_routes.shp"))

roads <- readRDS(file.path(project_file_path,
                           "Data", "OpenStreetMap", 
                           "FinalData","iraq_roads_rds", 
                           "gis_osm_roads_free_1.Rds"))%>% st_as_sf()


r7r8 <- readRDS(file.path(project_file_path, 
                  "Data", "Project Roads", "R7_R8ab",
                  "FinalData",
                  "r7_r8ab.Rds"))%>% st_as_sf()

grid_r7r8 <- readRDS(file.path(project_file_path, "Data", "VIIRS", "FinalData", 
                               "near_r78ab_roads", "Separate Files Per Variable",
                               "iraq_grid_panel_viirs.Rds"))

# Control Road - Rest of Expressway 1 -------------------------------------
#the larger road that connects rr7r8
primary_routes_subset <- primary_routes[which(primary_routes$ROUTE_NUMB == 8),]

# Clipping Primary Roads --------------------------------------------------
#create centroid
primary_routes_subset$centroids <- primary_routes_subset %>% 
  st_centroid() %>% 
  # this is the crs from d, which has no EPSG code:
  # since you want the centroids in a second geometry col:
  st_geometry()

#separate lat/lon into two different columns
primary_routes_subset<- primary_routes_subset %>%
  mutate(lat = unlist(map(primary_routes_subset$centroids,1)),
         long = unlist(map(primary_routes_subset$centroids,2)))


#subset data set by lat, to exclude anything greater than 46 degrees
primary_routes_subset<- primary_routes_subset[which(primary_routes_subset$lat < 45.6),]

#drop lat/lon
primary_routes_subset <- subset(primary_routes_subset, select = -c(centroids,lat,long))

#Plot control road and treatment road
ggplot()+
  geom_sf(data = iraq_sd, color = "gray", fill = NA)+
  geom_sf(data = primary_routes_subset, aes(color = "control road")) +
  geom_sf(data = r7r8, aes(color = "r7r8"))+
  labs(colour = "Roads") +
  theme_void()

# Create a shapefile for control road ---------------------------------
#convert to one single shapefile
primary_routes_subset <- st_union(primary_routes_subset)

#create a buffer for 20km
primary_routes_subset <- st_transform(primary_routes_subset,UTM_IRQ)

#Create a 20km buffer
control_road <- st_buffer(primary_routes_subset, 20000)

#crop road shapefile with districts
control_road <- st_crop(iraq_adm,control_road)

#create a grid
viirs_grid <- readRDS(file.path(project_file_path, "Data", "CSO Subdistricts", 
                                "FinalData", 
                                "subdistrict_data_df.Rds"))

#overlap viirs with matched grid
matched_grid <- merge(viirs_grid,cropped_dist)
matched_grid <- subset(matched_grid,select = c(uid,viirs_mean,year,month))


# Create a pre-trends line ------------------------------------------------
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
  geom_line(aes(x = year, y = viirs_mean.median, color = "control road"), data = annual_viirs)+
  geom_line(aes(x = year, y = avg_rad_df.median, color = "r7r8"), data = annual_viirs_r7r8)+
  labs(color = "Roads")+
  scale_colour_brewer(palette = "Set1")+
  theme_minimal()
