--Build Alternative Growth Footprint Tables using rules defined below:
--Select All parcels from all 5 of the Building_Data_2040 tbls where year built is greater than or equal to 2016. 
--Join to parcel geometry using Parcel_id by selecting all parcels from the Building_Data_2040 tbls that are related to Parcel Geometry (Left Outer Join)
--To get the total res and jobs units, join to PARCEL_DATA_DIFF using Parcel_ID by selecting all parcels from Parcel Geometry that are related to PARCEL_DATA_DIFF
--The footprint uses a threshold of GT 8 ppl per acre or 10 jobs per acre.
--Because the alt output does not contain ppl per parcel, an average hhsize of 2.69 was used to estimate population for each parcel based upon nthe number of res. units on that parcel.
--select count(objectid) From UrbanSim.Parcels
--Total Parcels (1956208)

--Scenario Numbers
--S0 No Project: r10
--S1 Main Streets: r11
--S3 Big Three: r12
--S4 Preferred: r7224c
--S5 EEJ: r17

USE DEIR2017
Go
--Drop view UrbanSim.Alt_0_GrowthFootprint
--Drop view UrbanSim.Alt_1_GrowthFootprint
--Drop view UrbanSim.Alt_3_GrowthFootprint
--Drop view UrbanSim.Alt_4_GrowthFootprint
--Drop view UrbanSim.Alt_5_GrowthFootprint
Go
--create view UrbanSim.Alt_0_GrowthFootprint as
--create view UrbanSim.Alt_1_GrowthFootprint as
--create view UrbanSim.Alt_3_GrowthFootprint as
--create view UrbanSim.Alt_4_GrowthFootprint as
create view UrbanSim.Alt_5_GrowthFootprint as
SELECT
--Using Distinct due to duplicate parcels in the Parcel Geometry Table (11271 Parcels selected)
Distinct
Top 20000
p.OBJECTID, 
p.COUNTY_ID, 
bldg.parcel_id,--removed bldg.year_built due to duplicate multiple year built values for single parcels
--bldg.year_built,
Cast(2.69*Diff.total_residential_units as numeric(18,0)) as Estimated_Population, 
Cast(Diff.total_residential_units as numeric(18,0)) as total_residential_units, 
Diff.total_job_spaces, 
Round(p.shape.STArea()*0.000247105381,2) as Acres,
Cast((2.69*Diff.total_residential_units)/(p.shape.STArea()*0.000247105381) as numeric(18,2)) as People_Per_Acre,
Cast((Diff.total_job_spaces/(p.shape.STArea()*0.000247105381)) as numeric(18,2)) as Jobs_Per_Acre,
--Convert shape to string to remove duplicates from parcel geometry table.
p.Shape.ToString() as Features
FROM            
--Analysis.RUN10_PARCEL_DATA_DIFF_EIRSLCT AS Diff INNER JOIN
--Analysis.RUN11_PARCEL_DATA_DIFF_EIRSLCT AS Diff INNER JOIN
--Analysis.RUN12_PARCEL_DATA_DIFF_EIRSLCT AS Diff INNER JOIN
--Analysis.RUN7224_PARCEL_DATA_DIFF_EIRSLCT AS Diff INNER JOIN
Analysis.RUN17_PARCEL_DATA_DIFF_EIRSLCT AS Diff INNER JOIN
UrbanSim.Parcels AS p ON Diff.parcel_id = p.PARCEL_ID RIGHT OUTER JOIN
--UrbanSim.RUN10_BUILDING_DATA_2040 AS bldg ON p.PARCEL_ID = bldg.parcel_id
--UrbanSim.RUN11_BUILDING_DATA_2040 AS bldg ON p.PARCEL_ID = bldg.parcel_id
--UrbanSim.RUN12_BUILDING_DATA_2040 AS bldg ON p.PARCEL_ID = bldg.parcel_id
--UrbanSim.RUN7224_BUILDING_DATA_2040 AS bldg ON p.PARCEL_ID = bldg.parcel_id
UrbanSim.RUN17_BUILDING_DATA_2040 AS bldg ON p.PARCEL_ID = bldg.parcel_id
WHERE        
(bldg.year_built >= 2016) AND (Diff.total_residential_units > 0) OR
(Diff.total_job_spaces > 0)
Order By County_ID
Go
--Drop View UrbanSim.Alt_0_GrowthFootprint_Features
--Drop View UrbanSim.Alt_1_GrowthFootprint_Features
--Drop View UrbanSim.Alt_3_GrowthFootprint_Features
--Drop View UrbanSim.Alt_4_GrowthFootprint_Features
--Drop View UrbanSim.Alt_5_GrowthFootprint_Features 
--Filter the growth footprint based upon the EIR Development Threshold (8 ppl/ac or 10 jobs/ac).
--Convert WKT to Geometry
--geometry::STGeomFromText(Features,26910).MakeValid() as Shape
Go
--create view UrbanSim.Alt_0_GrowthFootprint_Features as
--create view UrbanSim.Alt_1_GrowthFootprint_Features as
--create view UrbanSim.Alt_3_GrowthFootprint_Features as
--create view UrbanSim.Alt_4_GrowthFootprint_Features as
create view UrbanSim.Alt_5_GrowthFootprint_Features as
SELECT        
OBJECTID, 
COUNTY_ID, 
parcel_id, 
--year_built, 
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
--FROM            UrbanSim.Alt_0_GrowthFootprint
--FROM            UrbanSim.Alt_1_GrowthFootprint
--FROM            UrbanSim.Alt_3_GrowthFootprint
--FROM            UrbanSim.Alt_4_GrowthFootprint
FROM            UrbanSim.Alt_5_GrowthFootprint
WHERE        (People_Per_Acre >= 8) OR
                         (Jobs_Per_Acre >= 10)
Go
--select * From UrbanSim.Alt_0_GrowthFootprint_Features
--select * From UrbanSim.Alt_1_GrowthFootprint_Features
--select * From UrbanSim.Alt_3_GrowthFootprint_Features
--select * From UrbanSim.Alt_4_GrowthFootprint_Features
select * From UrbanSim.Alt_5_GrowthFootprint_Features
