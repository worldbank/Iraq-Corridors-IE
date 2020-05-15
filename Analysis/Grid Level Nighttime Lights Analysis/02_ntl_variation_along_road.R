# Iraq IE
# Distance to Roads

# Load Data --------------------------------------------------------------------
viirs_grid <- readRDS(file.path(final_data_file_path, "VIIRS Grid", "iraq_viirs_grid_data.Rds"))

distance_from_road <- 20

# Prep Data --------------------------------------------------------------------
viirs_grid <- viirs_grid[viirs_grid$distance_project_roads <= distance_from_road,]

viirs_grid <- summaryBy(avg_rad_df ~ lon + lat + year, data=viirs_grid, keep.names = T)

# Log
viirs_grid$avg_rad_df_ln <- log(viirs_grid$avg_rad_df+1)

# Distance to End Cities
safwan <- data.frame(name = "safwan",
           lat = 30.109842, 
           lon = 47.716882)

basra <- data.frame(name = "basra",
           lat = 30.520510, 
           lon = 47.775039)

viirs_grid$distance_safwan <- sqrt((viirs_grid$lon - safwan$lon)^2 + (viirs_grid$lat - safwan$lat)^2) * 111.12
viirs_grid$distance_basra <- sqrt((viirs_grid$lon - basra$lon)^2 + (viirs_grid$lat - basra$lat)^2) * 111.12

viirs_grid$distance_safwan_basra_min <- pmin(viirs_grid$distance_safwan, viirs_grid$distance_basra)
viirs_grid$distance_safwan_basra_min <- max(viirs_grid$distance_safwan_basra_min) - viirs_grid$distance_safwan_basra_min

# Figure -----------------------------------------------------------------------
height = 4
width = 8
viirs_fig <- ggplot() +
  geom_line(data=viirs_grid[viirs_grid$year %in% 2013,], aes(x=distance_safwan_basra_min, y=avg_rad_df_ln, color="2013"),alpha=0.6, size=1) +
  geom_line(data=viirs_grid[viirs_grid$year %in% 2017,], aes(x=distance_safwan_basra_min, y=avg_rad_df_ln, color="2017"),alpha=0.6,size=1) +
  scale_color_manual(values=c("blue","orange2")) +
  labs(x="Distance Along Expressway (km): East to West",
       y="Nighttime Lights Radiance",
       title=paste0("Nighttime Lights Along Expressway: ",distance_from_road,"km from Road"),
       color = "Nighttime\nLights") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face="bold")) +
  guides(colour = guide_legend(override.aes = list(alpha = 1)))
ggsave(viirs_fig, filename=file.path(figures_file_path, paste0("viirs_along_project_roads_",distance_from_road,"km.png")), height=height, width=width)  

