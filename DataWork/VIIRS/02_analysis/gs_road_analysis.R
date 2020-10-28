# G-S Road Analysis

# TODO
# 1. We should probably cluster on something... but adm2 is too big
# 2. When road finished? Update reference year.

# Load Data --------------------------------------------------------------------
grid <- readRDS(file.path(project_file_path, "Data", "VIIRS", "FinalData", 
                          "near_girsheen_suheila_road", "viirs_grid_clean.Rds")) %>%
  as.data.frame()

# Figure -----------------------------------------------------------------------
grid_sum_stack <- grid %>%
  group_by(year) %>%
  dplyr::summarise("avg_rad_5" = mean(avg_rad_df[dist_gs_road_km < 5]),
                   "avg_rad_0-1" = mean(avg_rad_df[dist_gs_road_km > 0 & dist_gs_road_km < 1]),
                   "avg_rad_1-2" = mean(avg_rad_df[dist_gs_road_km > 1 & dist_gs_road_km < 2]),
                   "avg_rad_2-3" = mean(avg_rad_df[dist_gs_road_km > 2 & dist_gs_road_km < 3]),
                   "avg_rad_3-4" = mean(avg_rad_df[dist_gs_road_km > 3 & dist_gs_road_km < 4]),
                   "avg_rad_4-5" = mean(avg_rad_df[dist_gs_road_km > 4 & dist_gs_road_km < 5])) %>%
  pivot_longer(cols = -year) %>%
  mutate(name = name %>% 
           str_replace_all("avg_rad_", "")) %>%
  dplyr::rename(buffer = name)

gs_ntl_trends <- grid_sum_stack %>%
  ggplot(aes(x = year, 
             y = value,
             group = buffer,
             color = buffer),
         size = 1) +
  geom_line(size=1) +
  labs(color = "Buffer (km)",
       title = "Average NTL Radiance near\nGirsheen Suheila Road",
       x = "", 
       y = "Average\nRadiance") +
  theme_minimal() + 
  scale_colour_brewer(palette = "Dark2")


ggsave(gs_ntl_trends, filename = file.path(project_file_path,"Figures","gs_ntl_trends_buffer_5km.png"), width = 6, height = 6)

# For buffers 5, 10 20 km
grid_buffer_stack <- grid %>%
  group_by(year) %>%
  dplyr::summarise("avg_rad_5" = mean(avg_rad_df[dist_gs_road_km > 0 & dist_gs_road_km <= 5]),
                   "avg_rad_10" = mean(avg_rad_df[dist_gs_road_km > 0 & dist_gs_road_km <= 10]),
                   "avg_rad_20" = mean(avg_rad_df[dist_gs_road_km > 0 & dist_gs_road_km <= 20])) %>%
  pivot_longer(cols = -year) %>%
  mutate(name = name %>% 
           str_replace_all("avg_rad_", "")) %>%
  dplyr::rename(buffer = name)

gs_ntl <- grid_buffer_stack %>%
  ggplot(aes(x = year, 
             y = value,
             group = buffer,
             color = buffer),
         size = 1) +
  geom_line(size=1) +
  labs(color = "Buffer (km)",
       title = "Average NTL Radiance near\nGirsheen Suheila Road",
       x = "", 
       y = "Average\nRadiance") +
  theme_minimal() + 
  scale_colour_brewer(palette = "Dark2")

ggsave(gs_ntl, filename = file.path(project_file_path,"Figures","gs_ntl_trends.png"), width = 6, height = 6)


## Check NDVI
grid %>%
  filter(dist_gs_road_km < 5) %>%
  group_by(year) %>%
  summarise(ndvi = mean(ndvi)) %>%
  ggplot() +
  geom_line(aes(x = year, y=ndvi))

# Event Study ------------------------------------------------------------------
#### Prep Data
#drop NA GADM
grid <-grid[!is.na(grid$GADM_ID_2),]

grid_annual_5km <- grid %>%
  # remove areas 0-1 km from road, as may just be picking up street or car lights
  filter(dist_gs_road_km > 1 & dist_gs_road_km < 5) %>%
  group_by(id, year, GADM_ID_2,year_month) %>%
  dplyr::summarise(avg_rad_df = mean(avg_rad_df),
                   ndvi = mean(ndvi)) %>%
  ungroup() %>%
  mutate(year = year %>% 
           factor() %>%
           relevel(ref = "2019")) # year left out in regs. should be year before
                                  # treatment. 
grid_annual_5km$log_avg_rad_df <- log(grid_annual_5km$avg_rad_df + sqrt((grid_annual_5km$avg_rad_df)^2+1))

#### Regressions
reg1 <- felm(avg_rad_df ~ factor(year) | id | 0 | 0, data = grid_annual_5km)
reg2 <- felm(avg_rad_df ~ factor(year) + ndvi | id | 0 | 0, data = grid_annual_5km)

reg3 <- felm(log_avg_rad_df ~ factor(year) | id | 0 | 0, data = grid_annual_5km)
reg4 <- felm(log_avg_rad_df ~ factor(year) + ndvi | id | 0 | 0, data = grid_annual_5km)


stargazer(reg1,
          reg2,
          reg3,
          reg4,
          title = "Within a 5km Buffer",
          font.size = "small",
          digits = 3,
          omit.stat = c("ser"),
          out = file.path(project_file_path,"Tables","gs_EventStudy_5km.tex"),
          float = F,
          header = F)



# 10km --------------------------------------------------------------------
grid_annual_10km <- grid %>%
  # remove areas 0-1 km from road, as may just be picking up street or car lights
  filter(dist_gs_road_km > 1 & dist_gs_road_km <= 10 ) %>%
  group_by(id, year, GADM_ID_2,year_month) %>%
  dplyr::summarise(avg_rad_df = mean(avg_rad_df),
                   ndvi = mean(ndvi)) %>%
  ungroup() %>%
  mutate(year = year %>% 
           factor() %>%
           relevel(ref = "2019")) # year left out in regs. should be year before
# treatment. 
grid_annual_10km$log_avg_rad_df <- log(grid_annual_10km$avg_rad_df + sqrt((grid_annual_10km$avg_rad_df)^2+1))

#### Regressions
reg1 <- felm(avg_rad_df ~ factor(year) | id | 0 | 0, data = grid_annual_10km)
reg2 <- felm(avg_rad_df ~ factor(year) + ndvi | id | 0 | 0, data = grid_annual_10km)

reg3 <- felm(log_avg_rad_df ~ factor(year) | id | 0 | 0, data = grid_annual_10km)
reg4 <- felm(log_avg_rad_df ~ factor(year) + ndvi | id | 0 | 0, data = grid_annual_10km)


stargazer(reg1,
          reg2,
          reg3,
          reg4,
          title = "Within a 10km Buffer",
          font.size = "small",
          digits = 3,
          omit.stat = c("ser"),
          out = file.path(project_file_path,"Tables","gs_EventStudy_10km.tex"),
          float = F,
          header = F)

# 20km --------------------------------------------------------------------
grid_annual_20km <- grid %>%
  # remove areas 0-1 km from road, as may just be picking up street or car lights
  filter(dist_gs_road_km > 1 & dist_gs_road_km <= 20 ) %>%
  group_by(id, year, GADM_ID_2,year_month) %>%
  dplyr::summarise(avg_rad_df = mean(avg_rad_df),
                   ndvi = mean(ndvi)) %>%
  ungroup() %>%
  mutate(year = year %>% 
           factor() %>%
           relevel(ref = "2019")) # year left out in regs. should be year before
# treatment. 
grid_annual_20km$log_avg_rad_df <- log(grid_annual_20km$avg_rad_df + sqrt((grid_annual_20km$avg_rad_df)^2+1))

#### Regressions
reg1 <- felm(avg_rad_df ~ factor(year) | id | 0 | 0, data = grid_annual_20km)
reg2 <- felm(avg_rad_df ~ factor(year) + ndvi | id | 0 | 0, data = grid_annual_20km)

reg3 <- felm(log_avg_rad_df ~ factor(year) | id | 0 | 0, data = grid_annual_20km)
reg4 <- felm(log_avg_rad_df ~ factor(year) + ndvi | id | 0 | 0, data = grid_annual_20km)


stargazer(reg1,
          reg2,
          reg3,
          reg4,
          title = "Within a 20km Buffer",
          font.size = "small",
          digits = 3,
          omit.stat = c("ser"),
          out = file.path(project_file_path,"Tables","gs_EventStudy_20km.tex"),
          float = F,
          header = F)




# Prepare Data  ----------------------------------------------------
grid$road_improvement <- ifelse(grid$year > 2019,1,0)

grid_monthly_subdist <- grid %>%
  filter(dist_gs_road_km > 1 & dist_gs_road_km <= 20) %>%
  group_by(id, year,month, GADM_ID_2,dist_gs_road_km,road_improvement,year_month) %>%
  dplyr::summarise(avg_rad_df = mean(avg_rad_df),
                   ndvi = mean(ndvi))%>%
  ungroup()


#transformed viirs
grid_monthly_subdist$transformed_avg_rad_df <- 
  log(grid_monthly_subdist$avg_rad_df + sqrt((grid_monthly_subdist$avg_rad_df)^2+1))

#drop NA GADM
grid_monthly_subdist <-grid_monthly_subdist[!is.na(grid_monthly_subdist$GADM_ID_2),] #check why they are empty

#Add a simple log variable
grid_monthly_subdist$log_avg_rad_df <- log(grid_monthly_subdist$avg_rad_df + 1)

# Regression(5km) ---------------------------------------------------------
grid_5km <- grid_monthly_subdist %>%
  filter(dist_gs_road_km > 1 & dist_gs_road_km <= 5)


reg1 <- lm(transformed_avg_rad_df ~ road_improvement + ndvi,
           data = grid_5km)

reg2 <- lm(transformed_avg_rad_df ~ road_improvement + ndvi + factor(month),
           data = grid_5km)

reg3 <- plm(transformed_avg_rad_df ~ road_improvement + ndvi, 
            data = grid_5km, 
            index = c("id", "year_month"), 
            model = "within")

stargazer(reg1,
          reg2,
          reg3,
          title = "Within a 5km Buffer",
          keep = c("road_improvement","ndvi"),
          font.size = "small",
          digits = 3,
          omit.stat = c("ser"),
          add.lines = list(c("Month and Pixel FE","No", "Month - Yes/Pixel - No", "Yes")),
          out = file.path(project_file_path,"Tables","GS_PixelXMonthly_5km.tex"),
          float = F,
          header = F, type = "text")


# Regression (10km) -------------------------------------------------------
grid_10km <- grid_monthly_subdist %>%
  filter(dist_gs_road_km > 1 & dist_gs_road_km <= 10)



reg1 <- lm(transformed_avg_rad_df ~ road_improvement + ndvi,
           data = grid_10km)

reg2 <- lm(transformed_avg_rad_df ~ road_improvement + ndvi + factor(month),
           data = grid_10km)

reg3 <- plm(transformed_avg_rad_df ~ road_improvement + ndvi, 
            data = grid_10km, 
            index = c("id", "year_month"), 
            model = "within")

stargazer(reg1,
          reg2,
          reg3,
          title = "Within a 10km Buffer",
          keep = c("road_improvement","ndvi"),
          font.size = "small",
          digits = 3,
          omit.stat = c("ser"),
          add.lines = list(c("Month and Pixel FE","No","Month - Yes/Pixel - No", "Yes")),
          out = file.path(project_file_path,"Tables","GS_PixelXMonthly_10km.tex"),
          float = F,
          header = F, type = "text")

# Regression (20km) -------------------------------------------------------
grid_20km <- grid_monthly_subdist %>%
  filter(dist_gs_road_km > 1 & dist_gs_road_km <= 20)


reg1 <- lm(transformed_avg_rad_df ~ road_improvement + ndvi,
           data = grid_20km)

reg2 <- lm(transformed_avg_rad_df ~ road_improvement + ndvi + factor(month),
           data = grid_20km)

reg3 <- plm(transformed_avg_rad_df ~ road_improvement + ndvi, 
            data = grid_20km, 
            index = c("id", "year_month"), 
            model = "within")

stargazer(reg1,
          reg2,
          reg3,
          title = "Within a 20km Buffer",
          keep = c("road_improvement","ndvi"),
          font.size = "small",
          digits = 3,
          omit.stat = c("ser"),
          add.lines = list(c("Month and Pixel FE","No","Month - Yes/Pixel- No", "Yes")),
          out = file.path(project_file_path,"Tables","GS_PixelXMonthly_20km.tex"),
          float = F,
          header = F, type="text")
