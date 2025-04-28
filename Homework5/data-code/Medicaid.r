
# Meta --------------------------------------------------------------------

## Title:  Medicaid Expansion


# Preliminaries -----------------------------------------------------------
kff.dat <- read_csv('/Users/sushmitarajan/econ470spring2025/Homework5/data/input/KFF_medicaid_expansion_2024.csv')

# Clean KFF data -------------------------------------------------------

kff.final <- kff.dat %>%
  mutate(expanded = (`Expansion Status` == 'Adopted and Implemented'),
         Description = str_replace_all(Description,c("\n"='','"'='')))

kff.final$splitvar <- kff.final %>% select(Description) %>% as.data.frame() %>%
  separate(Description, sep=" ", into=c(NA, NA, NA, "date"))

kff.final <- kff.final %>%
  mutate(date_adopted = mdy(splitvar$date)) %>%