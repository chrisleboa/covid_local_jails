# This script puto lls the scheduling data from Calandly and converts it to a form
#that can be imported to redcap. It currently is a manual process but will work
#to incorporate the Calandly and Redcap API's to automate the process

# Author: Chris LeBoa
# Version: 2020-07-21

# Libraries
library(tidyverse)

# Parameters

data_input <- here::here("data/staff_secheduling/smc_scheduling_20200721.csv")
schedule_output <- here::here("data/formatted_staff_scheduling/formatted_smc_scheduling_20200721.csv")
#===============================================================================

#Code


upcoming_schedule <- read_csv(data_input) #read upcoming data in
#This currently pulls all upcoming appointments

glimpse(upcoming_schedule)

formatted_schedule <-
  upcoming_schedule %>%
  transmute(
    barcode_id = "test_666",
    redcap_event_name = "baseline_arm_1",
    redcap_survey_identifier = "",
    staff_first_name = `Invitee First Name`,
    staff_last_name = `Invitee Last Name`,
    staff_schedule_date_time = `Start Date & Time`,
    staff_email = `Invitee Email`,
    staff_scheduling_complete = 2
  )

formatted_schedule %>%
  write_csv(schedule_output)
