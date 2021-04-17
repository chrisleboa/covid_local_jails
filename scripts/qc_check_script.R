# This is the qc script to add quality control b

# Author: Chris LeBoa
# Version: 2020-10-02

# Libraries

library(tidyverse)
library(RCurl)
library(lubridate)
library(kableExtra)
library(knitr)

data_output <-"/Users/ChrisLeBoa/GitHub/covid_local_jails/data/qc_data_to_upload.csv"

# API Pull
enrollment_data_raw <- postForm(
  uri='https://redcap.stanford.edu/api/',
  token='02528A04B2AEA71673CE1858FBA6D2BC',
  content='report',
  format='csv',
  report_id='73260',
  csvDelimiter='',
  rawOrLabel='raw',
  rawOrLabelHeaders='raw',
  exportCheckboxLabel='false',
  returnFormat='csv'
)

qc_data_raw <- postForm(
  uri='https://redcap.stanford.edu/api/',
  token='02528A04B2AEA71673CE1858FBA6D2BC',
  content='report',
  format='csv',
  report_id='78082',
  csvDelimiter='',
  rawOrLabel='raw',
  rawOrLabelHeaders='raw',
  exportCheckboxLabel='false',
  returnFormat='csv'
)

# Read in data
enrollment_data <-
  read_csv(enrollment_data_raw)


qc_data <-
  read_csv(qc_data_raw) %>%
  filter(quality_control_comments_complete == 2)

data <-
  enrollment_data %>%
  left_join(qc_data, by = c("barcode_id", "redcap_event_name")) %>%
  filter(redcap_event_name != "quality_control_arm_1")

qc_checked_data <-
  data %>%
  filter(consent_yn == 1) %>%
  mutate(
    qc_status = case_when(
      is.na(consent_name_sig) ~ 2,
      is.na(consent_confirm_sign) ~ 2,
      is.na(results_pic) ~ 2,
      is.na(consent_yn) ~ 2,
      year(consent_date) < 2020 ~ 2,
      TRUE ~ qc_status
    ),
    qc_notes = case_when(
      is.na(consent_name_sig) ~ "Missing consent signature",
      is.na(consent_confirm_sign) ~ "Missing consent confirmation signature",
      is.na(results_pic) ~ "Missing results photo",
      is.na(consent_yn) ~ "missing consent",
      year(consent_date) < 2020 ~ "Consent date is wrong",
      TRUE ~ qc_notes
    )
  ) %>%
  mutate(
    quality_control_comments_complete = case_when(
      qc_status == 1 ~ 2,
      qc_status == 2 ~ 1,
      qc_status == 3 ~ 1,
      qc_status == 99 ~ 1,
      TRUE ~ quality_control_comments_complete
    )
   )

qc_changes <-
  qc_checked_data %>%
  filter(!is.na(qc_status)) %>%
  select(barcode_id, redcap_event_name, qc_status, qc_notes, quality_control_comments_complete)

qc_changes %>%
  write_csv(data_output)


## To Do

### Overall result and antibody results
### The number of contacts > 20
### The jails people said that they were in
      #Make sure if intake say were in community
### Self Reported vs actual test results


# To Be pulled from EPIC
### Date of birth < 18 years
### COVID

## Make a one pager of the two analysis plans
## There is somethng there with the vaccine pieces but we did not have a big enough N
## Race age jail were significant but not enough to be included
# Can lump attitutes and effects in the jails
#Masks, Court dates, protect oneself,
## Could frame these policy pieces into the incidence / prevalence paper

### It makes sense to have paper on vaccine acceptance and medical trust
### Risk factord for COVID infection in jail
#  Vaccine medical trust and incidence / prevalenve
#  (need to remove those that are vaccinated)



