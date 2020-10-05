# Iraq IE
# Master Rscript

# Filepaths --------------------------------------------------------------------
if(Sys.info()[["user"]] == "WB521633") project_file_path <- "C:/Users/wb521633/Dropbox/World Bank/IEs/Iraq IE"
if(Sys.info()[["user"]] == "robmarty") project_file_path <- "~/Dropbox/World Bank/IEs/Iraq IE"

if(Sys.info()[["user"]] == "WB521633") github_file_path <- "C:/Users/wb521633/Documents/Github/Iraq-Corridors-IE"
if(Sys.info()[["user"]] == "robmarty") github_file_path <- "~/Documents/Github/Iraq-Corridors-IE"

if(Sys.info()[["user"]] == "chitr") project_file_path <- "C:/Users/chitr/Dropbox/Iraq IE"
if(Sys.info()[["user"]] == "chitr") github_file_path <- "C:/Users/chitr/Documents/GitHub/Iraq-Corridors-IE"

api_keys <- read.csv("~/Dropbox/World Bank/Webscraping/Files for Server/api_keys.csv",
                     stringsAsFactors = F)
#>>>>>>> 5a4136e344d0b198e51718a4151406e0b56b9130




# Global Parameters ------------------------------------------------------------
UTM_IRQ <- '+init=epsg:3394'
N_CORES <- 2

# Libraries --------------------------------------------------------------------

library(purrr)
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
library(readxl)
library(ggrepel)
library(readr)
library(plm)
library(stargazer)
library(xml2)
library(mapsapi)
library(leaflet)
library(leaflet)
library(XML)
source("https://raw.githubusercontent.com/ramarty/rgeos_chunks/master/R/rgeos_chunks.R")
source("https://raw.githubusercontent.com/ramarty/fast-functions/master/R/functions_in_chunks.R")

#>>>>>>> 5a4136e344d0b198e51718a4151406e0b56b9130





