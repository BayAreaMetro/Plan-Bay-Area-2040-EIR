--=================================================================================================
/*
Script purpose: 
Summarize demographic data produced by UrbanSim for the following geographies:
	County
	PDA
	TPA
Utilize UrbanSim output from the following runs: 
	Run 7224 2015 (Baseline) 
	Run 7224 2040 (Plan)
	Run r10 2040 (No Project)
	Run r11 (Main Streets)
	Run r12 (Big Cities)
	Run r17 (EES) 
*/
--=================================================================================================

--=================================================================================================
/*
Summarize demographic data for run7224 2015 (Baseline) 
	- group by county, tpa, pda
*/
--=================================================================================================
USE [DEIR2017]
GO

SELECT  
	t2.COUNTY_ID, 
	t2.tpa_objectid, 
	t2.pda_objectid, 
	sum(ISNULL(t1.hhq1, 0) + ISNULL(t1.hhq2, 0) + ISNULL(t1.hhq3, 0) + ISNULL(t1.hhq4, 0)) as Households, 
	(sum(ISNULL(t1.hhq1, 0) + ISNULL(t1.hhq2, 0) + ISNULL(t1.hhq3, 0) + ISNULL(t1.hhq4, 0))* 2.69) AS Population,
	sum(ISNULL(t1.[AGREMPN], 0) + ISNULL(t1.[MWTEMPN], 0) + ISNULL(t1.[RETEMPN], 0) + ISNULL(t1.[FPSEMPN], 0) + ISNULL(t1.[HEREMPN], 0) + ISNULL(t1.[OTHEMPN], 0)) AS Employment
FROM [dbo].[RUN7224_PARCEL_DATA_2015] AS t1 
INNER JOIN UrbanSim.Parcels AS t2 
ON t1.parcel_id = t2.PARCEL_ID
group by 
	t2.COUNTY_ID, 
	t2.tpa_objectid, 
	t2.pda_objectid
order by COUNTY_ID

--=================================================================================================
/*
Summarize demographic data for run7224 2040 (Plan) 
	- group by county, tpa, pda
*/
--=================================================================================================
USE [DEIR2017]
GO

SELECT  
	t2.COUNTY_ID, 
	t2.tpa_objectid, 
	t2.pda_objectid, 
	sum(ISNULL(t1.hhq1, 0) + ISNULL(t1.hhq2, 0) + ISNULL(t1.hhq3, 0) + ISNULL(t1.hhq4, 0)) as Households, 
	(sum(ISNULL(t1.hhq1, 0) + ISNULL(t1.hhq2, 0) + ISNULL(t1.hhq3, 0) + ISNULL(t1.hhq4, 0))* 2.69) AS Population,
	sum(ISNULL(t1.[AGREMPN], 0) + ISNULL(t1.[MWTEMPN], 0) + ISNULL(t1.[RETEMPN], 0) + ISNULL(t1.[FPSEMPN], 0) + ISNULL(t1.[HEREMPN], 0) + ISNULL(t1.[OTHEMPN], 0)) AS Employment
FROM UrbanSim.RUN7224_PARCEL_DATA_2040 AS t1 
INNER JOIN UrbanSim.Parcels AS t2 
ON t1.parcel_id = t2.PARCEL_ID
group by 
	t2.COUNTY_ID, 
	t2.tpa_objectid, 
	t2.pda_objectid
order by COUNTY_ID

--=================================================================================================
/*
Summarize demographic data for run10 2040 (No Project) 
	- group by county, tpa, pda
*/
--=================================================================================================
USE [DEIR2017]
GO

SELECT  
	t2.COUNTY_ID, 
	t2.tpa_objectid, 
	t2.pda_objectid, 
	sum(ISNULL(t1.hhq1, 0) + ISNULL(t1.hhq2, 0) + ISNULL(t1.hhq3, 0) + ISNULL(t1.hhq4, 0)) as Households, 
	(sum(ISNULL(t1.hhq1, 0) + ISNULL(t1.hhq2, 0) + ISNULL(t1.hhq3, 0) + ISNULL(t1.hhq4, 0))* 2.69) AS Population,
	sum(ISNULL(t1.[AGREMPN], 0) + ISNULL(t1.[MWTEMPN], 0) + ISNULL(t1.[RETEMPN], 0) + ISNULL(t1.[FPSEMPN], 0) + ISNULL(t1.[HEREMPN], 0) + ISNULL(t1.[OTHEMPN], 0)) AS Employment
FROM [dbo].[RUN10_PARCEL_DATA_2040] AS t1 
INNER JOIN UrbanSim.Parcels AS t2 
ON t1.parcel_id = t2.PARCEL_ID
group by 
	t2.COUNTY_ID, 
	t2.tpa_objectid, 
	t2.pda_objectid
order by COUNTY_ID

--=================================================================================================
/*
Summarize demographic data for run11 2040 (Main Streets) 
	- group by county, tpa, pda
*/
--=================================================================================================
USE [DEIR2017]
GO

SELECT  
	t2.COUNTY_ID, 
	t2.tpa_objectid, 
	t2.pda_objectid, 
	sum(ISNULL(t1.hhq1, 0) + ISNULL(t1.hhq2, 0) + ISNULL(t1.hhq3, 0) + ISNULL(t1.hhq4, 0)) as Households, 
	(sum(ISNULL(t1.hhq1, 0) + ISNULL(t1.hhq2, 0) + ISNULL(t1.hhq3, 0) + ISNULL(t1.hhq4, 0))* 2.69) AS Population,
	sum(ISNULL(t1.[AGREMPN], 0) + ISNULL(t1.[MWTEMPN], 0) + ISNULL(t1.[RETEMPN], 0) + ISNULL(t1.[FPSEMPN], 0) + ISNULL(t1.[HEREMPN], 0) + ISNULL(t1.[OTHEMPN], 0)) AS Employment
FROM [dbo].[RUN11_PARCEL_DATA_2040] AS t1 
INNER JOIN UrbanSim.Parcels AS t2 
ON t1.parcel_id = t2.PARCEL_ID
group by 
	t2.COUNTY_ID, 
	t2.tpa_objectid, 
	t2.pda_objectid
order by COUNTY_ID

--=================================================================================================
/*
Summarize demographic data for run12 2040 (Big Cities) 
	- group by county, tpa, pda
*/
--=================================================================================================
USE [DEIR2017]
GO

SELECT  
	t2.COUNTY_ID, 
	t2.tpa_objectid, 
	t2.pda_objectid, 
	sum(ISNULL(t1.hhq1, 0) + ISNULL(t1.hhq2, 0) + ISNULL(t1.hhq3, 0) + ISNULL(t1.hhq4, 0)) as Households, 
	(sum(ISNULL(t1.hhq1, 0) + ISNULL(t1.hhq2, 0) + ISNULL(t1.hhq3, 0) + ISNULL(t1.hhq4, 0))* 2.69) AS Population,
	sum(ISNULL(t1.[AGREMPN], 0) + ISNULL(t1.[MWTEMPN], 0) + ISNULL(t1.[RETEMPN], 0) + ISNULL(t1.[FPSEMPN], 0) + ISNULL(t1.[HEREMPN], 0) + ISNULL(t1.[OTHEMPN], 0)) AS Employment
FROM [dbo].[RUN12_PARCEL_DATA_2040] AS t1 
INNER JOIN UrbanSim.Parcels AS t2 
ON t1.parcel_id = t2.PARCEL_ID
group by 
	t2.COUNTY_ID, 
	t2.tpa_objectid, 
	t2.pda_objectid
order by COUNTY_ID

--=================================================================================================
/*
Summarize demographic data for run17 2040 (EEJ) 
	- group by county, tpa, pda
*/
--=================================================================================================
USE [DEIR2017]
GO

SELECT  
	t2.COUNTY_ID, 
	t2.tpa_objectid, 
	t2.pda_objectid, 
	sum(ISNULL(t1.hhq1, 0) + ISNULL(t1.hhq2, 0) + ISNULL(t1.hhq3, 0) + ISNULL(t1.hhq4, 0)) as Households, 
	(sum(ISNULL(t1.hhq1, 0) + ISNULL(t1.hhq2, 0) + ISNULL(t1.hhq3, 0) + ISNULL(t1.hhq4, 0))* 2.69) AS Population,
	sum(ISNULL(t1.[AGREMPN], 0) + ISNULL(t1.[MWTEMPN], 0) + ISNULL(t1.[RETEMPN], 0) + ISNULL(t1.[FPSEMPN], 0) + ISNULL(t1.[HEREMPN], 0) + ISNULL(t1.[OTHEMPN], 0)) AS Employment
FROM [dbo].[RUN17_PARCEL_DATA_2040] AS t1 
INNER JOIN UrbanSim.Parcels AS t2 
ON t1.parcel_id = t2.PARCEL_ID
group by 
	t2.COUNTY_ID, 
	t2.tpa_objectid, 
	t2.pda_objectid
order by COUNTY_ID

