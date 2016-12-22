--Build Alternative 4 Growth Footprint Tables using rules defined below:
--Select All parcels from run7224_Building_Data_2040 where year built is greater than or equal to 2016. 
--Join to parcel geometry using Parcel_id by selecting all parcels from run7224_Building_Data_2040 that are related to Parcel Geometry (Left Outer Join)
--To get the total res and jobs units, join to RUN7224_PARCEL_DATA_DIFF using Parcel_ID by selecting all parcels from Parcel Geometry that are related to RUN7224_PARCEL_DATA_DIFF
--The footprint uses a threshold of GT 8 ppl per acre or 10 jobs per acre.
--Because the alt output does not contain ppl per parcel, an average hhsize of 2.69 was used to estimate population for each parcel based upon nthe number of res. units on that parcel.
--select count(objectid) From UrbanSim.UrbanSim_Parcels
--Total Parcels (1956208)

USE [gis]
Go
Drop view UrbanSim.Alt_4_GrowthFootprint
Go
create view UrbanSim.Alt_4_GrowthFootprint as
SELECT
--Using Distinct due to duplicate parcels in the Parcel Geometry Table (11271 Parcels selected)
Distinct
Top 20000
p.OBJECTID, 
p.COUNTY_ID, 
alt_4_bldg.parcel_id, 
alt_4_bldg.year_built,
Cast(2.69*alt_4_Diff.total_residential_units as numeric(18,0)) as Estimated_Population, 
Cast(alt_4_Diff.total_residential_units as numeric(18,0)) as total_residential_units, 
alt_4_Diff.total_job_spaces, 
Round(p.shape.STArea()*0.000247105381,2) as Acres,
Cast((2.69*alt_4_Diff.total_residential_units)/(p.shape.STArea()*0.000247105381) as numeric(18,2)) as People_Per_Acre,
Cast((alt_4_Diff.total_job_spaces/(p.shape.STArea()*0.000247105381)) as numeric(18,2)) as Jobs_Per_Acre,
--Convert shape to string to remove duplicates from parcel geometry table.
p.Shape.ToString() as Features
FROM            
UrbanSim.RUN7224_PARCEL_DATA_DIFF AS alt_4_Diff INNER JOIN
UrbanSim.UrbanSim_Parcels AS p ON alt_4_Diff.parcel_id = p.PARCEL_ID RIGHT OUTER JOIN
UrbanSim.RUN7224_BUILDING_DATA_2040 AS alt_4_bldg ON p.PARCEL_ID = alt_4_bldg.parcel_id
WHERE        
(alt_4_bldg.year_built >= 2016) AND (alt_4_Diff.total_residential_units > 0) OR
(alt_4_Diff.total_job_spaces > 0)
Order By County_ID
Go
Drop View UrbanSim.Alt_4_GrowthFootprint_Features 
--Filter the growth footprint based upon the EIR Development Threshold (8 ppl/ac or 10 jobs/ac).
--Convert WKT to Geometry
--geometry::STGeomFromText(Features,26910).MakeValid() as Shape
Go
create view UrbanSim.Alt_4_GrowthFootprint_Features as
SELECT        
OBJECTID, 
COUNTY_ID, 
parcel_id, 
year_built, 
Estimated_Population, 
total_residential_units, 
total_job_spaces, 
Acres, 
People_Per_Acre, 
Jobs_Per_Acre, 
--Features
geometry::STGeomFromText(Features,26910).MakeValid() as Shape
--Drop Table UrbanSim.Alt_4_GFP_FC
--into UrbanSim.Alt_4_GFP_FC
FROM            UrbanSim.Alt_4_GrowthFootprint
WHERE        (People_Per_Acre >= 8) OR
                         (Jobs_Per_Acre >= 10)
Go
select * From UrbanSim.Alt_4_GrowthFootprint_Features


