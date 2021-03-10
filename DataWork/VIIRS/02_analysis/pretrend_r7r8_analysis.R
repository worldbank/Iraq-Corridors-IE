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

# Create a trends line ===================================================
##annual


# 1. Aggregate Data -------------------------------------------------------
#highway5
viirs_highway5 <- viirs_highway5 %>%
  dplyr::group_by(id,year,month) %>%
  dplyr::summarise(avg_rad_df = mean(avg_rad_df))

viirs_highway5$road <- "Highway 5(Iran)"

#r7r8
viirs_r7r8 <- viirs_r7r8 %>%
  dplyr::group_by(id,year,month) %>%
  dplyr::summarise(avg_rad_df = mean(avg_rad_df))

viirs_r7r8$road <- "R78ab"



# 2. Create Dataframe -----------------------------------------------------
viirs_grid_monthly <- bind_rows(viirs_highway5, 
                                viirs_r7r8)%>% 
  as.data.frame
viirs_grid_monthly <- melt(viirs_grid_monthly, id=c("year","road", "month"))

#Add date
viirs_grid_monthly$date <- paste0(viirs_grid_monthly$year, "-", 
                                  viirs_grid_monthly$month, "-", "01") %>% as.Date()

#Annual Aggregate Dataset
viirs_grid_annual <- viirs_grid_monthly %>%
  group_by(year, road, variable) %>%
  dplyr::summarise(value = mean(value))

# Add date in June 1; helpful for plotting as puts point in middle of year
viirs_grid_annual$date <- paste0(viirs_grid_annual$year, "-06-01") %>% as.Date()

#Focus on trends prior to 2016
viirs_grid_annual <- viirs_grid_annual[which(viirs_grid_annual$year < 2016),]
viirs_grid_monthly <- viirs_grid_monthly[which(viirs_grid_monthly$year < 2016),]

# Plot --------------------------------------------------------------------
height = 5
width = 6

ggplot() +
  geom_line(data=viirs_grid_annual,
            aes(x=date, y=value, group=road, color=road),
            size=1.5) +
  theme_minimal() +
  scale_colour_manual(values = c("#B8321A", "#44781E"))+
  labs(x="",
       y="Average Radiance",
       title="Average Nighttime Light Radiance (Within 5km) \n2012-2015",
       color="") 
  #ggsave(file.path(project_file_path, "Data", "VIIRS", "Outputs", "figures", 
   #                "viirs_pretrends_girsheen_zakho.png"), 
    #     height=height, width=width)  




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
