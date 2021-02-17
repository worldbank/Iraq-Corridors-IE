# VIIRs Around r78

# Load Data --------------------------------------------------------------------
viirs_2013 <- raster(file.path(project_file_path, "Data", "VIIRS", "RawData", "annual", "irq_viirs_median_2013.tif"))
viirs_2019 <- raster(file.path(project_file_path, "Data", "VIIRS", "RawData", "annual", "irq_viirs_median_2019.tif"))
r78 <- read_sf(file.path(project_file_path, "Data", "Project Roads","R7_R8ab","FinalData", "r7_r8ab.geojson")) %>%
  as("Spatial")

# Buffer and Subset Area -------------------------------------------------------
r78 <- r78 %>% gBuffer(width = 11/111.12, byid=F)

fig_extent <- extent(r78)
fig_extent@xmax <- 47.105526

viirs_2013 <- viirs_2013 %>% crop(fig_extent)
viirs_2019 <- viirs_2019 %>% crop(fig_extent)
r78        <- r78        %>% crop(fig_extent)

viirs_2013_pts <- viirs_2013 %>%
  rasterToPoints(spatial = TRUE) %>%
  data.frame() %>%
  dplyr::rename(value = irq_viirs_median_2013)

viirs_2019_pts <- viirs_2019 %>%
  rasterToPoints(spatial = TRUE) %>%
  data.frame() %>%
  dplyr::rename(value = irq_viirs_median_2019)

viirs_pts <- bind_rows(viirs_2013_pts %>% mutate(year = 2013),
                       viirs_2019_pts %>% mutate(year = 2019))

viirs_pts$value_log <- log(viirs_pts$value+1)
viirs_pts$value_log <- log(viirs_pts$value_log+1)

ggplot() +
  geom_raster(data=viirs_pts, aes(x=x, y=y, fill=value_log)) +
  geom_polygon(data = r78, aes(x=long, y=lat, group=group,
                               color = "10km Area Around Treated Road"),
               fill = "NA",
               size=.5) +
  labs(fill = "",
       color = "") +
  scale_fill_gradient2(low = "black",
                       mid = "black",
                       high = "yellow",
                       midpoint = 0.01,
                       guide = 'none') +
  scale_color_manual(values = "red1") +
  theme_void() +
  theme(strip.text.x = element_text(size = 14,
                                    face = "bold"),
        legend.text = element_text(size = 12),
        legend.position="bottom") +
  facet_wrap(~year) +
  ggsave(filename = file.path(project_file_path,
                              "Data",
                              "VIIRS",
                              "Outputs",
                              "figures",
                              "viirs_2013_2019.png"),
         height = 4, width = 7)

