#Updated 16th April 2019

The R scripts below read in CPdata_randsubj.csv. This is generated with data from .opf files (DataVyu), which is then anonymised before being read in
to scripts on the GitHub repository.

#Notes on generation of CPdata_randsubj:

 Consonant selection: 

 - no voicing contrast is noted for CPs, so all VMS and CType data includes both voiced and voiceless consonants
 - when a disyllabic word begins with a liquid or a vowel, C1 of the second syllable is coded for C1Obj/C1Prompt
 
 C1Prompt selection:
 
 - Instances where the caregiver is repeating the infant's production are omitted from the data
 - Full details of consonant selection (for infant CP, VMS, Object and CGPrompt are detailed on the Variables_READ ME document)
 - Instances where caregiver says 'toy' are kept in, whereas they are removed from the Attended Object data (see SI); this reflects the different linguistic 
   associations required for each of our variables (i.e. hearing 'toy' and responding /ta/ vs. seeing an object and knowing that it can be referred to as 
   a toy, when the infant probably has a more specific name for the object in question).

**Files in this repository:**

#1. ProductionData_randsubj: This script takes the full infant consonant data (CPdata_randsubj.csv) and creates numerical variables based on proportions of
TRUE/FALSE responses across infants. All variables used in the analysis are created here, and joined together at the end of the script to create ProdData,
the main dataset used in the analysis. Sub-sets of data are then created ready for analysis in the main Rmd analysis script. These include:

 - *CPtypes_audio*: takes counts of consonant types produced in the Audio recordings from vmscount for comparison across VMS groups
 - *vmstotal*: summaries of total consonant production in the Audio recordings
 - *compareRecordings.spread*: compares the average number of inREP vs outREP consonants produced in the Video recordings
 - *match.data.Prompt/Object.spread*: compares the number of input-congruent inREP consonants vs. outREP consonants

#2. Data Scrambling_randsubj: Data_scrambling.R randomizes the C1Prompt, C1Object and CType variables from DataGatherine_consonants and then 
re-generates Prompt.inProd and Object.inProd.PC for comparison with the original non-scrambled data.

*SupplementaryAnalyses_randsubj.rmd*

This includes three sub-analyses which draw on the following sub-scripts of ProductionData_randsubj.R:

#1. ProductionData_nostimmatch_randsubj.R

This script recreates the ProductionData_randsubj.R script, but starts by removing all instances where the CG prompt matches the object. 
The script is otherwise identical to ProductionData_randsubj.R. This script is read in to the main analysis file to re-run the data with 
these matching stimuli removed.

#2. ProductionData_noC1match_randsubj.R

This script recreates the ProductionData_randsubj.R script, but starts by removing all instances where the onset consonant of the CG prompt 
matches that of the object. The script is otherwise identical to ProductionData_randsubj.R. This script is read in to the main analysis 
file to re-run the data with these matching stimuli removed.

#3. ProductionData_nounsonly_randsubj.R

This script filters the data to consider only nouns, onomatopoeia, and greetings and routines (hi, bye, peekaboo) in the list of CG prompts. 
These word classes account for most of the early words of infants acquiring American English (Fenson et al., 1994). 
All levels from CPdata$cgprompt were labelled according to grammatical class to create levels_cgprompt.csv: noun (N), verb (V), onomatopoiea (O), 
adjective/adverb (A), determiner (D), greetings and routines (G), formulaic expression (F) or preposition (P). This script joins CPdata_randsubj.csv
with levels_cgprompt.csv, and then filters out all wordclasses except N, O and G.

##Associated files for these .rmd files include:

 - *Data_scrambling_nostimmatch_randsubj.R*: runs ProductionData_nostimmatch_randsubj.R, then scrambles the dataset
 - *Data_scrambling_noC1match_randsubj.R*: runs ProductionData_noC1match_randsubj.R, then scrambles the dataset
 - *Data_scrambling_Nounsonly_randsubj.R*: runs ProductionData_Nounsonly_randsubj.R, then scrambles the dataset
 - *levels_cgprompt.csv*: manually-coded word categories for each of the caregiver prompts, as generated in ProductionData_Nounsonly.R

##Files in /Data:

 - *vms_count_randsubj.csv*: for each infant, number of tokens of each consonant type produced in the 30-min audio segment at 10/11 months

 - *VMS_randsubj.csv*: file showing each infants' VMS, as well as demographic data (mothers' education and infant sex) and VMS group
