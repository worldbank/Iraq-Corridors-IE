# -*- coding: utf-8 -*-
"""
Clean Road Network using GOSTnets
"""

# Setup -----------------------------------------------------------------------
# Setup Project Filepath
import getpass
if getpass.getuser() == 'WB521633': project_file_path = 'C:/Users/wb521633/Dropbox/World Bank/IEs/Iraq IE'
if getpass.getuser() == 'robmarty': project_file_path = '/Users/robmarty/Dropbox/World Bank/IEs/Iraq IE'

# Load Packages
import geopandas as gpd
import os, sys, time
import pandas as pd
import importlib
import networkx as nx
import osmnx as ox
from shapely.ops import unary_union, linemerge, transform
from shapely.wkt import loads
from shapely.geometry import LineString, MultiLineString, Point
sys.path.append(r'' + project_file_path + '/Code/GOSTNets/GOSTNets')
import GOSTnet as gn
import LoadOSM as losm
import pyproj
from functools import partial
from scipy import spatial

# Load Graph ------------------------------------------------------------------
G_iraq = nx.read_gpickle(os.path.join(project_file_path, 'Data', 'FinalData', 'OpenStreetMap', 'graph_object', 'iraq.pickle'))

WGS = {'init': 'epsg:4326'}
UTM = {'init': 'epsg:3890'}

#gn.example_edge(G_iraq)

# Clean Network ---------------------------------------------------------------
def clean_network(G1, UTM, WGS):
    
    print('start')
    G = G1.copy()

    # Squeezes clusters of nodes down to a single node if they are within the snapping tolerance
    G = gn.simplify_junctions(G, UTM, WGS, 50)

    # ensures all streets are two-way
    print('progress 1')
    G = gn.add_missing_reflected_edges(G)

    # Finds and deletes interstital nodes based on node degree
    G = gn.custom_simplify(G)

    # rectify geometry
    for u, v, data in G.edges(data = True):
        if type(data['Wkt']) == list:
                data['Wkt'] = gn.unbundle_geometry(data['Wkt'])

    # For some reason CustomSimplify doesn't return a MultiDiGraph. Fix that here
    print('progress 2')
    G = gn.convert_to_MultiDiGraph(G)

    # This is the most controversial function - removes duplicated edges. This takes care of two-lane but separate highways, BUT
    # destroys internal loops within roads. Can be run with or without this line
    G = gn.remove_duplicate_edges(G)

    # Run this again after removing duplicated edges
    G = gn.custom_simplify(G)

    # Ensure all remaining edges are duplicated (two-way streets)
    G = gn.add_missing_reflected_edges(G)

    # Pulls out largest strongly connected component
    # TODO: Maybe better way to deal with subgraphs?
    print('progress 3')
    
    G = max(nx.strongly_connected_component_subgraphs(G), key=len)
    #D = list(nx.strongly_connected_component_subgraphs(G))
    #G = D[0]

    # Salt Long Lines
    print('progress 4')
    G = gn.salt_long_lines(G, WGS, UTM, thresh = 1000, factor = 1)

    # Conver network to time
    print('progress 5')
    G_time = gn.convert_network_to_time(G, 
                                        distance_tag = 'length',
                                        factor = 1000)

    # save final
    #gn.save(G_time, output_name, wpath)

    return G_time

G_clean = clean_network(G_iraq, UTM, WGS)
gn.save(G_clean, 'iraq_clean', os.path.join(project_file_path, 'Data', 'FinalData', 'OpenStreetMap', 'graph_object'))
















# OSM Network to Graph --------------------------------------------------------
iraq_osm = losm.OSM_to_network(os.path.join(project_file_path, 'Data', 'RawData', 'OpenStreetMap', 'pbf_file', 'iraq-latest.osm.pbf'))

# Subset road types
accepted_road_types = ['residential', 'unclassified', 'track','service','tertiary','road','secondary','primary','trunk','primary_link','trunk_link','tertiary_link','secondary_link']
iraq_osm.filterRoads(acceptedRoads = accepted_road_types)

# Convert to graph object
iraq_osm.generateRoadsGDF(verbose = False)
iraq_osm.initialReadIn()
gn.save(iraq_osm.network,'iraq',os.path.join(project_file_path, 'Data', 'FinalData', 'OpenStreetMap', 'graph_object'))

