
# 1)How many hospitals filed more than one report in the same year? Show your answer as a line graph of the number of hospitals over time. 

# Count reports per hospital per year
report_counts <- final.hcris.data %>%
  group_by(year, provider_number) %>%
  summarise(report_count = n(), .groups = "drop")

# View the counts
table(report_counts$report_count)  # This will show the frequency of report counts

# Ensure the dataset is in a dataframe format
hcris_data <- as.data.frame(final.hcris.data)  # Assuming your data is already loaded in R

# Check column names to confirm the correct address column
colnames(hcris_data)  

# Count reports per street per year
report_counts <- hcris_data %>%
  group_by(year, street) %>%
  summarise(report_count = n(), .groups = "drop")

# Count the number of addresses (streets) that filed more than one report per year
streets_with_multiple_reports <- report_counts %>%
  filter(report_count > 1) %>%
  group_by(year) %>%
  summarise(num_streets = n(), .groups = "drop")

# Ensure all years are included (even if no streets had multiple reports)
all_years <- data.frame(year = unique(hcris_data$year))

# Only join if streets_with_multiple_reports is not empty
if (nrow(streets_with_multiple_reports) > 0) {
  streets_with_multiple_reports <- left_join(all_years, streets_with_multiple_reports, by = "year") %>%
    mutate(num_streets = ifelse(is.na(num_streets), 0, num_streets))
} else {
  # If no streets had multiple reports, create an empty dataframe with zeros
  streets_with_multiple_reports <- all_years %>%
    mutate(num_streets = 0)
}

# Debugging: Print to check the dataframe
print(streets_with_multiple_reports)

# Plot the results as a line graph
ggplot(streets_with_multiple_reports, aes(x = year, y = num_streets)) +
  geom_line(color = "pink", size = 1) +
  geom_point(color = "hotpink", size = 2) +
  labs(title = "Number of Hospitals Filing More Than One Report Per Year",
       x = "Year",
       y = "Hospital Count") +
  theme_minimal()


# 2)Count the number of unique hospital IDs

# Count unique provider numbers for each year
count_per_year <- final.hcris.data %>% 
  group_by(year) %>%  # group by year
  summarise(unique_hospitals = n_distinct(provider_number), .groups = "drop") #call the unique hospitals per year

# Plot using ggplot2
ggplot(count_per_year, aes(x = year, y = unique_hospitals)) +
  geom_line(color = "purple", size = 2) +  # Line plot 
  geom_point(color ='red', size = 2)
  labs(title = "Number of Unique Hospital IDs Per Year", 
       x = "Year", 
       y = "Count of Unique Provider Numbers") +
  theme_minimal()

# Print the result to the console
print(count_per_year)

# 3) What is the distribution of total charges (tot_charges in the data) in each year?

# Remove top 1% and bottom 1% of total charges
# Filter data

filtered_data <- final.hcris.data %>%
  # Remove NA and zero values
  filter(!is.na(tot_charges), tot_charges > 0) %>%
  
  # Group by year to calculate quantile thresholds within each year
  group_by(year) %>%
  summarise(
    lower_bound = quantile(tot_charges, probs = 0.01, na.rm = TRUE),
    upper_bound = quantile(tot_charges, probs = 0.99, na.rm = TRUE)
  ) %>%
  
  # Join back to filter values based on computed bounds
  right_join(final.hcris.data, by = "year") %>%
  filter(!is.na(tot_charges), tot_charges > lower_bound, tot_charges < upper_bound, year>1997) %>%
  
  # Ungroup after filtering
  ungroup()


# Violin Plot for Total Charges Distribution (with outlier filtering)
ggplot(filtered_data, aes(x = as.factor(year), y = tot_charges)) + 
  geom_violin(fill = "#8A2BE2", color = "#006400", alpha = 0.75, adjust = 1) +  # Violet fill and dark green outline
  
  # Apply a log scale to the y-axis and format labels with commas for readability
  scale_y_log10() + 
  
  # Add titles, axis labels, and caption
  labs(
    title = "Distribution of Total Charges Over the Years (1% Trimmed)",
    x = "Year of Report",
    y = "Log of Total Charges",
    caption = "Data Source: HCRIS (Medicare/Medicaid) | Outliers (Top & Bottom 1%) Removed"
  ) +
  
  # Minimal theme for better aesthetics
  theme_minimal() 

   theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    plot.title = element_text(hjust = 0.5, size = 16),
    plot.caption = element_text(size = 10)
  )


# 4) Distribution of Estimated Prices by Year (Updated)

# Process and clean data
price.data <- final.hcris.data %>%
  mutate(
    discount_factor = 1 - tot_discounts / tot_charges,
    price_num = (ip_charges + icu_charges + ancillary_charges) * discount_factor - tot_mcare_payment,
    price_denom = tot_discharges - mcare_discharges,
    price = if_else(price_denom > 0, price_num / price_denom, NA_real_)  # Prevent division by zero
  ) %>%
  filter(
    price_denom > 100,       # Remove hospitals with low discharge counts
    !is.na(price_denom), 
    price_num > 0,           # Ensure positive numerator
    !is.na(price_num), 
    price < 100000,          # Remove extreme outliers
    beds > 30,               # Only keep hospitals with >30 beds
    !is.na(beds)
  ) %>%
  mutate(log_price = log(price))  # Apply log transformation

# Create violin plot with purple fill and green outline
ggplot(price.data, aes(x = as.factor(year), y = log_price)) +
  geom_violin(trim = TRUE, fill = "#8A2BE2", color = "#006400") +  # Purple fill, Green outline
  labs(
    title = "Distribution of Log-Transformed Estimated Prices by Year",
    x = "Year",
    y = "Log of Estimated Prices"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# 5)Calculate the average price among penalized versus non-penalized hospitals.
# Load necessary library
# Load necessary library

# Step 1: Compute discount factor and price metrics
hcris.2012 <- final.hcris.data %>%
  mutate(
    # Calculate the discount factor (adjusts for total discounts)
    discount_factor = 1 - tot_discounts / tot_charges,
    
    # Compute price numerator: total charges (adjusted for discounts) minus Medicare payments
    price_num = (ip_charges + icu_charges + ancillary_charges) * discount_factor - tot_mcare_payment,
    
    # Compute price denominator: total discharges minus Medicare discharges
    price_denom = tot_discharges - mcare_discharges,
    
    # Compute price, ensuring no division by zero
    price = if_else(price_denom > 0, price_num / price_denom, NA_real_)
  ) 

# Step 2: Apply filtering conditions
final.hcris.2012 <- hcris.2012 %>%
  filter(
    price_denom > 100,         # Ensure a meaningful number of discharges
    !is.na(price_denom),       # Exclude missing price denominators
    price_num > 0,             # Keep only positive price numerators
    !is.na(price_num),         # Exclude missing price numerators
    price < 100000,            # Filter out extreme price values
    beds > 30,                 # Consider hospitals with >30 beds
    year == 2012               # Focus only on data from 2012
  ) %>%
  mutate(
    # Replace missing values in HVBP payments with 0
    hvbp_payment = replace_na(hvbp_payment, 0),
    
    # Replace missing values in HRRP payments with 0 and take absolute value
    hrrp_payment = abs(replace_na(hrrp_payment, 0)),
    
    # Determine if a penalty exists (HVBP payment is less than HRRP payment)
    penalty = hvbp_payment < hrrp_payment
  )

# Step 3: Debugging & Validation
print(summary(final.hcris.2012))  # Print summary statistics
print(nrow(final.hcris.2012))     # Check the number of remaining rows
print(head(final.hcris.2012))     # Preview the first few rows


# Step 2: Apply filtering conditions
final.hcris.2012 <- hcris.2012 %>%
  filter(
    price_denom > 100,         # Ensure a meaningful number of discharges
    !is.na(price_denom),       # Exclude missing price denominators
    price_num > 0,             # Keep only positive price numerators
    !is.na(price_num),         # Exclude missing price numerators
    price < 100000,            # Filter out extreme price values
    beds > 30,                 # Consider hospitals with >30 beds
    year == 2012               # Focus only on data from 2012
  ) %>%
  mutate(
    # Replace missing values in HVBP payments with 0
    hvbp_payment = replace_na(hvbp_payment, 0),
    
    # Replace missing values in HRRP payments with 0 and take absolute value
    hrrp_payment = abs(replace_na(hrrp_payment, 0)),
    
    # Determine if a penalty exists (HVBP payment is less than HRRP payment)
    penalty = hvbp_payment < hrrp_payment
  )

# Step 3: Debugging & Validation
print(summary(final.hcris.2012))  # Print summary statistics
print(nrow(final.hcris.2012))     # Check the number of remaining rows
print(head(final.hcris.2012))     # Preview the first few rows


# 6) Split hospitals into quartiles based on bed size. To do this, create 4 new indicator variables, where each variable is set to 1 if the hospital’s bed size falls into the relevant quartile. Provide a table of the average price among treated/control groups for each quartile.

# 7) Find the average treatment effect using each of the following estimators, and present your results in a single table:
 # Nearest neighbor matching (1-to-1) with inverse variance distance based on quartiles of bed size
 # Nearest neighbor matching (1-to-1) with Mahalanobis distance based on quartiles of bed size
 # Inverse propensity weighting, where the propensity scores are based on quartiles of bed size
 # Simple linear regression, adjusting for quartiles of bed size using dummy variables and appropriate interactions as discussed in class

# 8) With these different treatment effect estimators, are the results similar, identical, very different?

# 9) Do you think you’ve estimated a causal effect of the penalty? Why or why not? (just a couple of sentences)

# 10) Briefly describe your experience working with these data (just a few sentences). Tell me one thing you learned and one thing that really aggravated or surprised you.







save.image("/Users/sushmitarajan/econ470spring2025/Homework2/submission2/results/Hwk2_workspace.RData")
dir.create("/Users/sushmitarajan/econ470spring2025/Homework2/submission2/results", recursive = TRUE)