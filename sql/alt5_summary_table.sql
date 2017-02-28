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
       t.Total Total,
	   c2.In_TPAs C2_In_TPAs,
       c3.In_Growth_Footprint_and_not_in_TPA C3_In_Growth_Footprint_and_not_in_TPA,
       c4.In_Growth_Footprint_and_in_TPA C4_In_Growth_Footprint_and_in_TPA
FROM 
	(SELECT  CountyName,
		Cast(Sum(Acres) as numeric(18,0)) as Total 
		FROM UrbanSim.Counties_TPAs_Alt_5_Overlay_DataSummary t
		Group By t.CountyName) t
LEFT JOIN 
	(   select CountyName,
		Cast(Sum(Acres) as numeric(18,0)) as In_TPAs
		From UrbanSim.Counties_TPAs_Alt_5_Overlay_DataSummary 
		Where Summary_Class = 'Class_2' 
		Group By CountyName 
	) c2 ON t.CountyName = c2.CountyName
LEFT JOIN 
	(   select CountyName,
		Cast(Sum(Acres) as numeric(18,0)) as In_Growth_Footprint_and_not_in_TPA
		From UrbanSim.Counties_TPAs_Alt_5_Overlay_DataSummary 
		Where Summary_Class = 'Class_3' 
		Group By CountyName 
	) c3 ON t.CountyName = c3.CountyName
LEFT JOIN 
	(   select CountyName, 
		Cast(Sum(Acres) as numeric(18,0)) as In_Growth_Footprint_and_in_TPA
		From UrbanSim.Counties_TPAs_Alt_5_Overlay_DataSummary 
		Where Summary_Class = 'Class_4' 
		Group By CountyName
	) c4 
  ON t.CountyName = c4.CountyName 
Order By CountyName; 
