import pandas as pd
import os 
full_ma_data = pd.DataFrame()

ma_path = ('/Users/sushmitarajan/econ470spring2025/Homework1/Submission2/Data/input/CPSC_Contract_Info_2015_01.csv')
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
# Add id_count by grouping
contract_info["id_count"] = contract_info.groupby(["contractid", "planid"]).cumcount() + 1
# Filter and drop id_count
contract_info = contract_info[contract_info["id_count"] == 1].drop(columns=["id_count"])
contract_info
ma_path1=('/Users/sushmitarajan/econ470spring2025/Homework1/Submission2/Data/input/CPSC_Enrollment_Info_2015_01.csv')
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
year = 2015
plan_data["year"] = year
# Fill missing fips codes by state and county
plan_data.sort_values(by=["state", "county"], inplace=True)
plan_data["fips"] = plan_data.groupby(["state", "county"])["fips"].ffill().bfill()
# Fill missing plan characteristics by contract and plan id
plan_data.sort_values(by=["contractid", "planid"], inplace=True)
plan_data[["plan_type", "partd", "snp", "eghp", "plan_name"]] = plan_data.groupby(["contractid", "planid"])[["plan_type", "partd", "snp", "eghp", "plan_name"]].ffill().bfill()

# Fill missing contract characteristics by contractid
plan_data[["org_type", "org_name", "org_marketing_name", "parent_org"]] = plan_data.groupby("contractid")[["org_type", "org_name", "org_marketing_name", "parent_org"]].ffill().bfill()

plan_data.rename(columns={'enrollment': 'avg_enrollment'}, inplace=True)
full_ma_data = pd.concat([full_ma_data, plan_data], ignore_index=True)


full_ma_data.to_csv("/Users/sushmitarajan/econ470spring2025/Homework1/submission2/data/output/full_ma_data.csv", index=False)

