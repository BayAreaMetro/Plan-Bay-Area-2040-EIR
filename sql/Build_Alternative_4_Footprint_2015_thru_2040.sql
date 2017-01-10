
#Build All Scenario Growth Footprint Tables using rules defined below:
#Select parcels where year built is greater than or equal to 2016. 
#Join to parcel geometry using parcel_id in parcel_shareable_09_01_2016 https://github.com/MetropolitanTransportationCommission/bayarea_urbansim#parcel-geometries
#To get the total res and jobs units, join to parcel_output.csv files from urbansim
#The footprint uses a threshold of greatet than 8 ppl per acre or 10 jobs per acre.
#Because the urbansim output does not contain ppl per parcel, an average hhsize of 2.69 was used to estimate population for each parcel based upon nthe number of res. units on that parcel.
--Because the alt output does not contain ppl per parcel, an average hhsize of 2.69 was used to estimate population for each parcel based upon nthe number of res. units on that parcel.
--select count(objectid) From UrbanSim.UrbanSim_Parcels
--Total Parcels (1956208)
Create View Analysis.run10_parcel_output_spatial as
SELECT  Analysis.p09_01_2015_parcel_shareable.COUNTY_ID as county_id, 
		Analysis.run10_parcel_output.parcel_id as parcel_id, 
		cast(Analysis.run10_parcel_output.year_built as integer) as year_built,
		cast(Analysis.run10_parcel_output.job_spaces as integer) as job_spaces,
		cast(Analysis.run10_parcel_output.total_residential_units as integer) as total_residential_units,
		Analysis.p09_01_2015_parcel_shareable.Shape as Shape
FROM Analysis.run10_parcel_output
LEFT JOIN Analysis.p09_01_2015_parcel_shareable
ON Analysis.p09_01_2015_parcel_shareable.parcel_id = Analysis.run10_parcel_output.parcel_id
WHERE cast(Analysis.run10_parcel_output.year_built AS integer)>2015

/*Cast(2.69*alt_4_Diff.total_residential_units as numeric(18,0)) as Estimated_Population, 
Cast(alt_4_Diff.total_residential_units as numeric(18,0)) as total_residential_units, 
alt_4_Diff.total_job_spaces, 
Round(p.shape.STArea()*0.000247105381,2) as Acres,
Cast((2.69*alt_4_Diff.total_residential_units)/(p.shape.STArea()*0.000247105381) as numeric(18,2)) as People_Per_Acre,
Cast((alt_4_Diff.total_job_spaces/(p.shape.STArea()*0.000247105381)) as numeric(18,2)) as Jobs_Per_Acre,
WHERE        (People_Per_Acre >= 8) OR
                         (Jobs_Per_Acre >= 10)


