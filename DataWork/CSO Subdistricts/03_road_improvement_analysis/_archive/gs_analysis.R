#gs analysis

# Loading Data set ---------------------------------------------------------
ntl_subdist <- readRDS(file=file.path(project_file_path, 
                                      "Data","CSO Subdistricts","FinalData", 
                                      "subdistrict_data_df_clean.Rds"))

#cleaning date variable
ntl_subdist$year_month <- paste0(ntl_subdist$year, "-", ntl_subdist$month, "-01") %>% 
  ymd()

#liberation
ntl_subdist$liberation <- ifelse(ntl_subdist$year_month > "2017-06-01",1,0)

#create interaction variable
ntl_subdist$roadimprovement_liberation <- ntl_subdist$roadimprovement*ntl_subdist$liberation
# Summary Statistics ------------------------------------------------------
ntl_subdist_20km <-
  ntl_subdist[which(ntl_subdist$dist_gs_km <= 20),]

#add roadimprovement
ntl_subdist$roadimprovement_gs <- ifelse(ntl_subdist$year > 2019,1,0)

#subset data
vars <- c("transformed_viirs_mean","area_km2","distance_to_baghdad","no_of_conflicts","population","no_of_settlements", "uid")
ntl_subdist_20km_subset <- ntl_subdist_20km[vars]

ntl_subdist_20km_subset <- aggregate(transformed_viirs_mean ~ uid + area_km2 + distance_to_baghdad + population,
                                     data = ntl_subdist_20km_subset, 
                                     FUN = mean)
ntl_subdist_20km_subset <- ntl_subdist_20km_subset[,2:5]
stargazer(ntl_subdist_20km_subset,
          out = file.path(project_file_path, "Tables" ,"summarystats_gs.tex"), 
          float = F)
