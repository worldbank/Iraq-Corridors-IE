
# Load Data ---------------------------------------------------------------
gtd_df <- read_excel(file.path(project_file_path,
                               "Data", "Global Terrorism Database","RawData",
                               "globalterrorismdb_0919dist.xlsx"))


iraq_adm <- readRDS(file.path(project_file_path,
                              "Data","CSO Subdistricts","FinalData",
                              "subdistrict_timeinvariant_data_sp.Rds"))
iraq_adm <- st_as_sf(iraq_adm)


roads <- readRDS(file.path(project_file_path,
                           "Data","OpenStreetMap","FinalData","iraq_roads_rds","gis_osm_roads_free_1.Rds"))

roads <- roads[roads$fclass == "trunk",]

roads <- st_as_sf(roads)
# Subset Data -------------------------------------------------------------
gtd_df <- gtd_df[which(gtd_df$country_txt == "Iraq"), names(gtd_df) %in%
                   c( "iyear", "imonth","latitude" ,"longitude")]

gtd_df <- gtd_df[(gtd_df$iyear > 2011) & (gtd_df$iyear < 2016), ]

#GTD 
gtd_df <- gtd_df %>%
  dplyr::rename(year = iyear, 
                month = imonth, 
                lat = latitude, 
                lon = longitude)

gtd_df$no_of_conflicts <- 1

gtd_df <- 
  aggregate(no_of_conflicts ~ lon + lat + year,
            data = gtd_df,
            FUN = sum) #aggregating data by location


# Figure  ----------------------------------------------------------------
ggplot()+
  geom_sf(data = iraq_adm, fill = NA, color = "gray69", aes(label = "ADM1_EN"))+
  geom_text()+
  geom_sf(data = roads, color = "coral3")+
  geom_point(data = gtd_df, aes(x = lon, y = lat, group = no_of_conflicts, size = no_of_conflicts), color = "coral", alpha = 0.5) +
  scale_size(range = c(.1,10),name = "Number \nof Conflicts")+
  theme_void()
 
  


