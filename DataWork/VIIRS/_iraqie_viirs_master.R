# Iraq IE
# VIIRS Analysis Master Script

datawork_viirs <- file.path(github_file_path, "DataWork", "VIIRS")

# 1. Clean Data ----------------------------------------------------------------
prep_data_path <- file.path(datawork_viirs, "01_prepare_gridded_dataset")

# Create grid
source(file.path(prep_data_path, "01_prep_grids", "create_viirs_grid.R"))

# Extract datasets to grid
source(file.path(prep_data_path, "02_extract_variables", "distance_osm_roads.R"))
source(file.path(prep_data_path, "02_extract_variables", "distance_project_roads.R"))
source(file.path(prep_data_path, "02_extract_variables", "gadm.R"))
source(file.path(prep_data_path, "02_extract_variables", "ndvi.R"))

# Merge and clean dataset
source(file.path(prep_data_path, "03_merge_clean", "merge.R"))
source(file.path(prep_data_path, "03_merge_clean", "clean_variables.R"))

# 2. Analysis ------------------------------------------------------------------

# Summary figures
analysis_path <- file.path(datawork_viirs, "02_analysis")

# Trends in NTL over itme
source(file.path(analysis_path, "trends.R"))

# Variable in NTL along roads
source(file.path(analysis_path, "ntl_variation_along_road.R"))





