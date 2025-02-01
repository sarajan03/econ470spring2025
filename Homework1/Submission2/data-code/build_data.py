import pandas as pd

# Define file paths
full_ma_data_path = "/Users/sushmitarajan/econ470spring2025/Homework1/submission2/data/output/full_ma_data.csv"
contract_service_area_path = "/Users/sushmitarajan/econ470spring2025/Homework1/submission2/data/output/contract_service_area.csv"

# Read CSV files
full_ma_data = pd.read_csv(full_ma_data_path)
contract_service_area = pd.read_csv(contract_service_area_path)

# Display the first few rows of each dataset
print("Full MA Data:")
print(full_ma_data.head())

print("\nContract Service Area Data:")
print(contract_service_area.head())