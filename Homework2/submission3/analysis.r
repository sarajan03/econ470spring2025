
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, dplyr, lubridate)
library(Matching)

#read final HCRIS data
final.hcris.data <- readRDS('/Users/sushmitarajan/econ470spring2025/Homework2/submission2/data/output/HCRIS_Data.rds')

# ================================
# QUESTION 1: NUMBER OF HOSPITALS FILING MULTIPLE REPORTS PER YEAR
# ================================
hcris_q1 <- final.hcris.data

# Group data by year and provider number to count reports per hospital per year
report_counts <- hcris_q1 %>%
  group_by(year, provider_number) %>%
  summarise(report_count = n(), .groups = "drop")

# Identify hospitals that filed more than one report per year
hospitals_with_multiple_reports <- report_counts %>%
  filter(report_count > 1) %>%
  group_by(year) %>%
  summarise(num_hospitals = n(), .groups = "drop")

# Ensure all years are included
all_years <- data.frame(year = unique(hcris_q1$year)

# Merge data and fill missing values with 0
hospitals_with_multiple_reports <- left_join(all_years, hospitals_with_multiple_reports, by = "year") %>%
  mutate(num_hospitals = ifelse(is.na(num_hospitals), 0, num_hospitals))

# Create line plot for number of hospitals filing multiple reports
q1_ggplot <- ggplot(hospitals_with_multiple_reports, aes(x = year, y = num_hospitals)) +
  geom_line(color = "purple", size = 1) +
  geom_point(color = "hotpink", size = 2) +
  labs(title = "Number of Hospitals Filing More Than One Report Per Year",
       x = "Year",
       y = "Hospital Count") +
  theme_minimal()

# ================================
# QUESTION 2: NUMBER OF UNIQUE HOSPITALS PER YEAR
# ================================
hcris_q2 <- final.hcris.data

# Count unique provider numbers per year
count_per_year <- hcris_q2 %>%
  group_by(year) %>%
  summarise(unique_hospitals = n_distinct(provider_number), .groups = "drop")

# Create line plot for unique hospital counts
q2_ggplot <- ggplot(count_per_year, aes(x = year, y = unique_hospitals)) +
  geom_line(color = "purple", size = 2) +
  geom_point(color ='red', size = 2) +
  labs(title = "Number of Unique Hospital IDs Per Year",
       x = "Year",
       y = "Count of Unique Provider Numbers") +
  theme_minimal()

# ================================
# QUESTION 3: DISTRIBUTION OF TOTAL CHARGES (FILTERED FOR OUTLIERS)
# ================================
hcris_q3 <- final.hcris.data

# Remove top and bottom 1% of total charges per year to filter out extreme values
filtered_data <- hcris_q3 %>%
  filter(!is.na(tot_charges), tot_charges > 0) %>%
  group_by(year) %>%
  summarise(lower_bound = quantile(tot_charges, probs = 0.01, na.rm = TRUE),
            upper_bound = quantile(tot_charges, probs = 0.99, na.rm = TRUE)) %>%
  right_join(hcris_q3, by = "year") %>%
  filter(tot_charges > lower_bound, tot_charges < upper_bound, year > 1997) %>%
  ungroup()

# Create violin plot for total charges distribution
q3_ggplot <- ggplot(filtered_data, aes(x = as.factor(year), y = tot_charges)) +
  geom_violin(fill = "#8A2BE2", color = "#006400", alpha = 0.75, adjust = 1) +
  scale_y_log10() +
  labs(title = "Distribution of Total Charges Over the Years",
       x = "Year of Report",
       y = "Log of Total Charges",
       caption = "Data Source: HCRIS (Medicare/Medicaid) | Outliers (Top & Bottom 1%) Removed") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# ================================
# QUESTION 4: DISTRIBUTION OF ESTIMATED PRICES BY YEAR
# ================================
hcris_q4 <- final.hcris.data

# Calculate estimated price per discharge, accounting for total discounts
price_data <- hcris_q4 %>%
  mutate(price_num = (ip_charges + icu_charges + ancillary_charges) * (1 - tot_discounts / tot_charges) - tot_mcare_payment,
         price_denom = tot_discharges - mcare_discharges,
         price = if_else(price_denom > 0, price_num / price_denom, NA_real_)) %>%
  filter(price_denom > 100, price_num > 0, !is.na(price), price < 100000, beds > 30) %>%
  group_by(year) %>%
  mutate(lower_bound = quantile(price, 0.01, na.rm = TRUE), upper_bound = quantile(price, 0.99, na.rm = TRUE)) %>%
  filter(price >= lower_bound, price <= upper_bound) %>%
  ungroup()

# Create violin plot for estimated prices per year
q4_ggplot <- ggplot(price_data, aes(x = as.factor(year), y = price)) +
  geom_violin(trim = TRUE, fill = "#8A2BE2", color = "blue", scale = "width") +
  scale_y_continuous(expand = expansion(mult = c(0.1, 0.1))) +
  labs(title = "Distribution of Estimated Prices by Year",
       x = "Year",
       y = "Estimated Prices") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# ================================
# QUESTION 5: AVERAGE PRICE AMONG PENALIZED VS. NON-PENALIZED HOSPITALS
# ================================
hcris_q5 <- final.hcris.data

# Process data for hospitals in 2012, applying filtering criteria
hcris_2012 <- hcris_q5 %>%
  filter(year == 2012) %>%
  mutate(discount_factor = 1 - tot_discounts / tot_charges,
         price_num = (ip_charges + icu_charges + ancillary_charges) * discount_factor - tot_mcare_payment,
         price_denom = tot_discharges - mcare_discharges,
         price = if_else(price_denom > 0, price_num / price_denom, NA_real_),
         hvbp_payment = replace_na(hvbp_payment, 0),
         hrrp_payment = abs(replace_na(hrrp_payment, 0)),
         penalty = hvbp_payment < hrrp_payment) %>%
  filter(price_denom > 100, price_num > 0, !is.na(price), price < 100000, beds > 30)

# Calculate mean prices for penalized and non-penalized hospitals
mean_penalized <- round(mean(hcris_2012$price[hcris_2012$penalty == TRUE], na.rm = TRUE), 2)
mean_non_penalized <- round(mean(hcris_2012$price[hcris_2012$penalty == FALSE], na.rm = TRUE), 2)

# Print mean prices
print(mean_penalized)
print(mean_non_penalized)

# QUESTION 6: Compute quartiles based on bed size and summary statistics
# ================================

# Rename dataset for clarity and convenience
hcris_q6 <- hcris_2012  # Original dataset

# Compute the 25th, 50th, and 75th percentiles (quartiles) of the 'beds' variable
bed_quartiles <- quantile(hcris_q6$beds, probs = c(0.25, 0.5, 0.75, 1), na.rm = TRUE)

# Assign hospitals to quartiles based on their bed size using 'ifelse'
hcris_q6 <- hcris_q6 %>% 
  mutate(
    Q1 = ifelse(beds <= bed_quartiles[1] & beds > 0, 1, 0),
    Q2 = ifelse(beds > bed_quartiles[1] & beds <= bed_quartiles[2], 1, 0),
    Q3 = ifelse(beds > bed_quartiles[2] & beds <= bed_quartiles[3], 1, 0),
    Q4 = ifelse(beds > bed_quartiles[3], 1, 0)
  )

# Create a new variable 'bed_quartile' to store the quartile label
hcris_q6 <- hcris_q6 %>% 
  mutate(
    bed_quartile = case_when(
      Q1 == 1 ~ "Q1",
      Q2 == 1 ~ "Q2",
      Q3 == 1 ~ "Q3",
      Q4 == 1 ~ "Q4"
    )
  )

# Calculate average prices by quartile and penalty status
hcris_q6 <- hcris_q6 %>% 
  group_by(bed_quartile, penalty) %>% 
  summarise(avg_price = mean(price, na.rm = TRUE), .groups = "drop") %>% 
  pivot_wider(names_from = penalty, values_from = avg_price, names_prefix = "penalty_")

# Renaming columns for clarity
hcris_q6 <- hcris_q6  %>% 
  rename(
    `No Penalty` = `penalty_FALSE`,
    `Penalty` = `penalty_TRUE`
  )


# Print the summary table for visual inspection
print(hcris_q6)

knitr::kable(hcris_q6, 
             caption = "Summary of Prices for Penalized and Non-Penalized Hospitals", 
             col.names = c("Bed Quartile", "No Penalty", "Penalty"))

# ================================
# QUESTION 7: Find the average treatment effect using each of the following estimators
# ================================
hcris_q7 <- hcris_2012  # Original dataset

# Compute the 25th, 50th, and 75th percentiles (quartiles) of the 'beds' variable
bed_quartiles <- quantile(hcris_q7$beds, probs = c(0.25, 0.5, 0.75, 1), na.rm = TRUE)

# Assign hospitals to quartiles based on their bed size using 'ifelse'
hcris_q7 <- hcris_q7 %>%
  mutate(
    Q1 = ifelse(beds <= bed_quartiles[1] & beds > 0, 1, 0),
    Q2 = ifelse(beds > bed_quartiles[1] & beds <= bed_quartiles[2], 1, 0),
    Q3 = ifelse(beds > bed_quartiles[2] & beds <= bed_quartiles[3], 1, 0),
    Q4 = ifelse(beds > bed_quartiles[3], 1, 0)
  )

# Create a new variable 'bed_quartile' to store the quartile label
hcris_q7 <- hcris_q7 %>%
  mutate(
    bed_quartile = case_when(
      Q1 == 1 ~ "Q1",
      Q2 == 1 ~ "Q2",
      Q3 == 1 ~ "Q3",
      Q4 == 1 ~ "Q4"
    )
  )
# Nearest neighbor matching (1-to-1) with inverse variance distance based on quartiles of bed size-----

# Create the treatment indicator (penalty) and other necessary variables for analysis
hcris_q7 <- hcris_q7 %>% 
  mutate(
    hvbp_payment = as.numeric(hvbp_payment),
    hrrp_payment = as.numeric(hrrp_payment),
    penalty = hvbp_payment < hrrp_payment  # Logical TRUE/FALSE condition
  )
# Perform matching with quartiles of bed size as covariates
match.inv <- Matching::Match(
  Y = hcris_q7$price,  # Outcome variable (price)
  Tr = hcris_q7$penalty,  # Treatment indicator (penalty)
  X = hcris_q7[, c("Q1", "Q2", "Q3", "Q4")],  # Covariates for matching (quartiles of bed size)
  M = 1,  # 1-to-1 matching
  Weight = 1,  # Equal weighting
  estimand = "ATE"  # Estimating the Average Treatment Effect (ATE)
)

# Check the summary of the matching
summary(match.inv)

# Nearest neighbor matching (1-to-1) with Mahalanobis distance based on quartiles of bed size------
match.mah <- Matching:: Match (
      Y=hcris_q7$price,
      Tr= hcris_q7$penalty,
      X = hcris_q7[, c("Q1", "Q2", "Q3", "Q4")],
      M = 1,  # 1-to-1 matching
      Weight = 2,  # Equal weighting
      estimand = "ATE"  # Estimating the Average Treatment Effect (ATE))
)

summary(match.mah)

# Inverse propensity weighting, where the propensity scores are based on quartiles of bed size-----

logit.model <- glm(penalty ~ Q1 + Q2 + Q3 + Q4,
                   family = binomial,
                   data = hcris_q7)

# Calculate the propensity scores
ps <- fitted(logit.model)

# Add the inverse propensity weights
hcris_q7 <- hcris_q7 %>%
  ungroup() %>%
  mutate(ipw = case_when(
    penalty == 1 ~ 1 / ps,            # IPW for treated (penalty = 1)
    penalty == 0 ~ 1 / (1 - ps),      # IPW for control (penalty = 0)
    TRUE ~ NA_real_                   # NA for any missing or undefined cases
  ))

mean.t1 <- hcris_q7 %>%
  filter(penalty == 1) %>%
  summarise(mean_p = weighted.mean(price, w = ipw, na.rm = TRUE))
mean.t0 <- hcris_q7 %>%
  filter(penalty == 0) %>%
  summarise(mean_p = weighted.mean(price, w = ipw, na.rm = TRUE))

ipw.diff <- mean.t1$mean_p - mean.t0$mean_p

ipw.reg <- lm(price ~ penalty, data=hcris_q7, weights=ipw)

print(ipw.diff)
summary(ipw.reg)


# Simple linear regression, adjusting for quartiles of bed size using dummy variables
reg.data <- hcris_q7 %>% ungroup() %>%
  mutate(Q1_diff = penalty * (Q1 - mean(Q1)),
         Q2_diff = penalty * (Q2 - mean(Q2)),
         Q3_diff = penalty * (Q3 - mean(Q3)))

# Run a linear regression adjusting for quartiles of bed size using dummy variables
reg <- lm(price ~ penalty + Q1 + Q2 + Q3 + 
            Q1_diff + Q2_diff + Q3_diff,
          data = reg.data)

# Show summary of the regression
summary(reg)
#ATEfor simple regression
ate <- coef(reg)
ate <-ate["penaltyTRUE"]


#Get Coefficients of each estimate
ate_1 <- match.inv$est
ate_2 <- match.mah$est
ate_3 <- ipw.diff
ate_4 <- ate

#Creating Table with Summary 
ate_estimates <- data.frame(
  Method = c(
    "Nearest Matching (Inverse Variance)",
    "Nearest Matching (Mahalanobis Distance)",
    "Inverse Propensity Weighting (IPW)",
    "Linear Regression"
  ),
  ATE_Estimate = c(ate_1, ate_2, ate_3, ate_4)
)
ate_estimates

knitr::kable(ate_estimates, 
             caption = "ATE Estimates from Different Methods", 
             col.names = c("Method", "ATE Estimate"))


# ================================
# Save workspace
# ================================
save.image("/Users/sushmitarajan/econ470spring2025/Homework2/submission3/results/Hwk2_workspace.RData")
