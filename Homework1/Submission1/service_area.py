import pandas as pd
ma_path2=(f'/Users/sushmitarajan/econ470spring2025/Homework1/Data/input/MA_Cnty_SA_2015_01.csv')
service_area= pd.read_csv(ma_path2,
                skiprows=1,
                encoding="ISO-8859-1",
                names=["contractid","org_name","org_type","plan_type","partial","eghp",
                       "ssa","fips","county","state","notes"],
                       dtype={"contractid": str,
                              "org_name": str,
                              "org_type": str,
                              "plan_type": str,
                              "partial": bool,
                              "eghp": str,
                              "ssa": float,
                              "fips": float,
                              "county": str,
                              "state": str,
                              "notes": str}, na_values="*")