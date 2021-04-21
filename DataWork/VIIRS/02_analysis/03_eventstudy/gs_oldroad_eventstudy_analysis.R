#IraqIE
#Event Study Analysis

# Load Data ---------------------------------------------------------------
viirs_grid_gs <- readRDS(file.path(project_file_path,"Data", "VIIRS",
                                   "FinalData", "near_girsheen_suheila_road",
                                   "viirs_grid_clean.Rds"))

viirs_grid_oldroad <- readRDS(file.path(project_file_path,"Data", "VIIRS",
                                   "FinalData", "near_zakho_road",
                                   "viirs_grid_clean.Rds"))


#project road
gs_road <- readRDS(file.path(project_file_path,"Data", "Project Roads",
                             "Girsheen-Suheila Road", "FinalData",
                             "gs_road_polyline.Rds"))

oldroad_gs <- readRDS(file.path(project_file_path,"Data", "Project Roads",
                             "Zakho Road", "FinalData",
                             "zakho_road.Rds"))

#check
leaflet() %>%
  addTiles() %>%
  addPolylines(data = oldroad_gs, color = "green")%>%
  addPolylines(data = gs_road, color = "red")


# Adding Variable ---------------------------------------------------------
viirs_grid_gs$Treated <- 1 #treatment
viirs_grid_oldroad$Treated <- 0 #control

#ntl to log
viirs_grid_gs$log_viirs <- log(viirs_grid_gs$avg_rad_df + 1)
viirs_grid_oldroad$log_viirs <- log(viirs_grid_oldroad$avg_rad_df + 1)

#creating vars to bind both df
viirs_grid_gs$dist_oldroad_km <- NA 
viirs_grid_oldroad$dist_gs_road_km <- NA


#adding liberation from ISIS
viirs_grid_gs <- viirs_grid_gs %>%
  mutate(liberation = ifelse((year_month > "2017-11-01"),1,0))

viirs_grid_oldroad <- viirs_grid_oldroad %>%
  mutate(liberation = ifelse((year_month > "2017-11-01"),1,0))

# Event Study Analysis ----------------------------------------------------
#1km
grid_annual_1km <- viirs_grid_gs %>%
  # remove areas 0-1 km from road, as may just be picking up street or car lights
  filter(dist_gs_road_km < 2) %>%
  group_by(id, year,year_month,liberation,log_viirs) %>%
  dplyr::summarise(ndvi = mean(ndvi)) %>%
  ungroup() %>%
  mutate(year = year %>% 
           factor() %>%
           relevel(ref = "2019")) # year left out in regs. should be year before treatment. 


grid_annual_1km_oldroad <- viirs_grid_oldroad %>%
  # remove areas 0-1 km from road, as may just be picking up street or car lights
  filter(dist_zakho_km < 2) %>%
  group_by(id, year,year_month,liberation,log_viirs) %>%
  dplyr::summarise(ndvi = mean(ndvi)) %>%
  ungroup() %>%
  mutate(year = year %>% 
           factor() %>%
           relevel(ref = "2019")) # year left out in regs. should be year before treatment.



#5km
grid_annual_5km <- viirs_grid_gs %>%
  # remove areas 0-1 km from road, as may just be picking up street or car lights
  filter(dist_gs_road_km> 1 & dist_gs_road_km < 5) %>%
  group_by(id, year,year_month,liberation,log_viirs) %>%
  dplyr::summarise(ndvi = mean(ndvi)) %>%
  ungroup() %>%
  mutate(year = year %>% 
           factor() %>%
           relevel(ref = "2019")) # year left out in regs. should be year before treatment. 

grid_annual_5km_oldroad <- viirs_grid_oldroad %>%
  # remove areas 0-1 km from road, as may just be picking up street or car lights
  filter(dist_zakho_km> 1 & dist_zakho_km < 5) %>%
  group_by(id, year,year_month,liberation,log_viirs) %>%
  dplyr::summarise(ndvi = mean(ndvi)) %>%
  ungroup() %>%
  mutate(year = year %>% 
           factor() %>%
           relevel(ref = "2019")) # year left out in regs. should be year before treatment. 


# 1km ---------------------------------------------------------------------
#### Regressions
reg1 <- felm(log_viirs ~ factor(year) + liberation + ndvi| id | 0 | 0, data = grid_annual_1km)
reg2 <- felm(log_viirs ~ factor(year) + liberation + ndvi| id | 0 | 0, data = grid_annual_1km_oldroad)

stargazer(reg1,
          reg2,
          column.labels = c("Girsheen - Suheila", "Old Road"),
          font.size = "small",
          digits = 3,
          omit.stat = c("ser"),
          out = file.path(project_file_path,"Data","VIIRS","Outputs","tables" ,
                         "event_study_gs_oldroad_1km.tex"),
          float = F, align = T,
          header = F)


# 5km ---------------------------------------------------------------------

#### Regressions
reg1 <- felm(log_viirs ~ factor(year) + liberation + ndvi| id | 0 | 0, data = grid_annual_5km)
reg2 <- felm(log_viirs ~ factor(year) + liberation + ndvi| id | 0 | 0, data = grid_annual_5km_oldroad)


stargazer(reg1,
          reg2,
          column.labels = c("Girsheen - Suheila", "Old Road"),
          font.size = "small",
          digits = 3,
          omit.stat = c("ser"),
          out = file.path(project_file_path,"Data","VIIRS","Outputs","tables" ,
                          "event_study_gs_oldroad_5km.tex"),
          float = F, align = T,
          header = F)

# Regression (10km) -------------------------------------------------------
grid_annual_10km<- viirs_grid_gs %>%
  # remove areas 0-1 km from road, as may just be picking up street or car lights
  filter(dist_gs_road_km > 1 & dist_gs_road_km < 10) %>%
  group_by(id, year,year_month,liberation,log_viirs) %>%
  dplyr::summarise(ndvi = mean(ndvi)) %>%
  ungroup() %>%
  mutate(year = year %>% 
           factor() %>%
           relevel(ref = "2019"))


grid_annual_10km_oldroad <- viirs_grid_oldroad %>%
  # remove areas 0-1 km from road, as may just be picking up street or car lights
  filter(dist_zakho_km > 1 & dist_zakho_km < 10) %>%
  group_by(id, year,year_month,liberation,log_viirs) %>%
  dplyr::summarise(ndvi = mean(ndvi)) %>%
  ungroup() %>%
  mutate(year = year %>% 
           factor() %>%
           relevel(ref = "2019"))

#### Regressions
reg1 <- felm(log_viirs ~ factor(year) + liberation + ndvi| id | 0 | 0, data = grid_annual_10km)
reg2 <- felm(log_viirs ~ factor(year) + liberation + ndvi| id | 0 | 0, data = grid_annual_10km_oldroad)


stargazer(reg1,
          reg2,
          column.labels = c("Girsheen - Suheila", "Old Road"),
          font.size = "small",
          digits = 3,
          omit.stat = c("ser"),
          out = file.path(project_file_path,"Data","VIIRS","Outputs","tables" ,
                          "event_study_gs_oldroad_10km.tex"),
          float = F, align = T,
          header = F)


# Regression (20km) -------------------------------------------------------
grid_annual_20km<- viirs_grid_gs %>%
  # remove areas 0-1 km from road, as may just be picking up street or car lights
  filter(dist_gs_road_km > 1 & dist_gs_road_km< 20) %>%
  group_by(id, year,year_month,liberation,log_viirs) %>%
  dplyr::summarise(ndvi = mean(ndvi)) %>%
  ungroup() %>%
  mutate(year = year %>% 
           factor() %>%
           relevel(ref = "2019"))


grid_annual_20km_oldroad <- viirs_grid_oldroad %>%
  # remove areas 0-1 km from road, as may just be picking up street or car lights
  filter(dist_zakho_km> 1 & dist_zakho_km < 20) %>%
  group_by(id, year,year_month,liberation,log_viirs) %>%
  dplyr::summarise(ndvi = mean(ndvi)) %>%
  ungroup() %>%
  mutate(year = year %>% 
           factor() %>%
           relevel(ref = "2019"))

#### Regressions
reg1 <- felm(log_viirs ~ factor(year) + liberation + ndvi | id | 0 | 0, data = grid_annual_20km)
reg2 <- felm(log_viirs ~ factor(year) + liberation + ndvi | id | 0 | 0, data = grid_annual_20km_oldroad)


stargazer(reg1,
          reg2,
          column.labels = c("Girsheen - Suheila", "Old Road"),
          font.size = "small",
          digits = 3,
          omit.stat = c("ser"),
          out = file.path(project_file_path,"Data","VIIRS","Outputs","tables" ,
                          "event_study_gs_oldroad_20km.tex"),
          float = F, align = T,
          header = F)

