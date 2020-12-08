#Analysis for Baghdad


# Load Data ---------------------------------------------------------------
ntl_subdist <- readRDS(file=file.path(project_file_path, 
                                      "Data","CSO Subdistricts","FinalData", 
                                      "subdistrict_data_df_clean.Rds")) %>%
  as.data.frame()



# Add liberation and interaction var --------------------------------------
#cleaning date variable
ntl_subdist$year_month <- paste0(ntl_subdist$year, "-", ntl_subdist$month, "-01") %>% 
  ymd()

#liberation
ntl_subdist$liberation <- ifelse(ntl_subdist$year_month > "2017-06-01",1,0)

#create interaction variable
ntl_subdist$roadimprovement_liberation <- ntl_subdist$roadimprovement*ntl_subdist$liberation


# Subset Data -------------------------------------------------------------
vars <- c("uid","viirs_time_id","year","month","ADM3_EN","transformed_viirs_mean",
          "ADM1_EN", "no_of_conflicts","roadimprovement","pop_new","roadimprovement_liberation")

ntl_subdist <- ntl_subdist[vars]

baghdad <- ntl_subdist[which(ntl_subdist$ADM1_EN == "Baghdad"),]

names(baghdad)

# Regression --------------------------------------------------------------

###FE with PLM
reg1 <- lm(transformed_viirs_mean ~ roadimprovement + no_of_conflicts + pop_new + factor(ADM3_EN) + factor(month),
           data = baghdad)

reg2 <- lm(transformed_viirs_mean ~ roadimprovement + no_of_conflicts + pop_new + factor(ADM3_EN) + factor(month)+ roadimprovement_liberation,
           data = baghdad)

reg3 <- plm(transformed_viirs_mean ~ roadimprovement + no_of_conflicts + pop_new, 
            data = baghdad, 
            index = c("ADM3_EN", "viirs_time_id"), 
            model = "within")

reg4 <- plm(transformed_viirs_mean ~ roadimprovement + no_of_conflicts + pop_new + roadimprovement_liberation, 
            data = baghdad, 
            index = c("ADM3_EN", "viirs_time_id"), 
            model = "within")


##Reg Output
stargazer(reg1,
          reg2,
          reg3,
          reg4,
          title = "Within Baghdad Governorate",
          keep = c("roadimprovement","no_of_conflicts","roadimprovement_liberation"),
          font.size = "small",
          digits = 3,
          omit.stat = c("ser"),
          add.lines = list(c("Month and Sub-District FE","Yes", "Yes", "Yes","Yes")),
          out = file.path(project_file_path,"Tables","Reg_NTLXMonthly_Baghdad.tex"),
          float = F,
          header = F)

       