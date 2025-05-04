
# Meta --------------------------------------------------------------------

## Title:  Medicaid Expansion
# Load required libraries
library(readr)      # For reading CSV/TSV files
library(dplyr)      # For data manipulation
library(stringr)    # For string operations
library(tidyr)      # For data tidying (if needed)
library(lubridate)  # For date handling


# Preliminaries -----------------------------------------------------------
kff.dat <- read_csv('/Users/sushmitarajan/econ470spring2025/Homework5/data/input/KFF_medicaid_expansion_2024.csv')

# Clean KFF data -------------------------------------------------------

kff.final <- kff.dat %>%
  mutate(Description = str_replace_all(Description, c("\n" = "", '"' = "")),
         date_extracted = str_extract(Description, "\\d{1,2}/\\d{1,2}/\\d{2,4}"),
         date_adopted = mdy(date_extracted)) %>%
  mutate(expanded = (`Expansion Status` == 'Adopted and implemented') & date_adopted < ymd('2020-01-01'),
         date_adopted = if_else(expanded, date_adopted, as.Date(NA))) %>%
  select(State, expanded, date_adopted)

# Write to output
write_tsv(kff.final, '/Users/sushmitarajan/econ470spring2025/Homework5/data/output/medicaid_expansion.txt')