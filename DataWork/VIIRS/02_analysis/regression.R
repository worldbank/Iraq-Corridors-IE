# Regressions


# Load Data ---------------------------------------------------------------
viirs_grid <- readRDS(file.path(project_file_path, "Data", "VIIRS", 
                          "FinalData", "iraq_viirs_grid_data_clean_subset.Rds"))


# Regressions (5km) -------------------------------------------------------------
##pixels within the 5km range
viirs_grid_5km <-
  viirs_grid[which(viirs_grid$distance_project_roads <=5),]

###FE with PLM
reg1 <- lm(transformed_avg_rad_df ~ road_improvement,
           data = viirs_grid_5km)

reg2 <- plm(transformed_avg_rad_df ~ road_improvement,
               data = viirs_grid_5km, 
            index = c("id", "viirs_time_id"), 
            model = "within")


##Reg Output
stargazer(reg1,
          reg2,
          title = "Within a 5km Buffer",
          font.size = "small",
          digits = 2,
          omit.stat = c("ser"),
          add.lines = list(c("Month and Pixel FE", "No", "Yes")),
          #out = file.path(project_file_path,"Tables","Reg_PixelXMonthly_5km.tex"),
          float = F,
          header = F, type = "text")



# Regressions (10km) -------------------------------------------------------------
##pixels within the 10km range
viirs_grid_10km <-
  viirs_grid[which(viirs_grid$distance_project_roads <=10),]

###FE with PLM
reg1 <- lm(transformed_avg_rad_df ~ road_improvement,
           data = viirs_grid_10km)

reg2 <- plm(transformed_avg_rad_df ~ road_improvement,
            data = viirs_grid_10km, 
            index = c("id", "viirs_time_id"), 
            model = "within")

##Reg Output
stargazer(reg1,
          reg2,
          title = "Within a 10km Buffer",
          font.size = "small",
          digits = 2,
          omit.stat = c("ser"),
          add.lines = list(c("Month and Pixel FE", "No", "Yes")),
          out = file.path(project_file_path,"Tables","Reg_PixelXMonthly_10km.tex"),
          float = F,
          header = F)

# Regressions (20km) -------------------------------------------------------------
##pixels within the 10km range
viirs_grid_20km <-
  viirs_grid[which(viirs_grid$distance_project_roads <=20),]

###FE with PLM
reg1 <- lm(transformed_avg_rad_df ~ road_improvement,
           data = viirs_grid_20km)

reg2 <- plm(transformed_avg_rad_df ~ road_improvement,
            data = viirs_grid_20km, 
            index = c("id", "viirs_time_id"), 
            model = "within")

##Reg Output
stargazer(reg1,
          reg2,
          title = "Within a 20km Buffer",
          font.size = "small",
          digits = 2,
          omit.stat = c("ser"),
          add.lines = list(c("Month and Pixel FE", "No", "Yes")),
          out = file.path(project_file_path,"Tables","Reg_PixelXMonthly_20km.tex"),
          float = F,
          header = F)


# Robustness Checks -------------------------------------------------------
##Change the road improvement time period from 2016 to 2013 onward. 
##Ideally, NTL should have little to no effect during this time period

viirs_grid$placebo_road_improvement <- ifelse(viirs_grid$year > 2012, 1,0)
viirs_grid_5km <-
  viirs_grid[which(viirs_grid$distance_project_roads <=5),]

###FE with PLM
reg1 <- lm(transformed_avg_rad_df ~ placebo_road_improvement,
           data = viirs_grid_5km)

reg2 <- plm(transformed_avg_rad_df ~ placebo_road_improvement,
            data = viirs_grid_5km, 
            index = c("id", "viirs_time_id"), 
            model = "within")


##Reg Output
stargazer(reg1,
          reg2,
          title = "Placebo Test within a 5km Buffer",
          font.size = "small",
          digits = 2,
          omit.stat = c("ser"),
          add.lines = list(c("Month and Pixel FE", "No", "Yes")),
          out = file.path(project_file_path,"Tables","Reg_PixelXMonthly_5km_robustness_check1.tex"),
          float = F,
          header = F)

##Aggregate at 1 km level and then check the results for consistency
viirs_grid <- mutate(viirs_grid, pixel_size = 0.75)
viirs_grid <- viirs_grid[order(id),] #order by pixel


