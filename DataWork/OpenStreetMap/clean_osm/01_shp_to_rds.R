# OSM Shapefiles: to RDS

# Load Data --------------------------------------------------------------------
roads <- readOGR(dsn = file.path(raw_data_file_path, "OpenStreetMap", "shp_files"),
                     layer = "gis_osm_roads_free_1")

# Export -----------------------------------------------------------------------
saveRDS(roads, file.path(final_data_file_path, "OpenStreetMap", "rds", "gis_osm_roads_free_1.Rds"))


