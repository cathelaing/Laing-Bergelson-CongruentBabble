# Updated 20th January 2020

# This script takes CPdata.csv and scrambles various aspects of infant and caregiver data. It then recreates the TRUE/FALSE binomials in line with 
# these randomly scarmbled responses, and re-calculates all proportions based on these.

# It works with data filtered for Object and Prompt exact matches

library(dplyr)
library(tidyverse)

source("ProductionData_nostimmatch_randsubj.R") # if script is run separately from InfantProductionStudy.Rmd then this script should be run first

set.seed(42) #meaning of life
CPdata.scr.C1Prompt_nostimmatch <- dplyr::select(CPdata_nostimmatch, subj, month, sex, VMSgroup, ctype, VMS, C1Obj, C1Prompt) %>% 
  mutate(Prompt.scrambled = sample(C1Prompt)) # C1 of CG prompts are scrambled

set.seed(13) #lucky number
CPdata.scr.C1Prompt.C1Obj_nostimmatch <- CPdata.scr.C1Prompt_nostimmatch %>% 
  mutate(Object.scrambled = sample(C1Obj))# C1 of attended objects are scrambled

set.seed(1) #loneliest number
CPdata.scr.C1Prompt.C1Obj.ctype_nostimmatch <- CPdata.scr.C1Prompt.C1Obj_nostimmatch %>% 
  mutate(InfantProd.scrambled = sample(ctype)) # Infants' CPs are scrambled

CPdata.scr_nostimmatch <- CPdata.scr.C1Prompt.C1Obj.ctype_nostimmatch %>%  
  mutate(Prompt.inProd = stri_detect_regex(as.character(ctype), as.character(Prompt.scrambled)), # is scrambled prompt congruent with CP
         Object.inProd = stri_detect_regex(as.character(ctype), as.character(Object.scrambled)), # is scrambled object congruent with CP
         VMS.match = stri_detect_regex(VMS, as.character(InfantProd.scrambled)) # Does VMS match scrambled CP
  )

# Now re-run variable calculations for scrambled data

Object.scrambled <- CPdata.scr_nostimmatch %>%
  group_by(subj, month, sex, VMSgroup, VMS, Object.inProd) %>% 
  filter(Object.scrambled != 'none') %>%
  tally() %>% 
  spread(Object.inProd, n) %>%
  rename(NoMatch = `FALSE`,
         Match = `TRUE`) %>%
  mutate(Prod.Obj.match.PC = Match/(Match+NoMatch)) %>%  # What % of scrambled objects match CPs?
  select(-Match, -NoMatch)

Prompt.scramble <- CPdata.scr_nostimmatch %>%
  filter(Prompt.scrambled != 'none') %>% # Remove 'none' to use same approach as used when testing real data
  group_by(subj, Prompt.inProd) %>%   # What % of scrambled prompts match CP?
  tally() %>% 
  spread(Prompt.inProd, n) %>%
  rename(NoMatch = `FALSE`,
         Match = `TRUE`) %>%
  mutate(Prod.Prompt.match.PC = Match/(Match+NoMatch)) %>%
  select(subj, Prod.Prompt.match.PC) 

# Join with Object.scrambled to give scrambled dataset

data.scrambled_nostimmatch <- Object.scrambled %>%
  left_join(Prompt.scramble) %>%
  replace(is.na(.), 0)   

