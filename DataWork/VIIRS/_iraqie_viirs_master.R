# Iraq IE
# VIIRS Analysis Master Script

#### Parameters
# Grid sample is the sample of viirs grids. 
# OPTIONS
#   1. near_major_roads: creates a grid that is 25km from a trunk road or 
#      motorway (from OSM), 25km from the r78am, or 50km from the G-S road in 
#      the north
#   2. near_girsheen_suheila_road: creates a grid with all cells with 100km 
#      of the Girsheen Suheila_road road in the north, where cells are also 
#      limited to those in Iraq
#   3. near_r78ab_roads: creates a grid with all cells within 75km ofthe r78am
#      road in the south, where cells are also limited to those in Iraq

GRID_SAMPLE <- "near_girsheen_suheila_road"

datawork_viirs <- file.path(github_file_path, "DataWork", "VIIRS")

# 1. Clean Data ----------------------------------------------------------------
prep_data_path <- file.path(datawork_viirs, "01_prepare_gridded_dataset")

#### Create grid
## Creates the following files:
# iraq_grid_panel_viirs.Rds: Panel with VIIRs data  
# iraq_grid_panel_blank.Rds: Blank panel grid
# iraq_grid_blank.Rds: Blank grid of one time period
source(file.path(prep_data_path, "01_prep_grids", paste0("create_viirs_grid_",GRID_SAMPLE,".R")))

#### Extract datasets to grid
source(file.path(prep_data_path, "02_extract_variables", "gadm.R"))
source(file.path(prep_data_path, "02_extract_variables", "distance_osm_roads.R"))
source(file.path(prep_data_path, "02_extract_variables", "distance_project_roads.R"))
source(file.path(prep_data_path, "02_extract_variables", "ndvi.R"))

#### Merge and clean dataset
source(file.path(prep_data_path, "03_merge_clean", "01_merge.R"))
source(file.path(prep_data_path, "03_merge_clean", "02_clean_variables.R"))

# 2. Analysis ------------------------------------------------------------------

# Summary figures
analysis_path <- file.path(datawork_viirs, "02_analysis")

# Trends in NTL over itme
source(file.path(analysis_path, "trends.R"))

# Variable in NTL along roads
source(file.path(analysis_path, "ntl_variation_along_road.R"))





