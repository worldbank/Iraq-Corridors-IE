#NTL Trends over the years


# Load Data ---------------------------------------------------------------
viirs_grid <- readRDS(file=file.path(project_file_path, 
                                     "Data","VIIRS","FinalData", 
                                     "near_r78ab_roads","viirs_grid_clean.Rds")) %>%
  as.data.frame()

names(viirs_grid)
# Subset Data -------------------------------------------------------------
vars <- c("avg_rad_df","year","month")
viirs_grid_all <- viirs_grid[vars]

viirs_grid_all <-
  summaryBy(avg_rad_df ~ year,
            data = viirs_grid_all,
            FUN = median) #aggregate over year (choose median)

#within the 5km buffer of R7/R8
viirs_grid_5km <- viirs_grid[which(viirs_grid$dist_r78ab_road_km<=5),]
viirs_grid_5km <- viirs_grid_5km[vars]

viirs_grid_5km <-
  summaryBy(avg_rad_df ~ year,
            data = viirs_grid_5km,
            FUN = median) #aggregate over year (choose median)

#within the 10km buffer of R7/R8
viirs_grid_10km <- viirs_grid[which(viirs_grid$dist_r78ab_road_km <=10),]
viirs_grid_10km <- viirs_grid_10km[vars]

viirs_grid_10km <-
  summaryBy(avg_rad_df ~ year,
            data = viirs_grid_10km,
            FUN = median) #aggregate over year (choose median)

#within the 20km buffer of R7/R8
viirs_grid_20km <- viirs_grid[which(viirs_grid$dist_r78ab_road_km <=20),]
viirs_grid_20km <- viirs_grid_20km[vars]

viirs_grid_20km <-
  summaryBy(avg_rad_df ~ year,
            data = viirs_grid_20km,
            FUN = median) #aggregate over year (choose median)

# Plot --------------------------------------------------------------------
grid_buffer_stack_all <- viirs_grid %>%
  group_by(year) %>%
  dplyr::summarise("avg_rad" = mean(avg_rad_df)) %>%
  pivot_longer(cols = -year) %>%
  mutate(name = name) %>%
  dplyr::rename(Average_NTL = name)

r7r8_ntl_all <- grid_buffer_stack_all %>%
  ggplot(aes(x = year, 
             y = value,
             group = Average_NTL,
             color = Average_NTL),
         size = 1) +
  geom_line(size=1) +
  geom_vline(xintercept = 2016, linetype = "dotted", color = "black", size = 1.5) +
  labs(title = "Average NTL Radiance\nAcross Iraq",
       x = "", 
       y = "Average\nRadiance") +
  theme_minimal() + 
  scale_colour_brewer(palette = "Dark2")+
  expand_limits(y = 0)

r7r8_ntl_all

ggsave(r7r8_ntl_all, filename = file.path(project_file_path,"Figures","iraq_ntl_trends_all.png"), width = 6, height = 6)

#With buffers
grid_buffer_stack <- viirs_grid %>%
  group_by(year) %>%
  dplyr::summarise("avg_rad_5" = mean(avg_rad_df[dist_r78ab_road_km > 0 & dist_r78ab_road_km <= 5]),
                   "avg_rad_10" = mean(avg_rad_df[dist_r78ab_road_km > 0 & dist_r78ab_road_km <= 10]),
                   "avg_rad_20" = mean(avg_rad_df[dist_r78ab_road_km > 0 & dist_r78ab_road_km <= 20])) %>%
  pivot_longer(cols = -year) %>%
  mutate(name = name %>% 
           str_replace_all("avg_rad_", "")) %>%
  dplyr::rename(buffer = name)

r7r8_ntl <- grid_buffer_stack %>%
  ggplot(aes(x = year, 
             y = value,
             group = buffer,
             color = buffer),
         size = 1) +
  geom_line(size=1) +
  geom_vline(xintercept = 2016, linetype = "dotted", color = "black", size = 1.5) +
  labs(color = "Buffer (km)",
       title = "Average NTL Radiance near\nR7/R8 Road",
       x = "", 
       y = "Average\nRadiance") +
  theme_minimal() + 
  scale_colour_brewer(palette = "Dark2")+
  expand_limits(y=0)

r7r8_ntl
ggsave(r7r8_ntl, filename = file.path(project_file_path, "Figures", "iraq_ntl_trends_5km.png"), width = 6, height = 6)



