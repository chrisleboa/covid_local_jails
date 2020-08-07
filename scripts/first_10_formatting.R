# This Changes the variables into the format we want to save in the new database


# Author: Chris
# Version: 2020-08-03

# Libraries
library(tidyverse)

# Parameters


data_input <- "/Users/ChrisLeBoa/Dropbox/Covid Screening in Jails  Project/Redcap/first10staff_SMC/COVID19ScreeningInLo_DATA_2020-07-13_2233_first10staff.csv"
data_output <- "/Users/ChrisLeBoa/Dropbox/Covid Screening in Jails  Project/Redcap/first10staff_SMC/formatted_first10staff.csv"
#===============================================================================

#Code

data <- read_csv(data_input)

data_formatted <-
  data %>%
  transmute(
    barcode_id,
    redcap_event_name,
    staff_first_name = str_extract(consent_name_print, "[^\\s]+"),
    staff_last_name = str_extract(consent_name_print, "\\s(.*)"),
    staff_scheduling_complete = 2,
    consent_old_enough = 1,
    consent_stf_or_incarc = 1,
    consent_location_stf = 2,
    consent_studies_stf = 0,
    consent_first_name  = str_extract(consent_name_print, "[^\\s]+"),
    consent_last_name = str_extract(consent_name_print, "\\s(.*)"),
    sick_stf = if_else(!is.na(sfsickdays_stf), 1, 0),
    sickdate_stf = sfsickdate_stf,
    sx_days_stf = sfsickdays_stf,
    covid_test_stf = case_when(
      covid_test_stf == 1 ~ 1,
      covid_test_stf == 2 ~ 0
    ),
    want_test_stf = case_when(
      want_test_stf == 0 ~ 1
    ),
    covid_dx_stf = sfcovid_stf,
    household_covid_dx_stf = case_when(
      household_covid_stf == 2 ~ 0,
      household_covid_stf == 1 ~ 1,
      household_covid_stf == 0 ~ 2
    ),
    health_worker_stf = case_when(
      healthcare_stf == 1 ~ 1,
      healthcare_stf == 2 ~ 0
    ),
    hours_change_stf = case_when(
      hours_change_staff == 0 ~ 1,
      hours_change_staff == 1 ~ 2,
      hours_change_staff == 2 ~ 0
    ),
    hrs_perweek_stf = hrs_covid,
    other_contacts_stf = other_contact_perday,
    other_contacts_hrs_stf = other_contact_hours,
    incarc_anycontact_stf = anycontact_incarc,
    incarc_contacts_stf = incarc_contacts_staff,
    incarc_contacts_hrs_stf = incarc_contact_perday,
    mentalhealth_stf = mentalhealth_effect_stf,
    covid_future_expos_stf = covid_exposure_stf,
    enough_action_stf = enough_action_staff,
    enough_action_incarc_stf = enough_action_incarc,
    privacy_stf = privacy_exp
  )

data_formatted %>%
  write_csv(data_output)


