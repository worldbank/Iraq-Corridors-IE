# Iraq IE
# Add covariates to grid level data


# Loading Dataset ---------------------------------------------------------
ntl_subdist <- readRDS(file.path(final_data_file_path, "Cleaned Data for Preliminary Analysis", "FinalData", "ntl_subdist_final.Rds"))
ntl_pixel_random <- readRDS(file.path(final_data_file_path, "VIIRS", "FinalData", "iraq_viirs_random_sample.Rds"))

##selecting a random sample (10% of each sub-district) for ease of coding
n <- round(0.1*nrow(ntl_pixel_random[ntl_pixel_random$uid,])) #5% from each sub-district
ntl_pixel_random1 <- sample_n(ntl_pixel_random,n)

remove(ntl_pixel_random)
# Road Improvement ----------------------------------------------
ntl_pixel_random1 <- 
  mutate(ntl_pixel_random1,
         roadimprovement = year > 2014) 



# Settlement,Conflict,Average Expenditure,Population -----------------------------------------------------
ntl_subdist <- subset(ntl_subdist, select = c(uid,year,month,average_hh_exp.mean,no_of_conflicts,no_of_settlements,population))

##merging with main data set
ntl_pixel_random1 <- left_join(ntl_pixel_random1,ntl_subdist, by = c("uid", "year","month"))

remove(ntl_subdist)

##imputing conflict for 2014



# Population Growth -------------------------------------------------------
##Data source - https://data.worldbank.org/indicator/SP.POP.GROW -- averages to 2.5%

##Function to apply
pop_est <- function(year,population){
  if (year == 2016){
    return(population*(1+2.5))
  }
  else if (year == 2017){
    return(population*((1+2.5)^2))
  }
  
  else if (year == 2018){
    return(population*((1+2.5)^3))
  }
  else if (year == 2019){
    return(population*((1+2.5)^4))
  }
  return(population)  
}

#!FIX ME - memory issue!
ntl_pixel_random1$pop_new <- sapply(X = ntl_pixel_random1$year, FUN = pop_est,population = ntl_pixel_random1$population) 


# Market access -----------------------------------------------------------
market_access <- readRDS(file.path(project_file_path, "Data", "CSO Subdistricts", "FinalData", "subdistrict_population_marketaccess.Rds"))
market_access <- market_access@data

##subset the data
market_access <- subset(market_access, select = c(uid,MA_dist_theta3_8,MA_rdlength_theta3_8,MA_dist_theta3_8_exclude10km,MA_dist_theta3_8_exclude100km))

##since population estimates are currently for 2015
market_access$year <- 2015

##merge only for 2015
ntl_pixel_random1 <- left_join(ntl_pixel_random1,market_access,suffix = c("uid","year"))


# Export ------------------------------------------------------------------
saveRDS(ntl_pixel_random1, file=file.path(final_data_file_path, "VIIRS", "FinalData", "03_iraq_viirs_random_sample_covar.Rds"))



