# Polygons with high night-light intensity
# 1. Take the spatial grid for R7/R8 & Girsheen - Suheila and create buffers of 5, 10 and 20km
# 2. Based on the night-time light intensity, subset the data
# 3. Export Polygons



# Load Data ---------------------------------------------------------------
clusters <- readRDS(file.path(data_file_path, "Clusters","FinalData",
                        "cluster_data_df.Rds"))


clusters_sf <- readRDS(file.path(data_file_path, "Clusters","FinalData",
                        "cluster_timeinvariant_data_sp.Rds")) %>% st_as_sf()



# Subset Data -------------------------------------------------------------
#r78
clusters_r78_20km <- clusters %>%
  filter(dist_r78_km < 20.1) %>%
  select(c(uid,viirs_mean,viirs_time_id,year,month,
           cell_id,area_km2,distance_to_baghdad,
           dist_r78_km,population,road_length_km_primary)) #subset within 20km of project road

clusters_r78_20km_coords <- clusters_sf %>%
  filter(dist_r78_km < 20.1) %>%
  select(c(uid,cell_id,geometry))

clusters_r78_20km <- left_join(clusters_r78_20km,clusters_r78_20km_coords,
                               by = c("uid","cell_id")) #merging lat/lon


#gs
clusters_gs_20km <- clusters %>%
  filter(dist_gs_km < 20.1) %>%
  select(c(uid,viirs_mean,viirs_time_id,year,month,
           cell_id,area_km2,distance_to_baghdad,
           dist_gs_km,population,road_length_km_primary))


clusters_gs_20km_coords <- clusters_sf %>%
  filter(dist_gs_km < 20.1) %>%
  select(c(uid,cell_id,geometry))


clusters_gs_20km <- left_join(clusters_gs_20km,clusters_gs_20km_coords,
                              by = c("uid","cell_id")) #merging lat/lon


# Computing Top 10 Percentiles --------------------------------------------

# Top 10 percentiles ===================================================================================================== 
clusters_r78_20km %>% #r78
  filter(year > 2019) %>% 
  summarize(top10_pctl = quantile(viirs_mean, c(0.9),na.rm = T), q = c(0.9)) #calculates the 90th percentile


clusters_gs_20km %>%  #gs
  filter(year > 2019) %>% 
  summarise(top10_pctl = quantile(viirs_mean, c(0.9),na.rm = T), q = c(0.9))


clusters_r78_20km$top10_pctl_2020 <- ifelse(clusters_r78_20km$viirs_mean > 152.5,1,0) #creates var flagging 90th percentile
clusters_gs_20km$top10_pctl_2020 <- ifelse(clusters_gs_20km$viirs_mean > 86.3,1,0)


# Change in NTL (b/w 2015 and 2020) =======================================================================================
#r78
clusters_r78_2015_2020 <- clusters_r78_20km %>%
  filter(year == 2015 | year == 2020) %>%
  group_by(uid,year)%>%
  summarize(annual_mean = mean(viirs_mean)) %>%
  drop_na(annual_mean) %>%
  change(clusters_r78_2015_2020,
         Var = "annual_mean",  
         NewVar = "pct_change_2015_2020",
         GroupVar = "uid",
         slideBy = -1, 
         type = "percent")
  


#gs
clusters_gs_2015_2020 <- clusters_gs_20km %>%
  filter(year == 2015 | year == 2020) %>%
  group_by(uid,year)%>%
  summarize(annual_mean = mean(viirs_mean)) %>%
  drop_na(annual_mean) %>%
  change(clusters_gs_2015_2020,
         Var = "annual_mean",  
         NewVar = "pct_change_2015_2020",
         GroupVar = "uid",
         slideBy = -1, 
         type = "percent")


# Top 10 Percentile for the Change in NTL =================================================================================
clusters_r78_2015_2020 %>% #r78
  filter(year > 2019) %>% 
  summarize(top10_pctl = quantile(pct_change_2015_2020, c(0.9),na.rm = T), q = c(0.9)) #calculates the 90th percentile


clusters_gs_2015_2020 %>%  #gs
  filter(year > 2019) %>% 
  summarise(top10_pctl = quantile(pct_change_2015_2020, c(0.9),na.rm = T), q = c(0.9))



clusters_r78_2015_2020 <- clusters_r78_2015_2020 %>%
  mutate(top10_pctl_2015_2020 = ifelse(clusters_r78_2015_2020$pct_change_2015_2020 > 406,1,0)) %>%
  group_by(uid) %>%
  summarize(top10_pctl_2015_2020) %>% #creates var that flags the 90th percentile by cluster
  drop_na(top10_pctl_2015_2020)
  


clusters_gs_2015_2020 <- clusters_gs_2015_2020 %>%
  mutate(top10_pctl_2015_2020 = ifelse(clusters_gs_2015_2020$pct_change_2015_2020 > 493.8,1,0)) %>%
  group_by(uid) %>%
  summarize(top10_pctl_2015_2020) %>% 
  drop_na(top10_pctl_2015_2020)

  
# Merging to Panel Data ==================================================================================================
clusters_r78_20km <- left_join(clusters_r78_20km,clusters_r78_2015_2020,by = c("uid"))
clusters_gs_20km <- left_join(clusters_gs_20km,clusters_gs_2015_2020,by = c("uid"))





