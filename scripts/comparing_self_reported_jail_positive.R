# Checking COVID POSITIVE INDIVIDUALS

# Author: Chris LeBoa
# Version: 2021-01-07

# Libraries
library(tidyverse)
library(tidyverse)
library(RCurl)
library(lubridate)
library(kableExtra)
library(knitr)


# Parameters
exposure_data_path <- "/Users/ChrisLeBoa/Dropbox/Covid Screening in Jails  Project/COVID_pos/Exposure Line list 11-24.xlsx"
#===============================================================================

#API Call


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

exposure_data <-
  readxl::read_excel(exposure_data_path, skip = 4, sheet = "Line List") %>%
  rename(name = `Name of Inmates & ID #,DOB with Positive Case or close contact with positive case`)
enrollment_data <-
  read_csv(enrollment_data_raw)

#Code

id_interest <-
  enrollment_data %>%
  filter(covid_dx_incarc == 1) %>%
  pull(unique(barcode_id))

inmates_pos <-
  enrollment_data %>%
  filter(barcode_id %in% id_interest) %>%
  select(consent_date, results_date, barcode_id, consent_first_name, consent_last_name, consent_inmate_number, covid_dx_incarc, covid_dx_symp_incarc, cell_mates_covid_dx_incarc) %>%
  fill(c(consent_first_name, consent_last_name, consent_inmate_number), .direction = "down") %>%
  filter(covid_dx_incarc == 1) %>%
  distinct(consent_first_name, .keep_all = TRUE) %>%
  filter(consent_inmate_number == 1163763) %>%
  select(barcode_id)

inmates_sr_pos <-
  inmates_pos %>%
  pull(consent_inmate_number)
  #write_csv("/Users/ChrisLeBoa/Dropbox/Covid Screening in Jails  Project/Redcap/inmate_report_pos.csv")


exposure_data %>%
  filter(str_detect(name, paste(inmates_sr_pos, collapse = "|"))) %>%
  select(name)

id_all <-
  enrollment_data %>%
  select(consent_date, results_date, barcode_id, consent_first_name, consent_last_name, consent_inmate_number, covid_dx_incarc, covid_dx_symp_incarc, cell_mates_covid_dx_incarc) %>%
  fill(c(consent_first_name, consent_last_name, consent_inmate_number), .direction = "down") %>%
  filter(!is.na(consent_inmate_number)) %>%
  pull(unique(consent_inmate_number))



exposure_data %>%
  filter(str_detect(name, paste(id_all, collapse = "|"))) %>%
  select(name)

incarc_pos_id <-
  exposure_data %>%
  mutate(
    id = str_extract(name, "\\-*\\d{7}+\\.*\\d*")
  ) %>%
  filter(!str_detect(name, "(rec)")) %>%
  select(id) %>%
  pull(id)

#pull exposure data barcodes from enrollment data

enrollment_data %>%
  filter(consent_inmate_number %in% incarc_pos_id) %>%
  select(barcode_id) %>%
  write_csv("/Users/ChrisLeBoa/Dropbox/Covid Screening in Jails  Project/Redcap/jail_report_pos.csv")




