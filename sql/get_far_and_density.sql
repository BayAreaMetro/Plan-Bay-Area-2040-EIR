--Floor area ratio = (total amount of usable floor area that a building has, zoning floor area) / (area of the plot)

--need to get square footages from the buildings table to get far
--assumed residential unit size is 1000 sq ft. see:
--https://github.com/MetropolitanTransportationCommission/bayarea_urbansim/blob/master/baus/variables.py#L786
--unclear if this includes common area. will assume that it does. 

create view UrbanSim.Parcels_Building_Square_Footage as
SELECT  b.parcel_id,
		sum(b.residential_units)*1000 as estimated_residential_square_feet
  FROM  DEIR2017.UrbanSim.RUN7224_BUILDING_DATA_2040 as b
		group by b.parcel_id;

--need to add units/acre
--then group by taz_id and average

CREATE VIEW UrbanSim.Parcels_FAR_Units_Per_Acre AS
SELECT  (CASE WHEN p.acres = 0 THEN NULL 
			ELSE pb.estimated_residential_square_feet /  
			(p.acres*43560) END) as far_estimate,
		(CASE WHEN p.acres = 0 THEN NULL 
			ELSE Y2040.total_residential_units/p.acres 
			END) as units_per_acre,
		pb.estimated_residential_square_feet as est_res_sq_ft,
		p.PARCEL_ID,
		p.tpa_objectid,
		p.taz_id,
		p.superd_id
  FROM  DEIR2017.UrbanSim.Parcels_Building_Square_Footage as pb JOIN
		DEIR2017.UrbanSim.Parcels as p ON pb.parcel_id = p.parcel_id JOIN
		UrbanSim.RUN7224_PARCEL_DATA_2040 AS y2040 ON p.PARCEL_ID = y2040.parcel_id;
GO

create view UrbanSim.Parcels_FAR_Units_Per_Acre_SP as
SELECT  pb.estimated_residential_square_feet as est_res_sq_ft,
		pb.units_per_acre,
		pb.far_estimate,
		p.OBJECTID,
		p.PARCEL_ID,
		p.tpa_objectid,
		p.taz_id,
		p.superd_id,
		pc.Centroid
  FROM  DEIR2017.UrbanSim.Parcels_FAR_Units_Per_Acre as pb
		JOIN DEIR2017.UrbanSim.Parcels as p 
			ON pb.parcel_id = p.parcel_id
		JOIN DEIR2017.UrbanSim.Parcels_Centroid_Only pc
			ON p.parcel_id = pb.parcel_id;

GO

---create non-zero view of above

CREATE VIEW UrbanSim.Parcels_FAR_Units_Per_Acre_Non_Zero AS
SELECT  far_estimate,
		units_per_acre,
		estimated_residential_square_feet,
		PARCEL_ID,
		tpa_objectid,
		taz_id,
		superd_id
  FROM  DEIR2017.UrbanSim.Parcels_FAR_Units_Per_Acre
  		WHERE units_per_acre > 0;

GO

create view UrbanSim.TAZ_CEQA_POTENTIAL as
SELECT
	taz_id,
	avg(far_estimate) as avg_far,
	count(*) as observations,
	avg(units_per_acre) as avg_units_per_acre,
	stdev(far_estimate) as stdev_far,
	stdev(units_per_acre) as stdev_units_per_acre,
	max(far_estimate) as max_far,
	max(units_per_acre) as max_units_per_acre,
	min(far_estimate) as min_far,
	min(units_per_acre) as min_units_per_acre,
	(AVG(far_estimate) + STDEV(far_estimate)*1.27) as cutoff_far_estimate,
	(AVG(units_per_acre) + STDEV(units_per_acre)*1.27) as cutoff_units_per_acre
FROM 
	UrbanSim.Parcels_FAR_Units_Per_Acre_Non_Zero
WHERE 
	tpa_objectid IS NOT NULL
GROUP BY 
	taz_id;

GO

create view UrbanSim.TAZ_CEQA_POTENTIAL_ALL_VARS as
SELECT
	t1.taz_id,
	t1.avg_far,
	t1.observations,
	t1.avg_units_per_acre,
	t1.stdev_far,
	t1.stdev_units_per_acre,
	t1.max_far,
	t1.max_units_per_acre,
	t1.min_far,
	t1.min_units_per_acre,
	t1.cutoff_far_estimate,
	t1.cutoff_units_per_acre,
	t2.shape
FROM 
	UrbanSim.TAZ_CEQA_POTENTIAL as t1 JOIN
	UrbanSim.TAZ as t2 on t1.taz_id = t2.taz1454;

GO

create view UrbanSim.TAZ_CEQA_POTENTIAL_ALL_VARS_TPA_2016_CLIP as
SELECT
	t1.taz_id,
	t1.avg_far,
	t1.observations,
	t1.avg_units_per_acre,
	t1.stdev_far,
	t1.stdev_units_per_acre,
	t1.max_far,
	t1.max_units_per_acre,
	t1.min_far,
	t1.min_units_per_acre,
	t1.cutoff_far_estimate,
	t1.cutoff_units_per_acre,
	tpa.SHAPE.STIntersection(t2.shape) AS shape
FROM  UrbanSim.TAZ_CEQA_POTENTIAL AS t1 INNER JOIN
 UrbanSim.TAZ AS t2 ON t1.taz_id = t2.taz1454 CROSS JOIN
 Transportation.TPAS_2016 AS tpa;

GO

create view UrbanSim.TAZ_CEQA_POTENTIAL_UNITS_SP as
SELECT
	t1.taz_id,
	t1.avg_far,
	t1.avg_units_per_acre,
	t2.shape
FROM 
	UrbanSim.TAZ_CEQA_POTENTIAL as t1 JOIN
	UrbanSim.TAZ as t2 on t1.taz_id = t2.taz1454
WHERE	
	t1.cutoff_units_per_acre > 20
;

GO

create view UrbanSim.TAZ_CEQA_POTENTIAL_FAR_AND_UNITS_SP as
SELECT
	t1.taz_id,
	t1.avg_far,
	t1.avg_units_per_acre,
	t2.shape
FROM 
	UrbanSim.TAZ_CEQA_POTENTIAL as t1 JOIN
	UrbanSim.TAZ as t2 on t1.taz_id = t2.taz1454
WHERE 
	t1.cutoff_units_per_acre > 20
	AND t1.cutoff_far_estimate> 0.75;

GO

SELECT q1.* INTO UrbanSim.TAZ_CEQA_POTENTIAL_SP_CLIP FROM (
SELECT
	cqtaz.taz_id as taz_id,
	tpa.shape.STIntersection(cqtaz.shape) as shape
FROM 
	UrbanSim.TAZ_CEQA_POTENTIAL_SP as cqtaz,
	Transportation.TPAS_2016 as tpa) q1;

GO

SELECT q2.* INTO UrbanSim.TAZ_CEQA_POTENTIAL_FAR_SP_CLIP FROM (
SELECT
	cqtaz.taz_id as taz_id,
	tpa.shape.STIntersection(cqtaz.shape) as shape
FROM 
	UrbanSim.TAZ_CEQA_POTENTIAL_FAR_SP as cqtaz,
	Transportation.TPAS_2016 as tpa) q2;

