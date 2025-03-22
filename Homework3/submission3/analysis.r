
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, dplyr, lubridate, stringr, readxl, data.table, gdata, fixest)

tax_burden_final <- readRDS('/Users/sushmitarajan/econ470spring2025/Homework3/data/output/TaxBurden_Data.rds')


## 1. Present a bar graph showing the proportion of states with a change in their cigarette tax in each year from 1970 to 1985.

# Summarize tax changes per state-year
tax_burden_final_changes <- tax_burden_final %>%
  arrange(state, Year) %>%
  group_by(state) %>%
  mutate(tax_change = ifelse(Year == 1970, FALSE, 
                              ifelse(is.na(lag(tax_state)) | tax_state != lag(tax_state), TRUE, FALSE))) %>%
  ungroup()

# Calculate the proportion of states with tax changes each year
proportion_changes <- tax_burden_final_changes %>%
  group_by(Year) %>%
  summarize(proportion_changed = mean(tax_change, na.rm = TRUE)) %>%
  filter(Year >= 1970 & Year <= 1985)

# Plot the bar graph
question1 <- ggplot(proportion_changes, aes(x = Year, y = proportion_changed)) +
  geom_bar(stat = "identity", fill = "#000000") +
  labs(title = "Proportion of States with Cigarette Tax Changes (1970–1985)",
       x = "Year",
       y = "Proportion of States with Tax Change") +
       ylim(0, 1) +
  theme_minimal()


## 2. Plot on a single graph the average tax (in 2012 dollars) on cigarettes and the average price of a pack of cigarettes from 1970 to 2018.

# Aggregate the data by Year
aggregated_data <- tax_burden_final %>%
  group_by(Year) %>%
  summarise(
    avg_tax_dollar = mean(tax_dollar, na.rm = TRUE),    # Average tax in 2012 dollars
    avg_cost_per_pack = mean(cost_per_pack, na.rm = TRUE) # Average cost per pack
  )

# Create the plot with the aggregated data
question2 <- ggplot(aggregated_data, aes(x = Year)) + 
  geom_line(aes(y = avg_tax_dollar, color = "Tax"), size = 1) + 
  geom_line(aes(y = avg_cost_per_pack, color = "Cost per pack"), size = 1) + 
  labs(
    title = "Average Tax and Average Price of a Pack of Cigarettes (1970-2018)",
    x = "Year",
    y = "Value (in 2012 dollars)"
  ) + 
  scale_color_manual(values = c("Tax" = "#D8BFD8", "Cost per pack" = "lightblue" )) + 
  theme_minimal() 


## 3. Identify the 5 states with the highest increases in cigarette prices (in dollars) over the time period. Plot the average number of packs sold per capita for those states from 1970 to 2018.

price_change <- tax_burden_final %>%
  group_by(state) %>%
  filter(Year == 1970 | Year == 2018) %>%
  summarise(price_change = cost_per_pack[Year == 2018] - cost_per_pack[Year == 1970])

top_states <- price_change %>%
  arrange(desc(price_change)) %>%
  head(5)

print(paste("States with the highest increases in cigarette prices:", paste(top_states$state, collapse = ", ")))


top_states_final <- tax_burden_final %>%
  filter(state %in% top_states$state)


question3 <- ggplot(top_states_final, aes(x = Year, y = sales_per_capita, color = state)) +
  geom_line(linewidth = 1) +
  labs(
    title = "Average Number of Packs Sold per Capita for the Top 5 States with the Highest Price Increase (1970-2018)",
    x = "Year",
    y = "Packs Sold per Capita",
    color = "State"
  ) +
  theme_minimal()


## 4. Identify the 5 states with the lowest increases in cigarette prices over the time period. Plot the average number of packs sold per capita for those states from 1970 to 2018.

low_states <- price_change %>%
  arrange(price_change) %>%
  head(5)

print(paste("States with the lowest increases in cigarette prices:", paste(low_states$state, collapse = ", ")))

low_states_final <- tax_burden_final %>%
  filter(state %in% low_states$state)


question4 <- ggplot(low_states_final, aes(x = Year, y = sales_per_capita, color = state)) +
  geom_line(linewidth = 1) +
  labs(
    title = "Average Number of Packs Sold per Capita for the Top 5 States with the Highest Price Increase (1970-2018)",
    x = "Year",
    y = "Packs Sold per Capita",
    color = "State"
  ) +
  theme_minimal()


## 5. Compare the trends in sales from the 5 states with the highest price increases to those with the lowest price increases.

#Combine both datasets for plotting
high_low_combined <- bind_rows(
  top_states_final %>% mutate(group = "Top 5 States (Highest Price Increase)"),
  low_states_final %>% mutate(group = "Top 5 States (Lowest Price Increase)")
)

# Compute average sales per capita for both groups
high_low_avg <- high_low_combined %>%
  group_by(Year, group) %>%
  summarise(avg_sales_per_capita = mean(sales_per_capita, na.rm = TRUE))

# Plot the averaged trends for the two groups
question5 <- ggplot(high_low_avg, aes(x = Year, y = avg_sales_per_capita, color = group)) +
  geom_line(linewidth = 1) +
  labs(
    title = "Average Cigarette Sales per Capita: Highest vs. Lowest Price Increases (1970-2018)",
    x = "Year",
    y = "Average Packs Sold per Capita",
    color = "Group"
  ) +
  scale_color_manual(values = c("Highest" = "#1f77b4", "Lowest" = "#ff7f0e")) +  # Professional colors
  theme_minimal() +
  theme(
    legend.position = "top",
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(size = 14, face = "bold"),  # Title styling
    axis.title

## The amount of cigarettes sold in both the highest and lowest states has drastically decreased because of the cultural shifts when it comes to smoking. Missouri and North Dakota seem to pull the lower states average of cost per pack sold up a bit but currently 50 packs sold per capita is seen for both the high and low states. The low states have more variability in packs sold in over the years with north carolina going up to about 250 packs sold per capita around 1975.


## 6.Focusing only on the time period from 1970 to 1990, regress log sales on log prices to estimate the price elasticity of demand over that period. Interpret your results.

# Filter data for the years 1970 to 1990 (if not already done)
tax_burden_1970_1990 <- tax_burden_final %>% filter(Year >= 1970 & Year <= 1990)

# Create log-transformed variables for sales and price
cig.data_1970_1990 <- tax_burden_1970_1990 %>% mutate(ln_sales=log(sales_per_capita),
                                ln_price_cpi=log(price_cpi),
                                tax_cpi=tax_state*(230/index),
                                total_tax_cpi=tax_dollar*(230/index),
                                ln_total_tax=log(total_tax_cpi),                             
                                ln_state_tax=log(tax_cpi))
# Run the regression
ols.1 <- feols(ln_sales ~ ln_price_cpi, data=cig.data_1970_1990)


# Display the summary of the regression model
summary(ols.1)

## 7. Again limiting to 1970 to 1990, regress log sales on log prices using the total (federal and state) cigarette tax (in dollars) as an instrument for log prices. Interpret your results and compare your estimates to those without an instrument. Are they different? If so, why?


# Run the instrumental variable regression
ivs.1 <- feols(ln_sales ~ 1 | ln_price_cpi ~ ln_total_tax, data = cig.data_1970_1990)

# Display the summary of the IV regression results
summary(ivs.1)

## 8. Show the first stage and reduced-form results from the instrument.

#First Stage Regression (Instrumental Variables)

# In the first stage, we regress ln_price (log of price) on ln_total_tax (log of total tax) to obtain predicted values of price.
first_stage.1 <- feols(ln_price_cpi ~ ln_total_tax, data = cig.data_1970_1990)
summary(first_stage.1)

#Reduced-form regression: ln_sales on predicted ln_total_tax to determine if  the instrument (log tax) has a direct effect on sales.
reduced.1 <- feols(ln_sales ~ ln_total_tax, data = cig.data_1970_1990)
summary(reduced.1)


## 9. Repeat questions 1-3 focusing on the period from 1991 to 2015.

# Filter data for the years 1970 to 1990 (if not already done)
tax_burden_1991_2015 <- tax_burden_final %>% filter(Year >= 1991 & Year <= 2015)

# Create log-transformed variables for sales and price
cig.data_1991_2015 <- tax_burden_1991_2015 %>% mutate(ln_sales=log(sales_per_capita),
                                ln_price_cpi=log(price_cpi),
                                tax_cpi=tax_state*(230/index),
                                total_tax_cpi=tax_dollar*(230/index),
                                ln_total_tax=log(total_tax_cpi),                             
                                ln_state_tax=log(tax_cpi))
# Run the regression
ols.2 <- feols(ln_sales ~ ln_price_cpi, data=cig.data_1991_2015)

# Display the summary of the regression model
summary(ols.2)
ols_estimate2 <- coef(ols.2)["ln_price2012"]

# Run the instrumental variable regression
ivs.2 <- feols(ln_sales ~ 1 | ln_price_cpi ~ ln_total_tax, data = cig.data_1991_2015)

# Display the summary of the IV regression results
  summary(ivs.2)
iv_estimate2 <- coef(ivs.2)["ln_price2012"]

#First Stage Regression (Instrumental Variables)

# In the first stage, we regress ln_price (log of price) on ln_total_tax (log of total tax) to obtain predicted values of price.
first_stage.2 <- feols(ln_price_cpi ~ ln_total_tax, data = cig.data_1991_2015)
summary(first_stage.2)
first_stage_estimate2 <- coef(first_stage.2)["ln_total_tax"]

#Reduced-form (Second Stage) Regression

#Reduced-form regression: ln_sales on predicted ln_total_tax to determine if  the instrument (log tax) has a direct effect on sales.
reduced.2 <- feols(ln_sales ~ ln_total_tax, data = cig.data_1991_2015)
summary(reduced.2)
reduced_estimate2 <- coef(reduced.2)["ln_total_tax"]




## 10. Compare your elasticity estimates from 1970-1990 versus those from 1991-2015. Are they different? If so, why?


1970-1990 shows a positive elasticity (i.e., price increase leads to more sales), which is unusual for most markets but could be explained by certain market factors like tax increases, changes in policy (e.g., tobacco taxation), or other structural shifts. For instance, if a tax increase made the product appear more "exclusive" or "prestigious," people might have bought more despite the higher price.

1991-2015 shows the more typical negative elasticity, where higher prices are associated with lower sales. This is consistent with standard economic theory and consumer behavior, where higher prices lead to a reduction in demand.


dir.create("/Users/sushmitarajan/econ470spring2025/Homework3/submission2/results", recursive = TRUE)
save.image("/Users/sushmitarajan/econ470spring2025/Homework3/submission2/results/Hwk3_workspace.RData")
