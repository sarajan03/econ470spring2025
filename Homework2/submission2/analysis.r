if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, dplyr, lubridate)

# 1)How many hospitals filed more than one report in the same year? Show your answer as a line graph of the number of hospitals over time. 

#From HCRIS Data-> read duplic hcris to identify years with multiple reprots
multi_report_counts <- duplicate.hcris %>%
group_by(fyear) %>%
summarise(num_hospitals = n_distinct(provider_number))

## Use ggplot to plot linegraph of all duplicates
ggplot(multi_report_counts, aes(x = fyear, y = num_hospitals)) +
geom_line(color = "blue", size = 1) 
labs(
title = "Duplicate Hospital Filings per year",
x = "Year",
y = "Number of Hospitals",) +
theme_minimal() 
