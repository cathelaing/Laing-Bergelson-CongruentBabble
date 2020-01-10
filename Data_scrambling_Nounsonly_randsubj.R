# Updated 18th March 2019

# This script takes CPdata.csv and scrambles various aspects of infant and caregiver data. It then recreates the TRUE/FALSE binomials in line with 
# these randomly scarmbled responses, and re-calculates all proportions based on these.

source("ProductionData_Nounsonly.R")

set.seed(42) #meaning of life
CPdata.scr.C1Prompt <- dplyr::select(CPdata_nouns, subj, month, sex, ctype, VMS, C1Obj, C1Prompt) %>% 
  mutate(Prompt.scrambled = sample(C1Prompt)) # C1 of CG prompts are scrambled

set.seed(13) #lucky number
CPdata.scr.C1Prompt.C1Obj <- CPdata.scr.C1Prompt %>% 
  mutate(Object.scrambled = sample(C1Obj))# C1 of attended objects are scrambled

set.seed(1) #loneliest number
CPdata.scr.C1Prompt.C1Obj.ctype <- CPdata.scr.C1Prompt.C1Obj %>% 
  mutate(InfantProd.scrambled = sample(ctype)) # Infants' CPs are scrambled

CPdata.scr <- CPdata.scr.C1Prompt.C1Obj.ctype %>%  
  mutate(Prompt.inProd = stri_detect_regex(as.character(ctype), as.character(Prompt.scrambled)), # is scrambled prompt congruent with CP
         Object.inProd = stri_detect_regex(as.character(ctype), as.character(Object.scrambled)), # is scrambled object congruent with CP
         VMS.match = stri_detect_regex(VMS, as.character(InfantProd.scrambled)) # Does VMS match scrambled CP
  )

# Now re-run variable calculations for scrambled data

data.scrambled_base <- CPdata.scr %>%
  filter(Prompt.scrambled != 'none') %>% # Remove 'none' to use same approach as used when testing real data
  group_by(subj, month, Prompt.inProd) %>%   # What % of scrambled prompts match CP?
  tally() %>% 
  spread(Prompt.inProd, n) %>%
  rename(NoMatch = `FALSE`,
         Match = `TRUE`) %>%
  mutate(Prod.Prompt.match.PC = Match/(Match+NoMatch)) %>%
   select(subj, Prod.Prompt.match.PC, month)

data.scrambled <- read_csv("Data/VMSdata.csv") %>%    # number of each consonant type produced during audio recordings
  dplyr::select(subj, Group, VMS) %>%
  mutate(subj = factor(subj),
         subj = fct_recode(subj,
                           "01" = "1",
                           "02" = "2",
                           "03" = "3",
                           "04" = "4",
                           "06" = "6",
                           "07"= "7",
                           "08" = "8",
                           "09" = "9")) %>%
  left_join(data.scrambled_base) %>%
  mutate(VMSgroup = ifelse(Group == "Nx", "noVMS", "withVMS")) %>%
  replace(is.na(.), 0)

