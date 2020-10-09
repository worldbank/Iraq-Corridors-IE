#NTL Trends over the years


# Load Data ---------------------------------------------------------------
viirs_grid <- readRDS(file=file.path(project_file_path, 
                                     "Data","CSO Subdistricts","FinalData", 
                                     "subdistrict_data_df_clean.Rds"))


# Subset Data -------------------------------------------------------------
vars <- c("viirs_mean","year","month")
viirs_grid_all <- viirs_grid[vars]

viirs_grid_all <-
  summaryBy(viirs_mean ~ year,
            data = viirs_grid_all,
            FUN = median) #aggregate over year (choose median)

#within the 5km buffer of R7/R8
viirs_grid_5km <- viirs_grid[which(viirs_grid$dist_r78_km <=5),]
viirs_grid_5km <- viirs_grid_5km[vars]

viirs_grid_5km <-
  summaryBy(viirs_mean ~ year,
            data = viirs_grid_5km,
            FUN = median) #aggregate over year (choose median)

#within the 10km buffer of R7/R8
viirs_grid_10km <- viirs_grid[which(viirs_grid$dist_r78_km <=10),]
viirs_grid_10km <- viirs_grid_10km[vars]

viirs_grid_10km <-
  summaryBy(viirs_mean ~ year,
            data = viirs_grid_10km,
            FUN = median) #aggregate over year (choose median)

#within the 20km buffer of R7/R8
viirs_grid_20km <- viirs_grid[which(viirs_grid$dist_r78_km <=20),]
viirs_grid_20km <- viirs_grid_20km[vars]

viirs_grid_20km <-
  summaryBy(viirs_mean ~ year,
            data = viirs_grid_20km,
            FUN = median) #aggregate over year (choose median)

# Plot --------------------------------------------------------------------
ntl_all <- viirs_grid_all %>%
           ggplot(aes(x = year, y = viirs_mean.median))+
           geom_line(color = "grey") +
           geom_point( shape = 21, color = "black", fill = "#69b3a2", size = 3) + 
           theme_bw()+
           geom_vline(xintercept = 2016, linetype = "dotted", color = "black", size = 1.5) +
           ggtitle("Across Iraq")+
           ylab("Median Nighttime Lights") +
           xlab("Year")

ntl_all

ggsave(ntl_all, filename = file.path(project_file_path,"Figures","iraq_ntl_trends_all.png"), width = 6, height = 6)

ntl_5km_10km_20km <- viirs_grid_5km %>%
           ggplot(aes(x = year, y = viirs_mean.median, color = viirs_mean.median))+
           geom_line(color ="grey") +
           geom_line(color = "grey",data = viirs_grid_10km) +
           geom_line(color = "grey", data = viirs_grid_20km) +
           geom_point(aes(fill = "5km"), shape = 21, color = "black", size = 3) +
           geom_point(aes(fill = "10km"), shape = 21, color = "black",  size = 3, data = viirs_grid_10km) +
           geom_point(aes(fill = "20km"),shape = 21, color = "black", size = 3, data = viirs_grid_20km) +
           scale_color_discrete(name = "buffer")+
           theme_bw()+
           geom_vline(xintercept = 2016, linetype = "dotted", color = "black", size = 1.5)+
           ggtitle("Within a 5km,10km & 20km buffer of R7/R8") +
           labs(y = "Median Nighttime Lights",
                x = "Year",
                fill = "Buffer")
          
           

ntl_5km_10km_20km
ggsave(ntl_5km_10km_20km, filename = file.path(project_file_path, "Figures", "iraq_ntl_trends_5km.png"), width = 6, height = 6)



