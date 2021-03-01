#Iraq IE
#Pre-trends


# Load Data ---------------------------------------------------------------
#gs
viirs_grid_gs <- readRDS(file.path(project_file_path, "Data", "VIIRS", 
                                   "FinalData","near_girsheen_suheila_road",
                                   "viirs_grid.Rds"))

viirs_grid_gs <- subset(viirs_grid_gs, select = -c(cf_cvg_df))


#oldroad
viirs_grid_oldroad<- readRDS(file.path(project_file_path,"Data", "VIIRS",
                                       "FinalData", "near_girsheen_suheila_road",
                                       "viirs_grid_oldroad.Rds" ))

# Create a Trends Line ----------------------------------------------------
#oldroad
annual_viirs_oldroad <-
  summaryBy(avg_rad_df ~ year,
            data = viirs_grid_oldroad,
            FUN = median)

#girsheen
annual_viirs_gs <-
  summaryBy(avg_rad_df ~ year,
            data = viirs_grid_gs,
            FUN = median)


#plot----------------------------------------------------------------------
#all years
ggplot()+
  geom_line(aes(x = year, y = avg_rad_df.median, color = "Old Road"), data = annual_viirs_oldroad)+
  geom_line(aes(x = year, y = avg_rad_df.median, color = "Girsheen - Suheila"), data = annual_viirs_gs)+
  labs(color = "Road", title = "Median NTL b/w 2012 - 2020")+
  ylab("Median NTL")+
  xlab("Year")+
  scale_colour_brewer(palette = "Set1")+
  theme_minimal()+
  theme(text = element_text(size=10),
        axis.text.x = element_text(angle=90, hjust=1))



grid_sum_stack <- viirs_grid_oldroad %>%
  group_by(year) %>%
  dplyr::summarise("avg_rad_5" = mean(avg_rad_df[dist_gs_road_km < 5]),
                   "avg_rad_0-1" = mean(avg_rad_df[dist_oldroad_km > 0 & dist_oldroad_km< 1]),
                   "avg_rad_1-2" = mean(avg_rad_df[dist_oldroad_km > 1 & dist_oldroad_km < 2]),
                   "avg_rad_2-3" = mean(avg_rad_df[dist_oldroad_km > 2 & dist_oldroad_km < 3]),
                   "avg_rad_3-4" = mean(avg_rad_df[dist_oldroad_km > 3 & dist_oldroad_km < 4]),
                   "avg_rad_4-5" = mean(avg_rad_df[dist_oldroad_km > 4 & dist_oldroad_km < 5])) %>%
  pivot_longer(cols = -year) %>%
  mutate(name = name %>% 
           str_replace_all("avg_rad_", "")) %>%
  dplyr::rename(buffer = name)


gs_ntl_trends <- grid_sum_stack %>%
  ggplot(aes(x = year, 
             y = value,
             group = buffer,
             color = buffer),
         size = 1) +
  geom_line(size=1) +
  labs(color = "Buffer (km)",
       title = "Average NTL Radiance near\nOld Road",
       x = "", 
       y = "Average\nRadiance") +
  theme_minimal() + 
  scale_colour_brewer(palette = "Dark2")

gs_ntl_trends

# For buffers 5, 10 20 km
grid_buffer_stack <- viirs_grid_oldroad %>%
  group_by(year) %>%
  dplyr::summarise("avg_rad_5" = mean(avg_rad_df[dist_oldroad_km > 0 & dist_oldroad_km <= 5]),
                   "avg_rad_10" = mean(avg_rad_df[dist_oldroad_km > 0 & dist_oldroad_km <= 10]),
                   "avg_rad_20" = mean(avg_rad_df[dist_oldroad_km > 0 & dist_oldroad_km <= 20])) %>%
  pivot_longer(cols = -year) %>%
  mutate(name = name %>% 
           str_replace_all("avg_rad_", "")) %>%
  dplyr::rename(buffer = name)

gs_ntl <- grid_buffer_stack %>%
  ggplot(aes(x = year, 
             y = value,
             group = buffer,
             color = buffer),
         size = 1) +
  geom_line(size=1) +
  labs(color = "Buffer (km)",
       title = "Average NTL Radiance near\nOld Road",
       x = "", 
       y = "Average\nRadiance") +
  theme_minimal() + 
  scale_colour_brewer(palette = "Dark2")
gs_ntl


# T-test between roads ---------------------------------------------------
##add column to grid 
viirs_grid_oldroad$road <- "oldroad_gs"
viirs_grid_gs$road <- "girsheen-suheila"

viirs_grid_oldroad$dist_gs_road_km <- NA
viirs_grid_gs$dist_oldroad_km <- NA

#create df for t-test
ttest_df_oldroad_gs <- rbind(viirs_grid_gs,viirs_grid_oldroad)
ttest_df_oldroad_gs <- ttest_df_oldroad_gs[which(ttest_df_oldroad_gs$year < 2020),]

#conduct t-test
t.test(avg_rad_df ~ road, data = ttest_df_oldroad_gs)




