CREATE TABLE #RUN_NUMBERS
(
RUN_NUMBERS VARCHAR(128) 
)

INSERT INTO #RUN_NUMBERS
VALUES 
('10'),
('11'),
('12'),
('17'),
('7224c')

DECLARE @RUN_NUMBER as VARCHAR(128); 
DECLARE @SQL VARCHAR(MAX);
DECLARE @Cursor AS CURSOR; 

SET @Cursor = CURSOR FOR 
SELECT RUN_NUMBERS
FROM #RUN_NUMBERS; 

OPEN @Cursor 
FETCH NEXT FROM @Cursor INTO @RUN_NUMBER; 

WHILE @@FETCH_STATUS = 0 
BEGIN 
	SET @SQL = 

		' 
		CREATE VIEW UrbanSim.RUN' + @RUN_NUMBER + '_tpa_summary AS
		SELECT r15.COUNTY
		      ,SUM(r15.TOTEMP) as sum_TOTEMP_2015
		      ,SUM(r40.TOTEMP) as sum_TOTEMP_2040
		      ,SUM(r15.TOTPOP) as sum_TOTPOP_2015
		      ,SUM(r40.TOTPOP) as sum_TOTPOP_2040
		      ,SUM(r15.EMPRES) as sum_EMPRES_2015
		      ,SUM(r40.EMPRES) as sum_EMPRES_2040
		      ,SUM(r15.TOTHH) as sum_TOTHH_2015
		      ,SUM(r40.TOTHH) as sum_TOTHH_2040
		      ,SUM(r15.TOTACRE) as sum_TOTACRE_2015
		      ,SUM(r40.TOTACRE) as sum_TOTACRE_2040
		FROM UrbanSim.TAZ as taz,
		Transportation.TPAS_2016 as tpa,
		UrbanSim.RUN' + @RUN_NUMBER + '_TAZ_SUMMARIES_2015_SLCT as r15,
		UrbanSim.RUN' + @RUN_NUMBER + '_TAZ_SUMMARIES_2040_SLCT as r40
		WHERE r15.zone_id = taz.taz1454 and
		r40.zone_id = taz.taz1454 and
		tpa.SHAPE.STIntersects(taz.shape) = 1
		GROUP BY r15.COUNTY;
		'

		EXEC(@SQL) 

		PRINT 'Fished creating summary view for ' +@RUN_NUMBER  
		FETCH NEXT FROM @Cursor INTO @RUN_NUMBER; 
END 

CLOSE @Cursor; 
DEALLOCATE @Cursor; 

DROP TABLE #TomTom_TableNames
PRINT 'Dropped temporary table' 


