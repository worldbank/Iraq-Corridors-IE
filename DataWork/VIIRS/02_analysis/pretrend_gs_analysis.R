#Iraq IE
#Pre-trends b/w Girsheen - Suheila & Zakho (oldroad before GS began its operations)


# Load Data ---------------------------------------------------------------
#gs
viirs_grid_gs <- readRDS(file.path(project_file_path, "Data", "VIIRS", 
                                   "FinalData","near_girsheen_suheila_road",
                                   "viirs_grid.Rds"))

viirs_grid_gs <- subset(viirs_grid_gs, select = -c(cf_cvg_df))


#oldroad
viirs_grid_oldroad<- readRDS(file.path(project_file_path,"Data", "VIIRS",
                                       "FinalData", "near_zakho_road",
                                       "viirs_grid.Rds" ))


# Pre - Trends ============================================================
# 1. Summarize NTL by Year/Month ----------------------------------------------------
#Aggregate values near Zakho (operated before the new road opened)
viirs_grid_oldroad_5km <- viirs_grid_oldroad[viirs_grid_oldroad$dist_zakho_km <= 5,][,j=list(viirs_mean = mean(avg_rad_df, na.rm = TRUE)), 
                                                                                     by = list(year, month)]

viirs_grid_oldroad_5km$roads <- "Zakho Road"


#Aggregate values for Girsheen - Suheila
viirs_grid_gs_5km <- viirs_grid_gs[viirs_grid_gs$dist_gs_road_km <= 5,][,j=list(viirs_mean = mean(avg_rad_df, na.rm = TRUE)), 
                                                                                     by = list(year, month)]

viirs_grid_gs_5km$roads <- "Girsheen - Suheila"



# Create dataframe with both roads ----------------------------------------
viirs_grid_monthly <- bind_rows(viirs_grid_oldroad_5km, 
                                viirs_grid_gs_5km) %>% 
  as.data.frame
viirs_grid_monthly <- melt(viirs_grid_monthly, id=c("year","roads", "month"))

#Add date
viirs_grid_monthly$date <- paste0(viirs_grid_monthly$year, "-", 
                                  viirs_grid_monthly$month, "-", "01") %>% as.Date()


#Annual Aggregate Dataset
viirs_grid_annual <- viirs_grid_monthly %>%
  group_by(year, roads, variable) %>%
  dplyr::summarise(value = mean(value))

# Add date in June 1; helpful for plotting as puts point in middle of year
viirs_grid_annual$date <- paste0(viirs_grid_annual$year, "-06-01") %>% as.Date()

#3. plot----------------------------------------------------------------------
height = 5
width = 6

#all years
ggplot() +
  geom_line(data=viirs_grid_monthly,
            aes(x=date, y=value, group=roads, color=roads),
            size=0.5, alpha=0.5) +
  geom_line(data=viirs_grid_annual,
            aes(x=date, y=value, group=roads, color=roads),
            size=1.5) +
  theme_minimal() +
  scale_colour_manual(values = c("#B8321A", "#44781E"))+
  labs(x="",
       y="Median Radiance",
       title="Median Nighttime Light Radiance (Within 5km) \n2012-2020",
       color="") +
  ggsave(file.path(project_file_path, "Data", "VIIRS", "Outputs", "figures", 
                   "viirs_trends_girsheen_zakho.png"), 
         height=height, width=width)  

#pre-trend
#Focus on trends prior to 2020
viirs_grid_annual <- viirs_grid_annual[which(viirs_grid_annual$year < 2020),]
viirs_grid_monthly <- viirs_grid_monthly[which(viirs_grid_monthly$year < 2020),]

ggplot() +
  geom_line(data=viirs_grid_monthly,
            aes(x=date, y=value, group=roads, color=roads),
            size=0.5, alpha=0.5) +
  geom_line(data=viirs_grid_annual,
            aes(x=date, y=value, group=roads, color=roads),
            size=1.5) +
  theme_minimal() +
  scale_colour_manual(values = c("#B8321A", "#44781E"))+
  labs(x="",
       y="Median Radiance",
       title="Median Nighttime Light Radiance (Within 5km) \n2012-2019",
       color="") +
  ggsave(file.path(project_file_path, "Data", "VIIRS", "Outputs", "figures", 
                   "viirs_pretrends_girsheen_zakho.png"), 
         height=height, width=width)  



# T-TEST =====================================================================
# 1. Match both data frames -----------------------------------------------
#add column to grid 
viirs_grid_oldroad_5km$road <- "zakho"
viirs_grid_gs_5km$road <- "girsheen-suheila"

viirs_grid_oldroad_5km$dist_gs_road_km <- NA
viirs_grid_gs_5km$dist_zakho_km <- NA


# 2. Create t-test dataframe ----------------------------------------------
#create df for t-test
ttest_df_oldroad_gs <- rbind(viirs_grid_gs_5km,viirs_grid_oldroad_5km)


# 3. Conduct t-test -------------------------------------------------------
#conduct t-test
t.test(avg_rad_df ~ road, data = ttest_df_oldroad_gs)



