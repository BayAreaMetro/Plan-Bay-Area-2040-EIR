/*I need the sum of Class_3 (In County and Growth Foorpint) 
and Class_4 (In County and Growth Footprint and TPA) by County for each Alternative 
(Alt 0, Alt 1, Alt 3, and Alt 5). 
I was planning on using the “…_SummaryZone” feature classes you made in the Footprint.gdb 
for me to run impacts and my question was if I should be using the existing Acres column or create my own. 
Tom mentioned that using the Acres column could potentially overestimate the acres if it is a large parcel. 
I want to be consistent with how you calculated the attached for Alt 4.*/

create view UrbanSim.Counties_TPAs_Alt_0_Overlay_DataSummary as 
SELECT 
COUNTYNAME, 
Summary_Class, 
Summary_Class_Description, 
Shape.STArea()*0.000247105 as Acres,
 Shape 
 FROM 
COUNTIES_TPAS_ALT_0_OVERLAY;

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
		FROM UrbanSim.Counties_TPAs_Alt_0_Overlay_DataSummary t
		Group By t.CountyName) t
LEFT JOIN 
	(   select CountyName,
		Cast(Sum(Acres) as numeric(18,0)) as In_TPAs
		From UrbanSim.Counties_TPAs_Alt_0_Overlay_DataSummary 
		Where Summary_Class = 'Class_2' 
		Group By CountyName 
	) c2 ON t.CountyName = c2.CountyName
LEFT JOIN 
	(   select CountyName,
		Cast(Sum(Acres) as numeric(18,0)) as In_Growth_Footprint_and_not_in_TPA
		From UrbanSim.Counties_TPAs_Alt_0_Overlay_DataSummary 
		Where Summary_Class = 'Class_3' 
		Group By CountyName 
	) c3 ON t.CountyName = c3.CountyName
LEFT JOIN 
	(   select CountyName, 
		Cast(Sum(Acres) as numeric(18,0)) as In_Growth_Footprint_and_in_TPA
		From UrbanSim.Counties_TPAs_Alt_0_Overlay_DataSummary 
		Where Summary_Class = 'Class_4' 
		Group By CountyName
	) c4 
  ON t.CountyName = c4.CountyName 
Order By CountyName; 
