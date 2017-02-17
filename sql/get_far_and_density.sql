--Floor area ratio = (total amount of usable floor area that a building has, zoning floor area) / (area of the plot)

--need to get square footages from the buildings table to get far
--assumed residential unit size is 1000 sq ft. see:
--https://github.com/MetropolitanTransportationCommission/bayarea_urbansim/blob/master/baus/variables.py#L786
--unclear if this includes common area. will assume that it does. 

create view UrbanSim.Building_Square_Footage as
SELECT  b.parcel_id,
		sum(b.residential_units)*1000 as estimated_residential_square_feet
  FROM  DEIR2017.UrbanSim.RUN7224_BUILDING_DATA_2040 as b
		group by b.parcel_id;

GO

create view UrbanSim.far_check AS
SELECT  b.estimated_residential_square_feet,
		Round(p.Shape.STArea()*10.7639,2) as parcel_square_feet,
		(b.estimated_residential_square_feet / Round(p.Shape.STArea()*10.7639,2)) as far_estimate,
		p.OBJECTID,
		p.COUNTY_ID,
		p.PARCEL_ID,
		p.tpa_objectid,
		p.taz_id,
		p.superd_id
  FROM  DEIR2017.UrbanSim.Building_Square_Footage as b JOIN
		DEIR2017.UrbanSim.Parcels as p ON b.parcel_id = p.parcel_id;

GO
---check how many parcels qualify
SELECT count(*) FROM [DEIR2017].[UrbanSim].[far_check]
where [far_estimate] >.75;
--result: ~150k

GO

drop view UrbanSim.far_check;

--need to add units/acre
--then group by taz_id and average

create view UrbanSim.far_check AS
SELECT  b.estimated_residential_square_feet,
		Round(p.Shape.STArea()*10.7639,2) as parcel_square_feet,
		(b.estimated_residential_square_feet / Round(p.Shape.STArea()*10.7639,2)) as far_estimate,
		p.OBJECTID,
		p.COUNTY_ID,
		p.PARCEL_ID,
		p.tpa_objectid,
		p.taz_id,
		p.superd_id
  FROM  DEIR2017.UrbanSim.Building_Square_Footage as b JOIN
		DEIR2017.UrbanSim.Parcels as p ON b.parcel_id = p.parcel_id

create view UrbanSim.Alt_4_2040_parcels_in_tpas_units_and_jobs as
SELECT
	p.parcel_id,
	Cast(2.69*y2040.total_residential_units as numeric(18,0)) as Estimated_Population, 
	Cast(y2040.total_residential_units as numeric(18,0)) as total_residential_units, 
	y2040.total_job_spaces, 
	Round(p.shape.STArea()*0.000247105381,2) as Acres,
	Cast((2.69*y2040.total_residential_units)/(p.shape.STArea()*0.000247105381) as numeric(18,2)) as People_Per_Acre,
	Cast((y2040.total_job_spaces/(p.shape.STArea()*0.000247105381)) as numeric(18,2)) as Jobs_Per_Acre
FROM            
	(SELECT * FROM UrbanSim.Parcels WHERE tpa_objectid IS NOT NULL) AS p JOIN
	UrbanSim.RUN7224_PARCEL_DATA_2040 AS y2040 ON p.PARCEL_ID = y2040.parcel_id
	--alt_4 is based on simulation run 7224
Go