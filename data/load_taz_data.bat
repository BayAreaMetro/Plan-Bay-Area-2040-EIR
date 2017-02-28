setlocal EnableDelayedExpansion
rem "taz runs"
set taz_runs=run10_taz_summaries_2015 run11_taz_summaries_2015 ^
run12_taz_summaries_2015 run17_taz_summaries_2015 run7224c_taz_summaries_2015 ^
run10_taz_summaries_2040 run11_taz_summaries_2040 ^
run12_taz_summaries_2040 run17_taz_summaries_2040 run7224c_taz_summaries_2040
rem "parcel_output query"
set taz_query=SELECT cast(zone_id as integer(40)) as zone_id ^
,cast(SD as integer(40)) as SD ^
,cast(ZONE as integer(40)) as ZONE ^
,cast(COUNTY as integer(40)) as COUNTY ^
,cast(TOTEMP as integer(40)) as TOTEMP ^
,cast(TOTHH as integer(40)) as TOTHH ^
,cast(TOTACRE as integer(40)) as TOTACRE ^
,cast(TOTPOP as integer(40)) as TOTPOP ^
,cast(EMPRES as integer(40)) as EMPRES

(for %%a in (%taz_runs%) do ( 
   ogr2ogr -append ^
   -nln %%a_slct ^
   -f FileGDB ^
   -sql "%taz_query% FROM %%a" taz_tpa_summary.gdb %%a.csv
))
