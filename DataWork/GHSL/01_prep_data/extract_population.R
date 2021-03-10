#Iraq IE

#Extract population from raster

# Load Data ---------------------------------------------------------------
population <- raster(file.path(project_file_path, "Data", "GHSL", 
                               "RawData", "GHS_POP_E2015_GLOBE_R2019A_54009_250_V1_0.tif"))

iraq_adm <- readRDS(file.path(project_file_path,"Data","GADM",
                              "RawData", "gadm36_IRQ_0_sp.Rds"))


# Changing Projection -----------------------------------------------------
iraq_adm <- iraq_adm%>% 
  spTransform(CRS(UTM_IRQ))


# Cropping Raster ---------------------------------------------------------
iraq_pop <- crop(population,extent(iraq_adm))
iraq_pop <- mask(population,iraq_adm)

plot(iraq_pop)
plot(iraq_adm, add = TRUE)
