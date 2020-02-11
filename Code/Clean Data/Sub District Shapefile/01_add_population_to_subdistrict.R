# Add Population to Subdistrict Shapefile

# Load Data --------------------------------------------------------------------
#### ADM 3
iraq_adm3 <- readOGR(dsn = file.path(raw_data_file_path, "Sub District Shapefile"),
        layer = "irq_admbnda_adm3_cso_20190603")

#### Population
population <- raster(file.path(raw_data_file_path, "Population density", "IRQ_ppp_v2b_2015_UNadj.tif"))

# Population per ADM -----------------------------------------------------------
population_vl <- velox(population)

iraq_adm3$population <- population_vl$extract(sp = iraq_adm3, fun=function(x) sum(x, na.rm=T)) %>% as.vector()

# Export -----------------------------------------------------------------------
iraq_adm3$uid <- 1:nrow(iraq_adm3)
saveRDS(iraq_adm3, file.path(final_data_file_path, "subdistrict_data", "subdistrict_population.Rds"))




