setlocal EnableDelayedExpansion
rem "set datatypes"
set taz_query=SELECT cast(taz_id as integer(40)) as taz_id, ^
cast(q4 as numeric(8,2)) as q4, ^
cast(q5 as numeric(8,2)) as q5, ^
cast(q6 as numeric(8,2)) as q6, ^
cast(q7 as numeric(8,2)) as q7, ^
cast(q8 as numeric(8,2)) as q8

ogr2ogr -append ^
-nln far ^
-f FileGDB ^
-sql "%taz_query% FROM taz_far_quantiles" ^
taz_far_ua_quantiles.gdb taz_far_quantiles.csv

rem "set datatypes"
set taz_query=SELECT cast(taz_id as integer(40)) as taz_id, ^
cast(q4 as numeric(8,2)) as q4, ^
cast(q5 as numeric(8,2)) as q5, ^
cast(q6 as numeric(8,2)) as q6, ^
cast(q7 as numeric(8,2)) as q7, ^
cast(q8 as numeric(8,2)) as q8

ogr2ogr -append ^
-nln ua ^
-f FileGDB ^
-sql "%taz_query% FROM taz_units_per_acre_quantiles" ^
taz_far_ua_quantiles.gdb taz_units_per_acre_quantiles.csv

rem "join to taz geometries"

ogr2ogr -append ^
-nln far_sp ^
-f FileGDB ^
-sql "select f.q4 as q4, f.q5 as q5, f.q6 as q6, f.q7 as q7, f.q8 as q8 from TAZ t join far f on t.TAZ1454 = f.taz_id" ^
taz_far_ua_quantiles.gdb taz_far_ua_quantiles.gdb

ogr2ogr -append ^
-nln ua_sp ^
-f FileGDB ^
-sql "select f.q4 as q4, f.q5 as q5, f.q6 as q6, f.q7 as q7, f.q8 as q8 from TAZ t join ua f on t.TAZ1454 = f.taz_id" ^
taz_far_ua_quantiles.gdb taz_far_ua_quantiles.gdb