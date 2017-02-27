create view UrbanSim.Counties_TPAs_Alt_5_Overlay_DataSummary as 
SELECT 
COUNTYNAME, 
Summary_Class, 
Summary_Class_Description, 
Shape.STArea()*0.000247105 as Acres,
 Shape 
 FROM 
COUNTIES_TPAS_ALT_5_OVERLAY;

Go 
--Calc the following 
--regional total acres 
SELECT t.CountyName, 
       t.Total_Acres Total_Acres,
       c3.Total_Acres_Class_3 Class_3_Acres,
       c4.Total_Acres_Class_4 Class_4_Acres
FROM 
	(SELECT  CountyName,
		Cast(Sum(Acres) as numeric(18,0)) as Total_Acres 
		FROM UrbanSim.Counties_TPAs_Alt_5_Overlay_DataSummary t
		Group By t.CountyName) t
JOIN 
	(   select CountyName,
		Cast(Sum(Acres) as numeric(18,0)) as Total_Acres_Class_3 
		From UrbanSim.Counties_TPAs_Alt_5_Overlay_DataSummary 
		Where Summary_Class = 'Class_3' 
		Group By CountyName 
	) c3 ON t.CountyName = c3.CountyName
JOIN 
	(   select CountyName, 
		Cast(Sum(Acres) as numeric(18,0)) as Total_Acres_Class_4 
		From UrbanSim.Counties_TPAs_Alt_5_Overlay_DataSummary 
		Where Summary_Class = 'Class_4' 
		Group By CountyName
	) c4 
  ON t.CountyName = c4.CountyName 
Order By CountyName; 
