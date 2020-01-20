# Updated 20th January 2020

# This script is the same as ProductionData_randsubj.r, though it joins CPdata with a dataset of cgprompt levels designated by wordclass.
# This allows for filtering of nouns and onomatopoeia. This is only relevant to the CGprompt variable (since attended objects
# were always nouns) and so only relevant variables are generated here. 

CPdata <- read_csv("Data/CPdata_randsubj.csv") %>%# read in CPdata_randsubj.csv to use as a base df for all following dfs
  mutate(subj = factor(subj))

# levels_cgprompt <- as.data.frame(unique(CPdata$cgprompt))  
# 
# write.csv(levels_cgprompt, "Data/levels_cgprompt.csv")  # create dataset of cgprompt levels, then manually assign each cgprompt
                                                          # to a word class

vmsgroupdata <- read_csv("Data/VMS_randsubj.csv") %>%    # number of each consonant type produced during audio recordings
  mutate(subj = factor(subj)) 

cgprompt_levels <- read_csv("Data/levels_cgprompt.csv")

CPdata_nouns <- CPdata %>% left_join(cgprompt_levels) %>%
  filter(wordclass == "N" | wordclass == "O" | wordclass == "G")            # only include nouns and onomatopoiea

ProdData_nouns_base <- CPdata_nouns %>%     # subj 189 does not have any CP tokens in this dataset
  group_by(subj, month, sex) %>%
  tally() %>%
  ungroup() %>%
  rename("nPrompt" = "n")    # How many CPs are accompanied by a CG Prompt?  (note that CPdata_nouns is already filtered for CG prompts so no need to re-filter here)

ProdData_nouns <- vmsgroupdata %>% 
  dplyr::select(subj, Group) %>%
  left_join(ProdData_nouns_base) %>%   # join with VMS data here and replace 189's NA with 0
    replace(is.na(.), 0) %>%
  mutate(VMSgroup = ifelse(Group == "Nx", "noVMS", "withVMS"))

Prod.Prompt_nouns <- CPdata_nouns %>%
  group_by(subj, Prod.Prompt.Cong, VMSgroup) %>%
  tally() %>%
  spread(Prod.Prompt.Cong, n) %>%
  replace(is.na(.), 0) %>%               # change all NAs to 0 across all VMS groups
  rename(Prod.Prompt.NoMatch = `FALSE`,
         Prod.Prompt.Match = `TRUE`) %>%
  mutate(Prod.Prompt.match.PC = Prod.Prompt.Match/(Prod.Prompt.Match+Prod.Prompt.NoMatch)) # What % of CG prompts match infants' CPs?
  # Need to convert 0s to NAs at end of script for all infants
  
cong.CP.P_nouns <- CPdata_nouns %>% 
  filter(VMS.Prompt.Cong == T) %>%   # One infant has no VMS congruent prompts
  group_by(subj, Prod.Prompt.Cong, VMSgroup) %>%
  tally() %>%
  spread(Prod.Prompt.Cong, n) %>%
  ungroup() %>%
  replace(is.na(.), 0) %>%    # Change NAs in the No.cong.CP.P column to 0 so %s can be calculated
  rename(cong.CP.P = `TRUE`,
         No.cong.CP.P = `FALSE`) %>%
  mutate(PCVMSMatch.Prompt = cong.CP.P/(cong.CP.P+No.cong.CP.P))  # When there is a VMS-congruent CG prompt, how often do infants respond with a congruent CP?
# need to convert NAs to 0 at end of script for withVMS infants only

incong.CP.P_nouns <- CPdata_nouns %>% 
  filter(VMS.Prompt.Cong == F & C1Prompt != 'none') %>%
  group_by(subj, Prod.Prompt.Cong) %>%
  tally() %>%
  spread(Prod.Prompt.Cong, n) %>%
  replace(is.na(.), 0) %>%
  rename(incong.CP.P = `TRUE`,
         No.incong.CP.P = `FALSE`) %>%
  mutate(PCNoVMSMatch.Prompt = incong.CP.P/(incong.CP.P+No.incong.CP.P)) # When there is a VMS-INcongruent CG prompt, how often do infants respond with a congruent CP?
# need to convert NAs to 0 at end of script for all infants


# Join all dfs with ProdData

ProdData_nouns <- ProdData_nouns %>%           # How many consonant tokens are produced by each infant?
  left_join(Prod.Prompt_nouns) %>%       # Does infant's CP match the caregiver prompt
  left_join(cong.CP.P_nouns) %>%         # When there is a VMS-congruent CG prompt, how often do infants respond with a congruent CP?
  left_join(incong.CP.P_nouns) %>%       # When there is a VMS-incongruent CG prompt, how often do infants respond with a congruent CP?
  select(-Prod.Prompt.NoMatch, -Prod.Prompt.Match, -No.cong.CP.P, -cong.CP.P, 
         -No.incong.CP.P, -incong.CP.P) %>%
  mutate(Prod.Prompt.match.PC = ifelse(is.na(Prod.Prompt.match.PC),0,Prod.Prompt.match.PC),  # Variable applies to all infants
         PCVMSMatch.Prompt = ifelse(VMSgroup!="noVMS" & is.na(PCVMSMatch.Prompt),0,PCVMSMatch.Prompt), # Keep noVMS infants as NA, change withVMS infants with no CPs to 0
         PCNoVMSMatch.Prompt = ifelse(is.na(PCNoVMSMatch.Prompt), 0, PCNoVMSMatch.Prompt)) 

# Create new datasets for analysis in .Rmd script

# match.data.Prompt: How many of infants' CPs match CG prompt and to what are these inREP vs. outREP?

matchPrompt <- ProdData_nouns %>% 
  dplyr::select(subj, VMSgroup, PCVMSMatch.Prompt) %>% 
  mutate(Type = "inREP") %>% 
  rename(PC = PCVMSMatch.Prompt)

nomatchPrompt <- ProdData_nouns %>% 
  dplyr::select(subj, VMSgroup, PCNoVMSMatch.Prompt) %>% 
  mutate(Type = "outREP") %>% 
  rename(PC = PCNoVMSMatch.Prompt) 
match.data.Prompt_nouns <- bind_rows(matchPrompt, nomatchPrompt)

match.data.Prompt_nouns.spread <- match.data.Prompt_nouns %>%      # to allow for paired comparisons of inREP vs. outREP consonants for withVMS infants
  group_by(subj) %>% # to allow pairwise comparisons
  spread(Type, PC)

