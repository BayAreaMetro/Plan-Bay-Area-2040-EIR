###TPP Priority Project CEQ Streamlining Map

This map is on page 61 in the PBA '13 document. The goal is basically to output a density map that represents areas where CEQA project approval is possible/likely based roughly on guidelines for 0.75 FAR or 20 Units Per Acre. It seems as if CEQA actually applies to individual parcels, so its a bit hard to aggregate this assessment up to a TAZ, but thats whats required.  

In creating the feature classes for this map we went through several iterations:

###Current Version

Is available [here](http://arcg.is/XGm5v)

###Background and Previous Versions

Below is a hastily documented version of how we got to the final output

####First Round  

In this case, we defined the Floor Area Ratio and the Units per Acre for each TAZ as the average over each parcel within each TAZ.   
 
We made a number of changes since the feature classes output here, so it probably isn't necessary to review them. But they are here in any case in case thats useful.  

An AGOL Map of the first round of data is [here](http://arcg.is/2m8H2aK)  

A box folder with the data for this map in FileGDB form is [here](https://mtcdrive.box.com/s/spz1yatu4nq16kwe4xdu3cms32w6a04h)  

The pull request for the SQL used to output these feature classes is [here](https://github.com/MetropolitanTransportationCommission/UrbanSim_Spatial_Analysis/pull/5)  

####Second Round  

In reviewing the first round, we found that there were a number of places in which we expected CEQA might be likely to be applied which were not included in the map including: Berkeley, some parts of Western SF, and areas along North 1st Street in San Jose. In addition, there were a few places such as North Vallejo and South Novato in which development CEQA application seems like it would have been unlikely.  

So we tried applying a method in which any TAZ in which the 80th percentile (top 20% of the distribution) of parcels might qualify for CEQA would be tagged as a potential CEQA streamlining TAZ. 

An AGOL Map of the a data of the second round of data is [here](http://mtc.maps.arcgis.com/home/item.html?id=c75f9011843842eb96b64ff28abbb698&jobid=a30452e8-ebd7-4da2-a46e-6a747288637c)   

The feature classes in here include:

1) potential CEQA TAZ's based on Units per acre 
2) potential CEQA TAZ's based on Units per acre AND FAR
3) potential CEQA TAZ's (*_ALL_VARS) clipped to the TPA's (which are a necessary area qualification for SQL) with all source data, regardless of what density threshold they meet. we included this last feature class in order to allow us to review all density values and potentially simply toggle on those. 

####Third Round    

We decided that the method used in the second round, using an assumed normal distribution for density, was unreasonable. So we applied a threshold of the 80th percentile within each TAZ based on the actual distribution of the given variable (Units per Acre or FAR) within each taz.   

It was more expedient to use Pandas to apply the quantile analysis, so we followed the following steps to get quantile thresholds for each TAZ for each density value:

1) dump the parcel density table (`UrbanSim.Parcels_FAR_Units_Per_Acre_SP`) to disk

2) create CSV's of the values at a set of reasonable quantiles within each TAZ (`calculate_taz_percentile_values.py`)

3) load those CSV's back to a FileGDB with TAZ geometries. AGOL link to data [here](http://mtc.maps.arcgis.com/home/item.html?id=0d4c83530b9f4039a09a497b28e2a386). (`load_taz_quantile_data.bat`, `join_taz_quantiles_to_shapes.bat`)

#####Naming comventions in 3rd map version

The output of the 3rd round is a set of feature classes, each of which is subset to a given quartile threshold. 

The naming convention for these feature classes, [here](http://mtc.maps.arcgis.com/home/item.html?id=46a5f6b4c0c44bf6b529daa157ce8be8), is:

`far_sp_q8` - a subset of all TAZ's in which the FAR is over the .75 CEQA threshold for the 80th percentile (quartile). 

`far_sp_q7` - a subset of all TAZ's in which the FAR is over the .75 CEQA threshold for the 70th percentile (quartile). 

`ua_sp_q8` - a subset of all TAZ's in which the Units per Acre is over the 20 units/acre CEQA threshold for the 80th percentile (quartile). 

`far_sp_q4_clip_to_uf_and_tpa` is an example of what these TAZ's look like when clipped to TPAs and the Urban Footprint. Below we talk a bit more about why that clipping is necessary. 

#####Clipping to Urban Footprint

The unit to which we are aggregating (the TAZ) makes sense for modeling, but presents problems cartographically. For example, there is a large TPA in the Presidio by GG Bridge, and a large TAZ there as well. So if we only clip the TAZ summaries to the TPA's, we end up with areas that are unlikely to see CEQA projects.   

Therefore, we also clipped an example TAZ output to the UrbanSim Preferred scenario/FMMP urban footprint file (available [here](http://mtc.maps.arcgis.com/home/item.html?id=43cd558b015143089d62226396d1d11e&jobid=47cfc388-f7fb-41a1-ae34-1fb1029566b6).    

You can see an example of what this clipping looks like, along with all of the feature classes at the various quartiles [here](http://mtc.maps.arcgis.com/home/item.html?id=46a5f6b4c0c44bf6b529daa157ce8be8).  

The clipped feature class is named `far_sp_q4_clip_to_uf_and_tpa`.    

The best next step might be to choose quartile that works and then clip it. Or clip all of the feature classes and then review. 

#####Clipped Output

Is available here:

http://arcg.is/XGm5v

####Background Data  

While we've tried to capture most of the necessary data in here, if you can't find something it might be available [here](https://mtcdrive.app.box.com/folder/19409281231)
