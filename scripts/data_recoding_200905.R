# This script aligns all the data written before 9/4 2020 with the new database
#Structure incorporated on 9/4/2020. The output data file was imported to Redcap
# to incorporate these changes on 9/4/2020

# Author: Chris LeBoa
# Version: 2020-09-04

# Libraries
library(tidyverse)

# Parameters
data_input <- here::here("data-raw/COVID19ScreeningInLo_DATA_2020-09-04.csv")
data_output <- here::here("data-raw/COVID19ScreeningInLo_DATA_formatted_2020-09-04.csv")

#===============================================================================

#Code

data_raw <- read_csv(data_input)

data_raw %>%
  mutate(
    med_conditions_stf___97 = med_conditions_stf___98,
    med_conditions_stf___98 = NA,
    symptoms_stf___97 = symptoms_stf___98,
    symptoms_stf___98 = NA,
    work_behav_stf___97= work_behav_stf___98,
    work_behav_stf___98 = NA,
    covid_dx_stf = case_when(
      covid_dx_stf == 1 ~ 1,
      covid_dx_stf == 2 ~ 0,
      covid_dx_stf == 3 ~ 2
    ),
    protect_measures_stf___97 = protect_measures_stf___98,
    protect_measures_stf___98 = NA,
    measures_outside_work_stf___97 = measures_outside_work_stf___98,
    measures_outside_work_stf___98 = NA,
    med_conditions_incarc___97 = med_conditions_incarc___98,
    med_conditions_incarc___98 = NA,
    symptoms_incarc___97 = symptoms_incarc___98,
    symptoms_incarc___98 = NA,
    covid_dx_incarc = case_when(
      covid_dx_incarc == 1 ~ 1,
      covid_dx_incarc == 2 ~ 0,
      covid_dx_incarc == 3 ~ 2
    ),
    court_incarc___97 = court_incarc___98,
    court_incarc___98 = NA
  ) %>%
  select(-c(staff_questionnaire_timestamp, incarc_questionnaire_timestamp, consent_timestamp)) %>%
  #count(med_conditions_incarc___97)
  write_csv(data_output, na = "")
