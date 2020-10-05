# Iraq IE
# Master Rscript - Data Analysis

# File paths --------------------------------------------------------------------
if(Sys.info()[["user"]] == "chitr") project_file_path <- "C:/Users/chitr/Dropbox/Iraq IE"
if(Sys.info()[["user"]] == "chitr") github_file_path <- "C:/Users/chitr/Documents/GitHub/Iraq-Corridors-IE/DataWork/VIIRS"

#if(Sys.info()[["user"]] == "robmarty") project_file_path <- "~/Dropbox/World Bank/IEs/Iraq IE"

final_data_file_path <- file.path(project_file_path, "Data")
figures_file_path <- file.path(github_file_path, "03_viirs_figures")
code_file_path <- file.path(github_file_path, "02_analysis")

# Libraries --------------------------------------------------------------------
library(sf)
library(sp)
library(raster)
library(dplyr)
library(parallel)
library(pbmcapply)
library(rgdal)
library(rgeos)
library(geosphere)
library(haven)
library(lfe)
library(plm)
library(doBy)
library(tidyverse)
library(reshape)
library(stargazer)
library(readxl)
library(cobalt)
library(WeightIt)
library(MatchIt)





