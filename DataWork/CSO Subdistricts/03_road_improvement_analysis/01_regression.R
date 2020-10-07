# Run regressions
# Loading Data set ---------------------------------------------------------
ntl_subdist <- readRDS(file=file.path(project_file_path, 
                                      "Data","CSO Subdistricts","FinalData", 
                                      "subdistrict_data_df_clean.Rds"))


# Regressions (5km) -------------------------------------------------------------
##sub-districts within the 5km range
ntl_subdist_5km <-
  ntl_subdist[which(ntl_subdist$dist_r78_km <=5),]

###FE with PLM

reg1 <- lm(transformed_viirs_mean ~ roadimprovement + no_of_conflicts + pop_new + avg_hh_exp.mean + missing + factor(ADM3_EN) + factor(month),
           data = ntl_subdist_5km)


reg2 <- plm(transformed_viirs_mean ~ roadimprovement, 
            data = ntl_subdist_5km, 
            index = c("ADM3_EN", "viirs_time_id"), 
            model = "within")

reg3 <- plm(transformed_viirs_mean ~ roadimprovement + no_of_conflicts + pop_new + avg_hh_exp.mean + missing, 
            data = ntl_subdist_5km, 
            index = c("ADM3_EN", "viirs_time_id"), 
            model = "within")

##Reg Output
stargazer(reg1,
          reg2,
          reg3,
          title = "Within a 5km Buffer",
          keep = c("roadimprovement","no_of_conflicts", "pop_new", "avg_hh_exp.mean"),
          font.size = "small",
          digits = 3,
          omit.stat = c("ser"),
          add.lines = list(c("Month and Sub-District FE","Yes", "Yes", "Yes")),
          out = file.path(project_file_path,"Tables","Reg_NTLXMonthly_5km.tex"),
          float = F,
          header = F, type = "text")

remove(ntl_subdist_5km,reg1,reg2,reg3)

# Regressions (10km) -------------------------------------------------------------
##sub-districts within the 10km range
ntl_subdist_10km <-
  ntl_subdist[which(ntl_subdist$dist_r78_km <= 10),]

###FE with FELM
reg1 <- lm(transformed_viirs_mean ~ roadimprovement + avg_hh_exp.mean + no_of_conflicts + pop_new + missing + factor(ADM3_EN) + factor(month),
           data = ntl_subdist_10km)


reg2 <- plm(transformed_viirs_mean ~ roadimprovement, 
            data = ntl_subdist_10km, 
            index = c("ADM3_EN", "viirs_time_id"), 
            model = "within")

reg3 <- plm(transformed_viirs_mean ~ roadimprovement + avg_hh_exp.mean + no_of_conflicts + pop_new + missing , 
            data = ntl_subdist_10km, 
            index = c("ADM3_EN", "viirs_time_id"), 
            model = "within")

##Reg Output
stargazer(reg1,
          reg2,
          reg3,
          title = "Within a 10km Buffer",
          keep = c("roadimprovement","no_of_conflicts","pop_new","average_hh_exp.mean"),
          font.size = "small",
          digits = 3,
          omit.stat = c("ser"),
          add.lines = list(c("Month and Sub-District FE", "Yes", "Yes", "Yes")),
          out = file.path(project_file_path,"Tables","Reg_NTLXMonthly_10km.tex"),
          float = F,
          header = F)

remove(ntl_subdist_10km,reg1,reg2,reg3)

# Regressions (20km) -------------------------------------------------------------
ntl_subdist_20km <-
  ntl_subdist[which(ntl_subdist$dist_r78_km <= 20),]

###FE with FELM
reg1 <- lm(transformed_viirs_mean ~ roadimprovement + avg_hh_exp.mean + no_of_conflicts + pop_new + missing + factor(ADM3_EN) + factor(month),
           data = ntl_subdist_20km)


reg2 <- plm(transformed_viirs_mean ~ roadimprovement, 
            data = ntl_subdist_20km, 
            index = c("ADM3_EN", "viirs_time_id"), 
            model = "within")

reg3 <- plm(transformed_viirs_mean ~ roadimprovement + avg_hh_exp.mean + no_of_conflicts + pop_new + missing , 
            data = ntl_subdist_20km, 
            index = c("ADM3_EN", "viirs_time_id"), 
            model = "within")

##Reg Output
stargazer(reg1,
          reg2,
          reg3,
          title = "Within a 20km Buffer",
          keep = c("roadimprovement","no_of_conflicts","no_of_settlements","pop_new", "average_hh_exp.mean"),
          font.size = "small",
          digits = 3,
          omit.stat = c("ser"),
          add.lines = list(c("Month and Sub-District FE", "Yes", "Yes", "Yes")),
          out = file.path(project_file_path, "Tables" ,"Reg_NTLXMonthly_20km.tex"),
          float = F,
          header = F)
