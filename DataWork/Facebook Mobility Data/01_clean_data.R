# Download GADM

fb_df <- fread(file.path(project_file_path, "Data", "Facebook Mobility Data", "RawData", "movement-range-2021-03-09.txt"))

fb_df <- fb_df %>%
  filter(country %in% "IRQ") 

irq <- readRDS(file.path(project_file_path, "Data", "GADM", "RawData", "gadm36_IRQ_2_sp.rds"))

