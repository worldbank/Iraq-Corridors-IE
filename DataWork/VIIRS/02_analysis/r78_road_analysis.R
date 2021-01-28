# Regressions


# Load Data ---------------------------------------------------------------
viirs_grid <- readRDS(file.path(project_file_path, "Data", "VIIRS", 
                          "FinalData", "near_r78ab_roads", "viirs_grid_clean.Rds")) %>%

as.data.frame()


# Event Study -------------------------------------------------------------
#transform viirs
viirs_grid$transformed_avg_rad_df <- 
  log(viirs_grid$avg_rad_df + sqrt((viirs_grid$avg_rad_df)^2+1))

#add treatment var
viirs_grid$road_improvement <- ifelse(viirs_grid$year > 2015,1,0)

#add conflict var
viirs_grid$liberation <- ifelse(viirs_grid$year_month > "2017-06-01",1,0)

##add interaction variable
viirs_grid$roadimprovement_liberation <- viirs_grid$road_improvement*viirs_grid$liberation


##Change the road improvement time period from 2016 to 2013 onward. 
##Ideally, NTL should have little to no effect during this time period
viirs_grid$placebo_road_improvement <- ifelse(viirs_grid$year > 2012, 1,0)

# Regressions (5km) -------------------------------------------------------------
##pixels within the 5km range
viirs_grid_5km <-
  viirs_grid[which(viirs_grid$dist_r78ab_road_km <=5),]

###FE with PLM
reg1 <- lm(transformed_avg_rad_df ~ road_improvement + ndvi,
           data = viirs_grid_5km)

reg2 <- lm(transformed_avg_rad_df ~ road_improvement + ndvi + roadimprovement_liberation,
           data = viirs_grid_5km)

reg3 <- plm(transformed_avg_rad_df ~ road_improvement + ndvi,
               data = viirs_grid_5km, 
            index = c("id", "year_month"), 
            model = "within")

reg4 <- plm(transformed_avg_rad_df ~ road_improvement + ndvi + roadimprovement_liberation,
            data = viirs_grid_5km, 
            index = c("id", "year_month"), 
            model = "within")


##Reg Output
stargazer(reg1,
          reg2,
          reg3,
          reg4,
          keep = c("transformed_avg_rad_df","road_improvement", "ndvi","roadimprovement_liberation"),
          title = "Within a 5km Buffer",
          font.size = "small",
          digits = 2,
          omit.stat = c("ser"),
          add.lines = list(c("Month and Pixel FE", "No","Yes")),
          out = file.path(project_file_path,"Tables","Reg_PixelXMonthlyXLiberation_5km.tex"),
          float = F,
          header = F)

rm(reg1,reg2)

# Regressions (10km) -------------------------------------------------------------
##pixels within the 10km range
viirs_grid_10km <-
  viirs_grid[which(viirs_grid$dist_r78ab_road_km <=10),]

#FE
reg1 <- lm(transformed_avg_rad_df ~ road_improvement + ndvi,
           data = viirs_grid_10km)

reg2 <- lm(transformed_avg_rad_df ~ road_improvement + ndvi + roadimprovement_liberation,
           data = viirs_grid_10km)

reg3 <- plm(transformed_avg_rad_df ~ road_improvement + ndvi,
            data = viirs_grid_10km, 
            index = c("id", "year_month"), 
            model = "within")

reg4 <- plm(transformed_avg_rad_df ~ road_improvement + ndvi + roadimprovement_liberation,
            data = viirs_grid_10km, 
            index = c("id", "year_month"), 
            model = "within")


##Reg Output
stargazer(reg1,
          reg2,
          reg3,
          reg4,
          keep = c("transformed_avg_rad_df","road_improvement", "ndvi","roadimprovement_liberation"),
          title = "Within a 10km Buffer",
          font.size = "small",
          digits = 2,
          omit.stat = c("ser"),
          add.lines = list(c("Month and Pixel FE", "No","Yes")),
          out = file.path(project_file_path,"Tables","Reg_PixelXMonthlyXLiberation_10km.tex"),
          float = F,
          header = F)

rm(reg1,reg2)

# Regressions (20km) -------------------------------------------------------------
##pixels within the 10km range
viirs_grid_20km <-
  viirs_grid[which(viirs_grid$dist_r78ab_road_km <=20),]

###FE with PLM
reg1 <- lm(transformed_avg_rad_df ~ road_improvement + ndvi,
           data = viirs_grid_20km)

reg2 <- lm(transformed_avg_rad_df ~ road_improvement + ndvi + roadimprovement_liberation,
           data = viirs_grid_20km)

reg3 <- plm(transformed_avg_rad_df ~ road_improvement + ndvi,
            data = viirs_grid_20km, 
            index = c("id", "year_month"), 
            model = "within")

reg4 <- plm(transformed_avg_rad_df ~ road_improvement + ndvi + roadimprovement_liberation,
            data = viirs_grid_20km, 
            index = c("id", "year_month"), 
            model = "within")


##Reg Output
stargazer(reg1,
          reg2,
          reg3,
          reg4,
          keep = c("transformed_avg_rad_df","road_improvement", "ndvi","roadimprovement_liberation"),
          title = "Within a 20km Buffer",
          font.size = "small",
          digits = 2,
          omit.stat = c("ser"),
          add.lines = list(c("Month and Pixel FE", "No","Yes")),
          out = file.path(project_file_path,"Tables","Reg_PixelXMonthlyXLiberation_20km.tex"),
          float = F,
          header = F)


# Graphing coefficient estimates ------------------------------------------

reg_5km <- plm(transformed_avg_rad_df ~ road_improvement + ndvi + roadimprovement_liberation,
               data = viirs_grid_5km, 
               index = c("id", "year_month"), 
               model = "within")
reg_10km <- plm(transformed_avg_rad_df ~ road_improvement + ndvi + roadimprovement_liberation,
                data = viirs_grid_10km, 
                index = c("id", "year_month"), 
                model = "within")

reg_20km <- plm(transformed_avg_rad_df ~ road_improvement + ndvi + roadimprovement_liberation,
                data = viirs_grid_20km, 
                index = c("id", "year_month"), 
                model = "within")

plot_summs(reg_5km, reg_10km, reg_20km,inner_ci_level = .9,
           model.names = c("5km", "10km", "20km"), scale = TRUE)

stargazer(reg_5km, reg_10km,reg_20km,
          font.size = "small",
          digits = 3,
          omit.stat = c("ser"),
          add.lines = list(c("Month and Sub-District FE","Yes", "Yes", "Yes")),
          out = file.path(project_file_path, "Tables" ,"Reg_NTLXPixel_all.tex"),
          float = F,
          header = F)

# Robustness Checks -------------------------------------------------------
###FE with PLM
reg1 <- lm(transformed_avg_rad_df ~ placebo_road_improvement + ndvi,
           data = viirs_grid_5km)

reg2 <- plm(transformed_avg_rad_df ~ placebo_road_improvement +ndvi,
            data = viirs_grid_5km, 
            index = c("id", "year_month"), 
            model = "within")


##Reg Output
stargazer(reg1,
          reg2,
          keep = c("road_improvement", "ndvi"),
          title = "Placebo Test within a 5km Buffer",
          font.size = "small",
          digits = 2,
          omit.stat = c("ser"),
          add.lines = list(c("Month and Pixel FE", "No", "Yes")),
          out = file.path(project_file_path,"Tables","Reg_PixelXMonthly_5km_robustness_check1.tex"),
          float = F,
          header = F, type = "text")

##Aggregate at 1 km level and then check the results for consistency



