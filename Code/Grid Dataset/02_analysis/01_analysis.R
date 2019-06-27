# Iraq IE
# Distance to Roads

# Load Data --------------------------------------------------------------------
viirs_grid <- readRDS(file.path(final_data_file_path, "VIIRS Grid", "iraq_viirs_grid_data.Rds"))

viirs_grid$viirs_1greater <- as.numeric(viirs_grid$avg_rad_df >= 1)
viirs_grid$viirs_2greater <- as.numeric(viirs_grid$avg_rad_df >= 2)
viirs_grid$viirs_5greater <- as.numeric(viirs_grid$avg_rad_df >= 5)

viirs_grid_project_roads <- viirs_grid[viirs_grid$distance_project_roads <= 10,][,j=list(viirs_mean = mean(avg_rad_df, na.rm = TRUE),
                                                                                         viirs_1greater_prop = mean(viirs_1greater, na.rm = TRUE),
                                                                                         viirs_2greater_prop = mean(viirs_2greater, na.rm = TRUE),
                                                                                         viirs_5greater_prop = mean(viirs_5greater, na.rm = TRUE)), by = list(year, month)]
viirs_grid_project_roads$roads <- "Project Roads"

viirs_grid_highways <- viirs_grid[(viirs_grid$distance_primary_route <= 10) & 
                                    (viirs_grid$distance_project_roads >= 10),][,j=list(viirs_mean = mean(avg_rad_df, na.rm = TRUE),
                                                                                        viirs_1greater_prop = mean(viirs_1greater, na.rm = TRUE),
                                                                                        viirs_2greater_prop = mean(viirs_2greater, na.rm = TRUE),
                                                                                        viirs_5greater_prop = mean(viirs_5greater, na.rm = TRUE)), by = list(year, month)]
viirs_grid_highways$roads <- "Primary Roads"
rm(viirs_grid)

viirs_grid_monthly <- bind_rows(viirs_grid_project_roads, viirs_grid_highways) %>% as.data.frame
viirs_grid_monthly <- melt(viirs_grid_monthly, id=c("year","roads", "month"))

viirs_grid_monthly$month[nchar(viirs_grid_monthly$month) == 1] <- paste0("0", viirs_grid_monthly$month[nchar(viirs_grid_monthly$month) == 1])
viirs_grid_monthly$date <- paste(viirs_grid_monthly$year, viirs_grid_monthly$month, "01", sep="-")
viirs_grid_monthly$date <- as.Date(viirs_grid_monthly$date)

viirs_grid_annual <- summaryBy(value ~ variable + year + roads, data=as.data.frame(viirs_grid_monthly), FUN=mean, keep.names=T)

viirs_grid_annual <- viirs_grid_annual %>% as.data.frame
viirs_grid_monthly <- viirs_grid_monthly %>% as.data.frame

viirs_grid_annual$date <- as.Date(paste(viirs_grid_annual$year, "06", "01", sep="-"))

# Figures ----------------------------------------------------------------------
height = 5
width = 6

viirs_mean_fig <- ggplot() +
  geom_line(data=viirs_grid_monthly[viirs_grid_monthly$variable == "viirs_mean",],
            aes(x=date, y=value, group=roads, color=roads),
            size=1, alpha=0.5) +
  geom_line(data=viirs_grid_annual[viirs_grid_annual$variable == "viirs_mean",],
            aes(x=date, y=value, group=roads, color=roads),
            size=2) +
  geom_point(data=viirs_grid_annual[viirs_grid_annual$variable == "viirs_mean",],
            aes(x=date, y=value, group=roads, color=roads),
            size=4) +
  #geom_point(size=4) +
  theme_minimal() +
  labs(x="",
       y="",
       title="Average Nighttime Light Radiance",
       color="") +
  theme(plot.title=element_text(hjust=0.5, face="bold"))
ggsave(viirs_mean_fig, filename=file.path(figures_file_path, "viirs_radiance_trends.png"), height=height, width=width)  

viirs_rad_1greater_fig <- ggplot() +
  geom_line(data=viirs_grid_monthly[viirs_grid_monthly$variable == "viirs_1greater_prop",],
            aes(x=date, y=value, group=roads, color=roads),
            size=1, alpha=0.5) +
  geom_line(data=viirs_grid_annual[viirs_grid_annual$variable == "viirs_1greater_prop",],
            aes(x=date, y=value, group=roads, color=roads),
            size=2) +
  geom_point(data=viirs_grid_annual[viirs_grid_annual$variable == "viirs_1greater_prop",],
            aes(x=date, y=value, group=roads, color=roads),
            size=4) +
  #geom_point(size=4) +
  theme_minimal() +
  labs(x="",
       y="",
       title="Proportion of Cells with Radiance > 1",
       color="") +
  theme(plot.title=element_text(hjust=0.5, face="bold"))
ggsave(viirs_rad_1greater_fig, filename=file.path(figures_file_path, "viirs_radiance_1greater_trends.png"), height=height, width=width)  

viirs_rad_5greater_fig <- ggplot() +
  geom_line(data=viirs_grid_monthly[viirs_grid_monthly$variable == "viirs_5greater_prop",],
            aes(x=date, y=value, group=roads, color=roads),
            size=1, alpha=0.5) +
  geom_line(data=viirs_grid_annual[viirs_grid_annual$variable == "viirs_5greater_prop",],
            aes(x=date, y=value, group=roads, color=roads),
            size=2) +
  geom_point(data=viirs_grid_annual[viirs_grid_annual$variable == "viirs_5greater_prop",],
            aes(x=date, y=value, group=roads, color=roads),
            size=4) +
  #geom_point(size=4) +
  theme_minimal() +
  labs(x="",
       y="",
       title="Proportion of Cells with Radiance > 5",
       color="") +
  theme(plot.title=element_text(hjust=0.5, face="bold"))
ggsave(viirs_rad_5greater_fig, filename=file.path(figures_file_path, "viirs_radiance_5greater_trends.png"), height=height, width=width)  

