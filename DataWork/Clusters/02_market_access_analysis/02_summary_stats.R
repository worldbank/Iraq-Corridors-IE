#Market access stats

# Load Data --------------------------------------------------------------------
cluster <- readRDS(file.path(data_file_path, "Clusters", "FinalData", 
                               "cluster_timeinvariant_data_sp.Rds")) %>% st_as_sf()


# Subset Data -------------------------------------------------------------
cluster_50km <- as.data.table(cluster[cluster$dist_gs_km < 50.1,])

# Tables ------------------------------------------------------------------
#theta = 3.8
table1_theta_3_8 <- cluster_50km[,.(MA_tt_rdlength_theta3_8_speed_limit,
                                      MA_tt_rdlength_theta3_8_speed_limit_gs_before,
                                      MA_tt_rdlength_theta3_8_speed_limit_gs_after,
                                      MA_tt_rdlength_theta3_8_exclude10km_speed_limit,
                                      MA_tt_rdlength_theta3_8_exclude10km_speed_limit_gs_before,
                                      MA_tt_rdlength_theta3_8_exclude10km_speed_limit_gs_after,
                                      MA_tt_rdlength_theta3_8_exclude20km_speed_limit,
                                      MA_tt_rdlength_theta3_8_exclude20km_speed_limit_gs_before,
                                      MA_tt_rdlength_theta3_8_exclude20km_speed_limit_gs_after,
                                      MA_tt_rdlength_theta3_8_exclude50km_speed_limit,
                                      MA_tt_rdlength_theta3_8_exclude50km_speed_limit_gs_before,
                                      MA_tt_rdlength_theta3_8_exclude50km_speed_limit_gs_after,
                                      MA_tt_rdlength_theta3_8_exclude100km_speed_limit,
                                      MA_tt_rdlength_theta3_8_exclude100km_speed_limit_gs_before,
                                      MA_tt_rdlength_theta3_8_exclude100km_speed_limit_gs_after,
                                      dist_gs_km),by = uid]
table1_theta_3_8 <- setDT(table1_theta_3_8)[order(dist_gs_km)]
table1_theta_3_8 <- setnames(table1_theta_3_8, 
                           old = c("MA_tt_rdlength_theta3_8_speed_limit",
                                   "MA_tt_rdlength_theta3_8_speed_limit_gs_before",
                                   "MA_tt_rdlength_theta3_8_speed_limit_gs_after",
                                   "MA_tt_rdlength_theta3_8_exclude10km_speed_limit",
                                   "MA_tt_rdlength_theta3_8_exclude10km_speed_limit_gs_before",
                                   "MA_tt_rdlength_theta3_8_exclude10km_speed_limit_gs_after",
                                   "MA_tt_rdlength_theta3_8_exclude20km_speed_limit",
                                   "MA_tt_rdlength_theta3_8_exclude20km_speed_limit_gs_before",
                                   "MA_tt_rdlength_theta3_8_exclude20km_speed_limit_gs_after",
                                   "MA_tt_rdlength_theta3_8_exclude50km_speed_limit",
                                   "MA_tt_rdlength_theta3_8_exclude50km_speed_limit_gs_before",
                                   "MA_tt_rdlength_theta3_8_exclude50km_speed_limit_gs_after",
                                   "MA_tt_rdlength_theta3_8_exclude100km_speed_limit",
                                   "MA_tt_rdlength_theta3_8_exclude100km_speed_limit_gs_before",
                                   "MA_tt_rdlength_theta3_8_exclude100km_speed_limit_gs_after"),
                           new = c("speed_limit",
                                   "gs_before",
                                   "gs_after",
                                   "speed_limit_exclude10km",
                                   "gs_before_exclude10km",
                                   "gs_after_exclude10km",
                                   "speed_limit_exclude20km",
                                   "gs_before_exclude20km",
                                   "gs_after_exclude20km",
                                   "speed_limit_exclude50km",
                                   "gs_before_exclude50km",
                                   "gs_after_exclude50km",
                                   "speed_limit_exclude100km",
                                   "gs_before_exclude100km",
                                   "gs_after_exclude100km"))

table1_theta_3_8 <- table1_theta_3_8 %>% 
  drop_na()                                   
                                   
