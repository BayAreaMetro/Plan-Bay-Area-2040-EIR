# Import standard utils
import sys
import getpass
user = getpass.getuser()
sys.path.insert(0, '/Users/{}/Documents/GitHub/EIR/notebooks'.format(user))
from utils_io import *

import fiona
import geopandas as gpd
# import pyproj
# pyproj.Proj("+init=epsg:4326")

acres_per_m = 0.000247105
dirname = os.path.join('/Users',
                        user,
                        'Box',
                        # 'DataViz Projects',
                        # 'Data Analysis and Visualization',
                        'Plan Bay Area 2050 - EIR Analysis and Data')


def get_counties_water():
    fname = os.path.join(dirname,
                         'Analyses',
                         'Growth Footprint Summary',
                         'data',
                         'PBA50_EIR_Datasets.gdb')

    # layers = fiona.listlayers(fname)
    # print(layers)

    counties_wtr = gpd.read_file(fname,
                                 driver='FileGDB',
                                 layer='bay_area_counties_sc_wtr')
    # print(len(counties_wtr))  # 1952
    counties_wtr = counties_wtr.to_crs('EPSG:32610')

    # #### Split into land and water

    # ensure that we're not missing anything by splitting into land and water
    q = '(land != 1) & (water != 1)'
    assert(len(counties_wtr[counties_wtr.eval(q, engine='python')]) == 0)

    # counties
    q = 'land == 1'
    counties = counties_wtr[counties_wtr.eval(q, engine='python')]
    # print(len(counties))  # 9

    # water
    q = 'water == 1'
    water = counties_wtr[counties_wtr.eval(q, engine='python')]
    # print(len(water))  # 1943

    counties = counties[['countyname', 'geometry']]
    water = water[['geometry']]

    return counties, water

