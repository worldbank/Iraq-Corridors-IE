#adding time variant data

# Load Data ---------------------------------------------------------------
ntl_subdist <- readRDS(file=file.path(project_file_path, 
                                      "Data","CSO Subdistricts","FinalData", 
                                      "subdistrict_data_df.Rds"))

# Transformation of viirs_mean --------------------------------------------
ntl_subdist$transformed_viirs_mean <- 
  log(ntl_subdist$viirs_mean + sqrt((ntl_subdist$viirs_mean)^2+1))


# Temp Road Improvement var -----------------------------------------------
ntl_subdist$roadimprovement <- ifelse(ntl_subdist$year > 2015,1,0)



# Adding new population var -----------------------------------------------
## include population growth (assuming a 2.5% annual growth)
ntl_subdist$pop_new <- ntl_subdist$population
ntl_subdist$pop_new[ntl_subdist$year == 2012] <- ntl_subdist$population[ntl_subdist$year == 2013]*(1-0.025)
ntl_subdist$pop_new[ntl_subdist$year == 2013] <- ntl_subdist$population[ntl_subdist$year == 2014]*(1-0.025)
ntl_subdist$pop_new[ntl_subdist$year == 2014] <- ntl_subdist$population[ntl_subdist$year == 2015]*(1-0.025)
ntl_subdist$pop_new[ntl_subdist$year == 2016] <- ntl_subdist$population[ntl_subdist$year == 2015]*(1+0.025)
ntl_subdist$pop_new[ntl_subdist$year == 2017] <- ntl_subdist$pop_new[ntl_subdist$year == 2016]*(1+0.025)
ntl_subdist$pop_new[ntl_subdist$year == 2018] <- ntl_subdist$pop_new[ntl_subdist$year == 2017]*(1+0.025)
ntl_subdist$pop_new[ntl_subdist$year == 2019] <- ntl_subdist$pop_new[ntl_subdist$year == 2018]*(1+0.025)


# Treating missing values -------------------------------------------------
##replace NA with 0 for conflicts, settlement and household exp. data
ntl_subdist$no_of_conflicts <-
  ifelse(is.na(ntl_subdist$no_of_conflicts),0,ntl_subdist$no_of_conflicts)

ntl_subdist$no_of_settlements <-
  ifelse(is.na(ntl_subdist$no_of_settlements),0,ntl_subdist$no_of_settlements)

ntl_subdist$avg_hh_exp.mean <-
  ifelse(is.na(ntl_subdist$avg_hh_exp.mean),0,ntl_subdist$avg_hh_exp.mean)

##create binary for incomplete data
ntl_subdist$missing <-
  ifelse(ntl_subdist$avg_hh_exp.mean == 0.00|ntl_subdist$no_of_conflicts == 0|ntl_subdist$no_of_settlements == 0,1,0)

# Export ------------------------------------------------------------------
saveRDS(ntl_subdist,file.path(project_file_path, 
                       "Data","CSO Subdistricts","FinalData", 
                       "subdistrict_data_df_clean.Rds"))


