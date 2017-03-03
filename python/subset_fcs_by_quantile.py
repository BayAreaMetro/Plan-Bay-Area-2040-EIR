import arcpy
import os
import numpy as np
 
#data from:
#http://mtc.maps.arcgis.com/home/item.html?id=0d4c83530b9f4039a09a497b28e2a386

# Set environment settings
arcpy.env.workspace = r"C:\Data\PBA_17_TPP_CEQA_taz_far_ua_quantiles_fgdb_export\64d07c6e1e7a45a896b843bd720de9e7.gdb"
 
# Set local variables
outWorkspace = r"C:\Data\PBA_17_TPP_CEQA_taz_far_ua_quantiles_fgdb_export\64d07c6e1e7a45a896b843bd720de9e7.gdb"
 
# Use ListFeatureClasses to generate a list of shapefiles in the
#  workspace shown above.
a1 = np.arange(.4,.9,0.1)

 # Execute CopyFeatures for each input shapefile
for quantile in a1:
    # Determine the new output feature class path and name
    quantile_name = str(int(round(quantile*10)))
    outFeatureClass = os.path.join(outWorkspace, "ua_sp_q{}".format(quantile_name))
    inFeatureClass = os.path.join(outWorkspace, "ua_sp")
    arcpy.analysis.Select(inFeatureClass, \
	outFeatureClass, \
	"q{} >= 20".format(quantile_name))

for quantile in a1:
# Determine the new output feature class path and name
	quantile_name = str(int(round(quantile*10)))
	outFeatureClass = os.path.join(outWorkspace, "far_sp_q{}".format(quantile_name))
	inFeatureClass = os.path.join(outWorkspace, "far_sp")
	arcpy.analysis.Select(inFeatureClass, \
	outFeatureClass, \
	"q{} >= 0.75".format(quantile_name))