# Create geojson and rds of Girsheen-Suheila Road

# Load Data --------------------------------------------------------------------
road <- st_read(file.path(project_file_path, "Data", "Project Roads", 
                          "Girsheen-Suheila Road", "RawData", 
                          "Girsheen-Suheila (Coordinates).xml"))

# Make Dataframe ---------------------------------------------------------------
# geometry has lat/long and a zero. Remove the zero

road <- road %>% as("Spatial")

road_df <- road@data

road_df <- road %>% 
  coordinates() %>%
  as.data.frame() %>%
  dplyr::rename(lon = coords.x1,
                lat = coords.x2) %>%
  dplyr::select(lat, lon) %>%
  bind_cols(road_df)

# Make Road Polygon ------------------------------------------------------------
# Grab subset of dataframe that is an ordered list of points. Make into
# polyline

rd_ord_df <- road_df %>%
  mutate(Name = Name %>% as.character()) %>%
  filter(Description %in% "CLSTALBL",
         nchar(Name) %in% 5:6) 

## Order by Name
rd_ord_df$Name[nchar(rd_ord_df$Name) %in% 5] <- 
  paste0("0", rd_ord_df$Name[nchar(rd_ord_df$Name) %in% 5])

rd_ord_df <- rd_ord_df %>%
  arrange(Name)

## Make into spatial polyline
line_obj <- sp::Line(cbind(rd_ord_df$lon,rd_ord_df$lat))
lines_obj <- sp::Lines(list(line_obj),ID=1)
road_sdf <- sp::SpatialLines(list(lines_obj))

## Add name variable and add crs
road_sdf$name <- "Girsheen-Suheila Road"
crs(road_sdf) <- CRS("+init=epsg:4326")

# Export -----------------------------------------------------------------------
write.csv(road_df, file.path(project_file_path, "Data", "Project Roads", 
                             "Girsheen-Suheila Road", "FinalData",
                             "gs_road_points_all.csv"),
          row.names = F)

st_write(road_sdf %>% st_as_sf(), file.path(project_file_path, "Data", "Project Roads", 
                                            "Girsheen-Suheila Road", "FinalData",
                                            "gs_road_polyline.geojson"))

writeRDS(road_sdf, file.path(project_file_path, "Data", "Project Roads", 
                             "Girsheen-Suheila Road", "FinalData",
                             "gs_road_polyline.Rds"))


#### CHECK
leaflet() %>%
  addTiles() %>%
  addPolylines(data=road_sdf, color="green", weight=15) %>%
  addCircles(data=road_df)






