
# Meta --------------------------------------------------------------------

# Preliminaries -----------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, dplyr, lubridate, readr, readxl, scales, acs, tidyr)

source('/Users/sushmitarajan/econ470spring2025/Homework5/data-code/Medicaid.R')
source('/Users/sushmitarajan/econ470spring2025/Homework5/data-code/ACS.R')


# Tidy --------------------------------------------------------------------
final.data <- final.insurance %>%
  left_join(kff.final, by="State") %>%
  mutate(expand_year = year(date_adopted),
       expand = (year>=expand_year & !is.na(expand_year))) %>%
  rename(expand_ever=expanded)


write_tsv(final.data,'data/output/acs_medicaid.txt')