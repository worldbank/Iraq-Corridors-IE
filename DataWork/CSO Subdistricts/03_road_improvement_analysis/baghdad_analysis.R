#Analysis for Baghdad


# Load Data ---------------------------------------------------------------
ntl_subdist <- readRDS(file=file.path(project_file_path, 
                                      "Data","CSO Subdistricts","FinalData", 
                                      "subdistrict_data_df_clean.Rds")) %>%
  as.data.frame()

names(ntl_subdist)
# Subset Data -------------------------------------------------------------
vars <- c("uid","viirs_time_id","year","month","ADM3_EN","transformed_viirs_mean",
          "ADM1_EN", "no_of_conflicts","roadimprovement","pop_new")

ntl_subdist <- ntl_subdist[vars]

baghdad <- ntl_subdist[which(ntl_subdist$ADM1_EN == "Baghdad"),]

names(baghdad)

# Regression --------------------------------------------------------------

###FE with PLM
reg1 <- lm(transformed_viirs_mean ~ roadimprovement + no_of_conflicts + pop_new + factor(ADM3_EN) + factor(month),
           data = baghdad)

reg2 <- plm(transformed_viirs_mean ~ roadimprovement, 
            data = baghdad, 
            index = c("ADM3_EN", "viirs_time_id"), 
            model = "within")

reg3 <- plm(transformed_viirs_mean ~ roadimprovement + no_of_conflicts + pop_new, 
            data = baghdad, 
            index = c("ADM3_EN", "viirs_time_id"), 
            model = "within")

##Reg Output
stargazer(reg1,
          reg2,
          reg3,
          title = "Within Baghdad Governorate",
          keep = c("roadimprovement","no_of_conflicts"),
          font.size = "small",
          digits = 3,
          omit.stat = c("ser"),
          add.lines = list(c("Month and Sub-District FE","Yes", "Yes", "Yes")),
          out = file.path(project_file_path,"Tables","Reg_NTLXMonthly_Baghdad.tex"),
          float = F,
          header = F)

       