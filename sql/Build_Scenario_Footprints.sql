--Build All Scenario Growth Footprint Tables using rules defined below:
--Select parcels where year built is greater than or equal to 2016. 
--Join to parcel geometry using parcel_id in parcel_shareable_09_01_2016 https://github.com/MetropolitanTransportationCommission/bayarea_urbansim#parcel-geometries
--To get the total res and jobs units, join to parcel_output.csv files from urbansim
--The footprint uses a threshold of greatet than 8 ppl per acre or 10 jobs per acre.
--Because the urbansim output does not contain ppl per parcel, an average hhsize of 2.69 was used to estimate population for each parcel based upon nthe number of res. units on that parcel.
--Because the alt output does not contain ppl per parcel, an average hhsize of 2.69 was used to estimate population for each parcel based upon nthe number of res. units on that parcel.
--select count(objectid) From UrbanSim.UrbanSim_Parcels
--Total Parcels (1956208)
Create View UrbanSim.run10_parcel_output_spatial as
SELECT  p.COUNTY_ID as county_id, 
		r.parcel_id as parcel_id, 
		r.year_built as year_built,
		r.job_spaces as job_spaces,
		r.total_residential_units as total_residential_units,
		Round(p.shape.STArea()*0.000247105381,2) as Acres,
		Cast((2.69*r.total_residential_units)/(p.shape.STArea()*0.000247105381) as numeric(18,2)) as People_Per_Acre,
		Cast((r.job_spaces/(p.shape.STArea()*0.000247105381)) as numeric(18,2)) as Jobs_Per_Acre,
		p.Shape as Shape
FROM Analysis.run10_parcel_output as r
LEFT JOIN Analysis.p09_01_2015_parcel_shareable as p
ON p.parcel_id = r.parcel_id
WHERE r.year_built>2015;

GO

CREATE VIEW UrbanSim.run17_parcel_output_spatial AS
SELECT  p.COUNTY_ID as county_id, 
		r.parcel_id as parcel_id, 
		r.year_built as year_built,
		r.job_spaces as job_spaces,
		r.total_residential_units as total_residential_units,
		Round(p.shape.STArea()*0.000247105381,2) as Acres,
		Cast((2.69*r.total_residential_units)/(p.shape.STArea()*0.000247105381) as numeric(18,2)) as People_Per_Acre,
		Cast((r.job_spaces/(p.shape.STArea()*0.000247105381)) as numeric(18,2)) as Jobs_Per_Acre,
		p.Shape as Shape
FROM Analysis.run17_parcel_output as r
left join Analysis.p09_01_2015_parcel_shareable as p
on p.parcel_id = r.parcel_id
WHERE r.year_built>2015;

GO

CREATE VIEW UrbanSim.run11_parcel_output_spatial AS
SELECT  p.COUNTY_ID as county_id, 
		r.parcel_id as parcel_id, 
		r.year_built as year_built,
		r.job_spaces as job_spaces,
		r.total_residential_units as total_residential_units,
		Round(p.shape.STArea()*0.000247105381,2) as Acres,
		Cast((2.69*r.total_residential_units)/(p.shape.STArea()*0.000247105381) as numeric(18,2)) as People_Per_Acre,
		Cast((r.job_spaces/(p.shape.STArea()*0.000247105381)) as numeric(18,2)) as Jobs_Per_Acre,
		p.Shape as Shape
FROM Analysis.run11_parcel_output as r
left join Analysis.p09_01_2015_parcel_shareable as p
on p.parcel_id = r.parcel_id
WHERE r.year_built>2015;

GO 

CREATE VIEW UrbanSim.run12_parcel_output_spatial AS
SELECT  p.COUNTY_ID as county_id, 
		r.parcel_id as parcel_id, 
		r.year_built as year_built,
		r.job_spaces as job_spaces,
		r.total_residential_units as total_residential_units,
		Round(p.shape.STArea()*0.000247105381,2) as Acres,
		Cast((2.69*r.total_residential_units)/(p.shape.STArea()*0.000247105381) as numeric(18,2)) as People_Per_Acre,
		Cast((r.job_spaces/(p.shape.STArea()*0.000247105381)) as numeric(18,2)) as Jobs_Per_Acre,
		p.Shape as Shape
FROM Analysis.run12_parcel_output as r
left join Analysis.p09_01_2015_parcel_shareable as p
on p.parcel_id = r.parcel_id
WHERE r.year_built>2015;

GO 

CREATE VIEW UrbanSim.run7224_parcel_output_spatial AS
SELECT  p.COUNTY_ID as county_id, 
		r.parcel_id as parcel_id, 
		r.year_built as year_built,
		r.job_spaces as job_spaces,
		r.total_residential_units as total_residential_units,
		Round(p.shape.STArea()*0.000247105381,2) as Acres,
		Cast((2.69*r.total_residential_units)/(p.shape.STArea()*0.000247105381) as numeric(18,2)) as People_Per_Acre,
		Cast((r.job_spaces/(p.shape.STArea()*0.000247105381)) as numeric(18,2)) as Jobs_Per_Acre,
		p.Shape as Shape
FROM Analysis.run7224_parcel_output as r
left join Analysis.p09_01_2015_parcel_shareable as p
on p.parcel_id = r.parcel_id
WHERE r.year_built>2015;

/*Cast(2.69*alt_4_Diff.total_residential_units as numeric(18,0)) as Estimated_Population, 
Round(p.shape.STArea()*0.000247105381,2) as Acres,
Cast((2.69*alt_4_Diff.total_residential_units)/(p.shape.STArea()*0.000247105381) as numeric(18,2)) as People_Per_Acre,
Cast((alt_4_Diff.total_job_spaces/(p.shape.STArea()*0.000247105381)) as numeric(18,2)) as Jobs_Per_Acre,
WHERE        (People_Per_Acre >= 8) OR
                         (Jobs_Per_Acre >= 10)


