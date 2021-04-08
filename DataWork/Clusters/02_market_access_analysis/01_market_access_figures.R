#Market access figures

# Load Data --------------------------------------------------------------------
iraq_adm3 <- readRDS(file.path(data_file_path, "Clusters", "FinalData", 
                               "subdistrict_timeinvariant_data_sp.Rds"))

gs <- readRDS(file.path(data_file_path, "Project Roads","Girsheen-Suheila Road","FinalData", 
                        "gs_road_polyline.Rds"))


# Log Market Access ------------------------------------------------------------
MA_vars <- names(iraq_adm3)[grepl("MA_", names(iraq_adm3))]

for(var in MA_vars){
  iraq_adm3[[var]] <- iraq_adm3[[var]] %>% quantcut(q=20) %>% as.numeric()
}

# Road Length ------------------------------------------------------------------
iraq_adm3$road_length_km_primary %>% summary()

ggplot(data=iraq_adm3@data) +
  geom_histogram(aes(x=road_length_km_primary), color="black", fill="gray60", bins = 30) +
  theme_minimal() +
  labs(x="Road Length (km)",
       y="Number of Clusters") +
  ggsave(file.path(data_file_path, "Clusters", "Outputs", 
                   "road_length_hist.png"), height=6, width=6)

# Focused on North -------------------------------------------------------------

#### bbox in north
north_center <- data.frame(id = 1, lat = 36.417783, lon = 43.519662)
coordinates(north_center) <- ~lon+lat
north_center <- gBuffer(north_center, width=150/111.12)
north_center <- north_center@bbox

#### Cropped shapefile
iraq_adm3_north <- crop(iraq_adm3, north_center)
iraq_adm3_north$id <- row.names(iraq_adm3_north)
iraq_adm3_north_tidy <- tidy(iraq_adm3_north)
iraq_adm3_north_tidy <- merge(iraq_adm3_north_tidy, iraq_adm3_north, by="id")


#### gs road file
gs_tidy <- tidy(gs)

#### basemap
north_center_basemap <- get_stamenmap(bbox = c(left = north_center[1,1],
                                               bottom = north_center[2,1],
                                               right = north_center[1,2],
                                               top = north_center[2,2]),
                                      maptype = "toner", 
                                      crop = T,
                                      zoom = 8)



# Before GS opened --------------------------------------------------------

#exclude 10km
ma_beforegs_exclude10km <- ggmap(north_center_basemap) +
  geom_path(data = gs_tidy, aes(x=long, y = lat, color = "Girsheen - Suheila"))+
  geom_polygon(data=iraq_adm3_north_tidy, aes(x=long, y=lat, group=group, 
                                              fill=MA_tt_rdlength_theta3_8_exclude10km_speed_limit_gs_before), 
               alpha = .7, color=NA) +
  scale_fill_continuous(type = "viridis", limits = c(0,20)) +
  labs(fill = "Market\nAccess\nGroup",
       title = "Market Access (theta = 3.8)\nExcluding 10km", 
       color = "") +
  theme_void() +
  coord_quickmap() +
  theme(plot.title = element_text(hjust = 0.5))+
  ggsave(file.path(data_file_path, "Clusters", "Outputs", 
                   "ma_3_8_beforegs_exclude10km.png"), height=6, width=6)


#Exclude 20km
ma_beforegs_exclude20km <- ggmap(north_center_basemap) +
  geom_polygon(data = gs_tidy, aes(x=long, y = lat, color = "Girsheen - Suheila"))+
  geom_polygon(data=iraq_adm3_north_tidy, aes(x=long, y=lat, group=group, 
                                              fill=MA_tt_rdlength_theta3_8_exclude20km_speed_limit_gs_before), 
               alpha = .7, color=NA) +
  scale_fill_continuous(type = "viridis", limits = c(0,20)) +
  labs(fill = "Market\nAccess\nGroup",
       title = "Market Access (theta = 3.8)\nExcluding 10km",
       color = "") +
  theme_void() +
  coord_quickmap() +
  theme(plot.title = element_text(hjust = 0.5))+
  ggsave(file.path(data_file_path, "Clusters", "Outputs", 
                   "ma_3_8_beforegs_exclude10km.png"), height=6, width=6)


#Exclude 50km
ma_beforegs_exclude50km <- ggmap(north_center_basemap) +
  geom_path(data = gs_tidy, aes(x=long, y = lat, color = "Girsheen - Suheila"))+
  geom_polygon(data=iraq_adm3_north_tidy, aes(x=long, y=lat, group=group, 
                                              fill=MA_tt_rdlength_theta3_8_exclude50km_speed_limit_gs_before), 
               alpha = .7, color=NA) +
  scale_fill_continuous(type = "viridis", limits = c(0,20)) +
  labs(fill = "Market\nAccess\nGroup",
       title = "Market Access (theta = 3.8)\nExcluding 50km",
       color = "")+
  theme_void() +
  coord_quickmap() +
  theme(plot.title = element_text(hjust = 0.5))+
  ggsave(file.path(data_file_path, "Clusters", "Outputs", 
                   "ma_3_8_beforegs_exclude50km.png"), height=6, width=6)


