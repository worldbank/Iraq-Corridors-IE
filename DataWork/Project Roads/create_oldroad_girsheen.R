#Iraq IE
#Create old road before Girsheen - Suheila


# Loading Data ------------------------------------------------------------
roads <- readRDS(file.path(project_file_path,
                           "Data", "OpenStreetMap", 
                           "FinalData","iraq_roads_rds", 
                           "gis_osm_roads_free_1.Rds"))
#roads <- roads[which(roads$fclass == "primary"|roads$fclass == "primary_link"|
                       #roads$fclass == "secondary"|roads$fclass == "motorway"),]

roads@data <- roads %>% 
  gCentroid(byid = T) %>% 
  coordinates() %>%
  as.data.frame() %>%
  dplyr::rename(lon_centroid = x, 
                lat_centroid = y) %>%
  bind_cols(roads@data)

#clipping road 37.07637374207513, 42.43475424605287 // 37.0246772209582, 42.64483719035412
split_extent_oldroad<- extent(roads)
split_extent_oldroad@xmax <- 42.64483719035412
split_extent_oldroad@xmin <- 42.43475424605287
split_extent_oldroad@ymin <- 37.0246772209582
split_extent_oldroad@ymax <- 37.07637374207513

#convert to sp
split_extent_oldroad<- as(split_extent_oldroad, 'SpatialPolygons')

#create an id
split_extent_oldroad$id <- 1

#create final road (subset of Rabat-Safi)
oldroad<- raster::intersect(roads, split_extent_oldroad)

#check
leaflet() %>%
  addTiles() %>%
  addPolylines(data = oldroad, color = "blue")
