#Iraq IE
#Pre-trends b/w R7R8 & highway5

# Load & Merging Data ---------------------------------------------------------------
grid_highway5 <- readRDS(file.path(project_file_path,"Data","VIIRS","FinalData",
                               "near_control_roads","Separate Files Per Variable",
                               "iraq_grid_panel_blank_highway5.Rds"))
viirs_highway5 <- readRDS(file.path(project_file_path,"Data","VIIRS","FinalData",
                                "near_control_roads","Separate Files Per Variable",
                                "iraq_grid_panel_viirs_highway5.Rds"))

grid_r7r8 <- readRDS(file.path(project_file_path,"Data","VIIRS","FinalData",
                                   "near_r78ab_roads","Separate Files Per Variable",
                                   "iraq_grid_panel_blank.Rds"))
viirs_r7r8 <- readRDS(file.path(project_file_path,"Data","VIIRS","FinalData",
                                    "near_r78ab_roads","Separate Files Per Variable",
                                    "iraq_grid_panel_viirs.Rds"))

# Merging Data ------------------------------------------------------------
viirs_highway5 <- merge(grid_highway5,viirs_highway5)
viirs_r7r8 <- merge(grid_r7r8,viirs_r7r8)

# Create a trends line ------------------------------------------------
##annual

#highway5
viirs_highway5 <- viirs_highway5 %>%
  dplyr::group_by(id,year) %>%
  dplyr::summarise(avg_rad_df = mean(avg_rad_df))

# Log
viirs_highway5$avg_rad_df_ln <- log(viirs_highway5$avg_rad_df+1)


viirs_r7r8 <- viirs_r7r8 %>%
  dplyr::group_by(id,year) %>%
  dplyr::summarise(avg_rad_df = mean(avg_rad_df))

# Log
viirs_r7r8$avg_rad_df_ln <- log(viirs_r7r8$avg_rad_df+1)

#plot
ggplot()+
  geom_line(data = viirs_highway5, aes(x = year, y = avg_rad_df_ln , color = "Highway 5 (Iran)"))+
  geom_line(data = viirs_r7r8, aes(x = year, y = avg_rad_df_ln , color = "R7R8"))+
  theme_minimal()



# T-test between roads ---------------------------------------------------
##add column to grid 

viirs_highway5 <- viirs_highway5 %>%
  mutate(road = "highway5")

viirs_r7r8 <- viirs_r7r8 %>%
  mutate(road = "r7r8")

ttest_df <- rbind(viirs_r7r8,viirs_highway5)

ttest_df_highway5_r7r8 <- ttest_df[which((ttest_df$road == "highway5"|
                                            ttest_df$road == "r7r8") & 
                                           (ttest_df$year < 2016)),]
t.test(avg_rad_df ~ road, data = ttest_df_highway5_r7r8) # t-test
