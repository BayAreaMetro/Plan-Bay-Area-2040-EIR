--Floor area ratio = (total amount of usable floor area that a building has, zoning floor area) / (area of the plot)

--need to get square footages from the buildings table to get far
--assumed residential unit size is 1000 sq ft. see:
--https://github.com/MetropolitanTransportationCommission/bayarea_urbansim/blob/master/baus/variables.py#L786
--unclear if this includes common area. will assume that it does. 

create view UrbanSim.Parcel_Usage_Square_Footage as
SELECT  b.parcel_id,
		sum(b.non_residential_sqft) as sum_non_residential_sqft,
		sum(b.residential_units) as sum_residential_units,
		sum(b.residential_units)*1000 as estimated_residential_square_feet
  FROM  DEIR2017.UrbanSim.RUN7224_BUILDING_DATA_2040 as b
		group by b.parcel_id;

create view UrbanSim.Building_Square_Footage as
SELECT  b.parcel_id,
		(CASE WHEN sum(b.non_residential_sqft) = 0 AND sum(b.residential_units) > 0
			THEN 1
			ELSE sum(b.residential_units)*1000/sum(b.non_residential_sqft) END)
			as residential_commercial_ratio,
		sum(b.residential_units)*1000 as estimated_residential_square_feet
  FROM  DEIR2017.UrbanSim.RUN7224_BUILDING_DATA_2040 as b
		group by b.parcel_id;

GO

alter view UrbanSim.Parcel_Mixed_Use AS
select  parcel_id,
		sum_non_residential_sqft,
		sum_residential_units,
		estimated_residential_square_feet,
		(estimated_residential_square_feet/(estimated_residential_square_feet+sum_non_residential_sqft))
			as sqft_residential_over_total
FROM UrbanSim.Parcel_Usage_Square_Footage
WHERE estimated_residential_square_feet > 0
AND sum_non_residential_sqft > 0;

GO

alter view UrbanSim.Parcel_Usage_Mix_Summary AS
select  t1.parcel_id,
		t1.sum_non_residential_sqft,
		t1.sum_residential_units,
		t1.estimated_residential_square_feet,
		(CASE 
			WHEN t2.sqft_residential_over_total IS NOT NULL
				THEN t2.sqft_residential_over_total 
			ELSE
				CASE WHEN t1.estimated_residential_square_feet > 0
					THEN 1
				ELSE 0 END
			END) as residential_mix
FROM UrbanSim.Parcel_Usage_Square_Footage as t1 LEFT JOIN
UrbanSim.Parcel_Mixed_Use t2 on t1.parcel_id = t2.parcel_id;

GO

CREATE VIEW UrbanSim.TAZ_CEQA_Staging AS
SELECT  p.taz_id,
		sum(b.sum_non_residential_sqft) as sum_non_residential_sqft,
		sum(b.estimated_residential_square_feet) as estimated_residential_square_feet,
		sum(b.sum_residential_units) as sum_residential_units,
		sum(p.acres) as acres,
		sum(b.sum_residential_units)/sum(p.acres) as units_per_acre
  FROM  DEIR2017.UrbanSim.Parcel_Usage_Mix_Summary as b JOIN
		DEIR2017.UrbanSim.Parcels as p ON b.parcel_id = p.parcel_id JOIN
		UrbanSim.RUN7224_PARCEL_DATA_2040 AS y2040 ON p.PARCEL_ID = y2040.parcel_id
		where p.tpa_objectid IS NOT NULL
		AND b.residential_mix > 0.25
		group by p.taz_id;




--need to add units/acre
--then group by taz_id and average

ALTER TABLE UrbanSim.Parcels ADD acres NUMERIC(15,2) NULL;  

GO
UPDATE
    t1
SET
    t1.acres = Round(t1.shape.STArea()*0.000247105381,2)
FROM
    UrbanSim.Parcels AS t1;

GO

CREATE VIEW UrbanSim.Parcels_FAR_Units_Per_Acre AS
SELECT  (CASE WHEN p.acres = 0 THEN NULL 
			ELSE b.estimated_residential_square_feet /  
			(p.acres*43560) END) as far_estimate,
		(CASE WHEN p.acres = 0 THEN NULL 
			ELSE Y2040.total_residential_units/p.acres END) as units_per_acre,
		p.PARCEL_ID,
		p.tpa_objectid,
		p.taz_id,
		p.superd_id
  FROM  DEIR2017.UrbanSim.Building_Square_Footage as b JOIN
		DEIR2017.UrbanSim.Parcels as p ON b.parcel_id = p.parcel_id JOIN
		UrbanSim.RUN7224_PARCEL_DATA_2040 AS y2040 ON p.PARCEL_ID = y2040.parcel_id;

GO

create view UrbanSim.far_check as
SELECT
	taz_id,
	avg(far_estimate) as avg_far,
	avg(units_per_acre) as avg_units_per_acre
FROM 
	UrbanSim.Parcels_FAR_Units_Per_Acre
GROUP BY 
	taz_id
WHERE 
	tpa_objectid IS NOT NULL;