##Files

Rough take on what the SQL scripts do.  

###AddSummaryClassDescription.sql    

Output tables summarizing housing and/or employment change in Transit Priority Areas and Priority Development Areas in Alternative 4 (aka land use model run 7224c)

###eir_summary_tables directory

Output summaries of acres in Transit Priority Areas and the estimated growth 'footprint' by county for the EIR for all scenarios/alternatives. Footprint has a particular meaning defined in the query but generally means locations where housing or employment changes are estimates to occur.   

###Build_Alternative_4_Footprint_2015_thru_2040.sql   

Output the 'footprint' of growth from 2015 to 2040 for the EIR Analysis.  Footprint has a particular meaning defined in the query but generally means locations where housing or employment changes are estimates to occur. 

###CreateDensityByCounty_TPA.sql   

Output a table of Land Use density by Transit Priority Areas.  

###get_far_and_density.sql  

Output the feature class geometry for the 2017 version of Map 7 - Transit Priority Project CEQA Streamlining (PBA '13)   

###parcels_setup.sql  

Used to setup (index, etc) a parcels table if necessary.
  



