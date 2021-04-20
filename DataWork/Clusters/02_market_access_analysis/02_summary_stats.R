#Market access stats

# Load Data --------------------------------------------------------------------
iraq_adm3 <- readRDS(file.path(data_file_path, "Clusters", "FinalData", 
                               "subdistrict_timeinvariant_data_sp.Rds")) %>% st_as_sf()

gs <- readRDS(file.path(data_file_path, "Project Roads","Girsheen-Suheila Road","FinalData", 
                        "gs_road_polyline.Rds"))


# Subset Data -------------------------------------------------------------
iraq_adm3_50km <- as.data.table(iraq_adm3[iraq_adm3$dist_gs_km < 50.1,])

# Tables ------------------------------------------------------------------

#theta = 3.8
table1_theta_3_8 <- iraq_adm3_50km[,.(MA_tt_rdlength_theta3_8_speed_limit_before,
                            MA_tt_rdlength_theta3_8_speed_limit_gs_after,dist_gs_km),by = uid]
table1_theta_3_8 <- setDT(table1_theta_3_8)[order(dist_gs_km)]

table1_theta_3_8 <- setnames(table1_theta_3_8, old = c("MA_tt_rdlength_theta3_8_exclude100km_speed_limit_gs_before",
                   "MA_tt_rdlength_theta3_8_exclude100km_speed_limit_gs_after"),
                   new = c("MA_tt_rdlength_before","MA_tt_rdlength_after"))

#theta = 8

table2_theta_8 <- iraq_adm3_50km[,.(MA_tt_rdlength_theta8_exclude100km_speed_limit_gs_before,
                                    MA_tt_rdlength_theta8_exclude100km_speed_limit_gs_after,dist_gs_km),by = uid]
table2_theta_8 <- setDT(table2_theta_8)[order(dist_gs_km)]
table2_theta_8 <- setnames(table2_theta_8, old = c("MA_tt_rdlength_theta8_exclude100km_speed_limit_gs_before",
                         "MA_tt_rdlength_theta8_exclude100km_speed_limit_gs_after"),
         new = c("MA_tt_rdlength_before","MA_tt_rdlength_after"))

