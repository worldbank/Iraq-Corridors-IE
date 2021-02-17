# OSM Shapefiles: to RDS

# Load Data --------------------------------------------------------------------
roads <- readOGR(dsn = file.path(data_file_path, "OpenStreetMap", "RawData", "shp"),
                     layer = "gis_osm_roads_free_1")

# Export -----------------------------------------------------------------------
saveRDS(roads, file.path(data_file_path, "OpenStreetMap", "FinalData", "iraq_roads_rds", "gis_osm_roads_free_1.Rds"))


