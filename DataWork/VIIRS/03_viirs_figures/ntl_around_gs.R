#ntl around GS Road

# Load Dataset ------------------------------------------------------------
viirs_2013 <- raster(file.path(project_file_path, "Data", 
                               "VIIRS", "RawData", "annual", 
                               "irq_viirs_median_2013.tif"))
gs <- read_sf(file.path(project_file_path, "Data", "Project Roads",
                         "Girsheen-Suheila Road","FinalData", 
                         "gs_road_polyline.geojson")) %>% as("Spatial")

# Buffer and Subset Area -------------------------------------------------------
gs <- gs %>% gBuffer(width = 11/111.12, byid=F)

fig_extent <- extent(gs)
fig_extent@xmin <- 40.96
fig_extent@xmax <- 45.07
fig_extent@ymin <- 36.3
fig_extent@ymax <- 42.80

viirs_2013 <- viirs_2013 %>% crop(fig_extent)
gs        <- gs        %>% crop(fig_extent)

viirs_2013_pts <- viirs_2013 %>%
  rasterToPoints(spatial = TRUE) %>%
  data.frame() %>%
  dplyr::rename(value = irq_viirs_median_2013)

viirs_pts <- bind_rows(viirs_2013_pts %>% mutate(year = 2013))

viirs_pts$value_log <- log(viirs_pts$value+1)
viirs_pts$value_log <- log(viirs_pts$value_log+1)

ggplot() +
  geom_raster(data=viirs_pts, aes(x=x, y=y, fill=value_log)) +
  geom_polygon(data = gs, aes(x=long, y=lat, group=group,
                               color = "10km Area around \nGirsheen-Suheila"),
               fill = "NA",
               size=.5) +
  labs(fill = "",
       color = "") +
  scale_fill_gradient2(low = "black",
                       mid = "black",
                       high = "yellow",
                       midpoint = 0.01) +
  scale_color_manual(values = "red1") +
  theme_void()
