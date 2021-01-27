"""
This file contains commonly-used data analysis functions
"""

import os
import copy
import json
import math
import time
import uuid
import random
import string
import binascii
import calendar
import operator
import itertools
import numpy as np
import pandas as pd
import urllib.parse
import dateutil.parser
from functools import reduce
from datetime import datetime
from collections import defaultdict

# Pre-requisite: ! pip install requests
try:
    import requests
except:
    print('need to install requests: pip install requests')


############### Unitary functions ###############

def is_null(x):
    try:
        return np.isnan(x)
    except:
        return x in [None, 'nan', np.datetime64('NaT')]


def to_float_safe(x):
    if str(x).replace(',','').replace('.','',1).isdigit():
        return float(str(x).replace(',',''))
    else:
        return np.nan


def float_to_intstr(x):
    """
    Returns an int string version of a float, e.g. 10.463 -> '10'
    """
    intstr = str(x).split('.')[0]
    return intstr if intstr != 'nan' else np.nan


def format_int_with_commas(x):
    """
    Returns an integer as its string representation with commas
    separating thousands
    """
    return '{:,}'.format(x)


def readable_digit(num, width=4):
    """
    Returns a readable string representation of a digit
    
    e.g. readable_digit(21519385, 3) --> '21.5M'
    
    From https://stackoverflow.com/a/45846841
    """
    float_width = '{' + ':.{}g'.format(width) + '}'
    num = float(float_width.format(num))
    magnitude = 0
    while abs(num) >= 1000:
        magnitude += 1
        num /= 1000.0
    readable_digit = '{}{}'.format('{:f}'.format(num)
                                       .rstrip('0')
                                       .rstrip('.'),
                                   ['', 'K', 'M', 'B', 'T'][magnitude])
    return readable_digit


def camel_to_snake_case(camel_string):
    """
    Converts a string in camelCase to snake_case

    From https://www.geeksforgeeks.org/python-program-to-convert-camel-case-string-to-snake-case/  # noqa
    """
    return reduce(lambda x, y: x + ('_' if y.isupper() else '') + y,
                  camel_string).lower()


############### Multi type transformation functions ###############

def find_idx_of_first_alpha(x):
    """
    Given a string, finds the index of the first alpha character
    """
    if not isinstance(x, str):
        return
    i = 0
    while i < len(x) - 1 and not str.isalpha(x[i]):
        i += 1
    if i >= len(x) or not str.isalpha(x[i]):
        return
    return i


def make_dict(*args, **kwargs):
    """
    Given some variables, creates a dictionary
    of the variable name to value

    Behavior:
    ---------
    If there are any shared variables in args and kwargs,
    args values will override kwargs.

    Example usage:
    --------------
    a, b = 1, 2
    c = {'a': 54}
    print(make_dict(a, b, **c))
    # {'a': 1, 'b': 2}

    print(make_dict(*[a, b], **c))
    # # {'a': 1, 'b': 2}

    c = {'c': 54}
    print(make_dict(a, b, **c))
    # {'c': 54, 'a': 1, 'b': 2}

    print(make_dict(*[a, b], a=1, b=2))
    # {'a': 1, 'b': 2}

    Derived from https://stackoverflow.com/a/57215575 and
    https://www.geeksforgeeks.org/packing-and-unpacking-arguments-in-python/  # noqa
    """
    # first handle kwargs
    return_d = dict(kwargs)

    # then handle args
    g = {k: v for k, v in globals().items() if not k.startswith('__')}  
    for arg in args:
        for k, v in g.items():
            try:
                if v == arg:
                    return_d[k] = v
            except ValueError:
                continue  # objects that don't allow comparison
    return return_d


def concat_dfs(df_list, **kwargs):
    default_args = {'ignore_index': True,
                    'sort':False}
    return pd.concat(df_list, **{**default_args, **kwargs})


############### Generator functions ###############

def generate_random_numbers_in_range(a, b, n):
    return random.sample(range(a, b), n)


def generate_random_dates(start, end, n, sort=False):
    """
    Given a start and end date and series length,
    generates a series of random datetimes
    within the range.
    
    From https://stackoverflow.com/a/50668285
    """
    ns = 10**9  # unix timestamp is ns by default
    
    start_u = pd.to_datetime(start).value//ns
    end_u = pd.to_datetime(end).value//ns

    random_dates = ns*np.random.randint(start_u,
                                        end_u,
                                        n,
                                        dtype=np.int64)
    random_dates = pd.DatetimeIndex(random_dates.view('M8[ns]'))
    if sort:
        random_dates = random_dates.sort_values()
    return random_dates


def generate_uuid_list(num_uuids, uuid_type=4):
    """
    Given the number of desired UUIDs,
    returns them in a list
    """
    uuid_list = []
    for i in range(num_uuids):
        if uuid_type == 1:
            uuid_list.append(str(uuid.uuid1()))
        else:
            uuid_list.append(str(uuid.uuid4()))
    return uuid_list


def create_dummy_dataset():
    """
    Creates a simple dummy dataset of length 3 for testing
    """
    df = pd.DataFrame({'a': ['a', 'b', 'c'],
                       'b': [1, 2, 3],
                       'c': [1.0, 2.0, 3.0],
                       'd': [True, False, True],
                       'e': generate_uuid_list(3)
                      })
    return df


def create_med_dummy_dataset():
    """
    Creates a medium-length dummy dataset of length 30
    """
    # initialize empty concat list for dataframes
    dfs = []
    # create 10 dummy dataframes of size 3
    for i in range(10):
        df = create_dummy_dataset()
        # create a column of the iter value
        df['d{}'.format(i)] = i
        # add to concat list
        dfs.append(df)
    df = concat_dfs(dfs)
    return df


def generate_numbers_not_in_exclude_list(n, exclude_list, i=0):
    """
    Given the desired length of the list (n), a list of integers to
    exclude, and optionally a start index, returns a list of integers of
    length n starting at the start index and excluding values from the
    exclude_list

    e.g.
    
    exclude_list = [1, 3, 6, 8, 9]
    generate_numbers_not_in_exclude_list(5, exclude_list, 7)
        -> [7, 10, 11, 12, 13]
    generate_numbers_not_in_exclude_list(5, exclude_list)
         -> [0, 2, 4, 5, 7]
    """
    max_exclude = exclude_list.max()
    include_arr = np.array(list(set(np.arange(i, max_exclude)).difference(exclude_list)))
    new_arr = np.arange(max_exclude, n + max_exclude - len(include_arr))
    return list(np.concatenate([include_arr, new_arr]).astype(int))


################## Copy functions ###############

def get_dict_copy(d):
    return copy.deepcopy(d)


############### Time functions ###############

def print_runtime(run_seconds):
    """
    Given a float of runtime seconds, formats the time for more readable
    logging
    """
    if run_seconds > 60:
        mins = run_seconds/60.0
        if mins < 60:
            return '{} minutes'.format(round(mins, 4))
        else:
            return '{} hours'.format(round(mins/60.0, 4))
    else:
        return '{} seconds'.format(round(run_seconds, 4))


def parse_day_from_day_str(day):
    return pd.to_datetime(day)


def timedelta_to_hour_str(timedelta):
    """
    Returns the hour component of a pandas TimeDelta (HH:MM format)
    """
    # td_comps = x.components
    # return str(td_comps[1]).zfill(2) + ':' + str(td_comps[2]).zfill(2)

    # c = x.components
    # return '{}:{}'.format(str(c[1]).zfill(2),
    #                      str(c[2]).zfill(2)
    #                     )

    # Need to convert to datetime since you cannot do td.strftime('%H:%M')
    ts = (timedelta + datetime(*(datetime.today()).timetuple()[:3]))
    return ts.strftime('%H:%M') # 2013-12-14 00:00:00


def timedelta_to_time_period_str(timedelta):
    """Given a pandas Timedelta object, returns a string of format
    HH:MM:SS"""
    return str(timedelta).split('days ')[-1]


def time_period_str_to_timedelta(time_str, start=True):
    """Given a string of format HH:MM format, returns a pandas Timedelta
    object"""
    if start:  # mark start seconds as 00
        time_str += ':00'
    else:  # mark end seconds as 59
        time_str += ':59'
    return pd.Timedelta(time_str)


def round_ts_to_day(ts, to_str=False):
    try:
        x = pd.to_datetime(ts)
        rounded_day = datetime(x.year,
                               x.month,
                               x.day)
        if to_str:
            rounded_day = rounded_day.strftime('%m-%d-%Y')
        return rounded_day
    except:
        pass


def get_current_time(to_iso=False, round_to_day=False):
    """
    If round_to_day is True, rounds to today with no timestamp.
    If to_iso is True, returns the current time in ISO 8601 format.
    Otherwise, returns a datetime object.
    """
    current_time = datetime.now()
    if round_to_day:
        current_time = round_ts_to_day(current_time)
    if to_iso:
        current_time = current_time.isoformat()
    return current_time


def ts_to_readable(ts):
    """
    Given a datetime/timestamp, returns a
    string of format mm/dd/YYYY HH:mm:ss
    """
    return ts.strftime('%m/%d/%Y %H:%M:%S')


def to_iso(x):
    """
    Updates a datetime-like string to be ISO 8601 format
    """
    iso = pd.Timestamp(x).isoformat()
    if iso != 'NaT':
        return iso


def iso_to_readable_ts(x):
    """
    Given a datetime ISO formatted string, returns a readable
    date + time string
    """
    try:
        ts = dateutil.parser.parse(x)
        return ts_to_readable(ts)
    except:
        return


def get_num_days_in_month(x):
    """
    Given a datetime object, returns the number of days in that month
    """
    return calendar.monthrange(x.year, x.month)[1]


def get_first_monday_of_month(year, month):
    """
    Returns the month day of the first Monday of the month
    """
    x = calendar.monthrange(year, month)[0]
    if x == 0:
        return 1
    else:
        return 8 - x


def get_last_monday_of_month(year, month):
    """
    Returns the month day of the last Monday of the month
    """
    first_monday = get_first_monday_of_month(year, month)
    num_days = calendar.monthrange(year, month)[1]
    i = first_monday
    while i <= num_days - 7:
        i += 7
    return i


def get_weeks_in_month(year, month):
    """
    Returns a list of weeks in the month
    """
    first_monday = get_first_monday_of_month(year, month)
    last_monday = get_last_monday_of_month(year, month)
    weeks = []
    for i in range(first_monday, last_monday + 7, 7):
        weeks.append('{}-{}-{}'.format(str(month).zfill(2), str(i).zfill(2), year))
    return weeks


def get_weeks_in_quarter(year, quarter):
    """
    Returns a list of weeks in the quarter
    """
    quarter_months_d = {1: range(1, 4),
                        2: range(4, 7),
                        3: range(7, 10),
                        4: range(10, 13)}
    quarter_weeks = []
    for month in quarter_months_d[quarter]:
        quarter_weeks.extend(get_weeks_in_month(year, month))
    return quarter_weeks


def interpolate_timedelta_col(s):
    return pd.to_timedelta(pd.to_timedelta(s)
                            .map(lambda x: x.total_seconds())
                            .interpolate()
                            .round(),
                            unit='seconds'              
            )


############### Dictionary functions ###############

def invert_list_dict(d):
    """
    Given a dictionary with list values, inverts the dictionary
    so it is of format
    {v: k} or {v: [list of keys]} if multiple keys have v in their
    values
    """
    reverse_d = defaultdict(list)
    for k, v in d.items():
        for val in v:
            reverse_d[val].append(k)
    # set value as list item if there is only one value
    for k, v in reverse_d.items():
        if len(v) == 1:
            reverse_d[k] = v[0]
    return dict(reverse_d)


def flatten_nested_dict(nested_d, separator='_', prefix=''): 
    """
    Derived from
    https://www.geeksforgeeks.org/python-convert-nested-dictionary-into-flattened-dictionary/  # noqa
    """
    return {prefix + separator + k if prefix else k: v 
             for kk, vv in nested_d.items() 
             for k, v in flatten_nested_dict(vv, separator, kk).items() 
             } if isinstance(nested_d, dict) else {prefix: nested_d}


############### Series/Array functions ###############

def count_null(s):
    return s.isnull().sum()


def get_null_pct(s):
    """
    Returns the percentage of null values in an array
    """
    return pd.Series(s).isnull().sum()/len(s)


def check_null_group(s, how='all'):
    """
    Returns whether or not the series has all or any null values
    """
    if how == 'all':
        return s.isnull().all()
    if how == 'any':
        return s.isnull().any()


def most_recent(s, format_str=None):
    """
    Given a pandas datetime-like series and optionally a date format
    string, returns the most recent date
    """
    if format_str is not None:
        date_series = pd.to_datetime(s, format=format_str)
    else:
        date_series = pd.to_datetime(s)
    idxmax = date_series.idxmax()
    if np.isnan(idxmax):
        return np.nan
    else:
        return s[idxmax]


def unique_sum(s):
    """
    Given a pandas Series, returns the sum of its unique elements 
    """
    return s.unique().sum()


def nonzero_mean(s):
    """
    Given a Series, returns the mean excluding zeros
    e.g.
    s = pd.Series([0, 1, 2])
    np.mean(s)  # 1.0
    nonzero_mean(s)    # 1.5
    """
    return s.replace(0, np.nan).mean()


def string_concat(s, join_str=' '):
    """
    Given a pandas Series, returns a string concatenation of its
    elements
    """
    return join_str.join(s.astype(str))


def get_mode(s):
    """
    Given a pandas Series, returns the mode
     (or if none or multiple, the first)

    Previously was 

    from statistics import mode
    if not is_null(x):
        try:
            return mode(x)
        # 'no unique mode; found 2 equally common values'
        except Exception as e:
            # return x[0]
            pass

    But the new version below is more concise
    """
    # could also do: TODO -- profile these options
    # return s.value_counts().index[0]

    if len(s.mode()) == 0:
        return np.nan
    else:
        return s.mode()[0]



def get_first_group_idx(s):
    """
    Given a series, returns the index of the first element
    """
    return s.index[0]


############### DataFrame functions ###############

def find_df_difference(new_df, old_df, return_indicator=False, return_new=True):
    """
    Given a new dataframe and an old dataframe (must have the same
    columns), returns the rows from the new dataframe that are updates
    (i.e. that do not exist in the old dataframe)

    Method found here: https://stackoverflow.com/a/48647840
    """
    old_df = old_df.copy()
    new_df = new_df.copy()
    dtype_d = dict(old_df.dtypes)
    # round floats due to insignificant floating point differences
    for c, dtype in dtype_d.items():
        if dtype == np.dtype('float64'):
            old_df[c] = old_df[c].round(5)
            new_df[c] = new_df[c].round(5)

    if return_new:
        merge_compare = new_df.merge(old_df, indicator=True, how='left')
    else:
        merge_compare = old_df.merge(new_df, indicator=True, how='left')
    updated_rows = merge_compare[merge_compare['_merge'] == 'left_only']
    if not return_indicator:
        updated_rows = updated_rows.drop('_merge', axis=1)
    return updated_rows


def get_unique_subset(df, dropna=False):
    """
    Returns the dataframe subset to the columns with more than one
    unique value
    
    e.g.
    df = pd.DataFrame({'a': [1] * 3,
                   'b': ['a', 'b', 'c'],
                   'c': None})
    
    get_unique_subset(df)
    ->
      b
    0 a
    1 b
    2 c
    
    """
    return df[df.nunique(dropna=dropna)[df.nunique(dropna=dropna) > 1].index]


def check_not_different(df, check_cols, id_col):
    """
    Given a dataframe, a list of suspected duplicate columns, and the
    ID column, checks if there are any conflicting non-null
    values for those columns. If there are, returns a dictionary of the
    column pair and the rows of the dataframe where those conflicts
    exist, otherwise returns True
    """
    check_df = (df[[id_col] + check_cols]
        .drop_duplicates()
        .dropna(subset=check_cols, how='all'))
    col_combinations = list(itertools.combinations(check_cols, 2))
    mismatches = {}
    for col_pair in col_combinations:
        c0 = col_pair[0]
        c1 = col_pair[1]
        not_null_0 = ~check_df[c0].isnull()
        not_null_1 = ~check_df[c1].isnull()
        not_equal = check_df[c0] != check_df[c1]
        mismatch = check_df[not_null_0 & not_null_1 & not_equal]
        if len(mismatch) > 0:
            mismatches[col_pair] = mismatch
    if len(mismatches) > 0:
        print('these columns have conflicting values: {}'.format(check_cols))
        return mismatches
    else:
        return True


def fillna_by_col_value(df, fillna_cols, by_cols):
    """
    Given a dataframe, a list of columns with null values to be filled,
    and a list of groupby columns, returns a new dataframe with
    filled null values based on any non-null values
    for the groupby columns

    Example:

    df = pd.DataFrame({'a': [1, np.nan, 2],
                       'b': ['a', 'a', 'b'],
                       'c': [np.nan, True, False]})

    df_filled = fillna_by_col_value(df, fillna_cols=['a', 'c'],
                                    by_col=['b'])
    print(df_filled)

    Returns -> 


         a  b      c
    0  1.0  a   True
    1  1.0  a   True
    2  2.0  b  False

    BEWARE: None is treated differently from np.nan. If above df
    had None instead of np.nan, result would be

         a  b      c
    0  1.0  a   None
    1  1.0  a   None
    2  2.0  b  False

    To fix this problem, first convert all null values to np.nan:

    df.fillna(np.nan, inplace=True)

    Warning: originally had

    def fillna(df):
        return df.fillna(method='ffill').fillna(method='bfill')
    df = df.groupby('APN').apply(fillna)

    but it took FOREVER, didn't complete, and had to be killed
    eventually.

    Instead followed this approach: https://stackoverflow.com/a/36288458
    """
    fillna_df = df.copy()
    g = fillna_df.groupby(by_cols, sort=False).first()
    for c in fillna_cols:
        is_na = fillna_df[c].isnull()
        fillna_df.loc[is_na, c] = fillna_df.loc[is_na, by_cols].merge(g[c].reset_index(), how='left')[c].values
    return fillna_df


def get_unique_vals(df, inspect_cols, id_col):
    """
    Given a dataframe, a list of columns to inspect, and an id_col,
    returns a dictionary of inspect_cols to subsets of the data where
    the id_col has multiple corresponding unique values in the inspect
    column
    """
    dup_ids = df[id_col].value_counts()[df[id_col].value_counts() > 1]
    check_df = df[df[id_col].isin(dup_apns.index)]
    nuniq = check_df.groupby(id_col).nunique()
    nuniq = nuniq[nuniq > 1][inspect_cols].dropna(how='all')
    check_d = {}
    for c in inspect_cols:
        check = nuniq[c].dropna()
        other_cols = [col for col in inspect_cols if col != c]
        check_d[c] = (df[df[id_col].isin(check.index)][[id_col, c] + other_cols]
                      .sort_values(by=[id_col])
                      .dropna(subset=[c])
                     .set_index([id_col, c])
                    .sort_index())
    return check_d


def get_cols_with_value(value, df):
    """
    Given a value and dataframe, returns a list of columns containing
    that value
    """
    cols_with_value = []
    for c in df:
        if value in df[c].unique():
            if df[c].dtype == bool:
                if isinstance(value, bool):
                    cols_with_value.append(c)
            elif df[c].dtype in [float, int]:
                if type(value) in [float, int]:
                    cols_with_value.append(c)
            else:
                cols_with_value.append(c)
    return cols_with_value


def stack_df(df, index_cols, stack_cols):
    """
    Given a dataframe, a list of columns to stack by,
    and a list of columns to stack, returns a stacked dataframe
    """
    return (df[index_cols + stack_cols]
        .set_index(index_cols)
        .stack()
        .reset_index())


def flatten_hierarchical_index(df, sep='_', inplace=True):
    """
    Flattens hierarchical index columns in a dataframe
    (from https://stackoverflow.com/a/14508355) 
    """
    if not inplace:
        df = df.copy()
    df.columns = ([sep.join([c for c in col if len(c) > 0]).strip()
        for col in df.columns.values])
    if not inplace:
        return df


def fill_col_from_two_dup_cols(a1, a2):
    """
    Given two duplicate columns, creates a new column that is a
    combination of non-null values from the two columns
    """
    df = pd.concat([a1, a2], axis=1)
    df.columns= ['a1', 'a2']
    null_d = get_null_pct_d(df)
    old_min_pct_null = min(null_d.values())
    worse_col = max(null_d.items(), key=operator.itemgetter(1))[0]
    better_col = a1 if worse_col == 'a2' else a2
    worse_col = a1 if worse_col == 'a1' else a2
    # new_col = np.where(~is_null(better_col), better_col, worse_col)
    new_col = np.where(~pd.Series(better_col).isnull(), better_col, worse_col)
    null_d['combined'] = get_null_pct(new_col)
    new_min_pct_null = min(null_d.values())
    if new_min_pct_null >= old_min_pct_null:
        print('no change')
    return new_col


def get_better_col_combination(df, compare_cols):
    """
    Given a dataframe and a list of duplicate columns to compare,
    returns a new column that is a combination of non-null values from
    the columns
    
    E.g.
    
    mini_df = pd.DataFrame({'a0': [1, np.nan, np.nan, np.nan],
                            'a1': [np.nan, 2, 3, np.nan],
                            'a2': [np.nan, np.nan, np.nan, 4]})
    compare_cols = ['a0', 'a1', 'a2']
    new_col = get_better_col_combination(mini_df, compare_cols)
    new_col
    ->  0    1.0
        1    2.0
        2    3.0
        3    4.0
        Name: a0_compare_a1_compare_a2, dtype: float64
    """
    new_df = df[compare_cols].copy()
    for i in range(len(compare_cols) - 1):
        compare_colname = '_compare_'.join(compare_cols[:i + 1])
        new_colname = '_compare_'.join(compare_cols[:i + 2])
        col_1 = new_df[compare_colname]
        col_2 = new_df[compare_cols[i + 1]]
        new_df[new_colname] = fill_col_from_two_dup_cols(col_1, col_2)
    return new_df[new_colname]


def get_nunique(df, cols=None):
    """
    Given a dataframe, returns a dictionary of
    the number of unique values for each column
    """
    if cols is not None:
        df = df[cols]
    return dict(df.nunique(dropna=False))


def get_top_values(df, cols=None, print_vals=True):
    """
    Given a dataframe, returns and optionally
    prints a dictionary of the top 5 values and
    their counts for each column
    """
    if cols is not None:
        df = df[cols]
    top_vals = {}
    for col in df:
        vcs = df[col].value_counts(dropna=False).head()
        top_vals[col] = vcs
        if print_vals:
            print('\n', vcs, '\n')
    return top_vals


def get_value_counts_df(df, gb_cols, vc_col):
    """
    Given a dataframe, a list of columns to group by, and the column
    whose values will be counted,
    returns a dataframe of value counts by group
    """
    vc_df = (pd.DataFrame(df.groupby(gb_cols)[vc_col].value_counts())
        .rename(columns={vc_col: 'ct'})
        .reset_index())
    return vc_df


def get_drop_cols(nuniq_d):
    """
    Given a dictionary of the number of unique values for each column
     (like that returned by get_nunique(df)),
    returns a list of columns that have no data (all null values)
    """
    drop_cols = []
    for col, n in nuniq_d.items():
        if n < 2:
            drop_cols.append(col)
    return drop_cols


def get_null_pct_d(df, cols=None):
    """
    Given a dataframe, returns a dictionary of
    null percentages for each column
    """
    if cols is not None:
        df = df[cols]
    null_cts = df.apply(count_null)
    return dict((null_cts / len(df)).round(4))


def get_mismatched_coltypes(target_df, mismatch_df):
    """
    Given two dataframes with the same column names, returns a series of
    columns and their datatypes in the second dataframe that do not
    match the datatype of the corresponding columns in the first
    dataframe
    """
    return mismatch_df.dtypes[mismatch_df.dtypes != target_df.dtypes]


def convert_float_to_string_safe(df, conv_cols):
    conv_df = df.copy()
    for c in conv_cols:
        conv_df[c] = conv_df[c].map(float_to_intstr)
    return conv_df


def convert_string_to_float_safe(df, conv_cols):
    conv_df = df.copy()
    for c in conv_cols:
        conv_df[c] = conv_df[c].map(to_float_safe)
    return conv_df


def conv_coltypes(df, ctype_d):
    string_conv_cols = []
    float_conv_cols = []
    for k, v in ctype_d.items():
        if v == 'float':
            float_conv_cols.append(k)
        else:
            string_conv_cols.append(k)
    df = convert_float_to_string_safe(df, string_conv_cols)
    df = convert_string_to_float_safe(df, float_conv_cols)
    return df


############### Data platform-specific functions ###############

def create_redshift_password():
    """
    Generates a Redshift password that meet the constraints detailed in
    https://docs.aws.amazon.com/redshift/latest/dg/r_CREATE_USER.html)
    """
    uuid = generate_uuid_list(1)[0]  # generates uuid1 of length 36
    # uuids always have at least one letter and number
    # so will capitalize the first letter
    first_alpha_idx = find_idx_of_first_alpha(uuid)
    uuid_comps = list(uuid)
    uuid_comps[first_alpha_idx] = uuid_comps[first_alpha_idx].upper()
    return ''.join(uuid_comps)


def create_column_type_dict(df, varchar_width_multiplier=2, detect_date=False, detect_geo=False):
    """
    Given a pandas DataFrame, returns a column type dictionary
     with SQL/Socrata datatypes (depending on host)

    Converts all numeric columns to float, and all boolean and
    non-numeric columns to text (Socrata) or varchar with <varchar_width_multiplier>
    times the maximum field length (Redshift)
    """
    df = df.copy()
    ctype_d = {c: 'varchar(max)' for c in df.columns}
    # numeric columns to float
    num_df = df._get_numeric_data()
    num_cols = num_df.columns
    str_cols = [c for c in df.columns if c not in num_cols]
    for c in num_cols:
        if df[c].dtype == np.dtype('bool'):
            str_cols.append(c)
            ctype_d[c] = 'varchar(5)'
        else:
            ctype_d[c] = 'float'

    # date columns
    if detect_date:
        for c in str_cols:
            try:
                df[c] = pd.to_datetime(df[c])
                str_cols.remove(c)
                # check if date or timestamp
                hours =df[c].dt.hour.unique()
                mins = df[c].dt.minute.unique()
                secs = df[c].dt.second.unique()
                if hours == mins == secs == np.array([0]):
                    ctype_d[c] = 'date'
                else:
                    ctype_d[c] = 'timestamp'
            except:
                pass

    if detect_geo:
        import geopandas as gpd
        # Geodataframe support:
        if isinstance(df, gpd.GeoDataFrame):
            geom_col = df.geometry.name
            str_cols.remove(geom_col)

    # string columns
    df[str_cols] = df[str_cols].astype(str)
    for c in str_cols:
        if ctype_d[c] == 'varchar(max)':
            col_len = df[c].str.len()
            max_field_len = varchar_width_multiplier * col_len.max()
            ctype_d[c] = 'varchar({})'.format(int(max_field_len))
    return ctype_d


def redshift_to_socrata_ctype_d(ctype_d):
    numeric_ctypes = ['integer',
                      'smallint',
                      'double precision',
                      'real',
                      'float']
    socrata_ctype_d = {}
    for k, v in ctype_d.items():
        if v.startswith('varchar') or v.startswith('char'):
            socrata_ctype_d[k] = 'text'
        if v in numeric_ctypes:
            socrata_ctype_d[k] = 'number'
        if v == 'date':
            socrata_ctype_d[k] = 'calendar_date'
        if v == 'timestamp':
            socrata_ctype_d[k] = 'date'
    return socrata_ctype_d


def create_redshift_table_str(tablename, ctypes=None, select_str=None,
    distkey=None, sortkey=None, diststyle=None, sortstyle=None):
    """
    Given a tablename of format schema.table and either a dictionary of
    column name to SQL type (for new table) or a select string
    (for CTAS), and optionally a distkey, sortkey, diststyle, and
    sortstyle, returns a create table statement string for Redshift.
    If both ctypes and a select_str are specified, returns with an error
    message.
    
    
    TODO: add diststyle and sortstyle
    
    CREATE TABLE NEW Redshift documentation:
    https://docs.aws.amazon.com/redshift/latest/dg/r_CREATE_TABLE_NEW.html  # noqa
    
    CREATE TABLE AS (CTAS) Redshift documentation:
    https://docs.aws.amazon.com/redshift/latest/dg/r_CREATE_TABLE_AS.html  # noqa
    https://docs.aws.amazon.com/redshift/latest/dg/r_CTAS_examples.html
    """
    if ctypes is not None and select_str is not None:
        error_msg = """Error, need to choose between
        CREATE_TABLE_NEW and CREATE_TABLE_AS.
        
        Docs:
        
        https://docs.aws.amazon.com/redshift/latest/dg/r_CREATE_TABLE_NEW.html
        https://docs.aws.amazon.com/redshift/latest/dg/r_CREATE_TABLE_AS.html
        """
        print(error_msg)
        return

    if distkey is not None:
        distkey_str = '\nDISTKEY({})'.format(distkey)
    else:
        distkey_str = ''

    if sortkey is not None:
        if isinstance(sortkey, list):
            sortkey = ', '.join(sortkey)
        sortkey_str = '\nSORTKEY({})'.format(sortkey)
    else:
        sortkey_str = ''

    if ctypes is not None:  # CREATE_TABLE_NEW
        ctype_str = ',\n'.join(['{} {}'.format(k, v) for k, v in ctypes.items()])
        table_create_str = 'CREATE TABLE {}(\n{}){}{};'.format(tablename,
                                                               ctype_str,
                                                               distkey_str,
                                                               sortkey_str)

    if select_str is not None:  # CREATE_TABLE_AS
        table_create_str = 'CREATE TABLE {}{}{}\nAS\n{};'.format(tablename,
                                                                 distkey_str,
                                                                 sortkey_str,
                                                                 select_str)

    return table_create_str


def create_s3_key_prefix(tablename, dbname='dev'):
    """
    Given a tablename of format 'schema.table' and a dbname,
    returns an S3 key prefix of format 'dbname/schema/table/'
    """
    # # doesn't work with Windows-- also unclear
    # return os.path.join(*([dbname, *(tablename.split('.'))])) + '/'
    return '/'.join([dbname, *(tablename.split('.'))]) + '/'


def scrub_creds_from_aws_cmd(aws_cmd):
    scrub_cmd = (aws_cmd.split('CREDENTIALS')[0]
                 + """CREDENTIALS 'aws_access_key_id=XXX;aws_secret_access_key=XXX'"""
                + ''.join(aws_cmd.split('CREDENTIALS')[1].split("'")[2:]))
    return scrub_cmd


def socrata_tablename_to_rs_tablename(socrata_data_id, socrata_tablename):
    """
    Given a Socrata data id (4 x 4) and table name, returns a
    Redshift-compatible table name
    """
    redshift_tablename = '{}_{}'.format(socrata_data_id, socrata_tablename)
    redshift_tablename = (redshift_tablename
                          .replace(' ', '_')
                          .replace('-', '_')
                          .lower()
                         )
    return redshift_tablename


def create_redshift_colname_map(df_cols):
    """
    Given a list of column names that are not Redshift-compliant, 
    returns a dictionary of the original column name to Redshift column
    names

    Redshift column name restrictions: https://docs.aws.amazon.com/redshift/latest/dg/r_names.html  # noqa

    Replaces all punctuation and spaces with underscores
    """
    redshift_col_mapping = {}
    for c in df_cols:
        new_colname = c.replace(' ', '_').lower()
        for p in string.punctuation:
            if p in new_colname:
                new_colname = new_colname.replace(p, '_')
        redshift_col_mapping[c] = new_colname
    return redshift_col_mapping


def create_socrata_column_list(ctype_dict=None, df=None, detect_geo=False):
    """
    Given either a DataFrame or a dictionary of columns and their Socrata data type, 
    creates the column list necessary for initializing a Socrata dataset
    
    Possible data types at https://dev.socrata.com/docs/datatypes/#
    """
    socrata_column_list = []

    if ctype_dict is not None:
        if not isinstance(ctype_dict, dict):
            print('Error, ctype_dict needs to be a dictionary')
            return

    # If provided with a DataFrame, create a ctype_dict:
    else:
        if df is None:
            print('Error: need to provide either a DataFrame or dictionary')
            return
        if not isinstance(df, pd.DataFrame):
            print('Error, df needs to be a pandas DataFrame')
            return
        ctype_dict = create_column_type_dict(df, detect_geo=detect_geo)
        ctype_dict = redshift_to_socrata_ctype_d(ctype_dict)
        if detect_geo:
            import geopandas as gpd
            # Geodataframe support:
            if isinstance(df, gpd.GeoDataFrame):
                geom_col = df.geometry.name
                if len(df.geom_type.unique()) > 1:
                    # pass  # add support for resolving multiple geometry types later
                    # --> make into MultiPolygon?
                    geom_type = 'multipolygon'
                else:
                    geom_type = df.geom_type.unique()[0].lower()
                # Socrata geom types:
                valid_geom_types = ['multiline',
                                    'multipoint',
                                    'multipolygon',
                                    'point',
                                    'polygon']
                if geom_type in valid_geom_types:
                    ctype_dict[geom_col] = geom_type

    new_colnames = create_redshift_colname_map(ctype_dict.keys())
    new_ctypes = {k: ctype_dict[k] for k in new_colnames.keys()}
    for col_name, col_type in new_ctypes.items():
        column_json = {'fieldName': col_name.lower(),
                       'name': col_name,
                       'dataTypeName': col_type}
        socrata_column_list.append(column_json)
    return socrata_column_list


def prepare_df_for_socrata(df, ctypes=None, print_messages=True):
    """
    Given a dataframe, returns a Socrata-upsert compatible
    list of dicts (1 dict per row, with no null values in each row dict)
    """
    upsert_data_raw = df.to_dict(orient='records')
    # null values throw an error on Socrata
    if print_messages:
        print('preparing data for Socrata')
    upsert_data_no_nulls = []
    for row in upsert_data_raw:
        row_d = {}
        for k, v in row.items():
            if not is_null(v):
                if type(v) == bool:
                    # keep as boolean format if checkbox
                    if ctypes is not None and ctypes.get(k) == 'checkbox':
                        pass
                    else:
                        v = str(v)  # Socrata needs booleans represented as string
                row_d[k] = v
        upsert_data_no_nulls.append(row_d)
    return upsert_data_no_nulls


def get_chunksize_socrata(df_shape, max_chunk_area=1e6):
    """
    Given a tuple of df shape (nrows, ncols) and a
    max_chunk_area (default is 1m values), returns the
    chunk size to pull from/push to Socrata
    
    e.g. chunksize = get_chunksize_socrata(df.shape)
    """
    num_rows, num_cols = df_shape
    # set chunk size based on max_chunk_area (default is 1m values):
    #   set default chunksize
    chunksize = round(max_chunk_area/num_cols)
    #   extremely wide (> 1m columns) dataframe:
    #       pull one row at a time
    if num_cols > max_chunk_area:
        chunksize = 1
    #   round chunksize to nearest 1000
    if chunksize > 1000:
        chunksize = int(round(chunksize, -3))
    #   if num_rows is less than chunksize, only pull num_rows
    if chunksize > num_rows:
        chunksize = num_rows
    return chunksize


def update_edit_fields(update_df, editor_name=None, 
    editor_field='editor', edit_date_field='edit_date',
    readable_edit_date_field=None, overwrite=True):
    """
    Formerly called update_edit_fields_socrata.
    Updates the editor and edit date fields in a table. If overwrite is
    False, only updates null values
    """
    update_df = update_df.copy()
    if editor_field is not None:
        if overwrite or editor_field not in update_df:
                update_df[editor_field] = editor_name
        else:  # fill editor where it is null
            update_df[editor_field] = np.where(update_df[editor_field].isnull(),
                                               editor_name,
                                               update_df[editor_field])
    # set default edit date as now
    edit_ts = get_current_time(round_to_day=True)
    if overwrite or edit_date_field not in update_df:
        update_df[edit_date_field] = edit_ts
    else:
        # fill edit date where it is null
        update_df[edit_date_field] = np.where(update_df[edit_date_field].isnull(),
                                              edit_ts,
                                              update_df[edit_date_field])

    update_df[edit_date_field] = (pd.to_datetime(update_df[edit_date_field])
        .map(lambda x: x.isoformat()))
    if readable_edit_date_field is not None:
        update_df[readable_edit_date_field] = (update_df[edit_date_field]
            .map(iso_to_readable_ts)
            )
    return update_df


############### Text analysis functions ###############

def get_fuzz_ratio(a, b, ratio_type='simple'):
    """
    Returns the fuzzy match ratio of two strings:

    Valid ratio_types:
    ('simple', 'partial', 'token sort', 'token set')

    Apply to a dataframe like this:
    df['fuzz_ratio'] = df.apply(lambda x: get_fuzz_ratio(x['a'],
                                                         x['b']),
                                axis=1)

    Fuzzywuzzy docs: https://github.com/seatgeek/fuzzywuzzy
    """
    from fuzzywuzzy import fuzz
    try:
        if ratio_type == 'simple':
            return fuzz.ratio(a, b)
        if ratio_type == 'partial':
            return fuzz.partial_ratio(a, b)
        if ratio_type == 'token sort':
            return fuzz.token_sort_ratio(a, b)
        if ratio_type == 'token set':
            return fuzz.token_set_ratio(a, b)
    except Exception:
        return


############### Geo functions ###############

def get_wkt(x):
    """
    Given an ArcGIS geodata type, returns its WKT representation
    """
    return x.WKT


def to_shapely(x):
    """
    Given a WKT string or geojson shape, loads it as a shapely geo
    object
    """
    if type(x) == str:
        import shapely.wkt
        try:
            return shapely.wkt.loads(x)
        except:
            if x.split()[0] == 'MULTILINESTRING':
                return fix_multiline_string(x)
    if type(x) == dict:
        from shapely.geometry import shape
        return shape(x)


def to_poly(x, buffer):
    """
    Given a shapely geo object and buffer, returns the object if it's a
    polygon, otherwise returns the object as a buffered polygon
    """
    from shapely.geometry import Polygon, MultiPolygon
    if type(x) in [Polygon, MultiPolygon]:
        return x
    else:
        return x.buffer(buffer)


def to_multipoly(x):
    """
    Given a polygon object, returns it as a multipolygon
    From https://gis.stackexchange.com/a/215411
    """
    from shapely.geometry import Polygon, MultiPolygon
    if isinstance(x, Polygon):
        return MultiPolygon([x])
    if isinstance(x, MultiPolygon):
        return x


def fix_multiline_string(x):
    """
    Given a malformed wkt MULTILINESTRING (has a linestring with only
    one point), corrects the error (makes a line by duplicating the
    single point) and returns as a shapely multiline_string geom type
    """
    import shapely.wkt
    if x.split()[0] == 'MULTILINESTRING':
        fixed = []
        lines = ['(' + c.strip(',') for c in x.split('(') if c.strip(',').endswith(')')]
        for line_str in lines:
            pts = line_str.strip('(').strip(')').split(',')
            if len(pts) == 1:
                fixed.append('(' + ','.join(pts * 2) + ')')
            else:
                fixed.append(line_str)
    return shapely.wkt.loads('MULTILINESTRING (' + ', '.join(fixed))


def wkb_to_wkt(x):
    from shapely import wkb
    try:
        wkb_text = x.tobytes()
    except:
        wkb_text = binascii.unhexlify(x)
    return wkb.loads(wkb_text).wkt


def geom_to_hexwkb(x):
    """
    Given a shapely geometry object, returns
    its hexcode WKB (well known binary) representation.
    
    This is mostly used to load geometry data to Redshift
    (https://docs.aws.amazon.com/redshift/latest/dg/copy-usage_notes-spatial-data.html)
    """
    import binascii
    return binascii.hexlify(x.wkb).decode('utf-8')


def convert_3D_2D(x):
    """
    Given a 3D shapely geometry object, returns it as a 2D object
    """
    import shapely
    return shapely.wkb.loads(
        shapely.wkb.dumps(x, output_dimension=2))


def geom_is_valid(x):
    try:
        return True if x.is_valid else False
    except:
        pass


def correct_invalid_polygon(x):
    """
    Buffers invalid polygons to correct them

    WARNING: can mess with polygons with self-intersections, better to
    do this check/correction outside of this function to visually verify
    that resulting polygon is ok
    """
    if not geom_is_valid(x):
        x = x.buffer(0)
    return x


def get_closest_vertex(point, shape):
    """
    Given a Shapely point and gets the closest vertex on a shape
    (LineString or Polygon). If Polygon, gets closest vertex to
    exterior ring
    """
    import shapely
    from shapely.geometry import Point, LineString, Polygon, MultiPolygon
    if type(shape) not in [LineString, Polygon, MultiPolygon]:
        return
    distances = []
    if type(shape) == LineString:
        coords = line.coords
    if type(shape) in [Polygon, MultiPolygon]:
        coords = shape.exterior.coords
    for coord in coords:
        distances.append(point.distance(Point(coord)))
    distances = np.array(distances)
    return Point(coords[int(distances.argmin())])


def get_centroid(x, ensure_within=True):
    """
    Given a shapely Polygon, returns the centroid.
    If ensure_within is True, and centroid is not
    within the polygon, returns the representative_point
    """
    centroid = x.centroid
    if ensure_within and not x.intersects(centroid):
        centroid = x.representative_point()
    return centroid


def is_identical(geom_1, geom_2, buffer_amt=0.00000001):
    """
    Given two shapely geometry objects, returns True
    if geom_1.buffer(buffer_amt) contains geom_2
    and vice versa

    Example usage:
    -------------
    df['is_identical'] = df.apply(lambda x: is_identical(x['geo_1']
                                                         x['geo_2']),
                                  axis=1)
    """
    geom_1_contains = geom_1.buffer(buffer_amt).contains(geom_2)
    geom_2_contains = geom_2.buffer(buffer_amt).contains(geom_1)
    return True if geom_1_contains and geom_2_contains else False


def get_intersection(x, base_geom_col, overlay_geom_col, return_area=False):
    """
    If return_area=True, will return a Series of tuples. To add
    as dataframe columns, do like the following:

    Example usage:
    -------------
    x_area = gdf.apply(lambda x: get_intersection(x,
                                                  base_geom_col,
                                                  overlay_geom_col
                                                  return_area=True),
                       axis=1)

    gdf[['x_geom', 'x_area']] = pd.DataFrame(x_area.tolist(),
                                             index=gdf.index)
    """
    if not is_null(x[overlay_geom_col]) and not is_null(x[base_geom_col]):
        if return_area:
            return (x[base_geom_col].intersection(x[overlay_geom_col]),
                    x[base_geom_col].intersection(x[overlay_geom_col]).area / x[base_geom_col].area)
        else:
            return x[base_geom_col].intersection(x[overlay_geom_col])
    else:
        if return_area:
            return (np.nan, np.nan)
        else:
            return np.nan


def get_intersection_area(x, base_geom_col, overlay_geom_col):
    if not is_null(x[overlay_geom_col]) and not is_null(x[base_geom_col]):
        return x[base_geom_col].intersection(x[overlay_geom_col]).area / x[base_geom_col].area
    else:
        return 0


def socrata_poly_to_shapely(x):
    from shapely.geometry import Polygon
    return Polygon(x['coordinates'][0][0])


def load_geojson_str(x):
    """
    Loads a geojson string as a dictionary
    """
    return json.loads(x.replace("'", '"'))


def flatten_vehicle_position_update_d(update_d):
    """
    Given a Real-Time GTFS vehicle position update
    (from a JSONified Protocol buffer), flattens the update dictionary
    """
#     d = {'vehicle_id': update_d.get('id', None)}
#     if update_d.get('vehicle', None) is not None:
    d = {'vehicle_id': update_d['id']}
    if update_d['vehicle'].get('trip', None) is not None:
        trip_details = update_d['vehicle']['trip']
        update_attrs =  ['tripId', 'trip_startDate',
                         'routeId', 'trip_startDate']
        for attr in update_attrs:
            attr_value = trip_details.get(attr, None)
            if attr_value is not None:
                d[attr] = trip_details[attr]

    if update_d['vehicle'].get('position', None) is not None:
        vehicle_pos = update_d['vehicle']['position']
        update_attrs =  ['latitude', 'longitude',
                         'bearing']
        for attr in update_attrs:
            attr_value = vehicle_pos.get(attr, None)
            if attr_value is not None:
                d[attr] = vehicle_pos[attr]


    update_attrs =  ['currentStopSequence', 'currentStatus',
                     'timestamp', 'stopId']
    for attr in update_attrs:
        attr_value = update_d['vehicle'].get(attr, None)
        if attr_value is not None:
            d[attr] = update_d['vehicle'][attr]
    return d


def create_geo_intersection_area_table(base_gdf, base_id_col,
                                       overlay_gdf,
                                       overlay_id_col,
                                       buffer_dist=0.00000001,
                                       overlay_name='overlay',
                                       use_centroids=True,
                                       by_overlay=False,
                                       overlay_category_col=None,
                                       return_geom=False,
                                       correct_invalid_polygons=False):
    """
    Given a base GeoDataFrame with polygon types (e.g. parcels)
    and an overlay GeoDataFrame with polygon types
    (with the same projection), returns a dataframe of the base IDs and
    intersection area, or if by_overlay=True, returns a dataframe of
    the overlay IDs (or category if overlay_category_col is not None) 
    and intersection area of each base geometry in that overlay


    If the centroid of a record in the base_gdf is contained in an
    overlay, then that overlay is related to that record. Once this
    relation has been compiled, intersection areas (the base record's
    intersection area with the overlay) are computed so that the fina
    table includes base_id_col, overlay_id_col, and
    overlay_intersection_area

    TODO: add functionality for point only (area is for polygon)

    TODO: rework (simplify) using gpd.overlay

    """
    import geopandas as gpd
    a = time.time()
    base_gdf = base_gdf.copy()
    overlay_gdf = overlay_gdf.copy()

    base_geom_col = base_gdf.geometry.name
    overlay_geom_col = overlay_gdf.geometry.name

    # ensure that column names are not the same
    if base_geom_col == overlay_geom_col:
        new_overlay_geom_colname = '{}_overlay'.format(overlay_geom_col)
        overlay_gdf = (overlay_gdf
                       .rename(columns={overlay_geom_col: new_overlay_geom_colname})
                      .set_geometry(new_overlay_geom_colname))
        overlay_geom_col = new_overlay_geom_colname
    if base_id_col == overlay_id_col:
        new_overlay_id_colname = '{}_overlay'.format(overlay_id_col)
        overlay_gdf = overlay_gdf.rename(columns={overlay_id_col: new_overlay_id_colname})
        overlay_id_col = new_overlay_id_colname

    if correct_invalid_polygons:
        # buffer polygons if they are not valid
        # WARNING: can mess with polygons with self-intersections, better to do this check/correction
        # outside of this function to visually verify that resulting polygon is ok
        base_gdf[base_geom_col] = base_gdf[base_geom_col].map(correct_invalid_polygon)
        overlay_gdf[overlay_geom_col] = overlay_gdf[overlay_geom_col].map(correct_invalid_polygon)

    # ensure polygons
    base_gdf[base_geom_col] = base_gdf[base_geom_col].map(lambda x: to_poly(x, buffer_dist))
    overlay_gdf[overlay_geom_col] = overlay_gdf[overlay_geom_col].map(lambda x: to_poly(x, buffer_dist))

    # spatial join
    if use_centroids:  # join using base geometry centroids
        base_gdf_centroid = base_gdf.copy()
        base_gdf_centroid['centroid'] = base_gdf_centroid[base_geom_col].map(get_centroid)
        base_gdf_centroid = base_gdf_centroid.set_geometry('centroid')
        merged = gpd.sjoin(base_gdf_centroid, overlay_gdf, op='intersects', how='left')
        # set geometry back to polygon for intersection area calculations
        merged = merged.set_geometry(base_geom_col)
    else:  # join using polygon intersection
        merged = gpd.sjoin(base_gdf, overlay_gdf, op='intersects', how='left')
    rejoin_proj = overlay_gdf[[overlay_geom_col]].copy()
    rejoin_proj['index_right'] = rejoin_proj.index
    merged = merged.merge(rejoin_proj, how='left', on='index_right')
    intersection_area_df = pd.DataFrame(
        (merged
            .apply(lambda x: get_intersection(x,
                base_geom_col,
                overlay_geom_col,
                return_area=True),
            axis=1))
        .tolist(), index=merged.index)
    intersection_col = '{}_intersection'.format(overlay_name)
    intersection_area_col = '{}_intersection_area'.format(overlay_name)
    intersection_cols = [intersection_col, intersection_area_col]
    merged[intersection_cols] = intersection_area_df
    merged = gpd.GeoDataFrame(merged, geometry=intersection_col)

    geom_cols = [overlay_geom_col, base_geom_col, intersection_col, 'centroid']
    dedup_subset_cols = [c for c in merged if c not in geom_cols]
    # by overlay
    if by_overlay:
        if overlay_category_col is not None:  # if by overlay category
            merged = gpd.GeoDataFrame(merged, geometry=overlay_geom_col)
            merged = merged.dissolve(by=[base_id_col, overlay_category_col]).reset_index()
            merged[intersection_area_col] = merged.apply(lambda x: get_intersection_area(x, base_geom_col, overlay_geom_col), axis=1)
            if return_geom:
                return_cols = [overlay_id_col, overlay_category_col,
                               overlay_geom_col,
                               base_id_col, base_geom_col] + intersection_cols
            else:
                return_cols = [overlay_category_col, base_id_col, intersection_area_col]

            merged = (merged[~merged[overlay_category_col].isnull()]
                .sort_values(by=overlay_category_col)
                .drop_duplicates(subset=dedup_subset_cols)
                )

        else:  # by overlay id
            if return_geom:
                return_cols = [overlay_id_col, overlay_geom_col,
                               base_id_col, base_geom_col] + intersection_cols
            else:
                return_cols = [overlay_id_col, base_id_col, intersection_area_col]
            
            merged = (merged[~merged[overlay_id_col].isnull()]
                .sort_values(by=overlay_id_col)
                .drop_duplicates(subset=dedup_subset_cols)
                )
        final_df = merged[return_cols]
    # by base geometry
    else:
        no_null_intersection_geom = merged[~merged[intersection_col].isnull()]
        intersection = no_null_intersection_geom.dissolve(by=base_id_col).reset_index()[[base_id_col, intersection_col]]
        intersection = merged[[base_id_col, base_geom_col]].merge(intersection, on=base_id_col, how='left')
        intersection[intersection_area_col] = (intersection
                                             .apply(lambda x: get_intersection_area(x, base_geom_col, intersection_col),
                                                    axis=1))
        overlay_flag_colname = '{}_flag'.format(overlay_name)
        intersection[overlay_flag_colname] = np.where(intersection[intersection_area_col] > 0, 1, 0)
        if return_geom:
            return_cols = [base_id_col, base_geom_col,
                           overlay_flag_colname, intersection_area_col]
        else:
            return_cols = [base_id_col, overlay_flag_colname,
                           intersection_area_col]
        final_df = intersection[return_cols].drop_duplicates(subset=[base_id_col, intersection_area_col])
    b = time.time()
    print('geo intersection area table took {}'.format(print_runtime(b-a)))
    return final_df
