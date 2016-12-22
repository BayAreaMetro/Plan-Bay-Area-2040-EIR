--select * from [UrbanSim].[COUNTY_TPAS_ALTERNATIVE_4_OVERLAY]
Go
SELECT        Distinct data.FID_Counties, data.FID_TPAs, data.FID_Alt_4, SummaryClass.Summary_Class AS SC, data.Summary_Class, 
                         SummaryClass.Summary_Class_Description AS [Desc], data.Summary_Class_Description
FROM            COUNTIES_TPAS_ALT_4_OVERLAY AS data LEFT OUTER JOIN
                         SummaryClass ON data.FID_Alt_4 = SummaryClass.FID_Alt_4 AND data.FID_TPAs = SummaryClass.FID_TPAs AND 
                         data.FID_Counties = SummaryClass.FID_Counties
Go
create view UrbanSim.SummaryClass as
SELECT DISTINCT FID_Counties, FID_TPAs, FID_Alt_4, Summary_Class, Summary_Class_Description
FROM            COUNTY_TPAS_ALTERNATIVE_4_OVERLAY
Go
select * From [COUNTIES_TPAS_ALT_4_OVERLAY]

--UPDATE       d
--SET                Summary_Class = s.Summary_Class, Summary_Class_Description = s.Summary_Class_Description
--FROM            COUNTIES_TPAS_ALT_4_OVERLAY AS d LEFT OUTER JOIN
--                         SummaryClass AS s ON d.FID_Counties = s.FID_Counties AND d.FID_TPAs = s.FID_TPAs AND d.FID_Alt_4 = s.FID_Alt_4