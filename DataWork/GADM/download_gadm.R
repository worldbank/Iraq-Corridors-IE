# Download GADM

store_path <- file.path(project_file_path, "Data", "GADM", "RawData")

getData('GADM', country='IRQ', level=0, path = store_path)
getData('GADM', country='IRQ', level=1, path = store_path)
getData('GADM', country='IRQ', level=2, path = store_path)

