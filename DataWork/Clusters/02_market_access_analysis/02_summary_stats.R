#Market access stats

# Load Data --------------------------------------------------------------------
cluster <- readRDS(file.path(data_file_path, "Clusters", "FinalData", 
                               "cluster_timeinvariant_data_sp.Rds")) %>% st_as_sf()


# Subset Data -------------------------------------------------------------
cluster_50km <- as.data.table(cluster[cluster$dist_gs_km < 50.1,])

names(cluster_50km)
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

table1_theta_3_8$change_in_speed <- round(((table1_theta_3_8$gs_after - table1_theta_3_8$gs_before)/table1_theta_3_8$gs_before)*100,2)                                  
table1_theta_3_8$change_in_speed_exclude10km <- round(((table1_theta_3_8$gs_after_exclude10km - table1_theta_3_8$gs_before_exclude10km)/table1_theta_3_8$gs_before_exclude10km)*100,2)
table1_theta_3_8$change_in_speed_exclude20km <- round(((table1_theta_3_8$gs_after_exclude20km - table1_theta_3_8$gs_before_exclude20km)/table1_theta_3_8$gs_before_exclude20km)*100,2)
table1_theta_3_8$change_in_speed_exclude50km <- round(((table1_theta_3_8$gs_after_exclude50km - table1_theta_3_8$gs_before_exclude50km)/table1_theta_3_8$gs_before_exclude50km)*100,2)
table1_theta_3_8$change_in_speed_exclude100km <- round(((table1_theta_3_8$gs_after_exclude100km - table1_theta_3_8$gs_before_exclude100km)/table1_theta_3_8$gs_before_exclude100km)*100,2)


# Subset Table ------------------------------------------------------------
table1_10km <- table1_theta_3_8[which(table1_theta_3_8$dist_gs_km < 10.1),]
table1_20km <- table1_theta_3_8[which(table1_theta_3_8$dist_gs_km < 20.1),]
table1_50km <- table1_theta_3_8[which(table1_theta_3_8$dist_gs_km < 50.1),]



# Create Tables -----------------------------------------------------------
customGreen = "#71CA97"

improvement_formatter <- 
  formatter("span", 
            style = x ~ style(font.weight = "bold", 
                              color = ifelse(x > 5, customGreen,"black")))

i1 <- table1_10km %>%
  select(c(`uid`, `change_in_speed`, `change_in_speed_exclude10km`, 
           `change_in_speed_exclude20km`,`change_in_speed_exclude50km`,
           `change_in_speed_exclude100km`))

formattable(i1,list(`uid` = formatter("span", style = ~ style(color = "grey",font.weight = "bold")),
                    `change_in_speed` = color_bar(customGreen),
                    `change_in_speed_exclude10km` = color_bar(customGreen) , 
                    `change_in_speed_exclude20km` = color_bar(customGreen),
                    `change_in_speed_exclude50km` = color_bar(customGreen),
                    `change_in_speed_exclude100km` = color_bar(customGreen)))


i2 <- table1_20km %>%
  select(c(`uid`, `change_in_speed`, `change_in_speed_exclude10km`, 
           `change_in_speed_exclude20km`,`change_in_speed_exclude50km`,
           `change_in_speed_exclude100km`))
formattable(i2,list(`uid` = formatter("span", style = ~ style(color = "grey",font.weight = "bold")),
            `change_in_speed` = color_bar(customGreen),
            `change_in_speed_exclude10km` = color_bar(customGreen) , 
            `change_in_speed_exclude20km` = color_bar(customGreen),
            `change_in_speed_exclude50km` = color_bar(customGreen),
            `change_in_speed_exclude100km` = color_bar(customGreen)))

i3 <- table1_50km %>%
  select(c(`uid`, `change_in_speed`, `change_in_speed_exclude10km`, 
           `change_in_speed_exclude20km`,`change_in_speed_exclude50km`,
           `change_in_speed_exclude100km`))
formattable(i3,list(`uid` = formatter("span", style = ~ style(color = "grey",font.weight = "bold")),
                    `change_in_speed` = color_bar(customGreen),
                    `change_in_speed_exclude10km` = color_bar(customGreen) , 
                    `change_in_speed_exclude20km` = color_bar(customGreen),
                    `change_in_speed_exclude50km` = color_bar(customGreen),
                    `change_in_speed_exclude100km` = color_bar(customGreen)))
            
