# Add Data to Subdistricts

# Define Filpaths --------------------------------------------------------------
SUBDIST_CLEAN_PATH <- file.path(github_file_path, "DataWork", "Clusters", "01_clean_data")

# Run Code ---------------------------------------------------------------------

## 1. Prep shapefile used to merge in other data
source(file.path(SUBDIST_CLEAN_PATH, "01_prep_clusters.R"))

## 2. Extract data to shapefile
source(file.path(SUBDIST_CLEAN_PATH, "02_distance_cities.R"))
source(file.path(SUBDIST_CLEAN_PATH, "02_extract_project_roads.R"))
source(file.path(SUBDIST_CLEAN_PATH, "02_extract_area.R"))
source(file.path(SUBDIST_CLEAN_PATH, "02_extract_population.R"))
source(file.path(SUBDIST_CLEAN_PATH, "02_extract_road_length.R"))
source(file.path(SUBDIST_CLEAN_PATH, "02_extract_viirs.R"))


## 3. Extract data to shapefile that depends on data from step 2
source(file.path(SUBDIST_CLEAN_PATH, "03_extract_market_access.R"))

## 4. Merge files into master dataset
source(file.path(SUBDIST_CLEAN_PATH, "04_merge.R"))



