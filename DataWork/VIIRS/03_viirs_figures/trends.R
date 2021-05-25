# Iraq IE
# Distance to Roads

# Load Data --------------------------------------------------------------------
viirs_grid <- readRDS(file.path(project_file_path, "Data", "VIIRS", "FinalData", "near_r78ab_roads", 
                                "viirs_grid_clean.Rds"))

# Prep Data --------------------------------------------------------------------
## Create Variables
viirs_grid$viirs_1greater <- as.numeric(viirs_grid$avg_rad_df >= 1)
viirs_grid$viirs_2greater <- as.numeric(viirs_grid$avg_rad_df >= 2)
viirs_grid$viirs_5greater <- as.numeric(viirs_grid$avg_rad_df >= 5)

## Aggregate values near project roads
viirs_grid_project_roads <- viirs_grid[viirs_grid$distance_project_roads <= 5,][,j=list(viirs_mean = mean(avg_rad_df, na.rm = TRUE),
                                                                                         viirs_1greater_prop = mean(viirs_1greater, na.rm = TRUE),
                                                                                         viirs_2greater_prop = mean(viirs_2greater, na.rm = TRUE),
                                                                                         viirs_5greater_prop = mean(viirs_5greater, na.rm = TRUE)), by = list(year, month)]
viirs_grid_project_roads$roads <- "Project Roads"

## Aggregate values near highways (but not near project road)
viirs_grid_highways <- viirs_grid[(viirs_grid$distance_primary_route <= 5) & 
                                    (viirs_grid$distance_project_roads >= 5),][,j=list(viirs_mean = mean(avg_rad_df, na.rm = TRUE),
                                                                                        viirs_1greater_prop = mean(viirs_1greater, na.rm = TRUE),
                                                                                        viirs_2greater_prop = mean(viirs_2greater, na.rm = TRUE),
                                                                                        viirs_5greater_prop = mean(viirs_5greater, na.rm = TRUE)), by = list(year, month)]
viirs_grid_highways$roads <- "Primary Roads"
rm(viirs_grid)

## Append near roads / near project roads
viirs_grid_monthly <- bind_rows(viirs_grid_project_roads, 
                                viirs_grid_highways) %>% 
  as.data.frame
viirs_grid_monthly <- melt(viirs_grid_monthly, id=c("year","roads", "month"))

## Add Date
viirs_grid_monthly$date <- paste0(viirs_grid_monthly$year, "-", 
                                  viirs_grid_monthly$month, "-", "01") %>% as.Date()

## Annual Aggregate Dataset
viirs_grid_annual <- viirs_grid_monthly %>%
  group_by(year, roads, variable) %>%
  dplyr::summarise(value = mean(value))

# Add date in June 1; helpful for plotting as puts point in middle of year
viirs_grid_annual$date <- paste0(viirs_grid_annual$year, "-06-01") %>% as.Date()

# Figures ----------------------------------------------------------------------
height = 5
width = 6

ggplot() +
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
  theme(plot.title=element_text(hjust=0.5, face="bold")) + 
ggsave(file.path(project_file_path, "Data", "VIIRS", "Outputs", "figures", 
                 "viirs_radiance_trends_2019.png"), 
       height=height, width=width)  

ggplot() +
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
  theme(plot.title=element_text(hjust=0.5, face="bold")) + 
ggsave(file.path(project_file_path, "Data", "VIIRS", "Outputs", "figures", 
                 "viirs_radiance_1greater_trends_2019.png"), 
       height=height, width=width)  

ggplot() +
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
  theme(plot.title=element_text(hjust=0.5, face="bold")) +
ggsave(file.path(project_file_path, "Data", "VIIRS", "Outputs", "figures", 
                 "viirs_radiance_5greater_trends_2019.png"), 
       height=height, width=width)  

## Stat
v14 <- viirs_grid_annual$value[viirs_grid_annual$year %in% 2014 & viirs_grid_annual$variable %in% "viirs_mean" & viirs_grid_annual$roads %in% "Project Roads"]
v19 <- viirs_grid_annual$value[viirs_grid_annual$year %in% 2018 & viirs_grid_annual$variable %in% "viirs_mean" & viirs_grid_annual$roads %in% "Project Roads"]
(v19 - v14)/v14







