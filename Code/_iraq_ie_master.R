# Iraq IE
# Master Rscript

# Filepaths --------------------------------------------------------------------
if(Sys.info()[["user"]] == "WB521633") project_file_path <- "C:/Users/wb521633/Dropbox/World Bank/IEs/Iraq IE"
if(Sys.info()[["user"]] == "robmarty") project_file_path <- "~/Dropbox/World Bank/IEs/Iraq IE"

raw_data_file_path <- file.path(project_file_path, "Data", "RawData")
intermediate_data_file_path <- file.path(project_file_path, "Data", "IntermediateData")
final_data_file_path <- file.path(project_file_path, "Data", "FinalData")
figures_file_path <- file.path(project_file_path, "Results", "Figures")
tables_file_path <- file.path(project_file_path, "Results", "Tables")
code_file_path <- file.path(project_file_path, "Code")

UTM_IRQ <- '+init=epsg:3394'

# Libraries --------------------------------------------------------------------
library(raster)
library(dplyr)
library(parallel)
library(pbmcapply)
library(rgdal)
library(rgeos)
library(geosphere)
library(sf)
library(velox)
library(broom)
library(ggplot2)
library(gdistance)
library(data.table)
library(ggpubr)
library(reshape)
library(doBy)
library(readstata13)
library(haven)
source("https://raw.githubusercontent.com/ramarty/rgeos_chunks/master/R/rgeos_chunks.R")

