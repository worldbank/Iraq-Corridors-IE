#VIIRS around GS

# Load Data --------------------------------------------------------------------
viirs_2020 <- raster(file.path(project_file_path, "Data", "VIIRS", "RawData", "annual", "irq_viirs_median_2020.tif"))
viirs_2019 <- raster(file.path(project_file_path, "Data", "VIIRS", "RawData", "annual", "irq_viirs_median_2019.tif"))
gs <- read_sf(file.path(project_file_path, "Data", "Project Roads", "Girsheen-Suheila Road","FinalData","gs_road_polyline.geojson")) %>%
  as("Spatial")

# Buffer and Subset Area -------------------------------------------------------
gs <- gs %>% gBuffer(width = 11/111.12, byid=F)

fig_extent <- extent(gs)
fig_extent@xmax <- 42.7

viirs_2020 <- viirs_2020 %>% crop(fig_extent)
viirs_2019 <- viirs_2019 %>% crop(fig_extent)
gs        <-  gs        %>% crop(fig_extent)

viirs_2020_pts <- viirs_2020 %>%
  rasterToPoints(spatial = TRUE) %>%
  data.frame() %>%
  dplyr::rename(value = irq_viirs_median_2020)

viirs_2019_pts <- viirs_2019 %>%
  rasterToPoints(spatial = TRUE) %>%
  data.frame() %>%
  dplyr::rename(value = irq_viirs_median_2019)

viirs_pts <- bind_rows(viirs_2020_pts %>% mutate(year = 2020),
                       viirs_2019_pts %>% mutate(year = 2019))

viirs_pts$value_log <- log(viirs_pts$value+1)
viirs_pts$value_log <- log(viirs_pts$value_log+1)


# Plot --------------------------------------------------------------------
ggplot() +
  geom_raster(data=viirs_pts, aes(x=x, y=y, fill=value_log)) +
  geom_polygon(data = gs, aes(x=long, y=lat, group=group,
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
                              "viirs_2019_2020.png"),
         height = 4, width = 7)



