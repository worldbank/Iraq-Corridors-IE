# Iraq IE
# Extract NDVI

#GRID_SAMPLE <- "near_girsheen_suheila_road"
#GRID_SAMPLE <- "near_r78ab_roads"
GRID_SAMPLE <- "near_zakho_road" #the old road operated before Girsheen - Suheila was constructed


# Load Data --------------------------------------------------------------------
grid <- readRDS(file.path(project_file_path, "Data", "VIIRS", "FinalData", GRID_SAMPLE ,
                          "Separate Files Per Variable", "iraq_grid_blank.Rds"))
coordinates(grid) <- ~lon+lat
crs(grid) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# Extract NDVI -----------------------------------------------------------------
extract_ndvi <- function(band, year){
  print(paste(year, band))
  
  ndvi_path <- file.path(project_file_path, "Data", "NDVI", "MODIS - Monthly", "RawData", 
                         paste0("ndvi_modis_iraq_monthly_1km_",year,".tif"))
  ndvi <- raster(ndvi_path, band)
  
  ndvi_v <- velox(ndvi)
  
  ndvi_df <- ndvi_v$extract_points(sp=grid) %>% 
    as.vector() %>%
    as.data.frame() %>%
    dplyr::rename(ndvi = ".") %>%
    mutate(year = year,
           month = band)
  
  ndvi_df$id <- grid$id
  
  return(ndvi_df)
}

## Extract for each year. Creates stacked dataframe of ndvi, year, month, id
ndvi_2012_df <- lapply(1:12, extract_ndvi, 2012)
ndvi_2013_df <- lapply(1:12, extract_ndvi, 2013)
ndvi_2014_df <- lapply(1:12, extract_ndvi, 2014)
ndvi_2015_df <- lapply(1:12, extract_ndvi, 2015)
ndvi_2016_df <- lapply(1:12, extract_ndvi, 2016)
ndvi_2017_df <- lapply(1:12, extract_ndvi, 2017)
ndvi_2018_df <- lapply(1:12, extract_ndvi, 2018)
ndvi_2019_df <- lapply(1:12, extract_ndvi, 2019)
ndvi_2020_df <- lapply(1:6,  extract_ndvi, 2020)

## Append
ndvi_all_df <- bind_rows(
  ndvi_2012_df,
  ndvi_2013_df,
  ndvi_2014_df,
  ndvi_2015_df,
  ndvi_2016_df,
  ndvi_2017_df,
  ndvi_2018_df,
  ndvi_2019_df,
  ndvi_2020_df
)

# Export -----------------------------------------------------------------------
saveRDS(ndvi_all_df, file=file.path(project_file_path, "Data", "VIIRS", "FinalData",
                                    GRID_SAMPLE,
                                    "Separate Files Per Variable", 
                                    "iraq_grid_panel_ndvi.Rds"))


