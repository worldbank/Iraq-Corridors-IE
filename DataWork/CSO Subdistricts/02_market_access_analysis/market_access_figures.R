# Iraq IE
# Distance to Roads

# Load Data --------------------------------------------------------------------
iraq_adm3 <- readRDS(file.path(project_file_path, "Data", "CSO Subdistricts", "FinalData", 
                               "subdistrict_population_marketaccess.Rds"))

# Log Market Access ------------------------------------------------------------
MA_vars <- names(iraq_adm3)[grepl("MA_", names(iraq_adm3))]

for(var in MA_vars){
  iraq_adm3[[var]] <- iraq_adm3[[var]] %>% quantcut(q=20) %>% as.numeric()
}

# Road Length ------------------------------------------------------------------
iraq_adm3$road_length_km_primary %>% summary()

ggplot(data=iraq_adm3@data) +
  geom_histogram(aes(x=road_length_km_primary), color="black", fill="gray60") +
  theme_minimal() +
  labs(x="Road Length (km)",
       y="Number of Sub-Districts") +
ggsave(file.path(project_file_path, "Data", "CSO Subdistricts", "Outputs", "figures", "road_length_hist.png"), height=6, width=6)

# Map --------------------------------------------------------------------------
iraq_adm3$id <- row.names(iraq_adm3)
iraq_adm3_tidy <- tidy(iraq_adm3)
iraq_adm3_tidy <- merge(iraq_adm3_tidy, iraq_adm3, by="id")

p1 <- ggplot() +
  geom_polygon(data=iraq_adm3_tidy, aes(x=long, y=lat, group=group, fill=MA_rdlength_theta3_8), color="black") +
  labs(fill = "Market\nAccess\nGroup",
       title = "Market Access (theta = 3.8)\n ") +
  scale_fill_continuous(type = "viridis") +
  theme_void() +
  coord_quickmap() +
  theme(plot.title = element_text(hjust = 0.5))

p2 <- ggplot() +
  geom_polygon(data=iraq_adm3_tidy, aes(x=long, y=lat, group=group, fill=MA_rdlength_theta3_8_exclude100km), color="black") +
  labs(fill = "Market\nAccess\nGroup",
       title = "Market Access (theta = 3.8)\nExcluding Areas within 100km") +
  scale_fill_continuous(type = "viridis") +
  theme_void() +
  coord_quickmap() +
  theme(plot.title = element_text(hjust = 0.5))

p_all <- ggarrange(p1, p2)
ggsave(p_all, filename = file.path(project_file_path, "Data", "CSO Subdistricts", "Outputs", "figures", "market_access.png"), height=6, width=12)
ggsave(p1, filename = file.path(project_file_path, "Data", "CSO Subdistricts", "Outputs", "figures", "market_access_3_8.png"), height=6, width=6)
ggsave(p2, filename = file.path(project_file_path, "Data", "CSO Subdistricts", "Outputs", "figures", "market_access_3_8_exclude100km.png"), height=6, width=6)

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

#### basemap
north_center_basemap <- get_stamenmap(bbox = c(left = north_center[1,1],
                                bottom = north_center[2,1],
                                right = north_center[1,2],
                                top = north_center[2,2]),
                       maptype = "toner", 
                       crop = T,
                       zoom = 8)

p_north_3_8 <- ggmap(north_center_basemap) +
  geom_polygon(data=iraq_adm3_north_tidy, aes(x=long, y=lat, group=group, fill=MA_rdlength_theta3_8), 
               alpha = .7, color=NA) +
  scale_fill_continuous(type = "viridis", limits = c(0,20)) +
  labs(fill = "Market\nAccess\nGroup",
       title = "Market Access (theta = 3.8)\n ") +
  theme_void() +
  coord_quickmap() +
  theme(plot.title = element_text(hjust = 0.5))

p_north_3_8_exclude <- ggmap(north_center_basemap) +
  geom_polygon(data=iraq_adm3_north_tidy, aes(x=long, y=lat, group=group, fill=MA_rdlength_theta3_8_exclude10km), 
               alpha = .7, color=NA) +
  scale_fill_continuous(type = "viridis", limits = c(0,20)) +
  labs(fill = "Market\nAccess\nGroup",
       title = "Market Access (theta = 3.8)\nExcluding Areas within 10km") +
  theme_void() +
  coord_quickmap() +
  theme(plot.title = element_text(hjust = 0.5))

# Focused on South -------------------------------------------------------------

#### bbox in north
south_center <- data.frame(id = 1, lat = 31.102454, lon = 46.249050)
coordinates(south_center) <- ~lon+lat
south_center <- gBuffer(south_center, width=150/111.12)
south_center <- south_center@bbox

#### Cropped shapefile
iraq_adm3_south <- crop(iraq_adm3, south_center)
iraq_adm3_south$id <- row.names(iraq_adm3_south)
iraq_adm3_south_tidy <- tidy(iraq_adm3_south)
iraq_adm3_south_tidy <- merge(iraq_adm3_south_tidy, iraq_adm3_south, by="id")

#### basemap
south_center_basemap <- get_stamenmap(bbox = c(left = south_center[1,1],
                                               bottom = south_center[2,1],
                                               right = south_center[1,2],
                                               top = south_center[2,2]),
                                      maptype = "toner", 
                                      crop = T,
                                      zoom = 8)

p_south_3_8 <- ggmap(south_center_basemap) +
  geom_polygon(data=iraq_adm3_south_tidy, aes(x=long, y=lat, group=group, fill=MA_rdlength_theta3_8), 
               alpha = .7, color=NA) +
  scale_fill_continuous(type = "viridis", limits = c(0,20)) +
  labs(fill = "Market\nAccess\nGroup",
       title = "Market Access (theta = 3.8)\n ") +
  theme_void() +
  coord_quickmap() +
  theme(plot.title = element_text(hjust = 0.5))

p_south_3_8_exclude <- ggmap(south_center_basemap) +
  geom_polygon(data=iraq_adm3_south_tidy, aes(x=long, y=lat, group=group, fill=MA_rdlength_theta3_8_exclude100km), 
               alpha = .7, color=NA) +
  scale_fill_continuous(type = "viridis", limits = c(0,20)) +
  labs(fill = "Market\nAccess\nGroup",
       title = "Market Access (theta = 3.8)\nExcluding Areas within 100km") +
  theme_void() +
  coord_quickmap() +
  theme(plot.title = element_text(hjust = 0.5))

# Export Focused on Project Areas ----------------------------------------------

p_northsouth <- ggarrange(p_north_3_8 , p_south_3_8, common.legend=T,
                          legend="bottom")
ggsave(p_northsouth, filename = file.path(project_file_path, "Data", "CSO Subdistricts", "Outputs", "figures", "market_access_northsouth.png"), height=6, width=12)

p_northsouth_exclude <- ggarrange(p_north_3_8_exclude , p_south_3_8_exclude, common.legend=T,
                          legend="bottom")
ggsave(p_northsouth_exclude, filename = file.path(project_file_path, "Data", "CSO Subdistricts", "Outputs", "figures", "market_access_northsouth_exclude.png"), height=6, width=12)








