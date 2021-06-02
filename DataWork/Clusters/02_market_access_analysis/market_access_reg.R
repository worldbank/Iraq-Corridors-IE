#Regression for market access
#Step 1: Subset data by distance
#Step 2: Summarize data by year and uid
#Step 3: Reshape Data
#Step 4: Take the difference
#Step 5: Regress the differences


# Load Data ---------------------------------------------------------------
cluster_df <- readRDS(file.path(data_file_path, "Clusters", "FinalData", 
                                "cluster_data_df.Rds"))


# Step 1: Subset data by distance -----------------------------------------
cluster_df_5km <- cluster_df %>%
  filter(dist_gs_km < 5.1) %>%
  filter(year == 2018|year == 2020) %>%
  group_by(uid,year,
           MA_tt_rdlength_theta3_8_speed_limit_gs_before,
           MA_tt_rdlength_theta3_8_speed_limit_gs_after,
           MA_tt_rdlength_theta3_8_exclude10km_speed_limit_gs_before,
           MA_tt_rdlength_theta3_8_exclude10km_speed_limit_gs_after,
           MA_tt_rdlength_theta3_8_exclude20km_speed_limit_gs_before,
           MA_tt_rdlength_theta3_8_exclude20km_speed_limit_gs_after,
           MA_tt_rdlength_theta3_8_exclude50km_speed_limit_gs_before,
           MA_tt_rdlength_theta3_8_exclude50km_speed_limit_gs_after) %>%
  summarize(annual_viirs_mean = mean(viirs_mean)) %>%
  mutate(transformed_viirs_mean = log(annual_viirs_mean + sqrt((annual_viirs_mean)^2+1)))%>%
  select(-c("annual_viirs_mean")) %>%
  pivot_wider(names_from = year, values_from = transformed_viirs_mean, names_prefix = "ntl") %>%
  mutate(diff_ntl = ntl2020 - ntl2018,
         diff_noexclusion = MA_tt_rdlength_theta3_8_speed_limit_gs_after - 
           MA_tt_rdlength_theta3_8_speed_limit_gs_before,
         diff_exclude10km = MA_tt_rdlength_theta3_8_exclude10km_speed_limit_gs_after -
           MA_tt_rdlength_theta3_8_exclude10km_speed_limit_gs_before,
         diff_exclude20km = MA_tt_rdlength_theta3_8_exclude20km_speed_limit_gs_after -
           MA_tt_rdlength_theta3_8_exclude20km_speed_limit_gs_before,
         diff_exclude50km = MA_tt_rdlength_theta3_8_exclude50km_speed_limit_gs_after - 
           MA_tt_rdlength_theta3_8_exclude50km_speed_limit_gs_before)

cluster_df_10km <- cluster_df %>%
  filter(dist_gs_km < 10.1) %>%
  filter(year == 2018|year == 2020) %>%
  group_by(uid,year,
           MA_tt_rdlength_theta3_8_speed_limit_gs_before,
           MA_tt_rdlength_theta3_8_speed_limit_gs_after,
           MA_tt_rdlength_theta3_8_exclude10km_speed_limit_gs_before,
           MA_tt_rdlength_theta3_8_exclude10km_speed_limit_gs_after,
           MA_tt_rdlength_theta3_8_exclude20km_speed_limit_gs_before,
           MA_tt_rdlength_theta3_8_exclude20km_speed_limit_gs_after,
           MA_tt_rdlength_theta3_8_exclude50km_speed_limit_gs_before,
           MA_tt_rdlength_theta3_8_exclude50km_speed_limit_gs_after) %>%
  summarize(annual_viirs_mean = mean(viirs_mean)) %>%
  mutate(transformed_viirs_mean = log(annual_viirs_mean + sqrt((annual_viirs_mean)^2+1)))%>%
  select(-c("annual_viirs_mean")) %>%
  pivot_wider(names_from = year, values_from = transformed_viirs_mean, names_prefix = "ntl") %>%
  mutate(diff_ntl = ntl2020 - ntl2018,
         diff_noexclusion = MA_tt_rdlength_theta3_8_speed_limit_gs_after - 
           MA_tt_rdlength_theta3_8_speed_limit_gs_before,
         diff_exclude10km = MA_tt_rdlength_theta3_8_exclude10km_speed_limit_gs_after -
           MA_tt_rdlength_theta3_8_exclude10km_speed_limit_gs_before,
         diff_exclude20km = MA_tt_rdlength_theta3_8_exclude20km_speed_limit_gs_after -
           MA_tt_rdlength_theta3_8_exclude20km_speed_limit_gs_before,
         diff_exclude50km = MA_tt_rdlength_theta3_8_exclude50km_speed_limit_gs_after - 
           MA_tt_rdlength_theta3_8_exclude50km_speed_limit_gs_before)

cluster_df_20km <- cluster_df %>%
  filter(dist_gs_km < 20.1) %>%
  filter(year == 2018|year == 2020) %>%
  group_by(uid,year,
           MA_tt_rdlength_theta3_8_speed_limit_gs_before,
           MA_tt_rdlength_theta3_8_speed_limit_gs_after,
           MA_tt_rdlength_theta3_8_exclude10km_speed_limit_gs_before,
           MA_tt_rdlength_theta3_8_exclude10km_speed_limit_gs_after,
           MA_tt_rdlength_theta3_8_exclude20km_speed_limit_gs_before,
           MA_tt_rdlength_theta3_8_exclude20km_speed_limit_gs_after,
           MA_tt_rdlength_theta3_8_exclude50km_speed_limit_gs_before,
           MA_tt_rdlength_theta3_8_exclude50km_speed_limit_gs_after) %>%
  summarize(annual_viirs_mean = mean(viirs_mean)) %>%
  mutate(transformed_viirs_mean = log(annual_viirs_mean + sqrt((annual_viirs_mean)^2+1)))%>%
  select(-c("annual_viirs_mean")) %>%
  pivot_wider(names_from = year, values_from = transformed_viirs_mean, names_prefix = "ntl") %>%
  mutate(diff_ntl = ntl2020 - ntl2018,
         diff_noexclusion = MA_tt_rdlength_theta3_8_speed_limit_gs_after - 
           MA_tt_rdlength_theta3_8_speed_limit_gs_before,
         diff_exclude10km = MA_tt_rdlength_theta3_8_exclude10km_speed_limit_gs_after -
           MA_tt_rdlength_theta3_8_exclude10km_speed_limit_gs_before,
         diff_exclude20km = MA_tt_rdlength_theta3_8_exclude20km_speed_limit_gs_after -
           MA_tt_rdlength_theta3_8_exclude20km_speed_limit_gs_before,
         diff_exclude50km = MA_tt_rdlength_theta3_8_exclude50km_speed_limit_gs_after - 
           MA_tt_rdlength_theta3_8_exclude50km_speed_limit_gs_before) #calculate differences


# Summary stats -----------------------------------------------------------
summary(cluster_df_20km$diff_exclude50km)
      

# Regressions -------------------------------------------------------------
#5km
reg1 <- lm(diff_ntl~diff_noexclusion + factor(uid),data = cluster_df_5km)
reg2 <- lm(diff_ntl~diff_exclude10km + factor(uid),data = cluster_df_5km)
reg3 <- lm(diff_ntl~diff_exclude20km + factor(uid),data = cluster_df_5km)
reg4 <- lm(diff_ntl~diff_exclude50km + factor(uid),data = cluster_df_5km)

stargazer(reg1,
          reg2,
          reg3,
          reg4,
          title = "Within a 5km Buffer",
          font.size = "small",
          digits = 3,
          keep = c("diff_noexclusion","diff_exclude10km","diff_exclude20km","diff_exclude50km"),
          omit.stat = c("ser"),
          add.lines = list(c("Cluster FE", "Yes","Yes","Yes","Yes")),
          out = file.path(data_file_path,"Clusters","Outputs","gs_5km.tex"),
          float = F,
          header = F)

#10km
reg5 <- lm(diff_ntl~diff_noexclusion + factor(uid),data = cluster_df_10km)
reg6 <- lm(diff_ntl~diff_exclude10km + factor(uid),data = cluster_df_10km)
reg7 <- lm(diff_ntl~diff_exclude20km + factor(uid),data = cluster_df_10km)
reg8 <- lm(diff_ntl~diff_exclude50km + factor(uid),data = cluster_df_10km)


stargazer(reg5,
          reg6,
          reg7,
          reg8,
          title = "Within a 10km Buffer",
          font.size = "small",
          digits = 3,
          keep = c("diff_noexclusion","diff_exclude10km","diff_exclude20km","diff_exclude50km"),
          omit.stat = c("ser"),
          add.lines = list(c("Cluster FE", "Yes","Yes","Yes","Yes")),
          out = file.path(data_file_path,"Clusters","Outputs","gs_10km.tex"),
          float = F,
          header = F)

#10km
reg9 <- lm(diff_ntl~diff_noexclusion + factor(uid),data = cluster_df_20km)
reg10 <- lm(diff_ntl~diff_exclude10km + factor(uid),data = cluster_df_20km)
reg11 <- lm(diff_ntl~diff_exclude20km + factor(uid),data = cluster_df_20km)
reg12 <- lm(diff_ntl~diff_exclude50km + factor(uid),data = cluster_df_20km)

stargazer(reg9,
          reg10,
          reg11,
          reg12,
          title = "Within a 20km Buffer",
          font.size = "small",
          digits = 3,
          keep = c("diff_noexclusion","diff_exclude10km","diff_exclude20km","diff_exclude50km"),
          omit.stat = c("ser"),
          add.lines = list(c("Cluster FE", "Yes","Yes","Yes","Yes")),
          out = file.path(data_file_path,"Clusters","Outputs","gs_20km.tex"),
          float = F,
          header = F)
