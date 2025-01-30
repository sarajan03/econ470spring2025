import pandas as pd

import os 
ma_path = (f'/Users/sushmitarajan/econ470spring2025/Homework1/Data/input/CPSC_Contract_Info_2015_01.csv')
contract_info = pd.read_csv(ma_path, encoding="latin1", skiprows=1, names=[ "contractid", "planid", "org_type", "plan_type", "partd", "snp", "eghp", "org_name", "org_marketing_name", "plan_name", "parent_org", "contract_date"], dtype= {
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
# Add id_count by grouping
contract_info["id_count"] = contract_info.groupby(["contractid", "planid"]).cumcount() + 1
# Filter and drop id_count
contract_info = contract_info[contract_info["id_count"] == 1].drop(columns=["id_count"])

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
enroll_info
# Merge contract info with enrollment info
plan_data = contract_info.merge(enroll_info, on=["contractid", "planid"], how="left")
plan_data
plan_data["year"] = y 
# Fill missing fips codes by state and county
plan_data.sort_values(by=["state", "county"], inplace=True)
plan_data["fips"] = plan_data.groupby(["state", "county"])["fips"].fillna(method="ffill").fillna(method="bfill")
# Fill missing plan characteristics by contract and plan id
plan_data.sort_values(by=["contractid", "planid"], inplace=True)
plan_data[["plan_type", "partd", "snp", "eghp", "plan_name"]] = plan_data.groupby(["contractid", "planid"])[["plan_type", "partd", "snp", "eghp", "plan_name"]].fillna(method="ffill").fillna(method="bfill")
# Fill missing contract characteristics by contractid
plan_data[["org_type", "org_name", "org_marketing_name", "parent_org"]] = plan_data.groupby("contractid")[["org_type", "org_name", "org_marketing_name", "parent_org"]].fillna(method="ffill").fillna(method="bfill")

plan_data


