#Clustering NTL

set.seed(98)

# Load Data ---------------------------------------------------------------
##Sub-Districts
irq_adm <- readRDS(file.path(data_file_path, "CSO Subdistricts", "FinalData",  
                     "individual_files","irq_adm_info.Rds"))
irq_adm <- spTransform(irq_adm, CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0 "))

##Globcover
# Create a raster that is 1 if urban in any time period
urban_constant <- raster(file.path(data_file_path, "Globcover", "RawData", 
                                   "2016_2018_data", "C3S-LC-L4-LCCS-Map-300m-P1Y-2018-v2.1.1.tif")) %>% crop(extent(irq_adm))
urban_constant[] <- as.numeric(urban_constant[] %in% c(190))



# Masking -----------------------------------------------------------------
## Crop/Mask to Iraq
gc_binary <- urban_constant %>% crop(irq_adm) %>% mask(irq_adm)

# Define raster layer of clusters ----------------------------------------------
gc_clumps <- clump(gc_binary, directions=8)

clumps_unique_values <- unique(gc_clumps[])[!is.na(unique(gc_clumps[]))]

plot(gc_clumps)


# Polygonize clusters ----------------------------------------------------------
## Polgyzonize raster grids
clump_sp_all <- rasterToPolygons(gc_clumps, 
                                 n=4, 
                                 na.rm=TRUE, 
                                 digits=12, 
                                 dissolve=F)
clump_sp_all$cluster_n_cells <- 1

## Collapse grids of same cluster
clumps_sp <- raster::aggregate(clump_sp_all, 
                               by="clumps",
                               list(list(sum, 'cluster_n_cells')))


# Group together clusters  ------------------------------------------------

## Centroid
points_sp <- coordinates(clumps_sp) %>%
  as.data.frame() %>%
  dplyr::rename(lon = V1,
                lat = V2) %>%
  bind_cols(clumps_sp@data)

## Spatially Define and project
coordinates(points_sp) <- ~lon+lat
crs(points_sp) <- CRS("+init=epsg:4326")
points_sp <- spTransform(points_sp, CRS(UTM_IRQ))

## Back to dataframe
points <- as.data.frame(points_sp)

## Clusters
points_dist <- points[,c("lat", "lon")] %>% dist()
clumps_sp$wardheirch_clust_id <- hclust(points_dist, method = "ward.D2") %>%
  cutree(h = 10000)

clumps_sp <- raster::aggregate(clumps_sp, by = "wardheirch_clust_id", 
                               sums=list(list(sum, 'cluster_n_cells')))

clumps_sp@data <- clumps_sp@data %>%
  dplyr::select(-c(wardheirch_clust_id)) %>% 
  dplyr::mutate(cell_id = 1:n())

# Export -----------------------------------------------------------------------
# We save "polygon" and "points" file, where "points" is actually just the polygon.
# We do this to make compatible with some scripts that also process grid data


## Dataframe with number of cells 
saveRDS(clumps_sp, file.path(data_file_path, "Globcover", "FinalData","cluster_n_cells.Rds"))
clumps_sp$cluster_n_cells <- NULL

## Main Files - 1km road cut out
saveRDS(clumps_sp, file.path(data_file_path, "Globcover", "FinalData", "polygons.Rds"))
saveRDS(clumps_sp, file.path(data_file_path, "Globcover", "FinalData", "points.Rds"))

##check
clumps_sf <- st_as_sf(clumps_sp)
iraq <- st_as_sf(irq_adm)
ggplot()+
  geom_sf(data = clumps_sf)+
  geom_sf(data = iraq, fill = NA, color = "grey")+
  theme_void()

