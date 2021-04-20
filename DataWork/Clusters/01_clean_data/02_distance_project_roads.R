#Extract Distance to Project Roads

# Load Data --------------------------------------------------------------------
iraq_adm3<- readRDS(file.path(data_file_path,"Clusters","FinalData",  
                                 "individual_files","irq_blank.Rds"))

iraq_adm3<- iraq_adm3%>% spTransform(CRS(UTM_IRQ))

# Distance to r78ab ------------------------------------------------------------
# Load/reproject
r78 <- readRDS(file.path(data_file_path, "Project Roads", "R7_R8ab", "FinalData","r7_r8ab.Rds"))
r78 <- r78 %>% spTransform(CRS(UTM_IRQ))

# Dissolve
r78   <- gBuffer(r78,width = .001/111.12, byid=T)
r78$id <- 1
r78 <- raster::aggregate(r78, by="id")

# Calculate distance
iraq_adm3$dist_r78_km <- gDistance(iraq_adm3, r78, byid = T) %>% 
  as.vector() %>%
  `/`(1000) # meters to kilometers



# Distance to gs ------------------------------------------------------------
# Load/reproject
gs <- readRDS(file.path(project_file_path, "Data",
                        "Project Roads", "Girsheen-Suheila Road", "FinalData",
                        "gs_road_polyline.Rds")) 

gs <- gs %>% spTransform(CRS(UTM_IRQ))

# Dissolve
gs   <- gBuffer(gs,width = .001/111.12, byid=T)
gs$id <- 1
gs <- raster::aggregate(gs, by = "id")

# Calculate distance
iraq_adm3$dist_gs_km <- gDistance(iraq_adm3, gs, byid = T) %>% 
  as.vector() %>%
  `/`(1000) # meters to kilometers


# Export -----------------------------------------------------------------------
saveRDS(iraq_adm3, file.path(data_file_path, "Clusters", "FinalData",  
                             "individual_files","irq_dist_prj_rds_km.Rds"))
