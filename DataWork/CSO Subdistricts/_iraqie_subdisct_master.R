# Iraq IE
# Subdistrict Analysis Master

datawork_subdist <- file.path(github_file_path, "DataWork", "CSO Subdistricts")

# 1. Clean Data ----------------------------------------------------------------
clean_data_path <- file.path(datawork_subdist, "01_clean_data")

source(file.path(clean_data_path, "01_extract_data_to_subdistricts.R"))
source(file.path(clean_data_path, "02_calc_market_access.R"))

# 2. Market Access Analysis ----------------------------------------------------
ma_analysis_path <- file.path(datawork_subdist, "02_market_access_analysis")

source(file.path(ma_analysis_path, "market_access_figures.R"))
source(file.path(ma_analysis_path, "shortest_path_example.R"))


