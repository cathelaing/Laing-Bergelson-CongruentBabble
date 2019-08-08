*Updated 7th August 2019*

This file goes through each factor level in each of the CPdata_randsubj.csv output file from the Production Study and describes the motivation 
behind each with regard to what was included and what was omitted.

First it is important to note that most input data (object, prompt) is focused on infant interactions with the caregiver, but other input - from
grandparents and siblings - is also included. All sibling input is marked as such in the original data. We refer to all input as caregiver input here.

**VMS**

VMS were determined according to the procedure adopted by DePaolis et al (2011) following Vihman and McCune (2001). These authors state that an infant has acquired a VMS either when a) a consonant is produced 10 or more times in three half-hour recording sessions, with no more than one intervening session with fewer than 10 utterances of that consonant, or b) a consonant is produced 50 times within a single half-hour session. As recordings in the Seedlings data were taken on a monthly basis, we defined a VMS as being established when:

  * an infant produced a consonant 50 times or more in one half-hour recording at 0;10;
  * OR an infant produced a consonant >20 but <50 times at 0;10, AND produced **the same** consonant >20 but <50 times at 0;11;
  * OR an infant produced a consonant >20 but <50 times at 0;10 but then produced any consonant >50 times when re-tested at 0;11.
  
 In order to ensure that the VMS data did not confound with the data used in the analysis, we drew upon the audio recordings to determine VMS production, and used the video data for the full analysis of infant productions. This way, we can be sure that consistencies across the audio and video data do represent stable VMS production.

A script was generated that extracted the four half-hour portions of the sixteen-hour LENA recordings containing the highest number of child vocalizations. This was first defined using the 10-month recording for each infant in the Seedlings corpus (n=44), and consonant production was tallied manually by the first author. Only fully-articulated supraglottal obstruents and nasals (i.e. plosives, nasals, and fricatives but not approximants) were counted in this data, since vowels and liquids can easily be confounded in impressionistic analysis. Voicing contrasts were not considered to be relevant in our analysis since infants of this age have been shown to have little control over voicing (Macken, 1980). In some instances the audio data contained long periods of crying, or the infant was clearly sucking on a pacifier – in such cases the half-hour portion with the second highest number of child vocalizations was analysed.

**CType**

The consonant produced by the infant is listed here - both voiced and voiceless iterations (where relevant). Only supraglottal consonants with a full vocal closure were considered, since this study considers consonant specifically - production of a consonant with a full closure is a more direct measure of phonological development than an /r/- or /l/-like production, which are more difficult to analyze impressionistically and thus may be confounded with. vowels. It is also important to note that liquids and approximants (r, l, w) are not generally produced in early infant speech; While some infants did produce liquids/approximants, these were rare in the data and didn't feature in any infant's VMS repertoire. 

In some cases (n=59) infants produced vocalizations that contained more than one consonant. In these cases we selected only the initial consonant of the vocalization. 

Voicing contrast is neutralized across plosives (i.e. both /p/ is coded as 'p b') as infants are thought to acquire voicing contrasts at around 18 months, and so this is not relevant to this data. Affricated (/dZ/ and /tS/, as well as /ts/) are included in the alveolar plosive category, while all fricatives (/s/, /th/, /sh/, etc) are all categorized as /s/: since all fricatives were alveolar or post-alveolar it made sense to collapse these into one category.

**Object**

The object cell was filled in DataVyu if the infant was seen to be attending to an object during their consonant production. This included pointing to an object, holding an object, or appearing to focus their gaze on an object. 

The R script extracts the first three letters from the object label and then from there, recodes as an IPA consonant to be compared with the infants' CP and VMS. All instances of an object being labelled as 'toy' are classed as [toy], so that these many labelled objects are not classed as /t/-initial and matched to infants' /t/ productions. The label 'toy' is ambiguous and in most cases objects are assumed to not be known as 'toy' to the infant (if they are known at all) and so including this label would produce a biased result. Similarly, instances where the infant was not attending to an object (none), or when an object was unclear (unclear: if the CP was obstructued by eating or an object in the infant's mouth, or if the object in question was not clear), or out of view (out of view) were also included in square brackets. When the script reduces the object words to only the first 3 letters, `[` is included as the first letter and so does not get confounded with other objects. These `[` instances were then recoded as 'none' so they can be easily removed from the analysis.

Objects were coded according to the most specific object thought to be attended by the infant during CP production. If an infant was looking at a book with a picture of a dog in it, that instance would be coded as 'dog' rather than 'book'. In some cases family-specific words were used, for example one infant produced /b/ while holding up a teddy - it later transpired that this teddy was referred to as 'bXXX' by the family, and so this was coded as such. Some instances were ambiguous, such as a TV remote or a tower of blocks (is it a tower or is it blocks?) - in these cases this was coded as the term that was used by the caregiver, where possible. When not possible the most obvious label for the object (remote or tower in these examples) was used. As with the classification of infant productions, affricates tS, ts and dZ were coded as /t d/ while all other fricatives were coded as /s/.

**CGPrompt**

The classification of CG prompts was similar to that of objects. A prompt was included in the DataVyu annotation if it was produced within the 15s prior to the infant's CP. In some cases caregivers' prompts were their repetitions of the infants' productions. For example, an infant said /bababa/ and the caregiver repeated this, leading the infant to go on producing that consonant. This happened 10 times in the dataset, and were removed from the analysis. In 7 cases the prompt is 'all done' or 'all gone'. These are coded as /d/ or /g/, respectively. 

A word was coded as a CG prompt if it was assumed to be acoustically salient to the infant. The majority of CG prompts are thus object words, but names, short phrases ('all gone') are also included. The speech did not have to be directed at the infant but did have to be produced clearly in the infants' presence. As with the classification of infant productions, affricates tS, ts and dZ were coded as /t d/ while all other fricatives were coded as /s/.

**CGResp**

We do not analyse CG response in this study, but it provides an interesting perspective on the data and so we include this information here. Caregiver responses following infants' CPs were coded according to six categories described below. There was no timeframe for this measure, but a response was only coded if it was clearly related to the infant's CP. In all cases, the response was the caregiver utterance that immediately followed the CP; in many instances this had nothing to do with the CP, and so was coded as 'none' (i.e. the caregiver utterance was not a response to the infant's production).

Responses were coded as 'unavailable' if the infant was eating, crying (and thus their CP was also excluded from analysis), or if they had an object in their mouth. CPs during which the caregiver was out of the room or out of sight were also coded as unavailable. The other six categories are listed below:

 - *Agreement*: The CP is followed by the caregiver 'agreeing' with the infant, such as 'yeah that's right'. In such cases the CG is treating the CP as speech and offering an affirmative response to the infant without attempting to prompt further production.

 - *Reformulation*: A response counts as a reformulation when the caregiver takes the phonological features of a CP and 'repeats' it by turning it into a word. For example, the infant says /da/ and the caregiver responds with 'it's a dog'. In some cases the CGResp was coded as the caregiver's reformulated word, in others it was coded as simply 'reformulation', which is why the script collapses a range of target words into this category. In other cases it is coded as 'correction'; the terminology was streamlined partway into data collection. There are also some examples of agrrement + reformulation ('that's right, dog'); rather than creating a new category for these few instances, it seemed reasonable to interpret reformulation as being an affirmative response, and so to collapse this category for ease of analysis. Since reformulation is the most salient response of the two categories (i.e. it is a linguistically more 'supportive' response) these combinations are collapsed into reformulations rather than agreements.

 - *Repetition*: A response is a repetition when the caregiver repeats the infant's CP (correctly or otherwise - sometimes [ta] was repeated as `[`ba`]`, for example). Again there were instances of response combinations, once each with agreement and question (see below), and three times with reformulation. Agreement/question + repetition were collapsed as repetition for the same reasons of salience described above; instances of repetition + reformulation were collapsed into repetitions because in each case the repetition preceeded the reformulation.

 - *Response*: Responses were coded as such when the caregiver responded to the CP as if in a conversation with the infant. For example, saying 'thank you' to an infant who is saying `[`ba`]` while holding out a toy. 

- *Question*: Responses were classed as questions when the caregiver responded to the CP with a question as if in a conversation with the infant. This goes a step further than 'response' or 'agreement' because it suggests an attempt to draw out the interaction. For example, if the infant says /ta/ while looking at a tower the caregiver might respond with 'can you knock it over?'.

Other variables

 - **C1Obj:** The initial consonant of the attended object

 - **C1Prompt:** The initial consonant of the caregiver prompt

 - **Prod.Obj.Cong:** is the CP congruent with the attended object? TRUE/FALSE

 - **Prod.Prompt.Cong:** is the CP congruent with the caregiver prompt? TRUE/FALSE

 - **VMS.Obj.Cong:** is the VMS congruent with the attended object? TRUE/FALSE

 - **VMS.Prompt.Cong:** is the VMS congruent with the caregiver prompt? TRUE/FALSE

 - **VMS.Prod.Cong:** is the CP congruent with the VMS? TRUE/FALSE


These variables are used to generate the dataset ProdData, which uses the following variables in the analysis:

 - **CPtokens:** how many CPs does the infant produce overall in the video data?

 - **CPtypes:** how many different consonants does the infant produce in the video data?

 - **VMS.Prod.Match.PC:** What % of infants' CPs match their VMS?

 - **VMS.Obj.Match.PC:** What % of attended objects match infants' VMS?

 - **Prod.Obj.Match.PC:** What % of infants' CPs match attended objects?

- **VMS.Prompt.Match.PC:** What % of CG prompts match infants' VMS?

 - **Prod.Prompt.Match.PC:** What % of infants' CPs match CG prompts?

 - **nObj:** How many CPs are accompanied by attended objects?

 - **nPrompt:** How many CPs are accompanied by CG prompts?

 - **PCVMSMatch.Prompt:** What % of CPs match CG prompts AND infants' VMS?

 - **PCVMSMatch.Obj:** What % of CPs match objects AND infants' VMS?

 - **PCVMSNoMatch.Prompt:** What % of CPs match CG prompts BUT NOT infants' VMS?

 - **PCVMSNoMatch.Obj:** What % of CPs match CG prompts BUT NOT infants' VMS?
