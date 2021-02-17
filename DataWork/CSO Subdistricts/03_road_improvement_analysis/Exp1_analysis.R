#Analysis on a Random part of Exp

#1. Take another part of Exp 1, and create buffers
#2. Run regression
#3. Difference between the two


# Load Data ---------------------------------------------------------------
viirs_grid <- readRDS(file=file.path(project_file_path, 
                                     "Data","CSO Subdistricts","FinalData", 
                                     "subdistrict_data_df_clean.Rds"))

roads <- readRDS(file.path(project_file_path,
                           "Data", "OpenStreetMap", 
                           "FinalData","iraq_roads_rds", 
                           "gis_osm_roads_free_1.Rds"))

r7_r8 <- readRDS(file.path(project_file_path, 
                             "Data", "Project Roads", "R7_R8ab",
                             "FinalData",
                             "r7_r8ab.Rds"))


# Subset Data -------------------------------------------------------------
roads <- roads[roads$ref %in% "1",]

#convert to sf
roads <- st_as_sf(roads)
r7_r8 <- st_as_sf(r7_r8)

st_erase = function(x, y) st_difference(x, st_union(st_combine(y)))

diff <- st_erase(roads,r7_r8)
diff <- diff[diff$fclass %in% "trunk" & diff$name %in% "Mosul-Baghdad road",]





