#NDVI MAP


# Load Data ---------------------------------------------------------------

iraq_adm <- readRDS(file.path(project_file_path,
                                          "Data","CSO Subdistricts","FinalData",
                                          "subdistrict_timeinvariant_data_sp.Rds"))


  
ndvi_2019 <- raster("C:/Users/chitr/Dropbox/Iraq IE/Data/NDVI/MODIS - Monthly/RawData/ndvi_modis_iraq_monthly_1km_2019.tif")

ndvi_2019_spdf <- as(ndvi_2019, "SpatialPixelsDataFrame")
ndvi_df <- as.data.frame(ndvi_2019_spdf)
colnames(ndvi_df) <- c("value", "x", "y")



ggplot()+
  geom_raster(data = ndvi_df, aes(x = x, y=y, fill = value), alpha = 0.8)+
  coord_quickmap()+
  labs(fill = "NDVI")+
  scale_fill_gradientn(colours = hcl.colors(3, alpha = 0.8, rev = FALSE, palette = "RdYlGn"))+
  theme_void()


