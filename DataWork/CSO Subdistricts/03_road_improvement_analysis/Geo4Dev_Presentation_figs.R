#Figures for Geo4Dev


# Loading Data ------------------------------------------------------------
population <- readRDS(file.path(project_file_path, 
                                "Data", "CSO Subdistricts", "FinalData",  
                                "individual_files","irq_population.Rds"))

viirs <- readRDS(file.path(project_file_path, 
                           "Data", "CSO Subdistricts", "FinalData",  
                           "individual_files",
                           "irq_viirs_monthly.Rds"))

# Figure ------------------------------------------------------------------
options(scipen = 999)

#Plotting population
ggplot()+
  geom_polygon(data = population_tidy, aes(x = long, y = lat, group = group,
                                       fill = population))+
  theme_void()+
  coord_quickmap()+
  labs(fill = "District\nPopulation")+
  scale_fill_gradient(low = "firebrick4",
                      high = "chartreuse2")



# Correlation b/w population and VIIRS --------------------------------------

#Cleaning
population$id <- row.names(population)
population_tidy <- tidy(population)
population_tidy <- merge(population_tidy, population@data, by = "id")

viirs_2015 <- viirs[which(viirs$year == 2015),]
viirs_2015 <- merge(viirs_2015,population_tidy)
viirs_2015 <-
  aggregate(viirs_mean ~ uid + year + population, 
            data = viirs_2015, FUN = mean)
viirs_2015 <- viirs_2015 %>%
  dplyr::mutate(log_pop = log10(population),
                log_viirs = log1p(viirs_mean))

#Figure
ggscatter(viirs_2015, x = "log_pop", y = "log_viirs", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "Log (Population) in 2015", ylab = "Log(NTL) in 2015 ")



# Figures for GS ----------------------------------------------------------
iraq_adm <- readRDS(file.path(project_file_path, 
                              "Data", "CSO Subdistricts", "FinalData",  
                              "individual_files","irq_blank.Rds"))
gs_road <- readOGR(file.path(project_file_path, "Data", "Project Roads", 
                             "Girsheen-Suheila Road", "FinalData",
                             "gs_road_polyline.geojson"))
roads <- readRDS(file.path(project_file_path,
                           "Data", "OpenStreetMap", 
                           "FinalData","iraq_roads_rds", 
                           "gis_osm_roads_free_1.Rds"))

#Cleaning
iraq_adm_tidy <- tidy(iraq_adm)
gs_road_tidy <- tidy(gs_road)
iraq_adm_sf <- st_as_sf(iraq_adm)

roads <- roads[which(roads$fclass == "trunk"),]


iraq_cropped <- st_crop(iraq_adm_sf, xmin = 42.3, xmax = 43,
                        ymin = 36.6, ymax = 38)

#Figure
ggplot()+
  geom_sf(data = iraq_cropped, fill = NA, color = "gray")+
  annotate("text", x=42.6, y= 37, label= "Duhok", size = 3,color = "grey20")+
  annotate("text", x=42.6, y= 36.8, label= "Mosul", size = 3, color = "grey20")+
  geom_path(data = gs_road_tidy,aes(x = long, y = lat, group = group, color = "Project Road \nGirsheen-Suheila"))+
  coord_sf()+
  labs(color = "")+
  scale_color_viridis_d()+
  theme_minimal()


#Create buffer around GS
gs_5km <- gBuffer(gs_road, width=5/111.12, byid = T)
gs_10km <- gBuffer(gs_road, width=10/111.12, byid = T)
gs_20km <- gBuffer(gs_road, width=20/111.12, byid = T)


#Figure

library(wesanderson)

ggplot()+
  geom_sf(data = iraq_cropped, fill = NA, color = "gray")+
  geom_polygon(data = gs_20km, aes(x = long, y = lat, group = group, fill = "20km"),alpha = 0.25)+
  geom_polygon(data = gs_10km, aes(x = long, y = lat, group = group, fill = "10km"),alpha = 0.25 , color = "grey20")+
  geom_polygon(data = gs_5km, aes(x = long, y = lat, group = group, fill = "5km"),alpha = 0.25, color = "grey20")+
  geom_path(data = gs_road_tidy,aes(x = long, y = lat, group = group, color = "Project Road \nGirsheen-Suheila"))+
  annotate("text", x=42.65, y= 36.9, label= "Dahuk", size = 3, color = "grey20")+
  annotate("text", x=42.6, y= 36.8, label= "Mosul", size = 3, color = "grey20")+
  coord_sf()+
  labs(color = "", fill = "Buffer")+
  scale_fill_viridis_d(labels = c("5km" , "10km" , "20km"),
                       breaks = c("5km", "10km","20km")) +
  scale_color_viridis_d() +
  theme_void()


# Grid Figure -------------------------------------------------------------
viirs_2019 <- raster(file.path(project_file_path, 
                               "Data", "VIIRS", "RawData", 
                               "annual", "irq_viirs_median_2019.tif"))
viirs_2020 <- raster(file.path(project_file_path, 
                               "Data", "VIIRS", "RawData", 
                               "annual", "irq_viirs_median_2020.tif"))



# Buffer and Subset Area --------------------------------------------------

