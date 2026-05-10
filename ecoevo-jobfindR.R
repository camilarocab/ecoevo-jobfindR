library(googlesheets4)
library(dplyr)
library(lubridate)
library(stringr)
library(janitor)
library(countrycode)
library(tibble)

# spreadsheet is public
gs4_deauth()

ecoevo_url <- "https://docs.google.com/spreadsheets/d/1P7BfU0emdcGFVIWIs_erFxyy0UGXXORw7h0rpU19gQ8/edit"

# 1. To detect country
## US states
us_states <- c(
  state.name,
  "District of Columbia",
  "Washington DC",
  "D.C.",
  "DC"
)

detect_country <- function(location_clean) {
  
  is_us_state <- str_detect(
    str_to_lower(location_clean),
    paste0("\\b(", str_to_lower(paste(us_states, collapse = "|")), ")\\b")
  )
  
  country_guess <- countrycode::countrycode(
    location_clean,
    origin = "country.name",
    destination = "country.name",
    warn = FALSE
  )
  
  case_when(
    is_us_state ~ "United States",
    !is.na(country_guess) ~ country_guess,
    TRUE ~ NA_character_
  )
}

# 2. Read spreadsheet and rename columns
read_ecoevo_jobs <- function(sheet = "Postdoc Jobs", skip = 1) {
  
  jobs <- read_sheet(ecoevo_url, sheet = sheet, skip = skip)
  
  jobs <- janitor::clean_names(jobs) 

    jobs <- jobs %>%
    mutate(
      review_date = ymd(review_date),
      
      
      last_update = ymd_hms(last_update),
      
      location_clean = str_squish(location),

      country = detect_country(location_clean),
      
      continent = countrycode(
        country,
        origin = "country.name",
        destination = "continent",
        warn = FALSE
      ),
      
      text_search = str_to_lower(paste(
        institution,
        location,
        subject_area,
        notes,
        if ("notes_2" %in% names(.)) notes_2 else "",
        sep = " "
      )),
      
      is_open = is.na(review_date) | review_date >= Sys.Date()
    )
  print(head(jobs))
  print("read correctly")  
  jobs
  
}

# 3. Filtering function
filter_ecoevo_jobs <- function(
    jobs,
    continent_filter = NULL,
    country_filter = NULL,
    keyword = NULL,
    subject_keyword = NULL,
    open_only = TRUE,
    updated_after = NULL,
    deadline_before = NULL
) {
  
  out <- jobs
  
  if (open_only) {
    out <- out %>% filter(is_open)
  }
  
  if (!is.null(continent_filter)) {
    out <- out %>% filter(str_to_lower(continent) %in% str_to_lower(continent_filter))
  }
  
  if (!is.null(country_filter)) {
    out <- out %>%
      filter(str_to_lower(.data$country) %in% str_to_lower(country_filter))
  }
  
  if (!is.null(keyword)) {
    pattern <- paste0("\\b(", paste(str_to_lower(keyword), collapse = "|"), ")\\b")
    out <- out %>%
      filter(str_detect(text_search, pattern))
  }
  
  if (!is.null(subject_keyword)) {
    out <- out %>%
      filter(str_detect(str_to_lower(subject_area), str_to_lower(paste(subject_keyword, collapse = "|"))))
  }
  
  if (!is.null(updated_after)) {
    updated_after <- ymd(updated_after)
    out <- out %>% filter(is.na(last_update) | last_update >= updated_after)
  }
  
  if (!is.null(deadline_before)) {
    deadline_before <- ymd(deadline_before)
    out <- out %>% filter(!is.na(review_date) & review_date <= deadline_before)
  }
  
  out %>%
    arrange(review_date, institution) %>%
    select(
      institution,
      location,
      country,
      continent,
      subject_area,
      review_date,
      last_update,
      url,
      notes,
      everything()
    )
}
