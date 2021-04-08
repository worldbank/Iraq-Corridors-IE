# Extract Population

# Load Data --------------------------------------------------------------------
iraq_adm3 <- readRDS(file.path(data_file_path,"Clusters","FinalData",  
                               "individual_files","irq_blank.Rds"))

# Extract Data -----------------------------------------------------------------
population <- raster(file.path(project_file_path, "Data", "Population Density", 
                               "RawData", "IRQ_ppp_v2b_2015_UNadj.tif"))
population_vl <- velox(population)
iraq_adm3$population <- population_vl$extract(sp = iraq_adm3, fun=function(x) sum(x, na.rm=T)) %>% as.vector()

# Export -----------------------------------------------------------------------
saveRDS(iraq_adm3, file.path(data_file_path,"Clusters", "FinalData",  
                             "individual_files","irq_population.Rds"))

