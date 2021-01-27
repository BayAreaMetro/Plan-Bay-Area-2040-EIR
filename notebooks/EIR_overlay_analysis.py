"""
Gets county project footprint overlays based on the
[Data inventory](https://mtcdrive.app.box.com/file/701734740559?s=43jc8eapmgh4jynd0hcwmkyu9cewfkpk)  # noqa

Run with python EIR_overlay_analysis.py

"""

from EIR_utils import *

overlay_output_dir = 'overlay_outputs'


def load_overlay_file(fname, layer):
    """
    Given a desired overlay filename and layer, returns the
    overlay as a GeoDataFrame projected to EPSG:32610
    """
    df = gpd.read_file(fname,
                         layer=layer,
                         driver='FileGDB')
    df = df.to_crs('EPSG:32610')
    return df


def load_data_inventory():
    data_inventory = pd.read_excel(os.path.join(dirname,
                                            'PBA 2050 DEIR Data Inventory.xlsx')
                              )
    data_inventory = data_inventory.rename(columns={'Layer Name': 'layer'})
    data_inventory.columns.values[2] = 'layer_name'
    return data_inventory


def load_inventory_row(layer, data_inventory):
    """
    Given an overlay layer name, loads the relevant processing
    info from the data inventory


    The GDB Location field was updated through manual inspection
    of these files:

    gdbname1 = os.path.join(dirname, 'pba2050_eirFeatureData1.gdb')
    # layers = fiona.listlayers(gdbname1)
    gdbname2 = os.path.join(dirname, 'pba2050_eirFeatureData2.gdb')
    # layers = fiona.listlayers(gdbname2)

    """
    q = 'layer_name == @layer'
    row = data_inventory[data_inventory.eval(q, engine='python')]
    # FileGDB location
    try:
        gdb_loc = int(row['FGDB Location'].iloc[0])
    except:
        print('Update the data inventory to specify the FileGDB location')
        return
    fname = os.path.join(dirname, 'pba2050_eirFeatureData{}.gdb'.format(gdb_loc))
    # output field name
    output_colname = row['PBA50 Output Fieldname'].iloc[0]
    return fname, output_colname


def get_habitat_layers(data_inventory):
    q = "layer.str.startswith('Critical Habitat', na=False)"
    habitat_layers = (data_inventory[data_inventory.eval(q, engine='python')]
                      ['layer_name'].unique())
    # write_lines(habitat_layers, 'EIR_habitat_layers.txt')
    return habitat_layers


def get_acreage_layers(data_inventory):
    """
    Returns a list of layer names for which we will do an
    overlay acreage analysis
    """
    habitat_layers = get_habitat_layers(data_inventory)
    is_ready = '~`GDB Location`.isnull()'
    not_habitat = '~layer_name.isin(@habitat_layers)'
    is_acreage = "`PBA50 Analysis Criteria` == 'Acres of Overlap'"

    q_list = [is_ready,
              not_habitat,
              is_acreage]

    q = ' & '.join(['({})'.format(query) for query in q_list])

    acreage_layers = (data_inventory[data_inventory.eval(q, engine='python')]
                      ['layer_name'].unique())
    return acreage_layers


def get_output_template(project_footprint):
    county_df = (project_footprint[['countyname']]
        .drop_duplicates()
        .copy())
    return county_df


def combine_williamson_dfs(fname, layer):
    if 'williamson' not in layer:
        return
    williamson_layers = layer.split()
    df_list = []
    for l in williamson_layers:
        df_list.append(load_overlay_file(fname, l))
    williamson_df = pd.concat(df_list,
                              ignore_index=True,
                              sort=False)
    # print(len(williamson_df))  # 12043
    return williamson_df


def get_overlay_acreage(project_footprint, layer,
                        output_colname=None, dump_results=True):
    """
    Given a project footprint (split by county) and an overlay layer,
    returns a dictionary of county to overlay acreage
    """
    data_inventory = load_data_inventory()
    fname, colname = load_inventory_row(layer, data_inventory)
    
    if output_colname is None:
        output_colname = colname

    final_fname = os.path.join(overlay_output_dir,
                               '{}.json'.format(output_colname))
    if os.path.exists(final_fname):
        print('already calculated {}'.format(output_colname))
        final_d = load_json(final_fname)
        return final_d
    else:
        print('Caculating {}'.format(colname))

    if 'williamson' not in layer:
        if colname == 'usgs_landslide_acres':
            layer = layer.split()[-1]  # existing landslide poly
        df = load_overlay_file(fname, layer)
    else:
        df = combine_williamson_dfs(fname, layer)

    joined = gpd.overlay(project_footprint,
                         df,
                         how='intersection')

    joined['acres'] = joined['geometry'].area * acres_per_m

    groupby_cols = ['countyname']
    agg_d = {'acres': 'sum'}
    rename_d = {'acres': output_colname}

    final = (joined
             .groupby(groupby_cols, as_index=False)
             .agg(agg_d)
             .rename(columns=rename_d)
            )
    final_d = dict(zip(final['countyname'], final[output_colname]))
    if dump_results:
        dump_json(final_d, final_fname)
    return final_d


def get_all_overlay_acreages(project_footprint, final_d):
    data_inventory = load_data_inventory()
    acreage_layers = get_acreage_layers(data_inventory)
    for layer in acreage_layers:
        fname, colname = load_inventory_row(layer, data_inventory)
        final_d[colname] = get_overlay_acreage(project_footprint, layer)


def num_airports(project_footprint, final_d):
    """
    Airports: Within 2-mile proximity
    """
    layer = 'cdot_mtc_airport_boundaries_2015'
    data_inventory = load_data_inventory()
    fname, colname = load_inventory_row(layer, data_inventory)

    final_fname = os.path.join(overlay_output_dir,
                               '{}.json'.format(colname))
    if os.path.exists(final_fname):
        print('already calculated {}'.format(colname))
        habitat_d = load_json(final_fname)
        final_d[colname] = habitat_d
        return
    else:
        print('Caculating {}'.format(colname))

    df = load_overlay_file(fname, layer)

    m_in_2mi = 3218.69

    proj_buff = project_footprint.copy()
    proj_buff['geom_buff'] = proj_buff['geometry'].buffer(m_in_2mi)
    proj_buff = gpd.sjoin(proj_buff.set_geometry('geom_buff'),
                         df,
                         how='left')

    groupby_cols = ['countyname']
    agg_d = {'index_right': 'nunique'}
    rename_d = {'index_right': colname}

    final = (proj_buff
             .groupby(groupby_cols, as_index=False)
             .agg(agg_d)
             .rename(columns=rename_d)
            )

    airport_d = dict(zip(final['countyname'], final[colname]))
    dump_json(airport_d, final_fname)
    final_d[colname] = airport_d


def critical_habitat(project_footprint, final_d):
    """
    Critical Habitat: Number of species intersected
    """
    data_inventory = load_data_inventory()
    habitat_layers = get_habitat_layers(data_inventory)
    layer = habitat_layers[0]  # just grab one
    fname, colname = load_inventory_row(layer, data_inventory)

    final_fname = os.path.join(overlay_output_dir,
                               '{}.json'.format(colname))
    if os.path.exists(final_fname):
        print('already calculated {}'.format(colname))
        habitat_d = load_json(final_fname)
        final_d[colname] = habitat_d
        return
    else:
        print('Caculating {}'.format(colname))

    habitat_d = {}
    for idx, layer in enumerate(habitat_layers):
        cname = 'habitat_{}'.format(idx)
        try:
            habitat_d[layer] = get_overlay_acreage(project_footprint,
                                                   layer,
                                                   output_colname=cname,
                                                   dump_results=False)
        except:
            # usfws_fch_branchinecta_lynchii_20060210 data not included
            print('{} data not included'.format(layer))
            habitat_d[layer] = {}

    # map habitat areas to county df
    final_df = get_output_template(project_footprint)
    for idx, k in enumerate(habitat_d):
        final_df['habitat_{}'.format(idx)] = final_df['countyname'].map(habitat_d[k])

    # count number of species intersected per county
    habitat_cols = [c for c in final_df if c.startswith('habitat')]
    for c in habitat_cols:
        final_df[c] = (~final_df[c].isnull()) * 1

    final_df[colname] = final_df[habitat_cols].sum(axis=1)

    final = final_df.drop(habitat_cols, axis=1)

    # add to final dict
    habitat_d = dict(zip(final['countyname'], final[colname]))
    dump_json(habitat_d, final_fname)
    final_d[colname] = habitat_d


def assemble_final(project_footprint, final_d):
    """
    Assemble/write final dataframe from dictionaries
    """
    # get county base df for mapping dicts
    final_df = get_output_template(project_footprint)
    for k in final_d:
        final_df[k] = final_df['countyname'].map(final_d[k])
    final_df = final_df.sort_values(by=['countyname'])
    final_df.to_csv('SLR_overlay_analysis.csv', index=False)


def perform_overlays(project_footprint):
    final_d = {}
    # perform overlays
    print('Getting overlay acreages')
    get_all_overlay_acreages(project_footprint, final_d)
    print('Getting num airports')
    num_airports(project_footprint, final_d)
    print('Getting num species')
    critical_habitat(project_footprint, final_d)
    # write results
    assemble_final(project_footprint, final_d)


if __name__ == '__main__':
    makedirs_if_not_exists(overlay_output_dir)

    ## Load project footprint
    fname = os.path.join(dirname,
                         'Data Collection',
                         'Project Footprint',
                         'SLR Footprint',
                         'SLR-Footprint_analysis.geojson')
    slr = gpd.read_file(fname, driver='GeoJSON')
    # print(slr.crs)  # epsg:32610

    ## Prepare for analysis: split by county
    counties, water = get_counties_water()
    project_footprint = gpd.overlay(slr.drop('Acres', axis=1),
                                    counties,
                                    how='intersection')


    # Perform overlays
    perform_overlays(project_footprint)
