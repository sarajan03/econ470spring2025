import pandas as pd

# Read the output datasets into pandas DataFrames
# 'full_ma_data' contains Medicare Advantage (MA) plan data
full_ma_data = pd.read_csv('/Users/sushmitarajan/econ470spring2025/Homework1/submission2/data/output/full_ma_data.csv')

# 'contract_service_area' contains the contract service area data
contract_service_area = pd.read_csv('/Users/sushmitarajan/econ470spring2025/Homework1/submission2/data/output/contract_service_area.csv')

# Pivot table to get the number of plans per 'plan_type' and 'year'
# This groups the data by 'plan_type' and 'year', and counts the number of distinct 'planid's for each combination
plans_per_type = full_ma_data.pivot_table(
    index='plan_type',  # Rows will represent different 'plan_type'
    columns='year',     # Columns will represent different years
    values='planid',    # We will count the occurrences of 'planid' for each combination of 'plan_type' and 'year'
    aggfunc='count'     # Aggregation function is 'count' to count the number of plans
)

# Filter out the SNP and EGHP plans, as well as plans with 'planid' between 800 and 899
# This creates a filtered DataFrame 'final_ma_data' that excludes SNP (Special Needs Plans) and EGHP (Employer/Union Health Plans),
# and excludes plans with 'planid' in the range 800-899 (likely considered invalid or irrelevant)
final_ma_data = full_ma_data[
    (full_ma_data['snp'] == "No") &  # Exclude SNP plans (Special Needs Plans)
    (full_ma_data['eghp'] == "No") & # Exclude EGHP plans (Employer/Union Health Plans)
    ((full_ma_data['planid'] < 800) | (full_ma_data['planid'] >= 900))  # Exclude plans with 'planid' between 800 and 899
]

# Create a new pivot table 'plans_per_type2' based on the filtered 'final_ma_data'
# This table gives the number of plans per 'plan_type' and 'year' for the filtered data
plans_per_type2 = final_ma_data.pivot_table(
    index='plan_type',  # Rows represent different 'plan_type'
    columns='year',     # Columns represent different years
    values='planid',    # We will count the occurrences of 'planid' for each combination of 'plan_type' and 'year'
    aggfunc='count'     # Aggregation function is 'count' to count the number of plans
)

# Pivot table to calculate the average enrollment per plan type and year
# This table groups the data by 'plan_type' and calculates both 'count' and 'mean' for 'avg_enrollment'
enrollment_per_type = final_ma_data.pivot_table(
    index='plan_type',              # Group data by 'plan_type'
    values='avg_enrollment',         # We are calculating on 'avg_enrollment'
    aggfunc={'avg_enrollment': ['count', 'mean']}  # Apply both 'count' (to count plans) and 'mean' (to calculate the average enrollment)
)

 
print(enrollment_per_type)