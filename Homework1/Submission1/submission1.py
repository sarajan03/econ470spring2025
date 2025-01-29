import pandas as pd
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
contract_info["id_count"] = contract_info.groupby(["contractid", "planid"]).cumcount() + 1
contract_info = contract_info[contract_info["id_count"] == 1][["id_count"]]

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
        na_values="*"
    )
 Merge contract info with enrollment info
    plan_data = contract_info.merge(enroll_info, on=["contractid", "planid"], how="left")
    plan_data["year"] = y
    
    # Fill in missing fips codes by state and county
    plan_data["fips"] = plan_data.groupby(["state", "county"])["fips"].ffill()
    
    # Fill in missing plan characteristics by contract and plan id
    plan_data[["plan_type", "partd", "snp", "eghp", "plan_name"]] = plan_data.groupby(["contractid", "planid"])[["plan_type", "partd", "snp", "eghp", "plan_name"]].ffill()
    
    # Fill in missing contract characteristics by contractid
    plan_data[["org_type", "org_name", "org_marketing_name", "parent_org"]] = plan_data.groupby("contractid")[["org_type", "org_name", "org_marketing_name", "parent_org"]].ffill()
    
    # Collapse from monthly data to yearly and rename enrollment column
    plan_year = plan_data.groupby(["contractid", "planid", "fips"]).agg({"enrollment": "mean"}).reset_index()
    plan_year = plan_year.rename(columns={"enrollment": "avg_enrollment"})
    
    # Save output file
    plan_year.to_pickle(f"data/output/ma_dat.pkl")
