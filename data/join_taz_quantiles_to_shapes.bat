rem ogr2ogr -f "ESRI Shapefile" merged.shp outdir -sql 

ogr2ogr -append ^
-nln far_sp ^
-f FileGDB ^
-sql "select f.* from TAZ t join far f on t.TAZ1454 = f.taz_id" ^
taz_far_ua_quantiles.gdb taz_far_ua_quantiles.gdb

ogr2ogr -append ^
-nln ua_sp ^
-f FileGDB ^
-sql "select f.* from TAZ t join ua f on t.TAZ1454 = f.taz_id" ^
taz_far_ua_quantiles.gdb taz_far_ua_quantiles.gdb
