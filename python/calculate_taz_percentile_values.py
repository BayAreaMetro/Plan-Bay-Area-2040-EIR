import pandas as pd
df = pd.read_csv("parcels_far_ua.csv")

def get_quantiles_for_col(array_of_quantiles, pandas_df, column_name, groupbycol="taz_id"):	
	df = pd.DataFrame()
	for quantile in array_of_quantiles:
		quantile_name = str(int(round(quantile*10)))
		df['q{}'.format(quantile_name)] = \
		 	pandas_df.groupby(by=groupbycol)[column_name].quantile(quantile)
	return df

df1 = df.loc[df['far_estimate'] != 0]
df2 = df.loc[df['units_per_acre'] != 0]

import numpy as np
a1 = np.arange(.4,.9,0.1)

df3 = get_quantiles_for_col(a1,df1,'far_estimate')
df4 = get_quantiles_for_col(a1,df2,'units_per_acre')

df3.to_csv("taz_far_quantiles.csv")
df4.to_csv("taz_units_per_acre_quantiles.csv")