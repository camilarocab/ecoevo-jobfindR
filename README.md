# ecoevo-jobfindR

R functions for searching and and filtering job postings from the public [ecoevojobs.net](https://ecoevojobs.net/) Google SpreadSheet.

The script reads the public EcoEvoJobs spreadsheet and allows users to filter jobs by keyword, continent, country, subject area, deadline and last update date. 

The functions presented here were developed to search in the "postdoc jobs" tab. For other jobs, column names are different and therefore the functions will require accounting for these column names.

## What it does

This script can:

- read the public EcoEvoJobs Google Sheet
- clean column names
- parse review dates and last update dates
- guess country and continent from the location field
- identify jobs that are still open
- filter jobs by:
  - continent
  - country
  - keyword
  - application deadline

## Requirements

R packages required:

```r
install.packages(c(
  "googlesheets4",
  "dplyr",
  "lubridate",
  "stringr",
  "janitor",
  "countrycode",
  "tibble"
))
```

## Usage
Download or cloan the repository and source the fucntions' script.
```r
source(ecoevo-jobfindR.R)

# Read postdoc sheet
jobs <- read_ecoevo_jobs(sheet = "Postdoc Jobs")

# Example 1 - postdocs in Europe related to biodiverity forecasting
ex1 <- filter_ecoevo_jobs(
  jobs,
  continent_filter = "Europe",
  keyword = c("biodiversity", "modelling", "modeling", "forecasting"),
  open_only = TRUE # Open
)

ex1

# Example 2 - postdocs in Southern Europe in conservation
ex2 <- filter_ecoevo_jobs(
  jobs,
  country_filter = c("Spain", "France", "Italy", "Greece", "Portugal"),
  keyword = "conservation"
  open_only = TRUE # Open
)

ex2

# Example 3 - searching with keyword only
ex3 <- <- filter_ecoevo_jobs(
  jobs,
  keyword = c("conservation", "global change"),
  open_only = TRUE
)

ex3
```
