# Add Population to Subdistrict Shapefile

# Load Data --------------------------------------------------------------------
#### ADM 3
iraq_adm3 <- readOGR(dsn = file.path(raw_data_file_path, "Sub District Shapefile"),
        layer = "irq_admbnda_adm3_cso_20190603")

#### Population



