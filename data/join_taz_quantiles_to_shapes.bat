rem ogr2ogr -f "ESRI Shapefile" merged.shp outdir -sql 

ogr2ogr -append ^
-nln urbn_ftprnt_prfrd ^
-f FileGDB ^
taz_far_quantiles.gdb urban_footprint_preferred_fmmp\urban_footprint_preferred_fmmp.shp

ogr2ogr -append ^
-nln tpas_2016_draft_aug_5 ^
-f FileGDB ^
-t_srs "EPSG:26910" ^
taz_far_quantiles.gdb "TPAs 2016 (Draft Aug 5th).shp"

rem set up the desired shapes:

rem desired outputs:
rem -taz clipped to tpa
rem -taz clipped to both

rem taz clipped to tpa
ogr2ogr -append ^
taz_far_quantiles.gdb taz_far_quantiles.gdb TAZ_26910 ^
-nln taz_clip_tpa3 ^
-f FileGDB ^
-clipsrc taz_far_quantiles.gdb -clipsrclayer tpas_2016_draft_aug_5

rem taz clipped to both tpa and uf
ogr2ogr -append ^
taz_far_quantiles.gdb taz_far_quantiles.gdb taz_clip_tpa3 ^
-nln taz_clip_tpa_and_urbn_ftprnt ^
-f FileGDB ^
-clipsrc taz_far_quantiles.gdb -clipsrclayer urbn_ftprnt_prfrd_simplified_26910

rem join the far and ua tables together
ogr2ogr -append ^
-nln far_ua_quantiles_tbl ^
-f FileGDB ^
-sql "select f.*, u.* from ua u join far f on u.taz_id = f.taz_id" ^
taz_far_quantiles.gdb taz_far_quantiles.gdb

rem join the far and ua tables together
ogr2ogr -append ^
-nln far_ua_quantiles_tbl_sp ^
-f FileGDB ^
-sql "select f.* from TAZ_26910 t join far_ua_quantiles_tbl f on t.TAZ1454 = f.f_taz_id" ^
taz_far_quantiles.gdb taz_far_quantiles.gdb

rem output the threshold taz geometries for UA
ogr2ogr -append ^
-nln temp_taz_at_ua_q8_ceqa_threshold_sp ^
-f FileGDB ^
-sql "select f.* from TAZ_26910 t join taz_at_ua_q8_ceqa_threshold f on t.TAZ1454 = f.f_taz_id" ^
taz_far_quantiles.gdb taz_far_quantiles.gdb

ogr2ogr -append ^
-nln taz_at_ua_q8_ceqa_threshold_sp ^
-f FileGDB ^
-sql "select * from temp_taz_at_ua_q8_ceqa_threshold_sp where f_u_q8 IS NOT NULL" ^
taz_far_quantiles.gdb taz_far_quantiles.gdb

rem output the table at the Units/Acre CEQA threshold for quantile (percentile) .8
ogr2ogr -append ^
-nln taz_at_ua_q8_ceqa_threshold ^
-f FileGDB ^
-sql "select f_taz_id, u_q8 from far_ua_quantiles_tbl WHERE u_q8 > 20" ^
taz_far_quantiles.gdb taz_far_quantiles.gdb

rem output the table at the Units/Acre and FAR CEQA threshold for quantile (percentile) .8
ogr2ogr -append ^
-nln taz_at_ua_and_far_q8_ceqa_threshold ^
-f FileGDB ^
-sql "select f_taz_id, u_q8, f_q8 from far_ua_quantiles_tbl WHERE u_q8 > 20 AND f_q8 > 0.75" ^
taz_far_quantiles.gdb taz_far_quantiles.gdb

rem output the threshold taz geometries (clipped to tpa and uf) for UA
ogr2ogr -append ^
-nln temp_taz_tpa_uf_at_ua_q8_ceqa_threshold ^
-f FileGDB ^
-sql "select f.* from taz_tpa_uf_geometry t join taz_at_ua_q8_ceqa_threshold f on t.TAZ1454 = f.f_taz_id" ^
taz_far_quantiles.gdb taz_far_quantiles.gdb

ogr2ogr -append ^
-nln taz_tpa_uf_at_ua_q8_ceqa_threshold ^
-f FileGDB ^
-sql "select * from temp_taz_tpa_uf_at_ua_q8_ceqa_threshold where f_u_q8 IS NOT NULL" ^
taz_far_quantiles.gdb taz_far_quantiles.gdb

rem output the threshold taz geometries (clipped to tpa and uf) for UA and FAR
ogr2ogr -append ^
-nln temp_taz_tpa_uf_at_ua_and_far_q8_ceqa_threshold_sp ^
-f FileGDB ^
-sql "select f.* from taz_tpa_uf_geometry t join taz_at_ua_and_far_q8_ceqa_threshold f on t.TAZ1454 = f.f_taz_id" ^
taz_far_quantiles.gdb taz_far_quantiles.gdb

ogr2ogr -append ^
-nln taz_tpa_uf_at_ua_and_far_q8_ceqa_threshold_sp ^
-f FileGDB ^
-sql "select * from temp_taz_tpa_uf_at_ua_and_far_q8_ceqa_threshold_sp where f_u_q8 IS NOT NULL and f_f_q8 IS NOT NULL" ^
taz_far_quantiles.gdb taz_far_quantiles.gdb

rem output the threshold taz geometries (clipped to tpa) for UA
ogr2ogr -append ^
-nln temp_taz_tpa_at_ua_q8_ceqa_threshold_sp ^
-f FileGDB ^
-sql "select f.* from taz_tpa_geometry t join taz_at_ua_q8_ceqa_threshold f on t.TAZ1454 = f.f_taz_id" ^
taz_far_quantiles.gdb taz_far_quantiles.gdb

ogr2ogr -append ^
-nln taz_tpa_at_ua_q8_ceqa_threshold_sp ^
-f FileGDB ^
-sql "select * from temp_taz_tpa_at_ua_q8_ceqa_threshold_sp where f_u_q8 IS NOT NULL" ^
taz_far_quantiles.gdb taz_far_quantiles.gdb

rem output the threshold taz geometries (clipped to tpa) for UA and FAR
ogr2ogr -append ^
-nln temp_taz_tpa_at_ua_and_far_q8_ceqa_threshold_sp ^
-f FileGDB ^
-sql "select f.* from taz_tpa_geometry t join taz_at_ua_and_far_q8_ceqa_threshold f on t.TAZ1454 = f.f_taz_id" ^
taz_far_quantiles.gdb taz_far_quantiles.gdb

ogr2ogr -append ^
-nln taz_tpa_at_ua_and_far_q8_ceqa_threshold_sp ^
-f FileGDB ^
-sql "select * from temp_taz_tpa_at_ua_and_far_q8_ceqa_threshold_sp where f_u_q8 IS NOT NULL AND f_f_q8 IS NOT NULL" ^
taz_far_quantiles.gdb taz_far_quantiles.gdb

rem output the threshold taz geometries for UA
ogr2ogr -append ^
-nln temp_taz_at_ua_q8_ceqa_threshold_sp ^
-f FileGDB ^
-sql "select f.* from TAZ_26910 t join taz_at_ua_q8_ceqa_threshold f on t.TAZ1454 = f.f_taz_id" ^
taz_far_quantiles.gdb taz_far_quantiles.gdb

ogr2ogr -append ^
-nln taz_at_ua_q8_ceqa_threshold_sp ^
-f FileGDB ^
-sql "select * from temp_taz_at_ua_q8_ceqa_threshold_sp where f_u_q8 IS NOT NULL" ^
taz_far_quantiles.gdb taz_far_quantiles.gdb

rem output the threshold taz geometries for UA and FAR
ogr2ogr -append ^
-nln temp_taz_at_ua_and_far_q8_ceqa_threshold_sp ^
-f FileGDB ^
-sql "select f.* from TAZ_26910 t join taz_at_ua_and_far_q8_ceqa_threshold f on t.TAZ1454 = f.f_taz_id" ^
taz_far_quantiles.gdb taz_far_quantiles.gdb

ogr2ogr -append ^
-nln taz_at_ua_and_far_q8_ceqa_threshold_sp ^
-f FileGDB ^
-sql "select * from temp_taz_at_ua_and_far_q8_ceqa_threshold_sp where f_u_q8 IS NOT NULL AND f_f_q8 IS NOT NULL" ^
taz_far_quantiles.gdb taz_far_quantiles.gdb

