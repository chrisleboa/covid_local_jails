# This script puto lls the scheduling data from Calandly and converts it to a form
#that can be imported to redcap. It currently is a manual process but will work
#to incorporate the Calandly and Redcap API's to automate the process

# Author: Chris LeBoa
# Version: 2020-07-21

# Steps to using this script
  # sign in to calendly password 56169COVID


#install.packages("httr")
# Libraries
library(tidyverse)
library(httr)
library(RCurl)
# Parameters

#API Call
#For real calls
current_data_raw <- postForm(
  uri='https://redcap.stanford.edu/api/',
  token='02528A04B2AEA71673CE1858FBA6D2BC',
  content='report',
  format='csv',
  report_id='77344',
  csvDelimiter='',
  rawOrLabel='raw',
  rawOrLabelHeaders='raw',
  exportCheckboxLabel='false',
  returnFormat='csv'
)

#For testing
#API Call
# current_data_raw <- postForm(
#   uri='https://redcap.stanford.edu/api/',
#   token='C0764C9272BF7328C7E8FA977F9F8AE0',
#   content='report',
#   format='csv',
#   report_id='78614',
#   csvDelimiter='',
#   rawOrLabel='raw',
#   rawOrLabelHeaders='raw',
#   exportCheckboxLabel='false',
#   returnFormat='csv'
# )

data_input <- here::here("data/staff_secheduling/smc_scheduling_210202.csv")
schedule_output <- here::here("data/formatted_staff_scheduling/formatted_smc_scheduling_210202.csv")
followup_1_output <- here::here("data/formatted_staff_scheduling/followup_needed/followup_smc_scheduling_210202.csv")

#===============================================================================

#Code

#Read in data
current_data <-
  read_csv(current_data_raw) %>%
  filter(str_detect(redcap_event_name, "arm_1")) %>%
  mutate_at(vars(staff_first_name, staff_last_name), str_to_lower)

current_data %>%
#   pivot_wider(names_from = redcap_event_name, values_from = results_complete) %>%
   view()

upcoming_schedule <-
  read_csv(data_input) %>%
  mutate(
    staff_first_name = `Invitee First Name`,
    staff_last_name = `Invitee Last Name`
  ) %>%
  mutate_at(vars(staff_first_name, staff_last_name), str_to_lower)
  #read upcoming data in
#This currently pulls all upcoming appointments



matches <-
  current_data %>%
  inner_join(upcoming_schedule, by = c("staff_first_name", "staff_last_name"))

non_matches <-
  upcoming_schedule %>%
  anti_join(current_data, by = c("staff_first_name", "staff_last_name"))
  #pull(staff_first_name, staff_last_name)


matches
#view(non_matches)

followup_1_needed <-
  matches %>%
  #filter(follow_up_staff_scheduling_complete == 0) %>%
  transmute(
    barcode_id = barcode_id,
    redcap_event_name = "3month_arm_1",
    staff_first_name_2 = str_to_title(staff_first_name),
    staff_last_name_2 = str_to_title(staff_last_name),
    staff_schedule_date_time_followup = `Start Date & Time`,
    #staff_email = staff_email,
    first_time_stf = 0,
    follow_up_staff_scheduling_complete = 2
  )

followup_2_needed <-
  matches %>%
  #filter(follow_up_staff_scheduling_complete == 2) %>%
  transmute(
    barcode_id = barcode_id,
    redcap_event_name = "6month_arm_1",
    staff_first_name_3 = str_to_title(staff_first_name),
    staff_last_name_3 = str_to_title(staff_last_name),
    staff_schedule_date_time_followup_2 = `Start Date & Time`,
    #staff_email = staff_email,
    first_time_stf = 0,
    follow_up_staff_scheduling_complete = 2
  )



formatted_schedule <-
  non_matches %>%
  transmute(
    barcode_id = "56169-SMC-S", #This part needs improvement
    redcap_event_name = "baseline_arm_1",
    staff_first_name = str_to_title(staff_first_name),
    staff_last_name = str_to_title(staff_last_name),
    redcap_survey_identifier = "",
    staff_schedule_date_time = `Start Date & Time`,
    staff_email = `Invitee Email`,
    staff_scheduling_complete = 2
  )

formatted_schedule %>%
  write_csv(schedule_output)

followup_1_needed %>%
  write_csv(followup_1_output)

#r <- GET("https://auth.calendly.com/oauth/authorize?
#           client_id=RXoSbfhPq1sfIu0iPR3TzLzj62HKNqsO3IHHy6AtLp4")

