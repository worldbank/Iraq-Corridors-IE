#Cluster Trends

# Load Data --------------------------------------------------------------------
cluster <- readRDS(file.path(data_file_path,"Clusters", "FinalData",
                             "cluster_data_df.Rds"))

# Prep Data --------------------------------------------------------------------

# 1.Subset Data -----------------------------------------------------------
vars <- c("month", "year", "viirs_mean", "dist_r78_km")
cluster <- cluster[vars]

## By Buffer
cluster_5km <- cluster[cluster$dist_r78_km <= 5,]
cluster_5km$buffer <-"5km"

cluster_10km <- cluster[cluster$dist_r78_km <= 10,]
cluster_10km$buffer <- "10km"



#2.Combine and Aggregate Data (Annually and Monthly) -----------------------
##Monthly
cluster_monthly <- bind_rows(cluster_5km,
                             cluster_10km) %>% 
  as.data.frame
cluster_monthly <- melt(cluster_monthly, id=c("year", "buffer","month"))

## Add Date
cluster_monthly$date <- paste0(cluster_monthly$year, "-", 
                               cluster_monthly$month, "-", "01") %>% as.Date()
## Annually
cluster_annual <- cluster_monthly %>%
  group_by(year, buffer, variable) %>%
  dplyr::summarise(value = mean(value))

# Add date in June 1; helpful for plotting as puts point in middle of year
cluster_annual$date <- paste0(cluster_annual$year, "-06-01") %>% as.Date()


#3. Combine 20km Buffer -----------------------------------------------------
##Adding 20km buffer separately since the radiance jumps significantly

cluster_20km <- cluster[cluster$dist_r78_km <= 20,]
cluster_20km$buffer <- "20km"

cluster_monthly_with20 <- bind_rows(cluster_5km,
                                    cluster_10km,
                                    cluster_20km) %>% 
  as.data.frame
cluster_monthly_with20 <- melt(cluster_monthly_with20, id=c("year", "buffer","month"))

## Add Date
cluster_monthly_with20$date <- paste0(cluster_monthly_with20$year, "-", 
                                      cluster_monthly_with20$month, "-", "01") %>% as.Date()
## Annual Aggregate Dataset
cluster_annual_with20 <- cluster_monthly_with20 %>%
  group_by(year, buffer, variable) %>%
  dplyr::summarise(value = mean(value))

# Add date in June 1; helpful for plotting as puts point in middle of year
cluster_annual_with20$date <- paste0(cluster_annual_with20$year, "-06-01") %>% as.Date()

#4. Figures ----------------------------------------------------------------------
##5 & 10km buffer
height = 5
width = 6

ggplot() +
  geom_line(data=cluster_monthly[cluster_monthly$variable == "viirs_mean",],
            aes(x=date, y=value, group=buffer, color=buffer),
            size=1, alpha=0.5) +
  geom_line(data=cluster_annual[cluster_annual$variable == "viirs_mean",],
            aes(x=date, y=value, group=buffer, color=buffer),
            size=2) +
  theme_minimal() +
  labs(x="",
       y="",
       title="Average Nighttime Light Radiance \nAround r78",
       color="") +
  scale_color_manual(values = get_pal("Kakariki")[c(1,3)])+
  theme(plot.title=element_text(hjust=0.5, face="bold"))+  
  ggsave(file.path(project_file_path, "Data", "Clusters", "Outputs", 
                   "cluster_radiance_5_10km_r78.png"), 
         height=height, width=width) 


##All Buffers
ggplot() +
  geom_line(data=cluster_monthly_with20[cluster_monthly_with20$variable == "viirs_mean",],
            aes(x=date, y=value, group=buffer, color=buffer),
            size=1, alpha=0.5) +
  geom_line(data=cluster_annual_with20[cluster_annual_with20$variable == "viirs_mean",],
            aes(x=date, y=value, group=buffer, color=buffer),
            size=2) +
  
  theme_minimal() +
  labs(x="",
       y="",
       title="Average Nighttime Light Radiance \nAround r78",
       color="") +
  scale_color_manual(values = get_pal("Kakariki")[c(1,4,3)])+
  theme(plot.title=element_text(hjust=0.5, face="bold"))+
  ggsave(file.path(project_file_path, "Data", "Clusters", "Outputs", 
                   "cluster_radiance_5_10_20km_r78.png"), 
         height=height, width=width) 
