# -*- coding: utf-8 -*-
"""
Convert OSM File to Network

1. Load OSM as network
2. Use GOSTnets to clean network
3. Export as network
"""

# Define Functions ============================================================

# Shapefile to G --------------------------------------------------------------
def shp_to_G(shape1, speed_var, target_utm, temp_osm_network):
    print(speed_var)

    shape = shape1.copy()

    # Convert to OSM Type
    shape = shape.to_crs({'init':'epsg:4326'})
    shape['osm_id'] = shape.index
    shape[speed_var] = shape[speed_var].apply(int)
    shape['infra_type'] = 'speed_' + shape[speed_var].apply(str)
   # eth = losm.OSM_to_network(os.path.join(project_file_path,'Data','RawData','template_osmfile_for_gostnet', 'tajikistan-latest.osm.pbf'))
    temp_osm_network.roads_raw = shape
    temp_osm_network.generateRoadsGDF(verbose = False)
    temp_osm_network.initialReadIn()
    G = temp_osm_network.network

    # Add length in meters
    source = 'epsg:4326'

    project_WGS_UTM = partial(
                    pyproj.transform,
                    pyproj.Proj(init=source),
                    pyproj.Proj(init=target_utm))
    G2 = G.copy()

    for u, v, data in G2.edges(data = True):

        project_UTM_WGS = partial(
                    pyproj.transform,
                    pyproj.Proj(init=target_utm),
                    pyproj.Proj(init=source))

        UTM_geom = transform(project_WGS_UTM, data['Wkt'])

        data['length'] = UTM_geom.length

    return G2

def clean_network(G1, UTM_eth, UTM_eth_str, WGS, WGS_str, wpath, output_name):

    G = G1.copy()

    # Squeezes clusters of nodes down to a single node if they are within the snapping tolerance
    G = gn.simplify_junctions(G, UTM_eth, WGS, 50)

    # ensures all streets are two-way
    print("movin' along 1 ...")
    G = gn.add_missing_reflected_edges(G)

    # Finds and deletes interstital nodes based on node degree
    print("movin' along 2 ...")
    G = gn.custom_simplify(G)

    # rectify geometry
    print("movin' along 3 ...")
    for u, v, data in G.edges(data = True):
        if type(data['Wkt']) == list:
                data['Wkt'] = gn.unbundle_geometry(data['Wkt'])

    # For some reason CustomSimplify doesn't return a MultiDiGraph. Fix that here
    print("movin' along 4 ...")
    G = gn.convert_to_MultiDiGraph(G)

    # This is the most controversial function - removes duplicated edges. This takes care of two-lane but separate highways, BUT
    # destroys internal loops within roads. Can be run with or without this line
    print("movin' along 5 ...")
    G = gn.remove_duplicate_edges(G)

    # Run this again after removing duplicated edges
    print("movin' along 6 ...")
    G = gn.custom_simplify(G)

    # Ensure all remaining edges are duplicated (two-way streets)
    print("movin' along 7 ...")
    G = gn.add_missing_reflected_edges(G)

    # Pulls out largest strongly connected component
    # TODO: Maybe better way to deal with subgraphs?
    print("movin' along 8 ...")
    G = max(nx.strongly_connected_component_subgraphs(G), key=len)

    # Salt Long Lines
    print("movin' along 9 ...")
    G = gn.salt_long_lines(G, WGS_str, UTM_eth_str, thresh = 1000, factor = 1)

    # Add time variable
    # Create speed dictionary
    s_d = {'speed_10': 10,
           'speed_15': 15,
           'speed_20': 20,
           'speed_25': 25,
           'speed_30': 30,
           'speed_35': 35,
           'speed_45': 45,
           'speed_50': 50,
           'speed_60': 60,
           'speed_70': 70,
           'speed_80': 80,
           'speed_120': 120}

    print("movin' along 10 ...")
    G_time = gn.convert_network_to_time(G,
                                       distance_tag = 'length',
                                       graph_type = 'drive',
                                       road_col = 'infra_type',
                                       speed_dict = s_d)

    # save final
    gn.save(G_time, output_name, wpath)

    return G_time


# Load OSM --------------------------------------------------------------------
# Load Roads
roads = gpd.read_file(os.path.join(project_file_path, 'Data', 'RawData', 'OpenStreetMap', 'shp_files', 'gis_osm_roads_free_1.shp'))

# Drop Minor Roads
roads_to_keep = ['trunk', 'trunk_link',
                   'primary', 'primary_link', 
                   'secondary', 'secondary_link',
                   'tertiary', 'tertiary_link',
                   'motorway', 'motorway_link']

roads_sub  = roads.loc[roads['fclass'].isin(roads_to_keep)]

# Create Speed Variable
roads_sub['speed'] = 0
roads_sub['speed'][roads_sub['fclass'].isin(['trunk','trunk_link'])] = 80
roads_sub['speed'][roads_sub['fclass'].isin(['primary','primary_link'])] = 70
roads_sub['speed'][roads_sub['fclass'].isin(['secondary','secondary_link'])] = 60
roads_sub['speed'][roads_sub['fclass'].isin(['tertiary','tertiary_link'])] = 50
roads_sub['speed'][roads_sub['fclass'].isin(['motorway','motorway_link'])] = 70

# OSM to Graph ----------------------------------------------------------------


# Define folder where graph objects should go
wpath = os.path.join(project_file_path, 'Data', 'RawData', 'road_graph_objects', 'osm')

# Load template OSM Object
template_osm_network = losm.OSM_to_network(os.path.join(project_file_path,'Data','RawData','OpenStreetMap','pbf_file', 'iraq-latest.osm.pbf'))

# Convert to Network
roads_G = shp_to_G(roads_sub, 'speed', UTM_str, template_osm_network)

# Clean Network
roads_G_clean = clean_network(roads_G, UTM, UTM_str, WGS, WGS_str, wpath, 'osm_mainroads_G_clean')



