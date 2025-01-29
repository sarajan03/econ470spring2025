import pandas as pd
import os 
ma_path = (f'/Users/sushmitarajan/econ470spring2025/Homework1/Data/input/CPSC_Contract_Info_2015_01.csv')
contract_info = pd.read_csv(ma_path, encoding="ISO-8859-1", skiprows=1, names=[ "contractid", "planid", "org_type", "plan_type", "partd", "snp", "eghp", "org_name", "org_marketing_name", "plan_name", "parent_org", "contract_date"], dtype= {
                "contractid": str,
                "planid": float,
                "org_type": str,
                "plan_type": str,
                "partd": str,
                "snp": str,
                "eghp": str,
                "org_name": str,
                "org_marketing_name": str,
                "plan_name": str,
                "parent_org": str,
                "contract_date": str })
contract_info
# Group by contractid and planid, then add a row number column
contract_info["id_count"] = contract_info.groupby(["contractid", "planid"]).cumcount() + 1
# Filter for rows where id_count is 1
contract_info = contract_info[contract_info["id_count"] == 1]

contract_info
ma_path1=(f'/Users/sushmitarajan/econ470spring2025/Homework1/Data/input/CPSC_Enrollment_Info_2015_01.csv')
enroll_info = pd.read_csv(
        ma_path1,
        skiprows=1,
        names=["contractid", "planid", "ssa", "fips", "state", "county", "enrollment"],
        dtype={
            "contractid": str,
            "planid": float,
            "ssa": float,
            "fips": float,
            "state": str,
            "county": str,
            "enrollment": float
        },
        na_values="*")
 Merge contract info with enrollment info
    plan_data = contract_info.merge(enroll_info, on=["contractid", "planid"], how="left")
plan_data
plan_data["2015"] = 2015
ma_path2=(f'/Users/sushmitarajan/econ470spring2025/Homework1/Data/input/MA_Cnty_SA_2015_01.csv')
SA= pd.read_csv(ma_path2,
                skiprows=1, 
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