# Updated 18th December 2019

# This script works with the main consonant production spreadsheet (CPdata.csv) to count how
# many CPs match VMS/Objects/Prompts for each infant. This creates the main dataset to be used in the production study analysis.

library(tidyverse)
library(forcats)
library(feather)
library(stringi)

CPdata <- read_csv("Data/CPdata_randsubj.csv") %>% # read in CPdata_randsubj.csv to use as a base df for all following dfs
 mutate(subj = factor(subj))

ProdData <- CPdata %>%
  group_by(subj, month, sex, MOTedu, Siblings, VMSgroup, VMS) %>%
  tally() %>%
  ungroup() %>%
  rename("CPtokens" = "n") %>%
  mutate(MOTedulevel = fct_recode(MOTedu,
                                  "1" = "High School",
                                  "2" =  "Some college",
                                  "3" = "Assoc Degree",
                                  "4" = "Bachelors Degree",
                                  "5" = "Masters Degree",
                                  "6" =  "Doctorate"))

ProdData$MOTedulevel <- as.numeric(as.character(ProdData$MOTedulevel))

CPtyp <- CPdata %>%
  group_by(subj) %>%
  summarise(CPtypes = n_distinct(ctype)) %>%  # How many CP types produced per infant?
  ungroup()

VMS.Prod <- CPdata %>%    
  group_by(subj, VMS.Prod.Cong, VMSgroup) %>%
  tally() %>%
  spread(VMS.Prod.Cong, n) %>%
  rename(VMS.Prod.NoMatch = `FALSE`,
         VMS.Prod.Match = `TRUE`) %>%
  mutate(VMS.Prod.Match = ifelse(VMSgroup!="noVMS" & is.na(VMS.Prod.Match),0,VMS.Prod.Match),  # Variable only applies to withVMS infants
    VMS.Prod.NoMatch = ifelse(VMSgroup!="noVMS" & is.na(VMS.Prod.NoMatch),0,VMS.Prod.NoMatch), # Keep noVMS infants as NA, change withVMS infants with no CPs to 0
    VMS.Prod.match.PC = VMS.Prod.Match/(VMS.Prod.Match+VMS.Prod.NoMatch)) # For infants who have VMS, what % of CPs are congruent with VMS?

Prod.Obj <- CPdata %>%                  # Only includes 43 infants as subj 944 doesn't have any attended objects
  filter(!grepl("^\\[",object)) %>%    # exclude all instances where object is coded as [toy], [unclear], etc but keep insances of e.g. 'lxx [name]'
  group_by(subj, Prod.Obj.Cong, VMSgroup) %>%
  tally() %>%
  spread(Prod.Obj.Cong, n) %>%
  ungroup() %>%
  replace(is.na(.), 0) %>%               # analysis includes all infants, so change all NAs to 0 across VMS groups
  rename(Prod.Obj.NoMatch = `FALSE`,
         Prod.Obj.Match = `TRUE`) %>%
  mutate(Prod.Obj.match.PC = Prod.Obj.Match/(Prod.Obj.Match+Prod.Obj.NoMatch)) # What % of attended objects match infants' CPs?

Prod.Prompt <- CPdata %>%
  filter(!grepl("^\\[",cgprompt)) %>%     # exclude all instances where object is coded as [toy], [unclear], etc but keep insances of e.g. 'lxx [name]'
  group_by(subj, Prod.Prompt.Cong, VMSgroup) %>%
  tally() %>%
  spread(Prod.Prompt.Cong, n) %>%
  replace(is.na(.), 0) %>%               # analysis includes all infants, so change all NAs to 0 across VMS groups
  rename(Prod.Prompt.NoMatch = `FALSE`,
         Prod.Prompt.Match = `TRUE`) %>%
  mutate(Prod.Prompt.match.PC = Prod.Prompt.Match/(Prod.Prompt.Match+Prod.Prompt.NoMatch)) # What % of CG prompts match infants' CPs?

CP.Obj <- CPdata %>%
  filter(!grepl("^\\[",object)) %>%    # exclude all instances where object is coded as [toy], [unclear], etc
  group_by(subj) %>%
  count() %>%
  rename(nObj = n) %>% # How many CPs are accompanied by an Object?
  ungroup() %>%
  add_row(subj = "944", nObj = 0)   # subj 944 has no objects, so add this row manually

CP.Prompt <- CPdata %>%
  filter(!grepl("^\\[",cgprompt)) %>%  # exclude all instances where prompt is coded as [unclear], etc, but include eg. "txx [chi name]"
  group_by(subj) %>%
  tally() %>%
  rename(nPrompt = n)    # How many CPs are accompanied by a CG Prompt?

cong.CP.P <- CPdata %>% 
  filter(VMS.Prompt.Cong == T) %>%   # withVMS infants only; one infant has no VMS congruent prompts
  group_by(subj, Prod.Prompt.Cong, VMSgroup) %>%
  tally() %>%
  spread(Prod.Prompt.Cong, n) %>%
  ungroup() %>%
  replace(is.na(.), 0) %>%    # Change NAs in the No.cong.CP.P column to 0 so %s can be calculated for all withVMS infants
  rename(cong.CP.P = `TRUE`,
         No.cong.CP.P = `FALSE`) %>%
  mutate(PCVMSMatch.Prompt = cong.CP.P/(cong.CP.P+No.cong.CP.P))  # When there is a VMS-congruent CG prompt, how often do infants respond with a congruent CP?

cong.CP.O <- CPdata %>%
  filter(VMS.Obj.Cong == T) %>%    # withVMS infants only; two infants have no VMS congruent objects
  group_by(subj, Prod.Obj.Cong, VMSgroup) %>%
  tally() %>%
  spread(Prod.Obj.Cong, n) %>%
  ungroup() %>%
  replace(is.na(.), 0) %>%      # Change NAs in the No.cong.CP.O column to 0 so %s can be calculated for all withVMS infants
  rename(cong.CP.O = `TRUE`,
         No.cong.CP.O = `FALSE`) %>%
  mutate(PCVMSMatch.Obj = cong.CP.O/(cong.CP.O+No.cong.CP.O)) #  When there is a VMS-congruent Object, how often do infants respond with a congruent CP?

incong.CP.P <- CPdata %>% 
  filter(VMS.Prompt.Cong == F,            # includes withVMS and noVMS infants (noVMS infants all filter as VMS.Prompt.Cong ==F)
         !grepl("^\\[",cgprompt)) %>%     # filter out all instances of [unclear], etc but keep, e.g. 'lxx [name]'
  group_by(subj, Prod.Prompt.Cong) %>%
  tally() %>%
  spread(Prod.Prompt.Cong, n) %>%
  replace(is.na(.), 0) %>%           # Change NAs to 0 so %s can be calculated for all infants
  rename(incong.CP.P = `TRUE`,
         No.incong.CP.P = `FALSE`) %>%
  mutate(PCNoVMSMatch.Prompt = incong.CP.P/(incong.CP.P+No.incong.CP.P)) # When there is a VMS-INcongruent CG prompt, how often do infants respond with a congruent CP?

incong.CP.O <- CPdata %>% 
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

# Join all dfs with ProdData

ProdData <- ProdData %>%           # How many consonant tokens are produced by each infant?
  left_join(CPtyp) %>%             # How many consonant types are produced by each infant?
  left_join(VMS.Prod) %>%          # Does infant's CP match their VMS?
  left_join(Prod.Obj) %>%          # Does infant's CP match the attended object?
  left_join(Prod.Prompt) %>%       # Does infant's CP match the caregiver prompt
  left_join(CP.Obj) %>%            # How many CPs are accompanied by an object?
  left_join(CP.Prompt) %>%         # How many CPs are accompanied by a caregiver prompt?
  left_join(cong.CP.P) %>%         # When there is a VMS-congruent CG prompt, how often do infants respond with a congruent CP?
  left_join(cong.CP.O) %>%         # When there is a VMS-congruent object, how often do infants respond with a congruent CP?
  left_join(incong.CP.P) %>%       # When there is a VMS-incongruent CG prompt, how often do infants respond with a congruent CP?
  left_join(incong.CP.O) %>%       # When there is a VMS-incongruent object, how often do infants respond with a congruent CP?
  select(-Prod.Obj.NoMatch, -Prod.Obj.Match, -Prod.Prompt.NoMatch, -Prod.Prompt.Match,
         -No.cong.CP.P, -cong.CP.P, -No.cong.CP.O, -cong.CP.O, -No.incong.CP.O, -No.incong.CP.P,
         -incong.CP.O, -incong.CP.P) 

# Read in VMS datasets for analysis in .Rmd script

VMS <- read_csv("Data/VMS_randsubj.csv") %>%
  mutate(subj = factor(subj))

vmscount <- read_csv("Data/vms_count_randsubj.csv") %>%    # number of each consonant type produced during audio recordings
  mutate(subj = factor(subj)) %>% 
  left_join(VMS, by = "subj") %>%
  mutate(VMSgroup = ifelse(Group == "Nx", "noVMS", "withVMS")) %>%
  #select(-month.y) %>%
  rename("month" = "month.y",                # month used in full analysis (i.e. month at which infant was tested)
         "month_chron" = "month.x") %>%      # data from month 10 or 11, for infants who were analyzed twice
  group_by(subj, month_chron) %>% 
  mutate(totalprod = sum(n)) %>%
  ungroup()

vmscount$Consonant <- substr(vmscount$Consonant, 1, 1)  # to classify consonant as inREP or outREP

vmscount <- vmscount %>% mutate(inREP = stri_detect_regex((vmscount$VMS), (vmscount$Consonant))) # match between VMS and CP: inREP or outREP

vmscount$subj <- reorder(vmscount$subj, vmscount$totalprod, sum)   # reorder consonants for plotting in order by total n
vmscount$subj <- fct_rev(vmscount$subj)

# Create subsets for summaries in methodology

vmssubset1 <- vmscount %>% group_by(subj) %>% tally() %>% filter(n == 5)  # infants with data at 10m only
vms_subset2 <- vmscount %>% group_by(subj) %>% tally() %>% filter(n == 10) # 17 infants with data at 10 and 11 months



# Create new datasets for analysis in .Rmd script

# vmstotal: calculates total consonant production (types and tokens) in audio recordings

CPtypes_audio <- vmscount %>% filter(n > 0 & month_chron == month) %>% group_by(subj) %>% 
  summarise(audiotypes = n_distinct(Consonant))

vmstotal <- vmscount %>% group_by(subj, month, sex, MOTedu, VMSgroup, VMS) %>% 
  filter(month_chron == month) %>%
  summarise(audiotokens = sum(n)) %>% 
  ungroup() %>% mutate(MOTedulevel = fct_recode(MOTedu,
                                                "1" = "High School",
                                                "2" =  "Some college",
                                                "3" = "Assoc Degree",
                                                "4" = "Bachelors Degree",
                                                "5" = "Masters Degree",
                                                "6" =  "Doctorate")) %>%
  left_join(CPtypes_audio) %>%
  replace(is.na(.),0)


vmstotal$MOTedulevel <- as.numeric(as.character(vmstotal$MOTedulevel))

# CPtypes_audio: calculates number of consonant types produced in audio recordings

CPtypes_audio <- vmscount %>% group_by(subj, VMSgroup, month, sex, MOTedu) %>% 
  filter(n > 0 & month_chron == month) %>%     # filter out consonants that are not produced
  summarise(CPtypes = n_distinct(Consonant))

CPtypes_audio <- CPtypes_audio %>% ungroup() %>% mutate(MOTedulevel = fct_recode(MOTedu,
                                                                                 "1" = "High School",
                                                                                 "2" =  "Some college",
                                                                                 "3" = "Assoc Degree",
                                                                                 "4" = "Bachelors Degree",
                                                                                 "5" = "Masters Degree",
                                                                                 "6" =  "Doctorate"))
CPtypes_audio$MOTedulevel <- as.numeric(as.character(CPtypes_audio$MOTedulevel))

# compareRecordings: number of inREP and outREP consonants produced in Video recordings  
# to compare with VMS as determined in audio recordings

compareRecordings <- CPdata %>% filter(VMSgroup != "noVMS") %>% # only analysing withVMS infants with this variable
  group_by(VMS.Prod.Cong, subj, ctype) %>%
  tally() %>%
  summarise(meanProd = mean(n)) %>%
  ungroup() %>%
  add_row(VMS.Prod.Cong = F, meanProd = 0, subj = "351") %>% # because 351 had 0 non-congruent CPs, row is missing.
  arrange(VMS.Prod.Cong, subj) #otherwise when you do the paired test below, it's not lined up right

compareRecordings.spread <- compareRecordings %>% group_by(subj) %>% # to allow pairwise comparisons
  spread(VMS.Prod.Cong,meanProd) %>% 
  rename(VMS.Prod.Cong=`TRUE`, VMS.Prod.Incong=`FALSE`)

# match.data.Prompt: How many of infants' CPs match CG prompt and to what are these inREP vs. outREP?

matchPrompt <- ProdData %>% 
  dplyr::select(subj, VMSgroup, PCVMSMatch.Prompt) %>%   # Both VMS groups included
  mutate(Type = "inREP") %>%                             # BUT no CPs are inREP for noVMS infants; all turned to NA
  rename(PC = PCVMSMatch.Prompt) %>%                     # %s represent proportion of CPs that did match prompt
  mutate(PC = ifelse(VMSgroup != "noVMS" & is.na(PC),0, PC))  # change NAs to 0 to include withVMS infants who never match with CG input

nomatchPrompt <- ProdData %>% 
  dplyr::select(subj, VMSgroup, PCNoVMSMatch.Prompt) %>% # Both VMS groups included
  mutate(Type = "outREP") %>%                           # all CPs are outREP for noVMS infants
  rename(PC = PCNoVMSMatch.Prompt)                      # %s represent proportion of CPs that didn't match prompt
match.data.Prompt <- bind_rows(matchPrompt, nomatchPrompt)

match.data.Prompt.spread <- match.data.Prompt %>%      # to allow for paired comparisons of inREP vs. outREP consonants for withVMS infants
  group_by(subj) %>% # to allow pairwise comparisons
  spread(Type, PC)

# match.data.Object: How many of infants' CPs match attended object and to what are these inREP vs. outREP?

matchObject <- ProdData %>%                             
  dplyr::select(subj, VMSgroup, PCVMSMatch.Obj) %>%     # Both VMS groups included
  mutate(Type = "inREP") %>%                            # BUT no CPs are inREP for noVMS infants; all turned to NA
  rename(PC = PCVMSMatch.Obj) %>%                       # %s represent proportion of CPs that did match object
  mutate(PC = ifelse(VMSgroup != "noVMS" & is.na(PC),0, PC)) # change NAs to 0 to include infants who always match to object, 
# exclude subj 944 who has no objects in input
  
nomatchObject <- ProdData %>% 
  dplyr::select(subj, VMSgroup, PCNoVMSMatch.Obj) %>%   # Both VMS groups included
  mutate(Type = "outREP") %>%                           # all CPs are outREP for noVMS infants
  rename(PC = PCNoVMSMatch.Obj) %>%                        # %s represent proportion of CPs that didn't match prompt
  mutate(PC = ifelse(subj != "944" & is.na(PC), 0, PC))     # change NAs to 0 to include infants who always match to object, 
                                                        # exclude subj 944 who has no objects in input

match.data.Object<- bind_rows(matchObject, nomatchObject) 

match.data.Object.spread <- match.data.Object %>%      # to allow for paired comparisons of inREP vs. outREP consonants for withVMS infants
  group_by(subj) %>% # to allow pairwise comparisons
  spread(Type, PC)

