# HH Survey Analysis
# Iraq IE

# Load Data --------------------------------------------------------------------
# LSMS Data
lsms_df <- read.dta13(file.path(final_data_file_path, "LSMS/lsms_2012_merged_hh.dta"))

lsms_df <- summaryBy(viirs_2012 + viirs_2013 + viirs_2014 + viirs_2015 + viirs_2016 + 
                       expenditure + hh_size + min_income_needed + 
                       satis_life_overall + satis_food + satis_housing + satis_income + satis_local_security +
                       hh_situation ~ NAME_2, data=lsms_df, FUN=mean, keep.names=T)

lsms_df <- lsms_df[lsms_df$viirs_2012 < 10,]

lsms_df$viirs_2012_ln <- log(lsms_df$viirs_2012)

# Figure -----------------------------------------------------------------------
height = 5
width = 6
ntl_satis_income_fig <- ggplot() +
  geom_point(data=lsms_df, aes(x=viirs_2012_ln, y=satis_income),
             size=1.5) +
  geom_smooth(data=lsms_df, aes(x=viirs_2012_ln, y=satis_income),
              method="lm", se=F, color="red") +
  theme_minimal() +
  labs(x="Log(Nighttime Lights)", 
       y="Satisfied Income",
       title="Relation Between Nighttime Lights and Satisfied in Income",
       caption="Average values at ADM 2 level")
ggsave(ntl_satis_income_fig, filename=file.path(figures_file_path, "ntl_satis_income_cor.png"), height=height, width=width)  

# Map
irq <- getData('GADM', country='IRQ', level=0)

lsms_df <- read.dta13(file.path(final_data_file_path, "LSMS/lsms_2012_merged_hh.dta"))
lsms_df <- lsms_df[!is.na(lsms_df$latitude),]
lsms_df <- lsms_df[!is.na(lsms_df$longitude),]
coordinates(lsms_df) <- ~longitude+latitude
crs(lsms_df) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
lsms_df <- lsms_df[irq,]
lsms_df <- as.data.frame(lsms_df)

lsms_points <- ggplot() + 
  geom_polygon(data=irq, aes(x=long, y=lat, group = group), fill="navajowhite2", color=NA) + 
  geom_point(data=lsms_df, aes(x=longitude, y=latitude),size=0.6) + 
  theme_void() +
  coord_quickmap()
ggsave(lsms_points, filename=file.path(figures_file_path, "lsms_points.png"), height=height, width=width)  



plot(log(lsms_df$viirs_2012), lsms_df$satis_income)
plot(lsms_df$viirs_2012, lsms_df$satis_income)

cor.test(log(lsms_df$viirs_2014), lsms_df$satis_income)





lsms.df <- lsms.df[!is.na(lsms.df$latitude),]
lsms.df <- lsms.df[!is.na(lsms.df$longitude),]
lsms.df <- lsms.df[lsms.df$NAME_0 != "",]

lsms.sdf <- lsms.df
coordinates(lsms.sdf) <- ~longitude+latitude
crs(lsms.sdf) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# Iraq Data
setwd(paste(file.path,"Data/GADM/",sep=""))
iraq.gadm.0 <- raster::getData('GADM', country='IRQ', level=0)	
iraq.gadm.1 <- raster::getData('GADM', country='IRQ', level=1)	

# Road Data
setwd(paste(file.path,"Data/Roads/primary_routes/All/",sep=""))
roads.all <- readOGR(dsn=".", layer="primary_routes")

setwd(paste(file.path,"Data/Roads/primary_routes/R7_R8ab/",sep=""))
roads.r7_8ab <- readOGR(dsn=".", layer="r7_8ab")
roads.r7_8ab.extent.buffer <- extent(roads.r7_8ab) + 1

# Summary Stats by Roads -------------------------------------------------------
lsms.df$road.type[lsms.df$dist_road <= 10 & lsms.df$dist_road_r7_r8ab >= 10] <- "primary road"
lsms.df$road.type[lsms.df$dist_road_r7_r8ab <= 10] <- "r78ab"
lsms.df$road.type[is.na(lsms.df$road.type)] <- "Far From Road"

lsms.df$expenditure_per_hh_member <- lsms.df$expenditure / lsms.df$hh_size

lsms.mean.df <- summaryBy(.~road.type,FUN=mean,keep.names=T,data=lsms.df,na.rm=T) %>%
                t() %>%
                as.data.frame()
names(lsms.mean.df) <- c("far_from_road.mean","primary_road.mean","r78ab.mean")
lsms.mean.df <- lsms.mean.df[-1,]

lsms.sd.df <- summaryBy(.~road.type,FUN=sd,keep.names=T,data=lsms.df,na.rm=T) %>%
  t() %>%
  as.data.frame()
names(lsms.sd.df) <- c("far_from_road.sd","primary_road.sd","r78ab.sd")
lsms.sd.df <- lsms.sd.df[-1,]

# Mean and SD in Same Column ---------------------------------------------------
lsms.sum.df <- cbind(lsms.mean.df,lsms.sd.df)
for(var in names(lsms.sum.df)){
  lsms.sum.df[[var]] <- as.numeric(as.character(lsms.sum.df[[var]]))
}

lsms.sum.df$far_from_road <- paste(round(lsms.sum.df$far_from_road.mean,2),
                       " (", round(lsms.sum.df$far_from_road.sd,2), ")", sep="")

lsms.sum.df$primary_road <- paste(round(lsms.sum.df$primary_road.mean,2),
                                   " (", round(lsms.sum.df$primary_road.sd,2), ")", sep="")

lsms.sum.df$r78ab <- paste(round(lsms.sum.df$r78ab.mean,2),
                                   " (", round(lsms.sum.df$r78ab.sd,2), ")", sep="")

write.csv(lsms.sum.df, paste(file.path, "Tables/sum_stat.csv",sep=""))




summarize.hh <- function(variable, variable.name){
  cat(
    variable.name,
    " & ",
    lsms.df[[variable]][lsms.df$road.type == "r78ab"] %>% mean(na.rm=T) %>% round(2),
    " (",
    lsms.df[[variable]][lsms.df$road.type == "r78ab"] %>% sd(na.rm=T) %>% round(2),
    ")",
    " & ",
    lsms.df[[variable]][lsms.df$road.type == "primary road"] %>% mean(na.rm=T) %>% round(2),
    " (",
    lsms.df[[variable]][lsms.df$road.type == "primary road"] %>% sd(na.rm=T) %>% round(2),
    ")",
    " & ",
    lsms.df[[variable]][lsms.df$road.type == "Far From Road"] %>% mean(na.rm=T) %>% round(2),
    " (",
    lsms.df[[variable]][lsms.df$road.type == "Far From Road"] %>% sd(na.rm=T) %>% round(2),
    ")",
    " \\","\\ ",
    sep=""
  )
}


cat("Variable & Within 10km of R7 or R8A/B & Within 10km of Primary Road", "Greater than 10km from Road \\","\\ ",sep="")
summarize.hh("satis_life_overall","Satisfied Life")
summarize.hh("min_income_needed","Satisfied Food")

# NTL vs. Population -----------------------------------------------------------
lsms.df$number.HH <- 1
lsms.adm.df <- lsms.df %>%
  group_by(governorate,qhada) %>% 
  summarize(mean_ntl = max(viirs_2013, na.rm=TRUE),
            min_income_needed = mean(min_income_needed, na.rm=T),
            number.HH = sum(number.HH))

lsms.adm.df$mean_ntl <- log(lsms.adm.df$mean_ntl+1)

plot(lsms.adm.df$mean_ntl, lsms.adm.df$min_income_needed)

metadata %>%
  group_by(cit, clade) %>%
  summarize(mean_size = mean(genome_size, na.rm = TRUE),
            min_generation = min(generation))



summaryBy(viirs_2013+data=lsms.df)
lsms.df$viirs_2013

# Analysis: NTL vs HH Data -----------------------------------------------------
vars <- c("satis_food",              "satis_housing" ,          "satis_income" ,          
"satis_health"   ,         "satis_work"     ,         "satis_local_security"  , 
"satis_education"   ,      "satis_freedom_choice"    ,"satis_control_over_life",
"satis_trust_acc_comm" ,   "satis_life_overall")

lsms.df$viirs_2013.log <- log(lsms.df$viirs_2013+1)

cor.i <- function(v,viirs) as.data.frame(t(c(v,cor(lsms.df[[v]], lsms.df[[viirs]], use="complete.obs"))))
lapply(vars, cor.i, "viirs_2013.log") %>% bind_rows

# Figure: Number of HH Near Road -----------------------------------------------
distances <- seq(from=0,to=50,by=0.5)
num_within_distance <- function(d) sum(lsms.df$dist_road_r7_r8ab <= d)
number.within.distance <- lapply(distances, num_within_distance) %>% unlist

distances.df <- cbind(distances,number.within.distance) %>% as.data.frame
names(distances.df) <- c("distance","number.hh")

distance.road.plot <- ggplot(distances.df, aes(x=distance, y=number.hh)) + 
  geom_line(size=1) +
  labs(x="Distance from R7 or R8A/B (km)",
       y="Households") +
  theme_minimal() + 
  theme(axis.title.x = element_text(size=15),
        axis.title.y = element_text(size=15),
        axis.text.x = element_text(size=15),
        axis.text.y = element_text(size=15)) 
ggsave(distance.road.plot, filename=paste(file.path, "Figures/CN/number_HH_distance_r78ab.png",sep=""), height=5, width=4)

# Figure: Households in Iraq ---------------------------------------------------
hh.locations.iraq <- ggplot() + 
  geom_point(data=lsms.df, aes(x=longitude,y=latitude), size=0.1) +
  geom_polygon(data=iraq.gadm.0, aes(x=long,y=lat,group=group),fill=NA, color="black") +
  geom_path(data=roads.all, aes(x=long,y=lat,group=group,color="Major Roads"), alpha=1) +
  geom_path(data=roads.r7_8ab, aes(x=long,y=lat,group=group,color="R7, R8A/B")) +
  scale_color_manual(values=c("palegreen4", "red")) +
  labs(colour="Roads") +
  theme_void() +
  coord_map() +
  theme(legend.key=element_blank(),
        legend.position = c(0.76, 0.59),
        legend.title=element_text(size=14),
        legend.text=element_text(size=14))
hh.locations.iraq
ggplot2::ggsave(hh.locations.iraq, filename=paste(file.path, "Figures/CN/hh.locations.iraq.png",sep=""), height=7, width=7)

hh.locations.r7r8ab <- ggplot() + 
  geom_point(data=lsms.df, aes(x=longitude,y=latitude), size=0.5) +
  geom_path(data=roads.all, aes(x=long,y=lat,group=group,color="Major Roads"), alpha=1) +
  geom_path(data=roads.r7_8ab, aes(x=long,y=lat,group=group,color="R7, R8A/B")) +
  scale_color_manual(values=c("palegreen4", "red")) +
  labs(colour="Roads") +
  theme_void() +
  coord_map() +
  theme(legend.key=element_blank(),
        legend.position = c(.15, .12),
        legend.title=element_text(size=15),
        legend.text=element_text(size=15)) +
  coord_cartesian(xlim = c(46, 48), ylim=c(30.15,31.1)) +
  theme(legend.position="none",
        plot.margin=margin(l=-4,r=-4,unit="cm"))
ggsave(hh.locations.r7r8ab, filename=paste(file.path, "Figures/CN/hh.locations.r7r8ab.png",sep=""), height=7, width=7)


hh_maps_distance <- plot_grid(hh.locations.iraq, hh.locations.r7r8ab, distance.road.plot, 
               labels = c('A', 'B', 'C'), 
               ncol=3, 
               scale=c(1,.4,0.9))
ggsave(hh_maps_distance, filename=paste(file.path, "Figures/CN/hh_maps_distance.png",sep=""), width=15, height=6)


# Nighttime Lights vs. HH Data -------------------------------------------------

# Nighttime Lights Along Corridor ----------------------------------------------
viirs.2015 <- raster(paste(file.path, "Data/NTL Rasters Annual Avg/viirs2017.tif", sep=""))
viirs.2015 <- raster::crop(viirs.2015, roads.r7_8ab.extent.buffer) 

viirs.2015 <- log(viirs.2015+1)
viirs.2015 <- log(viirs.2015+1) 
viirs.2015.df <- as(viirs.2015, "SpatialPixelsDataFrame")
viirs.2015.df <- as.data.frame(viirs.2015.df)
colnames(viirs.2015.df) <- c("value", "x", "y") 

roads.r7_8ab.10km <- gBuffer(roads.r7_8ab, width=10/111.12)

ntl_r7r8ab <- ggplot() +
  geom_tile(data=viirs.2015.df, aes(x=x,y=y,fill=value)) +
  geom_path(data=roads.r7_8ab.10km, aes(x=long, y=lat, group=group, color="10km Around\nR7 & R8A/B")) +
  scale_color_manual(values="red") +
  labs(colour="") +
  coord_equal() +
  ggmap::theme_nothing(legend=TRUE) + 
  theme(legend.key=element_blank(),
        legend.text = element_text(size=11),
        legend.title = element_text(size=11)) +
  scale_fill_gradient(name="Nighttime Lights", 
                      low = "black", high = "yellow",
                      breaks=c(quantile(viirs.2015.df$value, 0.10),
                               quantile(viirs.2015.df$value, 0.50),
                               quantile(viirs.2015.df$value, 0.99999)),
                      labels=c("Minimum","","Maximum"))
ggsave(ntl_r7r8ab, filename=paste(file.path, "Figures/CN/ntl_r7r8ab.png",sep=""), height=7, width=9)


mean(lsms.df$satis_life_overall[lsms.df$dist_road_r7_r8ab <= 10], na.rm=T)
mean(lsms.df$satis_life_overall[lsms.df$dist_road_r7_r8ab > 10], na.rm=T)






