# -*- coding: utf-8 -*-
"""
Convert OSM File to Network

1. Load OSM as network
2. Use GOSTnets to clean network
3. Export as network
"""

# Parameters ------------------------------------------------------------------
# CONSTANT_POPULATION: If True, then use 2000 population for all market access
#                      calculateions. If False, then use population of given year
CONSTANT_POPULATION = True

# MA_CALC_FUNCTION: If "by_cell" then loop through cells, if "by_node" then loop
#                   through nodes. (either: by_cell OR by_node)
MA_CALC_FUNCTION = "by_cell"

# WALKING_SPEED: Walking speed in km/hr (GOSTNets Uses 4.5km/hr by default)
WALKING_SPEED = 4.5

# Functions -------------------------------------------------------------------
# Method 1: Loop through cells
def calc_tt_per_cell(cell_id):

    points_gdp_Gsnap_i = points_gdp_Gsnap[points_gdp_Gsnap.id == cell_id]
    traveltime_all_df_i = traveltime_all_df[traveltime_all_df.index == list(points_gdp_Gsnap_i.NN)[0]]
    out = pd.concat([points_gdp_Gsnap_i.reset_index(drop=True), traveltime_all_df_i.reset_index(drop=True)], axis=1)
    
    return(out)

# Load Data -------------------------------------------------------------------
#### Points
points_dict = pyreadr.read_r(os.path.join(project_file_path,'Data','FinalData','VIIRS Grid','Separate Files Per Variable', 'iraq_grid_blank.Rds'))
points_df = points_dict[None]
points_df = pd.DataFrame(points_df)

geometry = [Point(xy) for xy in zip(points_df.lon, points_df.lat)]
points_df = points_df.drop(['lon', 'lat'], axis=1)
crs = {'init': 'epsg:4326'}
points_gdp = gpd.GeoDataFrame(points_df, crs=crs, geometry=geometry)

#### Graph
G = nx.read_gpickle(os.path.join(project_file_path,'Data','RawData','road_graph_objects','osm', 'osm_mainroads_G_clean.pickle'))

#### Cities
cities = pd.read_csv(os.path.join(project_file_path,'Data','RawData','Cities','cities.csv'))
geometry = [Point(xy) for xy in zip(cities.longitude, cities.latitude)]
cities = cities.drop(['longitude', 'latitude'], axis=1)
crs = {'init': 'epsg:4326'}
cities_gdp = gpd.GeoDataFrame(cities, crs=crs, geometry=geometry)

# Snap to Network ----------------------------------------------------------------
## Snap grid points to network
points_gdp_Gsnap = gn.pandana_snap(G, points_gdp, add_dist_to_node_col=True, target_crs = UTM_str)
cities_gdp_Gsnap = gn.pandana_snap(G, cities_gdp, add_dist_to_node_col=True, target_crs = UTM_str)

# Travel Time from All City Nodes to All Network Locations --------------------
nodes = list(cities_gdp_Gsnap.NN)

# Initialize Dataframe
node_i = nodes[0]
traveltime_dict = nx.single_source_dijkstra_path_length(G, node_i, cutoff = None, weight = 'time')
traveltime_all_df = pd.Series(traveltime_dict).to_frame(node_i)

# Loop through nodes and merge to dataframe
for node_i in nodes[1:]:
    print(node_i)

    traveltime_dict = nx.single_source_dijkstra_path_length(G, node_i, cutoff = None, weight = 'time')
    traveltime_df = pd.Series(traveltime_dict).to_frame(node_i)

    traveltime_all_df = traveltime_all_df.merge(traveltime_df, how='outer', left_index=True, right_index=True)


### Calc Travel Times
traveltime_all_df.index.name = 'NN'
traveltime_all_df.reset_index(inplace=True)    
    
points_gdp_Gsnap_withTT = points_gdp_Gsnap.merge(traveltime_all_df, on='NN')
    
# Export ----------------------------------------------------------------------    
pyreadr.write_rds(os.path.join(project_file_path,'Data','FinalData','VIIRS Grid','Separate Files Per Variable', 'travel_times.Rds'), points_gdp_Gsnap_withTT)

    

