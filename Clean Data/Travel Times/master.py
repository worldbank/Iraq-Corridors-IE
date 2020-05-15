# -*- coding: utf-8 -*-
"""
Created on Thu Jun 27 14:16:22 2019

@author: WB521633
"""

# Setup -----------------------------------------------------------------------
# Setup Project Filepath
import getpass
if getpass.getuser() == 'WB521633': project_file_path = 'C:/Users/wb521633/Dropbox/World Bank/IEs/Iraq IE'
if getpass.getuser() == 'WB521633': code_file_path = 'C:/Users/wb521633/Documents/Github/Iraq-Corridors-IE/Code'

if getpass.getuser() == 'robmarty': project_file_path = '/Users/robmarty/Dropbox/World Bank/IEs/Iraq IE'
if getpass.getuser() == 'robmarty': code_file_path = '/Users/robmarty/Dropbox/World Bank/IEs/Iraq IE'

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
sys.path.append(r'' + code_file_path + '/00_general_functions/GOSTNets/GOSTNets')
import GOSTnet as gn
import LoadOSM as losm
import pyproj
from functools import partial
from scipy import spatial
import pyreadr
import functools

# Define UTMs
UTM = {'init': 'epsg:20138'}
UTM_str = 'epsg:20138'
WGS = {'init': 'epsg:4326'}
WGS_str = 'epsg:4326'