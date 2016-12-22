--select * from [UrbanSim].[COUNTY_TPAS_ALTERNATIVE_4_OVERLAY]
Go
SELECT        Distinct data.FID_Counties, data.FID_TPAs, data.FID_Alt_4, SummaryClass.Summary_Class AS SC, data.Summary_Class, 
                         SummaryClass.Summary_Class_Description AS [Desc], data.Summary_Class_Description
FROM            COUNTIES_TPAS_ALT_4_OVERLAY AS data LEFT OUTER JOIN
                         SummaryClass ON data.FID_Alt_4 = SummaryClass.FID_Alt_4 AND data.FID_TPAs = SummaryClass.FID_TPAs AND 
                         data.FID_Counties = SummaryClass.FID_Counties
Go
create view UrbanSim.SummaryClass as
SELECT DISTINCT FID_Counties, FID_TPAs, FID_Alt_4, Summary_Class, Summary_Class_Description
FROM            COUNTY_TPAS_ALTERNATIVE_4_OVERLAY
Go
select * From [COUNTIES_TPAS_ALT_4_OVERLAY]

UPDATE       d
SET                Summary_Class = s.Summary_Class, Summary_Class_Description = s.Summary_Class_Description
FROM            COUNTIES_TPAS_ALT_4_OVERLAY AS d LEFT OUTER JOIN
                         SummaryClass AS s ON d.FID_Counties = s.FID_Counties AND d.FID_TPAs = s.FID_TPAs AND d.FID_Alt_4 = s.FID_Alt_4

Update d
set Summary_Zone = CountyName + '_' + Summary_Class
FROM            COUNTIES_TPAS_ALT_4_OVERLAY AS d


Select Distinct FID_Counties, FID_TPAs, FID_Alt_4

select * From [UrbanSim].[COUNTIES_TPAS_ALT_4_OVERLAY]
create view UrbanSim.Counties_TPAs_PDAs_Alt_4_Overlay_DataSummary as
select CountyName, FID_Counties, FID_TPAs, FID_PDAs, FID_Alt_4, Shape.STArea()*0.000247105 as Acres From UrbanSim.Counties_TPAs_PDAs_Alt_4_Overlay

--Calc the following

--regional total acres
select CountyName, Cast(Sum(Acres) as numeric(18,0)) as Total_Acres From UrbanSim.Counties_TPAs_PDAs_Alt_4_Overlay_DataSummary Group By CountyName Order By CountyName

--CountyName	TotalAcres By County
--Alameda		470593
--Contra Costa	459627
--Marin			331743
--Napa			483730
--San Francisco	29741
--San Mateo		287432
--Santa Clara	817546
--Solano		529291
--Sonoma		1009458

--TPA total acres
select CountyName, Cast(Sum(Acres) as numeric(18,0)) as Total_Acres_TPAs 
From UrbanSim.Counties_TPAs_PDAs_Alt_4_Overlay_DataSummary 
Where FID_TPAs = 1
Group By CountyName 
Order By CountyName 

--CountyName	Total_Acres_TPAs
--Alameda		48196
--Contra Costa	11808
--Marin			4359
--San Francisco	28531
--San Mateo		21935
--Santa Clara	53942
--Solano		2544
--Sonoma		3979

--PDA total acres
select CountyName, Cast(Sum(Acres) as numeric(18,0)) as Total_Acres_PDAs
From UrbanSim.Counties_TPAs_PDAs_Alt_4_Overlay_DataSummary 
Where FID_PDAs = 1
Group By CountyName 
Order By CountyName

--CountyName	Total_Acres_PDAs
--Alameda		33621
--Contra Costa	16027
--Marin			1019
--Napa			951
--San Francisco	13239
--San Mateo		9373
--Santa Clara	25077
--Solano		6548
--Sonoma		8154

--TPA and PDA overlap acres
select CountyName, Cast(Sum(Acres) as numeric(18,0)) as Total_Acres_TPAs_PDAs_Overlap
From UrbanSim.Counties_TPAs_PDAs_Alt_4_Overlay_DataSummary 
Where FID_PDAs = 1 and FID_TPAs = 1
Group By CountyName 
Order By CountyName

--CountyName	Total_Acres_TPAs_PDAs_Overlap
--Alameda		22413
--Contra Costa	4489
--Marin			653
--San Francisco	13006
--San Mateo		7697
--Santa Clara	18322
--Solano		493
--Sonoma		1643


--TPA non PDA overlap acres
select CountyName, Cast(Sum(Acres) as numeric(18,0)) as Total_Acres_TPA_NonPDA_Overlap
From UrbanSim.Counties_TPAs_PDAs_Alt_4_Overlay_DataSummary 
Where FID_TPAs = 1 and FID_PDAs=-1
Group By CountyName 
Order By CountyName

--CountyName	Total_Acres_TPA_NonPDA_Overlap
--Alameda		25784
--Contra Costa	7319
--Marin			3706
--San Francisco	15525
--San Mateo		14237
--Santa Clara	35619
--Solano		2051
--Sonoma		2336

--PDA non TPA overlap acres
--See note above on TPA 

--the acres of footprint total
select CountyName, Cast(Sum(Acres) as numeric(18,0)) as Total_Acres_Alt_4
From UrbanSim.Counties_TPAs_PDAs_Alt_4_Overlay_DataSummary 
Where FID_Alt_4 = 1
Group By CountyName 
Order By CountyName

--CountyName	Total_Acres_Alt_4
--Alameda		3681
--Contra Costa	4073
--Marin			212
--Napa			459
--San Francisco	1456
--San Mateo		1384
--Santa Clara	4748
--Solano		1578
--Sonoma		1134

--the acres of footprint in TPA
select CountyName, Cast(Sum(Acres) as numeric(18,0)) as Total_Acres_Alt_4_TPAs
From UrbanSim.Counties_TPAs_PDAs_Alt_4_Overlay_DataSummary 
Where FID_Alt_4 = 1 and FID_TPAs = 1
Group By CountyName 
Order By CountyName

--CountyName	Total_Acres_Alt_4_TPAs
--Alameda		1958
--Contra Costa	599
--Marin			49
--San Francisco	1422
--San Mateo		701
--Santa Clara	2516
--Solano		16
--Sonoma		136

--the acres of footprint in PDA
select CountyName, Cast(Sum(Acres) as numeric(18,0)) as Total_Acres_Alt_4_PDAs
From UrbanSim.Counties_TPAs_PDAs_Alt_4_Overlay_DataSummary 
Where FID_Alt_4 = 1 and FID_PDAs = 1
Group By CountyName 
Order By CountyName

--CountyName	Total_Acres_Alt_4_PDAs
--Alameda		2553
--Contra Costa	2103
--Marin			20
--Napa			54
--San Francisco	1425
--San Mateo		590
--Santa Clara	2396
--Solano		121
--Sonoma		632

--the acres of footprint in TPA & PDAs
select CountyName, Cast(Sum(Acres) as numeric(18,0)) as Total_Acres_Alt_4_PDAs_TPAs
From UrbanSim.Counties_TPAs_PDAs_Alt_4_Overlay_DataSummary 
Where FID_Alt_4 = 1 and FID_PDAs = 1 and FID_TPAs = 1
Group By CountyName 
Order By CountyName

--CountyName	Total_Acres_Alt_4_PDAs_TPAs
--Alameda		1827
--Contra Costa	478
--Marin			17
--San Francisco	1391
--San Mateo		527
--Santa Clara	1885
--Solano		15
--Sonoma		96


--the acres of footprint in TPAs non PDAs
select CountyName, Cast(Sum(Acres) as numeric(18,0)) as Total_Acres_Alt_4_TPAs_NotInPDAs
From UrbanSim.Counties_TPAs_PDAs_Alt_4_Overlay_DataSummary 
Where FID_Alt_4 = 1 and FID_TPAs =1 and FID_PDAs=-1
Group By CountyName 
Order By CountyName

--CountyName	Total_Acres_Alt_4_TPAs_NotInPDAs
--Alameda		131
--Contra Costa	121
--Marin			32
--San Francisco	31
--San Mateo		174
--Santa Clara	631
--Solano		1
--Sonoma		40

--the acres of footprint in PDAs non TPAs
select CountyName, Cast(Sum(Acres) as numeric(18,0)) as Total_Acres_Alt_4_PDAs_NotInTPAs
From UrbanSim.Counties_TPAs_PDAs_Alt_4_Overlay_DataSummary 
Where FID_Alt_4 = 1 and FID_PDAs = 1 and FID_TPAs=-1
Group By CountyName 
Order By CountyName

--CountyName	Total_Acres_Alt_4_PDAs_NotInTPAs
--Alameda		726
--Contra Costa	1625
--Marin			3
--Napa			54
--San Francisco	34
--San Mateo		62
--Santa Clara	510
--Solano		106
--Sonoma		536

--the acres of footprint in non TPAs non PDAs
select CountyName, Cast(Sum(Acres) as numeric(18,0)) as Total_Acres_Alt_4_NotInPDAs_NotInTPAs
From UrbanSim.Counties_TPAs_PDAs_Alt_4_Overlay_DataSummary 
Where FID_Alt_4 = 1 and FID_PDAs = -1 and FID_TPAs = -1
Group By CountyName 
Order By CountyName

--CountyName	Total_Acres_Alt_4_NotInPDAs_NotInTPAs
--Alameda		998
--Contra Costa	1849
--Marin			160
--Napa			404
--San Francisco	1
--San Mateo		621
--Santa Clara	1722
--Solano		1456
--Sonoma		462
