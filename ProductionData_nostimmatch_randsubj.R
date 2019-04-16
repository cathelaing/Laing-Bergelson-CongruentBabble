# Updated 16th April 2019

# This script works with the main consonant production spreadsheet (CPdata_randsubj.csv) to count how
# many CPs match VMS/Objects/Prompts for each infant. This creates another version of the ProdData dataset but with all instances
# of a phonological match between CG prompt and attended object removed.

library(tidyverse)
library(forcats)

CPdata <- read_csv("Data/CPdata_randsubj.csv") %>%# read in CPdata_randsubj.csv to use as a base df for all following dfs
  mutate(subj = factor(subj))

CPdata$object <- as.character(CPdata$object)
CPdata$cgprompt <- as.character(CPdata$cgprompt)

CPdata_nostimmatch <- CPdata %>% 
  mutate(match = cgprompt == object) %>%
  filter(match == F | cgprompt %in% c("[none", "[imitation", "[media]", "[unavailable]", "[unclear]"))

Prod.Prompt <- CPdata_nostimmatch %>%
  filter(!grepl("^\\[",cgprompt)) %>%     # exclude all instances where object is coded as [toy], [unclear], etc but keep insances of e.g. 'lxx [name]'
  group_by(subj, month, Prod.Prompt.Cong, VMSgroup) %>%
  tally() %>%
  spread(Prod.Prompt.Cong, n) %>%
  replace(is.na(.), 0) %>%               # analysis includes all infants, so change all NAs to 0 across VMS groups
  rename(Prod.Prompt.NoMatch = `FALSE`,
         Prod.Prompt.Match = `TRUE`) %>%
  mutate(Prod.Prompt.match.PC = Prod.Prompt.Match/(Prod.Prompt.Match+Prod.Prompt.NoMatch)) # What % of CG prompts match infants' CPs?


Prod.Obj <- CPdata_nostimmatch %>%                  # Only includes 43 infants as subj 944 doesn't have any attended objects
  filter(!grepl("^\\[",object)) %>%    # exclude all instances where object is coded as [toy], [unclear], etc but keep insances of e.g. 'lxx [name]'
  group_by(subj, Prod.Obj.Cong, VMSgroup) %>%
  tally() %>%
  spread(Prod.Obj.Cong, n) %>%
  ungroup() %>%
  replace(is.na(.), 0) %>%               # analysis includes all infants, so change all NAs to 0 across VMS groups
  rename(Prod.Obj.NoMatch = `FALSE`,
         Prod.Obj.Match = `TRUE`) %>%
  mutate(Prod.Obj.match.PC = Prod.Obj.Match/(Prod.Obj.Match+Prod.Obj.NoMatch)) # What % of attended objects match infants' CPs?

CP.Obj <- CPdata_nostimmatch %>%
  filter(!grepl("^\\[",object)) %>%    # exclude all instances where object is coded as [toy], [unclear], etc
  group_by(subj) %>%
  count() %>%
  rename(nObj = n) %>% # How many CPs are accompanied by an Object?
  ungroup() %>%
  add_row(subj = "944", nObj = 0)   # subj 944 has no objects, so add this row manually

CP.Prompt <- CPdata_nostimmatch %>%
  filter(!grepl("^\\[",cgprompt)) %>%  # exclude all instances where prompt is coded as [unclear], etc, but include eg. "txx [chi name]"
  group_by(subj) %>%
  tally() %>%
  rename(nPrompt = n)    # How many CPs are accompanied by a CG Prompt?

cong.CP.P <- CPdata_nostimmatch %>% 
  filter(VMS.Prompt.Cong == T) %>%   # withVMS infants only; one infant has no VMS congruent prompts
  group_by(subj, Prod.Prompt.Cong, VMSgroup) %>%
  tally() %>%
  spread(Prod.Prompt.Cong, n) %>%
  ungroup() %>%
  replace(is.na(.), 0) %>%    # Change NAs in the No.cong.CP.P column to 0 so %s can be calculated for all withVMS infants
  rename(cong.CP.P = `TRUE`,
         No.cong.CP.P = `FALSE`) %>%
  mutate(PCVMSMatch.Prompt = cong.CP.P/(cong.CP.P+No.cong.CP.P))  # When there is a VMS-congruent CG prompt, how often do infants respond with a congruent CP?

cong.CP.O <- CPdata_nostimmatch %>%
  filter(VMS.Obj.Cong == T) %>%    # withVMS infants only; two infants have no VMS congruent objects
  group_by(subj, Prod.Obj.Cong, VMSgroup) %>%
  tally() %>%
  spread(Prod.Obj.Cong, n) %>%
  ungroup() %>%
  replace(is.na(.), 0) %>%      # Change NAs in the No.cong.CP.O column to 0 so %s can be calculated for all withVMS infants
  rename(cong.CP.O = `TRUE`,
         No.cong.CP.O = `FALSE`) %>%
  mutate(PCVMSMatch.Obj = cong.CP.O/(cong.CP.O+No.cong.CP.O)) #  When there is a VMS-congruent Object, how often do infants respond with a congruent CP?

incong.CP.P <- CPdata_nostimmatch %>% 
  filter(VMS.Prompt.Cong == F,            # includes withVMS and noVMS infants (noVMS infants all filter as VMS.Prompt.Cong ==F)
         !grepl("^\\[",cgprompt)) %>%     # filter out all instances of [unclear], etc but keep, e.g. 'lxx [name]'
  group_by(subj, Prod.Prompt.Cong) %>%
  tally() %>%
  spread(Prod.Prompt.Cong, n) %>%
  replace(is.na(.), 0) %>%           # Change NAs to 0 so %s can be calculated for all infants
  rename(incong.CP.P = `TRUE`,
         No.incong.CP.P = `FALSE`) %>%
  mutate(PCNoVMSMatch.Prompt = incong.CP.P/(incong.CP.P+No.incong.CP.P)) # When there is a VMS-INcongruent CG prompt, how often do infants respond with a congruent CP?

incong.CP.O <- CPdata_nostimmatch %>% 
  filter(VMS.Obj.Cong == F,             # includes withVMS and noVMS infants (noVMS infants all filter as VMS.Obj.Cong ==F )
         !grepl("^\\[",object)) %>%     # filter out all instances of [toy], [unavailable], etc but keep, e.g. 'lxx [name]'
  group_by(subj, Prod.Obj.Cong) %>%
  tally() %>%
  spread(Prod.Obj.Cong, n) %>%
  ungroup() %>%
  replace(is.na(.), 0) %>%                           # Change NAs to 0 so %s can be calculated for all infants
  rename(incong.CP.O = `TRUE`,
         No.incong.CP.O = `FALSE`) %>%
  mutate(PCNoVMSMatch.Obj = incong.CP.O/(incong.CP.O+No.incong.CP.O))  # When there is a VMS-INcongruent Object, how often do infants respond with a congruent CP?

# Join all dfs with ProdData_nostimmatch

ProdData_nostimmatch <- Prod.Prompt %>%  # Does infant's CP match the caregiver prompt?
  left_join(Prod.Obj) %>%       # Does infant's CP match the attended object?
  left_join(CP.Obj) %>%            # How many CPs are accompanied by an object?
  left_join(CP.Prompt) %>%         # How many CPs are accompanied by a caregiver prompt?
  left_join(cong.CP.P) %>%         # When there is a VMS-congruent CG prompt, how often do infants respond with a congruent CP?
  left_join(cong.CP.O) %>%         # When there is a VMS-congruent object, how often do infants respond with a congruent CP?
  left_join(incong.CP.P) %>%       # When there is a VMS-incongruent CG prompt, how often do infants respond with a congruent CP?
  left_join(incong.CP.O) %>%       # When there is a VMS-incongruent object, how often do infants respond with a congruent CP?
  select(-Prod.Obj.NoMatch, -Prod.Obj.Match, -Prod.Prompt.NoMatch, -Prod.Prompt.Match,
         -No.cong.CP.P, -cong.CP.P, -No.cong.CP.O, -cong.CP.O, -No.incong.CP.O, -No.incong.CP.P,
         -incong.CP.O, -incong.CP.P) %>%
  mutate(PCVMSMatch.Prompt = ifelse(VMSgroup!="noVMS" & is.na(PCVMSMatch.Prompt),0,PCVMSMatch.Prompt), # Keep noVMS infants as NA, change withVMS infants with no CPs to 0
         PCNoVMSMatch.Prompt = ifelse(VMSgroup!="noVMS" & is.na(PCNoVMSMatch.Prompt),0,PCNoVMSMatch.Prompt),# Keep noVMS infants as NA, change withVMS infants with no CPs to 0
         PCVMSMatch.Obj = ifelse(VMSgroup!="noVMS" & is.na(PCVMSMatch.Obj),0,PCVMSMatch.Obj), # Keep noVMS infants as NA, change withVMS infants with no CPs to 0
         PCNoVMSMatch.Obj = ifelse(VMSgroup!="noVMS" & is.na(PCNoVMSMatch.Obj),0,PCNoVMSMatch.Obj)) # Keep noVMS infants as NA, change withVMS infants with no CPs to 0



# Dataframes for comparison of inREP vs outREP consonants

# Prompt

matchPrompt <- ProdData_nostimmatch %>% 
  dplyr::select(subj, VMSgroup, PCVMSMatch.Prompt) %>% 
  mutate(Type = "inREP") %>% 
  rename(PC = PCVMSMatch.Prompt)

nomatchPrompt <- ProdData_nostimmatch %>% 
  dplyr::select(subj, VMSgroup, PCNoVMSMatch.Prompt) %>% 
  mutate(Type = "outREP") %>% 
  rename(PC = PCNoVMSMatch.Prompt) 
match.data.Prompt <- bind_rows(matchPrompt, nomatchPrompt)

match.data.Prompt.spread <- match.data.Prompt %>%      # to allow for paired comparisons of inREP vs. outREP consonants for withVMS infants
  group_by(subj) %>% # to allow pairwise comparisons
  spread(Type, PC)

# Object

matchObject <- ProdData_nostimmatch %>%
  dplyr::select(subj, VMSgroup, PCVMSMatch.Obj) %>%
  mutate(Type = "inREP") %>%
  rename(PC = PCVMSMatch.Obj)

nomatchObject <- ProdData_nostimmatch %>%
  dplyr::select(subj, VMSgroup, PCNoVMSMatch.Obj) %>%
  mutate(Type = "outREP") %>%
  rename(PC = PCNoVMSMatch.Obj)

match.data.Object <- bind_rows(matchObject, nomatchObject)
  
match.data.Object.spread <- match.data.Object %>%      # to allow for paired comparisons of inREP vs. outREP consonants for withVMS infants
  group_by(subj) %>% # to allow pairwise comparisons
  spread(Type, PC)

