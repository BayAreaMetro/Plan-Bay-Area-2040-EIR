setlocal EnableDelayedExpansion
rem "set datatypes"
set taz_query=SELECT cast(taz_id as integer(40)) as taz_id, ^
cast(q4 as numeric(8,2)) as q4, ^
cast(q4 as numeric(8,2)) as q5, ^
cast(q4 as numeric(8,2)) as q6, ^
cast(q4 as numeric(8,2)) as q7

ogr2ogr ^
-nln far ^
-f FileGDB ^
-sql "%taz_query% FROM taz_far_quantiles" ^
taz_far_ua_quantiles.gdb taz_far_quantiles.csv

rem "set datatypes"
set taz_query=SELECT cast(taz_id as integer(40)) as taz_id, ^
cast(q4 as numeric(8,2)) as q4, ^
cast(q4 as numeric(8,2)) as q5, ^
cast(q4 as numeric(8,2)) as q6, ^
cast(q4 as numeric(8,2)) as q7

ogr2ogr -append ^
-nln ua ^
-f FileGDB ^
-sql "%taz_query% FROM taz_units_per_acre_quantiles" ^
taz_far_ua_quantiles.gdb taz_units_per_acre_quantiles.csv