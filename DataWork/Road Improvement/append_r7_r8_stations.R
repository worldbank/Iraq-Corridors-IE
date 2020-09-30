# Append r7/r8 stations into one dataset

#### Load Data 
r7_stations <- read.csv(file.path(project_file_path, "Data", "Road Improvement", 
                                  "R7", "FinalData", "R7-stations.csv"),
                        stringsAsFactors = F)

r8_stations <- read.csv(file.path(project_file_path, "Data", "Road Improvement", 
                                  "R8", "FinalData", "R8-stations.csv"),
                        stringsAsFactors = F)

#### Append
stations <- bind_rows(r7_stations,
                      r8_stations)

#### Export
write.csv(stations, file.path(project_file_path, "Data", "Road Improvement", 
                              "All Stations", "stations.csv"),
          row.names = F)

