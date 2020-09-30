# Iraq IE
# Master Rscript

# Filepaths --------------------------------------------------------------------
if(Sys.info()[["user"]] == "WB521633") project_file_path <- "C:/Users/wb521633/Dropbox/World Bank/IEs/Iraq IE"
if(Sys.info()[["user"]] == "robmarty") project_file_path <- "~/Dropbox/World Bank/IEs/Iraq IE"

if(Sys.info()[["user"]] == "WB521633") github_file_path <- "C:/Users/wb521633/Documents/Github/Iraq-Corridors-IE"
if(Sys.info()[["user"]] == "robmarty") github_file_path <- "~/Documents/Github/Iraq-Corridors-IE"

# Global Parameters ------------------------------------------------------------
UTM_IRQ <- '+init=epsg:3394'
N_CORES <- 2

# Libraries --------------------------------------------------------------------
library(raster)
library(readr)
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
library(ggmap)
library(gtools)
source("https://raw.githubusercontent.com/ramarty/rgeos_chunks/master/R/rgeos_chunks.R")
source("https://raw.githubusercontent.com/ramarty/fast-functions/master/R/functions_in_chunks.R")

