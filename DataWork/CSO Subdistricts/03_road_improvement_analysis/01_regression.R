# Run regressions
# Loading Data set ---------------------------------------------------------
ntl_subdist <- readRDS(file=file.path(project_file_path, 
                                      "Data","CSO Subdistricts","FinalData", 
                                      "subdistrict_data_df.Rds"))

# Transformation of viirs_mean --------------------------------------------
ntl_subdist$transformed_viirs_mean <- 
  log(ntl_subdist$viirs_mean + sqrt((ntl_subdist$viirs_mean)^2+1))


# Temp Road Improvement var -----------------------------------------------
ntl_subdist$roadimprovement <- ifelse(ntl_subdist$year > 2015,1,0)

# Treating missing values -------------------------------------------------
## include population growth (assuming a 2.5% annual growth)
ntl_subdist$pop_new <- ntl_subdist$population
ntl_subdist$pop_new[ntl_subdist$year == 2016] <- ntl_subdist$population[ntl_subdist$year == 2016]*(1+2.5)
ntl_subdist$pop_new[ntl_subdist$year == 2017] <- ntl_subdist$population[ntl_subdist$year == 2017]*(1+2.5)^2
ntl_subdist$pop_new[ntl_subdist$year == 2018] <- ntl_subdist$population[ntl_subdist$year == 2017]*(1+2.5)^3
ntl_subdist$pop_new[ntl_subdist$year == 2019] <- ntl_subdist$population[ntl_subdist$year == 2017]*(1+2.5)^4

##settlement var should only reflect 2014 figures
ntl_subdist$no_of_settlements <- ifelse(ntl_subdist$year == 2014,
                                        ntl_subdist$no_of_settlements,0)

##replace NA with 0
ntl_subdist[is.na(ntl_subdist)] <- 0


##create binary for incomplete data
ntl_subdist$missing <-
  ifelse(ntl_subdist$avg_hh_exp.mean == 0|ntl_subdist$no_of_conflicts ==0 |ntl_subdist$no_of_settlements == 0,1,0)



# Regressions (5km) -------------------------------------------------------------
##sub-districts within the 5km range
ntl_subdist_5km <-
  ntl_subdist[which(ntl_subdist$dist_r78_km <=5),]


###FE with PLM
reg1 <- lm(transformed_viirs_mean ~ roadimprovement,
           data = ntl_subdist_5km)


reg2 <- plm(transformed_viirs_mean ~ roadimprovement, 
            data = ntl_subdist_5km, 
            index = c("ADM3_EN", "viirs_time_id"), 
            model = "within")

reg3 <- plm(transformed_viirs_mean ~ roadimprovement + avg_hh_exp.mean + no_of_conflicts + no_of_settlements + pop_new + missing , 
            data = ntl_subdist_5km, 
            index = c("ADM3_EN", "viirs_time_id"), 
            model = "within")

##Reg Output
stargazer(reg1,
          reg2,
          reg3,
          keep = c("roadimprovement", "average_hh_exp.mean","no_of_conflicts","no_of_settlements", "pop_new"),
          font.size = "small",
          digits = 3,
          omit.stat = c("ser"),
          add.lines = list(c("Month and Sub-District FE", "No", "Yes", "Yes")),
          out = file.path(project_file_path,"Tables","Reg_NTLXMonthly_5km.tex"),
          float = F,
          header = F)

remove(ntl_subdist_5km,reg1,reg2,reg3)

# Regressions (10km) -------------------------------------------------------------
##sub-districts within the 10km range
ntl_subdist_10km <-
  ntl_subdist[which(ntl_subdist$dist_r78_km <= 10),]

###FE with FELM
reg1 <- lm(transformed_viirs_mean ~ roadimprovement,
           data = ntl_subdist_10km)


reg2 <- plm(transformed_viirs_mean ~ roadimprovement, 
            data = ntl_subdist_10km, 
            index = c("ADM3_EN", "viirs_time_id"), 
            model = "within")

reg3 <- plm(transformed_viirs_mean ~ roadimprovement + avg_hh_exp.mean + no_of_conflicts + no_of_settlements + pop_new + missing , 
            data = ntl_subdist_10km, 
            index = c("ADM3_EN", "viirs_time_id"), 
            model = "within")

##Reg Output
stargazer(reg1,
          reg2,
          reg3,
          keep = c("roadimprovement", "average_hh_exp.mean","no_of_conflicts","no_of_settlements","pop_new"),
          font.size = "small",
          digits = 3,
          omit.stat = c("ser"),
          add.lines = list(c("Month and Sub-District FE", "No", "Yes", "Yes")),
          out = file.path(project_file_path,"Tables","Reg_NTLXMonthly_10km.tex"),
          float = F,
          header = F)

remove(ntl_subdist_10km,reg1,reg2,reg3)

# Regressions (20km) -------------------------------------------------------------
ntl_subdist_20km <-
  ntl_subdist[which(ntl_subdist$dist_r78_km <= 20),]

###FE with FELM
reg1 <- lm(transformed_viirs_mean ~ roadimprovement,
           data = ntl_subdist_20km)


reg2 <- plm(transformed_viirs_mean ~ roadimprovement, 
            data = ntl_subdist_20km, 
            index = c("ADM3_EN", "viirs_time_id"), 
            model = "within")

reg3 <- plm(transformed_viirs_mean ~ roadimprovement + avg_hh_exp.mean + no_of_conflicts + no_of_settlements + pop_new + missing , 
            data = ntl_subdist_20km, 
            index = c("ADM3_EN", "viirs_time_id"), 
            model = "within")

##Reg Output
stargazer(reg1,
          reg2,
          reg3,
          keep = c("roadimprovement", "average_hh_exp.mean","no_of_conflicts","no_of_settlements","pop_new"),
          font.size = "small",
          digits = 3,
          omit.stat = c("ser"),
          add.lines = list(c("Month and Sub-District FE", "No", "Yes", "Yes")),
          out = file.path(project_file_path, "Tables" ,"Reg_NTLXMonthly_20km.tex"),
          float = F,
          header = F)
