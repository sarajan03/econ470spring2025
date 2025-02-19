if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, dplyr, lubridate)

#Create objects for qmd
final.hcris.data <- readRDS('/Users/sushmitarajan/econ470spring2025/Homework2/submission2/data/output/HCRIS_Data.rds')

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

count <- final.hcris.data %>% 
  summarise(.groups ="drop") %>%
  distinct(provider_number)%>% # Get unique provider numbers
  nrow()  # Count the number of unique provider numbers

# Print the result to the console
cat("Number of unique hospital IDs (Medicare provider numbers):", count, "\n")


# 3) What is the distribution of total charges (tot_charges in the data) in each year?

#clear top on e percent and bottom one percetn

mutate(tot_charges_low = quantile(to_charges, probs =0.01, na.rm=TRUE),)

library(scales)


# Create a violin plot for the distribution of total charges by year
library(scales)
library(ggplot2)

# Violin Plot for Total Charges Distribution (Updated)
ggplot(final.hcris.data, aes(x = as.factor(year), y = tot_charges)) + 
  # Generate the violin plot with customized fill and outline colors
  geom_violin(fill = "#8A2BE2", color = "#006400", alpha = 0.75) +  # Violet fill and dark green outline

  # Apply a log scale to the y-axis and format labels with commas for readability
  scale_y_log10(
    labels = label_comma(scale = 1, accuracy = 0.1)  # Adjusting accuracy for clearer labels
  ) + 
  
  # Add titles, axis labels, and caption with a more descriptive text
  labs(
    title = "Distribution of Total Charges Over the Years",
    x = "Year of Report",
    y = "Log of Total Charges",
    caption = "Data Source: HCRIS (Medicare/Medicaid)"
  ) +
  
  # Minimal theme for better aesthetics
  theme_minimal() +
  
  # Adjust the x-axis labels to be angled for better visibility
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10),  # Rotate x-axis labels
    axis.title.x = element_text(size = 14),  # Increase font size for x-axis title
    axis.title.y = element_text(size = 14),  # Increase font size for y-axis title
    plot.title = element_text(hjust = 0.5, size = 16),  # Center-align and increase font size of the title
    plot.caption = element_text(size = 10)  # Adjusting font size for the caption
  )


# 4) Distribution of Estimated Prices by Year (Updated)
# Calculate discount factor and price estimates


#price denom greater than 100
prince num greater than 0


final.hcris.data <- final.hcris.data %>%
  mutate(
    discount_factor = 1 - tot_discounts / tot_charges,
    price_num = (ip_charges + icu_charges + ancillary_charges) * discount_factor - tot_mcare_payment,
    price_denom = tot_discharges - mcare_discharges,
    price = if_else(price_denom > 0, price_num / price_denom, NA_real_)  # Avoid division by zero or negative denominator
  )

# Filter out negative, invalid prices, and outliers
final.hcris.data <- final.hcris.data %>%
  filter(!is.na(price) & price > 0)

# Log transformation of prices
final.hcris.data <- final.hcris.data %>%
  mutate(log_price = log(price))

# Create a violin plot for price distribution by year with updated colors




# 5)Calculate the average price among penalized versus non-penalized hospitals.

Split hospitals into quartiles based on bed size. To do this, create 4 new indicator variables, where each variable is set to 1 if the hospital’s bed size falls into the relevant quartile. Provide a table of the average price among treated/control groups for each quartile.

Find the average treatment effect using each of the following estimators, and present your results in a single table:

Nearest neighbor matching (1-to-1) with inverse variance distance based on quartiles of bed size
Nearest neighbor matching (1-to-1) with Mahalanobis distance based on quartiles of bed size
Inverse propensity weighting, where the propensity scores are based on quartiles of bed size
Simple linear regression, adjusting for quartiles of bed size using dummy variables and appropriate interactions as discussed in class
With these different treatment effect estimators, are the results similar, identical, very different?

Do you think you’ve estimated a causal effect of the penalty? Why or why not? (just a couple of sentences)

Briefly describe your experience working with these data (just a few sentences). Tell me one thing you learned and one thing that really aggravated or surprised you.



















save.image("/Users/sushmitarajan/econ470spring2025/Homework2/submission2/results/Hwk2_workspace.RData")
dir.create("/Users/sushmitarajan/econ470spring2025/Homework2/submission2/results", recursive = TRUE)