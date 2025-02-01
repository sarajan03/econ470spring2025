import pandas as pd
import os
import numpy as np

contract_service_area = pd.DataFrame()

ma_path2=(f'/Users/sushmitarajan/econ470spring2025/Homework1/Submission2/Data/input/MA_Cnty_SA_2015_01.csv')
service_area= pd.read_csv(ma_path2,
                skiprows=1,
                encoding="ISO-8859-1",
                names=["contractid","org_name","org_type","plan_type","partial","eghp",
                       "ssa","fips","county","state","notes"],
                       dtype={"contractid": str,
                              "org_name": str,
                              "org_type": str,
                              "plan_type": str,
                              "partial": str,
                              "eghp": str,
                              "ssa": float,
                              "fips": float,
                              "county": str,
                              "state": str,
                              "notes": str}, na_values="*")
# Process the data
service_area['month'] = month
service_area['year'] = year
service_area['partial'] = np.where(service_area['partial'] == '*', True, False)
service_area['eghp'] = np.where(service_area['eghp'] == 'Y', True, False)

# Fill in missing fips codes (by state and county)
service_area['fips'] = service_area.groupby(['state', 'county'])['fips'].ffill().bfill()

# Fill in missing plan type, org info, partial status, and eghp status (by contractid)
list_chars = ['plan_type', 'org_name', 'org_type', 'partial', 'eghp']
for char in list_chars:
    service_area[char] = service_area.groupby('contractid')[char].ffill().bfill()

# Save to output
contract_service_area = pd.concat([contract_service_area, service_area], ignore_index=True)


contract_service_area.to_csv("/Users/sushmitarajan/econ470spring2025/Homework1/submission2/data/output/contract_service_area.csv", index=False)

