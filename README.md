# ecoevo-jobfindR
R functions for searching and filtering ecoevojobs.org  postings by keyword, location and application deadline.

# ecoevo-jobfinder

R fucntions for searching and and filtering job postings from the public [ecoevojobs.net](https://ecoevojobs.net/) Google SpreadSheet.

The script reads the public EcoEvoJobs spreadsheet and allows users to filter jobs by keyword, continent, country, subject area, deadline and last update date.

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
  - subject keyword
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
