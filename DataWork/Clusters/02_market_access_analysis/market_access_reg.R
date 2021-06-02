#Regression for market access


# Load Data ---------------------------------------------------------------
cluster_df <- readRDS(file.path(data_file_path, "Clusters", "FinalData", 
                                "cluster_data_df.Rds"))


# Subset Data & Create Treament Var -------------------------------------------------------------
#gs
cluster_gs_20km <- cluster_df %>%
  filter(dist_gs_km < 20.1) %>%
  select(c(uid,viirs_mean,viirs_time_id,year,month,
           dist_gs_km,
           MA_tt_rdlength_theta3_8_exclude20km_speed_limit_gs_before,
           MA_tt_rdlength_theta3_8_exclude20km_speed_limit_gs_after,
           MA_tt_rdlength_theta3_8_exclude50km_speed_limit_gs_before,
           MA_tt_rdlength_theta3_8_exclude50km_speed_limit_gs_after)) %>%
  group_by(uid,year,month) %>%
  mutate(ma_diff_exclude20km = log(MA_tt_rdlength_theta3_8_exclude20km_speed_limit_gs_after) - log(MA_tt_rdlength_theta3_8_exclude20km_speed_limit_gs_before),
         ma_diff_exclude50km = log(MA_tt_rdlength_theta3_8_exclude50km_speed_limit_gs_after) - log(MA_tt_rdlength_theta3_8_exclude50km_speed_limit_gs_before),
         transformed_viirs_mean = log(viirs_mean + sqrt((viirs_mean)^2+1))) %>%
  arrange(uid,year,month)
  


# Regressions -------------------------------------------------------------
#5km

cluster_gs_5km <- cluster_gs_20km %>%
  filter(dist_gs_km < 5.1)

reg1 <- lm(transformed_viirs_mean ~ ma_diff_exclude20km + factor(uid) + factor (viirs_time_id), data = cluster_gs_5km)
reg2 <- lm(transformed_viirs_mean ~ ma_diff_exclude50km + factor(uid) + factor (viirs_time_id), data = cluster_gs_5km)
reg3 <- felm(transformed_viirs_mean ~ ma_diff_exclude20km |uid| 0 |0, data = cluster_gs_5km)
reg4 <- felm(transformed_viirs_mean ~ ma_diff_exclude50km |uid | 0 |0, data = cluster_gs_5km)



cluster_gs_10km <- cluster_gs_20km %>%
  filter(dist_gs_km < 10.1)

reg5 <- lm(transformed_viirs_mean ~ ma_diff_exclude20km + factor(uid) + factor (viirs_time_id), data = cluster_gs_10km)
reg6 <- lm(transformed_viirs_mean ~ ma_diff_exclude50km + factor(uid) + factor (viirs_time_id), data = cluster_gs_10km)
reg7 <- felm(transformed_viirs_mean ~ ma_diff_exclude20km |uid| 0 |0, data = cluster_gs_10km)
reg8 <- felm(transformed_viirs_mean ~ ma_diff_exclude50km |uid | 0 |0, data = cluster_gs_10km)

reg9 <-  lm(transformed_viirs_mean ~ ma_diff_exclude20km + factor(uid) + factor (viirs_time_id), data = cluster_gs_20km)
reg10 <- lm(transformed_viirs_mean ~ ma_diff_exclude50km + factor(uid) + factor (viirs_time_id), data = cluster_gs_20km)
reg11 <- felm(transformed_viirs_mean ~ ma_diff_exclude20km |uid| 0 |0, data = cluster_gs_20km)
reg12 <- felm(transformed_viirs_mean ~ ma_diff_exclude50km |uid | 0 |0, data = cluster_gs_20km)


stargazer(reg1,
          reg2,
          reg3,
          reg4,
          title = "Within a 5km Buffer",
          font.size = "small",
          digits = 3,
          keep = c("ma_diff_exclude20km", "ma_diff_exclude50km"),
          omit.stat = c("ser"),
          add.lines = list(c("Month and Cluster FE", "Yes","Yes","No/Yes","No/Yes")),
          out = file.path(data_file_path,"Clusters","Outputs","gs_5km.tex"),
          float = F,
          header = F)

stargazer(reg5,
          reg6,
          reg7,
          reg8,
          title = "Within a 10km Buffer",
          font.size = "small",
          digits = 3,
          keep = c("ma_diff_exclude20km", "ma_diff_exclude50km"),
          omit.stat = c("ser"),
          add.lines = list(c("Month and Cluster FE", "Yes","Yes","No/Yes","No/Yes")),
          out = file.path(data_file_path,"Clusters","Outputs","gs_10km.tex"),
          float = F,
          header = F)

stargazer(reg9,
          reg10,
          reg11,
          reg12,
          title = "Within a 20km Buffer",
          font.size = "small",
          digits = 3,
          keep = c("ma_diff_exclude20km", "ma_diff_exclude50km"),
          omit.stat = c("ser"),
          add.lines = list(c("Month and Cluster FE", "Yes","Yes","No/Yes","No/Yes")),
          out = file.path(data_file_path,"Clusters","Outputs","gs_20km.tex"),
          float = F,
          header = F)
