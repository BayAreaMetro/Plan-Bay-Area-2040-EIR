create view UrbanSim.Counties_TPAs_Alt_3_Overlay_DataSummary as 
SELECT 
COUNTYNAME, 
Summary_Class, 
Summary_Class_Description, 
Shape.STArea()*0.000247105 as Acres,
 Shape 
 FROM 
COUNTIES_TPAS_ALT_3_OVERLAY;

Go 
--Calc the following 
--regional total acres 
select 
CountyName, 
Cast(Sum(Acres) as numeric(18,0)) as Total_Acres 
From UrbanSim.Counties_TPAs_Alt_3_Overlay_DataSummary 
Group By CountyName 
Order By CountyName select CountyName, 
Cast(Sum(Acres) as numeric(18,0)) as Total_Acres_Class_3 
From UrbanSim.Counties_TPAs_Alt_3_Overlay_DataSummary 
Where Summary_Class = 'Class_3' 
Group By CountyName 
Order By CountyName; 

GO

select CountyName, 
Cast(Sum(Acres) as numeric(18,0)) as Total_Acres_Class_4 
From UrbanSim.Counties_TPAs_Alt_3_Overlay_DataSummary 
Where Summary_Class = 'Class_4' 
Group By CountyName 
Order By CountyName; 