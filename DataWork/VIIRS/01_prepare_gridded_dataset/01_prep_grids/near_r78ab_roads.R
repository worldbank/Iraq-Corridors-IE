# Iraq IE

# Create panel of VIIRs at grid level and blank datasets to be used when extracting
# other variables to VIIRs level. Creates grid that uses pixels within DIST_ROAD km
# of trunk roads and motorways from OSM and the R7/R8ab, and that is within 75km
# of the g-s road in the north.

# 1. Load Data
# 2. Prep VIIRS Shapefile to limit cells in analysis
# 3. Determine which cells in analysis (near highway and in country)
# 4. Extract VIIRs values to dataframe
# 5. Add in month & year to dataframe
# 6. Export
#   6.1 Panel with VIIRs data
#   6.2 Blank panel (only id, month and year)
#   6.3 Bank cross section (only id)

# 0. Settings ------------------------------------------------------------------
DIST_ROAD <- 75 # kilometer distance to primary road to be included in 
# analysis. If not within distance, cell dropped.

# 1. Load Data -----------------------------------------------------------------
#### GADM
iraq <- readRDS(file.path(project_file_path, "Data", "GADM", "RawData", "gadm36_IRQ_0_sp.rds"))

#### Project Roads
prj_rd_r78ab <- readRDS(file.path(project_file_path, "Data", "Project Roads", "R7_R8ab", "FinalData", "r7_r8ab.Rds"))

#### VIIRS
viirs_avg_rad <- stack(file.path(project_file_path, "Data", "VIIRS", "RawData", "monthly", "iraq_viirs_raw_monthly_start_201204_avg_rad.tif"))
viirs_cf_cvg <- stack(file.path(project_file_path, "Data", "VIIRS", "RawData", "monthly", "iraq_viirs_raw_monthly_start_201204_cf_cvg.tif"))

num_bands <- dim(viirs_avg_rad)[3]

# 2. Create Area to Restrict Cells ---------------------------------------------

# ** 2.1 Prep Road SpatialPolygon that Limit Cells in Analysis -----------------
#### Prep roads shapefile
## Common variables
prj_rd_r78ab@data <- prj_rd_r78ab@data %>% mutate(id = 1) %>% dplyr::select(id)

## Common CRS
prj_rd_r78ab <- prj_rd_r78ab %>% spTransform(CRS("+init=epsg:4326"))

## Buffer
# Larger buffer around road in the north
prj_rd_r78ab <- gBuffer_chunks(prj_rd_r78ab, width=DIST_ROAD/111.12, 100)

## Append
roads <- prj_rd_r78ab

## Dissolve
roads <- gBuffer(roads, width=0, byid=T) # cleanup self intersections
roads <- raster::aggregate(roads, by = "id")

## Simplify
roads <- gSimplify(roads, tol = .01)

## Add Variable
roads$in_area <- 1

# ** 2.2. Prep Country SpatialPolygon that Limit Cells in Analysis ------------------
iraq$in_country <- 1
iraq <- iraq %>% spTransform(CRS("+init=epsg:4326"))
iraq <- gSimplify(iraq, tol = .01)

## Add Variable
iraq$id <- 1

# ** 3.2 Study Area Polygon ----------------------------------------------------
# Mask roads to country to get study area: in both roads and country
roads <- raster::intersect(roads, iraq)

# 4. Determine which cells are in Analysis -------------------------------------
# Determine if cell should be in analysis: near a road and in the county.

## Create spatial points file from VIIRS
r_tmp <- raster(file.path(project_file_path, "Data", "VIIRS", "RawData", "monthly", 
                          "iraq_viirs_raw_monthly_start_201204_avg_rad.tif"), band=1)
r_tmp_coords <- coordinates(r_tmp) %>% as.data.frame
coordinates(r_tmp_coords) <- ~x+y
crs(r_tmp_coords) <- CRS("+init=epsg:4326")
r_tmp_coords$id <- 1:length(r_tmp_coords)

## Indicate whether intesects country/road
r_OVER_roads   <- over_chunks(r_tmp_coords, roads, "sum", 10000)

cell_in_analysis <- (r_OVER_roads$in_area %in% 1) 

# Coordinates ------------------------------------------------------------------
viirs_coords_in_iraq <- r_tmp_coords[cell_in_analysis,] %>% coordinates %>% as.data.frame
names(viirs_coords_in_iraq) <- c("lon","lat")

viirs_coords_in_iraq$id <- 1:nrow(viirs_coords_in_iraq)

num_obs_per_band <- nrow(viirs_coords_in_iraq)

# Extract Values to Dataframe --------------------------------------------------
extract_raster_value_in_country <- function(band_num, raster_file_path, cell_in_analysis, var_name){
  
  r <- raster(raster_file_path, band=band_num)
  r_values <- r[]
  r_values <- r_values[cell_in_analysis]
  
  return(r_values)
}

## Extract values as vectors
avg_rad_df <- pbmclapply(1:num_bands, extract_raster_value_in_country, 
                         file.path(project_file_path, "Data", "VIIRS", "RawData", 
                                   "monthly", "iraq_viirs_raw_monthly_start_201204_avg_rad.tif"), 
                         cell_in_analysis, "viirs_rad", mc.cores=1) %>% unlist

cf_cvg_df <- pbmclapply(1:num_bands, extract_raster_value_in_country, 
                        file.path(project_file_path, "Data", "VIIRS", "RawData", 
                                  "monthly", "iraq_viirs_raw_monthly_start_201204_cf_cvg.tif"), 
                        cell_in_analysis, "viirs_cf_cvg", mc.cores=1) %>% unlist

## id and band vectors
id <- rep(1:num_obs_per_band, num_bands)
band <- rep(1:num_bands, each=num_obs_per_band)

## Make dataframe
# Dataframe from radiance/cloud cover/id/bands vectors
iraq_grid_viirs <- data.frame(avg_rad_df=avg_rad_df, 
                              cf_cvg_df=cf_cvg_df, 
                              id=id, 
                              band=band)
# Add in coordinates
iraq_grid_viirs <- merge(iraq_grid_viirs, viirs_coords_in_iraq, by="id")

# Add Month and Year -----------------------------------------------------------
iraq_grid_viirs$month <- NA
iraq_grid_viirs$year <- NA

month <- 4
year <- 2012
for(band_num in 1:max(iraq_grid_viirs$band)){
  print(band_num)
  iraq_grid_viirs$month[iraq_grid_viirs$band %in% band_num] <- month
  iraq_grid_viirs$year[iraq_grid_viirs$band %in% band_num] <- year
  
  month <- month + 1
  if(month == 13){
    month <- 1
    year <- year + 1
  }
}

# Export -----------------------------------------------------------------------
OUT_PATH <- file.path(project_file_path, "Data", "VIIRS", "FinalData", "near_r78ab_roads", "Separate Files Per Variable")

# 1. Panel with VIIRS
iraq_grid_viirs_nolatlon <- subset(iraq_grid_viirs, select=-c(lat,lon,band))
saveRDS(iraq_grid_viirs_nolatlon, file=file.path(OUT_PATH, "iraq_grid_panel_viirs.Rds"))
rm(iraq_grid_viirs_nolatlon)

# 2. Blank Panel
iraq_grid_viirs_blankpanel <- subset(iraq_grid_viirs, select=c(id,month,year, lat, lon))
saveRDS(iraq_grid_viirs_blankpanel, file=file.path(OUT_PATH, "iraq_grid_panel_blank.Rds"))
rm(iraq_grid_viirs_blankpanel)

# 3. Blank Cross Section
iraq_grid_viirs_blank <- iraq_grid_viirs[iraq_grid_viirs$band %in% 1,]
iraq_grid_viirs_blank <- subset(iraq_grid_viirs_blank, select=c(id, lat, lon))
saveRDS(iraq_grid_viirs_blank, file=file.path(OUT_PATH, "iraq_grid_blank.Rds"))
rm(iraq_grid_viirs_blank)



