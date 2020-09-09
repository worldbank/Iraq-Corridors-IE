# Iraq IE
# Conducting regression


# Loading Data set ---------------------------------------------------------
ntl_subdist <- readRDS(file=file.path(final_data_file_path, "Cleaned Data for Preliminary Analysis", "FinalData", "ntl_subdist_final.Rds"))
market_access <- readRDS(file=file.path(final_data_file_path, "CSO Subdistricts", "FinalData","subdistrict_population_marketaccess.Rds"))
#ntl_pixel <- readRDS(file=file.path(final_data_file_path, "VIIRS", "FinalData","iraq_viirs_grid_data_clean.Rds"))

# Transformation of viirs_mean --------------------------------------------
ntl_subdist$transformed_viirs_mean <- 
  log(ntl_subdist$viirs_mean + sqrt((ntl_subdist$viirs_mean)^2+1))



# Treating missing values -------------------------------------------------
##replace NA with 0
ntl_subdist[is.na(ntl_subdist)] <- 0

##create binary for incomplete data
ntl_subdist$missing <-
  ifelse(ntl_subdist$average_hh_exp.mean == 0|ntl_subdist$no_of_conflicts ==0 |ntl_subdist$no_of_settlements == 0,1,0)



# Regressions (5km) -------------------------------------------------------------
##sub-districts within the 5km range
ntl_subdist_5km <-
  ntl_subdist[which(ntl_subdist$treat_5km == 1),]


###FE with FELM
reg1 <- lm(transformed_viirs_mean ~ roadimprovement,
           data = ntl_subdist_5km)


reg2 <- plm(transformed_viirs_mean ~ roadimprovement, 
            data = ntl_subdist_5km, 
            index = c("ADM3_EN", "viirs_time_id"), 
            model = "within")
reg3 <- plm(transformed_viirs_mean ~ roadimprovement + average_hh_exp.mean + no_of_conflicts + no_of_settlements + missing , 
            data = ntl_subdist_5km, 
            index = c("ADM3_EN", "viirs_time_id"), 
            model = "within")

##Reg Output
stargazer(reg1,
          reg2,
          reg3,
          keep = c("roadimprovement", "average_hh_exp.mean","no_of_conflicts","no_of_settlements"),
          font.size = "small",
          digits = 3,
          omit.stat = c("ser"),
          add.lines = list(c("Month and Sub-District FE", "No", "Yes", "Yes")),
          out = file.path(tables_file_path, "Reg_NTLXMonthly_5km.tex"),
          float = F,
          header = F)

remove(ntl_subdist_5km,reg1,reg2,reg3)

# Regressions (10km) -------------------------------------------------------------
##sub-districts within the 10km range
ntl_subdist_10km <-
  ntl_subdist[which(ntl_subdist$treat_10km == 1),]


###FE with FELM
reg1 <- lm(transformed_viirs_mean ~ roadimprovement,
           data = ntl_subdist_10km)


reg2 <- plm(transformed_viirs_mean ~ roadimprovement, 
            data = ntl_subdist_10km, 
            index = c("ADM3_EN", "viirs_time_id"), 
            model = "within")

reg3 <- plm(transformed_viirs_mean ~ roadimprovement + average_hh_exp.mean + no_of_conflicts + no_of_settlements + missing , 
            data = ntl_subdist_10km, 
            index = c("ADM3_EN", "viirs_time_id"), 
            model = "within")

##Reg Output
stargazer(reg1,
          reg2,
          reg3,
          keep = c("roadimprovement", "average_hh_exp.mean","no_of_conflicts","no_of_settlements"),
          font.size = "small",
          digits = 3,
          omit.stat = c("ser"),
          add.lines = list(c("Month and Sub-District FE", "No", "Yes", "Yes")),
          out = file.path(tables_file_path, "Reg_NTLXMonthly_10km.tex"),
          float = F,
          header = F)

remove(ntl_subdist_10km,reg1,reg2,reg3)

# Regressions (20km) -------------------------------------------------------------
ntl_subdist_20km <-
  ntl_subdist[which(ntl_subdist$treat_20km == 1),]

###FE with FELM
reg1 <- lm(transformed_viirs_mean ~ roadimprovement,
           data = ntl_subdist_20km)


reg2 <- plm(transformed_viirs_mean ~ roadimprovement, 
            data = ntl_subdist_20km, 
            index = c("ADM3_EN", "viirs_time_id"), 
            model = "within")

reg3 <- plm(transformed_viirs_mean ~ roadimprovement + average_hh_exp.mean + no_of_conflicts + no_of_settlements + missing , 
            data = ntl_subdist_20km, 
            index = c("ADM3_EN", "viirs_time_id"), 
            model = "within")

##Reg Output
stargazer(reg1,
          reg2,
          reg3,
          keep = c("roadimprovement", "average_hh_exp.mean","no_of_conflicts","no_of_settlements"),
          font.size = "small",
          digits = 3,
          omit.stat = c("ser"),
          add.lines = list(c("Month and Sub-District FE", "No", "Yes", "Yes")),
          out = file.path(tables_file_path, "Reg_NTLXMonthly_20km.tex"),
          float = F,
          header = F)

remove(ntl_subdist_20km,reg1,reg2,reg3)


# Variation in Nighttime Lights --------------------------------------------------------
##aggregate by month + year
ntl_subdist_year <-
  aggregate(transformed_viirs_mean ~ month + year,
            data = ntl_subdist,
            FUN = mean)

##create plot
ntl_variation <- ggplot(ntl_subdist_year, aes(year,transformed_viirs_mean)) +
  geom_point(size = 2, shape = 1) +
  geom_vline(xintercept = as.numeric(ntl_subdist_year$year[which(ntl_subdist_year$year == 2014)]), 
             size = 1, colour = "red",linetype = "dashed") +
  geom_smooth(method = "lm", se = T, color = "black") +
  ggtitle("Variation in NTL Pre & Post 2014")

ntl_variation <- p + theme(
  plot.title = element_text(color="black", size=12, face="bold", hjust = 0.5))
 
ggsave(filename = file.path(figures_file_path,"ntl_variation.png"))


# Market Access -----------------------------------------------------------
market <- market_access@data
remove(market_access)

##merge market access with main dataset
ntl_subdist <- merge(ntl_subdist,market, by = "uid")


# Market Access (5km) -----------------------------------------------------
##sub-districts within the 5km range
ntl_subdist_5km <-
  ntl_subdist[which(ntl_subdist$treat_5km == 1),]

names(ntl_subdist)

###FE with FELM
reg1 <- lm(transformed_viirs_mean ~ MA_dist_theta3_8 + MA_dist_theta3_8_exclude10km + MA_rdlength_theta3_8_exclude10km + 
             MA_tt_theta3_8_exclude100km + MA_rdlength_theta3_8_exclude100km ,
           data = ntl_subdist_5km)


reg2 <- plm(transformed_viirs_mean ~ MA_dist_theta3_8 + MA_dist_theta3_8_exclude10km + MA_rdlength_theta3_8_exclude10km + 
              MA_tt_theta3_8_exclude100km + MA_rdlength_theta3_8_exclude100km , 
            data = ntl_subdist_5km, 
            index = c("ADM3_EN", "viirs_time_id"), 
            model = "within")

reg3 <- plm(transformed_viirs_mean ~ roadimprovement + average_hh_exp.mean + no_of_conflicts + no_of_settlements + missing , 
            data = ntl_subdist_10km, 
            index = c("ADM3_EN", "viirs_time_id"), 
            model = "within")

