# Iraq IE
# Distance to Roads

# Load Data --------------------------------------------------------------------
iraq_adm3 <- readRDS(file.path(final_data_file_path, "subdistrict_data", "subdistrict_population_marketaccess.Rds"))

# Log Market Access ------------------------------------------------------------
MA_vars <- names(iraq_adm3)[grepl("MA_", names(iraq_adm3))]

for(var in MA_vars){
  iraq_adm3[[var]] <- log(iraq_adm3[[var]])
}

# Map --------------------------------------------------------------------------
iraq_adm3$id <- row.names(iraq_adm3)
iraq_adm3_tidy <- tidy(iraq_adm3)
iraq_adm3_tidy <- merge(iraq_adm3_tidy, iraq_adm3, by="id")

p1 <- ggplot() +
  geom_polygon(data=iraq_adm3_tidy, aes(x=long, y=lat, group=group, fill=MA_dist_theta5), color="black") +
  labs(fill = "Market\nAccess\n(logged)",
       title = "Market Access (theta = 5)\n ") +
  scale_fill_continuous(type = "viridis") +
  theme_void() +
  coord_quickmap() +
  theme(plot.title = element_text(hjust = 0.5))

p2 <- ggplot() +
  geom_polygon(data=iraq_adm3_tidy, aes(x=long, y=lat, group=group, fill=MA_dist_theta5_exclude100km), color="black") +
  labs(fill = "Market\nAccess\n(logged)",
       title = "Market Access (theta = 5),\nExcluding Areas within 100km") +
  scale_fill_continuous(type = "viridis") +
  theme_void() +
  coord_quickmap() +
  theme(plot.title = element_text(hjust = 0.5))

p_all <- ggarrange(p1, p2)
ggsave(p_all, filename = file.path(figures_file_path, "market_access.png"), height=6, width=12)







