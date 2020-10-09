# G-S Road Analysis

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

grid_sum_stack %>%
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

## Check NDVI
grid %>%
  filter(dist_gs_road_km < 5) %>%
  group_by(year) %>%
  summarise(ndvi = mean(ndvi)) %>%
  ggplot() +
  geom_line(aes(x = year, y=ndvi))

# Event Study ------------------------------------------------------------------
#### Prep Data
grid_annual <- grid %>%
  filter(dist_gs_road_km > 1 & dist_gs_road_km < 5) %>%
  group_by(id, year, GADM_ID_2) %>%
  dplyr::summarise(avg_rad_df = mean(avg_rad_df),
                   ndvi = mean(ndvi)) %>%
  ungroup() %>%
  mutate(year = year %>% 
           factor() %>%
           relevel(ref = "2016")) # year left out in regs. should be year before
                                  # treatment. TODO when was road finished?

#### Regressions
felm(avg_rad_df ~ factor(year) | id | 0 | 0, data = grid_annual) %>%
  summary()

felm(avg_rad_df ~ factor(year) + ndvi | id | 0 | 0, data = grid_annual) %>%
  summary()

