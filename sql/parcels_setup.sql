---this is a scratch space for all
---queries used to modify and set up
---various infrastructure for parcel data
---on a vanilla parcel table 
---with no indexes, centroids, acres, etc

ALTER TABLE UrbanSim.Parcels ADD acres NUMERIC(15,2) NULL;  

GO
UPDATE
    t1
SET
    t1.acres = Round(t1.shape.STArea()*0.000247105381,2)
FROM
    UrbanSim.Parcels AS t1;

GO

-------------------
-------Put TPA's on 
-------all parcels
-------------------

--we need to know the TPA for every parcel
--So, first we need to assign a TPA value to each parcel

--the UrbanSim.parcels table doesn't have any indexes, 
--so in the interest of expediency, we use an existing parcels
--table that has indexes from the Analysis schema
---we can always come back and setup the UrbanSim.Parcels table later

SELECT q1.* INTO UrbanSim.Parcels_Centroid_Only FROM (
SELECT p1.parcel_id as parcel_id, 
p1.Shape.STCentroid() as Centroid
FROM Analysis.p09_01_2015_parcel_shareable as p1) q1

GO
---
ALTER TABLE UrbanSim.Parcels_Centroid_Only ALTER COLUMN parcel_id INTEGER NOT NULL
--
ALTER TABLE UrbanSim.Parcels_Centroid_Only ADD CONSTRAINT parcel_id_pk
 PRIMARY KEY CLUSTERED (parcel_id);

GO
--Get the required bounding box for the spatial index below
--from https://alastaira.wordpress.com/2011/07/26/determining-the-geographic-extent-of-spatial-features-in-a-sql-server-table/
SELECT
  geometry::EnvelopeAggregate(Shape).STPointN(1).STX AS MinX,
  geometry::EnvelopeAggregate(Shape).STPointN(1).STY AS MinY,
  geometry::EnvelopeAggregate(Shape).STPointN(3).STX AS MaxX,
  geometry::EnvelopeAggregate(Shape).STPointN(3).STY AS MaxY
FROM Analysis.p09_01_2015_parcel_shareable;

GO
--result: 453705.104767737	4083961.21954119		

--xmin=0, ymin=0, xmax=500, ymax=200
CREATE SPATIAL INDEX SIndx_Parcels_Centroid_Only_Centroid_idx   
   ON UrbanSim.Parcels_Centroid_Only(Centroid)  
   WITH ( BOUNDING_BOX = ( 453705.104767737, 4083961.21954119, 659289.046884376, 4301890.14477043 ) );  
GO
ALTER TABLE UrbanSim.Parcels_Centroid_Only ADD tpa_objectid INTEGER NULL;  

GO
UPDATE
    t1
SET
    t1.tpa_objectid = t2.OBJECTID
FROM
    UrbanSim.Parcels_Centroid_Only AS t1
INNER JOIN
	Transportation.TPAS_2016 AS t2
ON 
	t1.Centroid.STWithin(t2.SHAPE) = 1;
GO

GO
--result: 453705.104767737	4083961.21954119		

--it will be cleaner in the future to just set up the parcels table
--as the main one with all the variables, 
--so might as well do so

CREATE INDEX parcel_id_idx ON UrbanSim.Parcels (parcel_id); 

ALTER TABLE UrbanSim.Parcels ADD CONSTRAINT parcels_objectid_idx
 PRIMARY KEY CLUSTERED (OBJECTID);

--xmin=0, ymin=0, xmax=500, ymax=200
CREATE SPATIAL INDEX SIndx_Parcels_Poly   
   ON UrbanSim.Parcels(Shape)  
   WITH ( BOUNDING_BOX = ( 453705.104767737, 4083961.21954119, 659289.046884376, 4301890.14477043 ) );  

ALTER TABLE UrbanSim.Parcels ADD tpa_objectid INTEGER NULL;  

GO
UPDATE
    t1
SET
    t1.tpa_objectid = t2.tpa_objectid
FROM
    UrbanSim.Parcels AS t1
INNER JOIN
	UrbanSim.Parcels_Centroid_Only AS t2
ON 
	t1.parcel_id = t2.parcel_id;
GO

ALTER TABLE UrbanSim.Parcels_Centroid_Only
DROP COLUMN "tpa_objectid";
