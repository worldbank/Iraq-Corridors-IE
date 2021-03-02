#DID analysis
#Between Old Road and Girsheen - Suheila

# Load Data ---------------------------------------------------------------
#gs
viirs_grid_gs <- readRDS(file.path(project_file_path, "Data", "VIIRS", 
                                        "FinalData","near_girsheen_suheila_road",
                                        "viirs_grid_clean.Rds"))


#oldroad
viirs_grid_oldroad<- readRDS(file.path(project_file_path,"Data", "VIIRS",
                                         "FinalData", "near_zakho_road",
                                         "viirs_grid_clean.Rds" ))

# Adding vars -------------------------------------------------------------
viirs_grid_gs$Treated<- 0 #control road
viirs_grid_oldroad$Treated <- 1 #treatment roads

viirs_grid_gs$dist_oldroad_km <- NA
viirs_grid_oldroad$dist_gs_road_km <- NA



# Creating panel for DID --------------------------------------------------
#gs + oldroad
grid_gs_oldroad <- rbind(viirs_grid_gs,viirs_grid_oldroad, fill= TRUE)

#adding vars
grid_gs_oldroad <- grid_gs_oldroad %>%
  mutate(Time = ifelse((year_month > "2019-12-01"),1,0))

# Converting NTL to Log ---------------------------------------------------
grid_gs_oldroad <- grid_gs_oldroad %>%
  mutate(log_viirs = log(avg_rad_df + 1))

grid_gs_oldroad$liberation <- ifelse(grid_gs_oldroad$year_month > "2017-06-01",1,0)

# Subset by Buffer --------------------------------------------------------
grid_gs_oldroad_1km <- grid_gs_oldroad[which(grid_gs_oldroad$dist_gs_road_km < 2 |
                                               grid_gs_oldroad$dist_oldroad_km< 2),]

grid_gs_oldroad_5km <- grid_gs_oldroad[which(grid_gs_oldroad$dist_gs_road_km < 5.1 |
                                               grid_gs_oldroad$dist_oldroad_km < 5.1),]

grid_gs_oldroad_10km <- grid_gs_oldroad[which(grid_gs_oldroad$dist_gs_road_km < 10.1 |
                                               grid_gs_oldroad$dist_oldroad_km < 10.1),]

grid_gs_oldroad_20km <- grid_gs_oldroad[which(grid_gs_oldroad$dist_gs_road_km < 20.1 |
                                                grid_gs_oldroad$dist_oldroad_km < 20.1),]

# Summary Statistics ------------------------------------------------------
summaryBy(log_viirs ~ Treated + year, data = grid_gs_oldroad_10km,
          FUN = function(x) { c(m = mean(x), s = sd(x)) } )

# Regressions -------------------------------------------------------------
did_gs_oldroad_1km <- lm(log_viirs ~ Treated*Time + ndvi + liberation,
                               data = grid_gs_oldroad_1km)

did_gs_oldroad_5km <- lm(log_viirs ~ Treated*Time + ndvi + liberation,
                                data = grid_gs_oldroad_5km)

did_gs_oldroad_10km <- lm(log_viirs ~ Treated*Time + ndvi + liberation,
                                data = grid_gs_oldroad_10km)

did_gs_oldroad_20km <- lm(log_viirs ~ Treated*Time + ndvi + liberation,
                          data = grid_gs_oldroad_20km)

stargazer(did_gs_oldroad_1km,
          did_gs_oldroad_5km,
          did_gs_oldroad_10km,
          did_gs_oldroad_20km,
          column.labels = c("1km","5km", "10km", "20km"),
          font.size = "small",
          digits = 3,
          omit.stat = c("ser"),
          #out = file.path(project_file_path,"Data","VIIRS","Outputs","tables" ,
           #               "did_gs_oldroad.tex"),
          float = F, align = T,
          header = F, type = "text")




