# Quantifying the shift of public export finance from fossil fuels to renewable energy 
Code and data for Censkowsky et al. (2024). If you have questions about the code or find any errors/bugs, please contact Paul Waidelich (paul.waidelich[at]gess.ethz.ch, corresponding author).

## Organization of the overall project repository
The repository is organized in accordance to the Code and Software Submission Checklist provided by Nature Research. 
It features the following elements:
 1. Information on system requirements
 2. A brief installation guide
 3. A demo
 4. Instructions for use
 5. Description of scripts in the repository

## (1) Information on system requirements
The scripts can be executed on an ordinary computer and require neither substantial computational resources nor parallel processing. Runtime is a few minutes. No non-standard software is required.

For do-Files, we used Stata version 17 and tested that do-Files also run smoothly for Stata version 16. 

For Figure 5 and to generate the combined OCI-TXF data set used in the paper's Supplementary Information, we used R version 4.3.1 (2023-06-16 ucrt) with the following details: 
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows 10 x64 (build 19045)

Please see more information on R packages used below under "sessionInfo() in R".

## (2) Brief installation guide 
For STATA version 17: Please select your operating system and follow the official installation guide (https://www.stata.com/install-guide/). Typical install time: < 5 mins 

User defined commands: grc1leg2, shufflevar, and unique

*** install grc1leg2 as follows:

1) type 'search grc1leg2' into the Command in STATA
2) click on "grc1leg2 from http://digital.cgdev.org/doc/stata/MO/Misc" and then on "(click here to install)"

*** install shufflevar as follows:
ssc install shufflevar

*** install unique as follows: 
ssc install unique

For R version 4.3.1: Download instructions and installation files for different R versions are available on CRAN (https://cran.r-project.org/bin/windows/base/old/). Typical install time: < 5mins

## (3) Demo 
Instructions to run on the data: 
1. Install the right STATA software and version, including the user-defined commands (see above)
2. Open the Script Element 2 ("Figures"). Note that this is the only script that is designed to 'run smoothly' as a demo with a separately uploaded, censored, and randomly reshuffled dataset (approx. 10% sample size).
3. Change the file paths for the current directory according to the following instructions: 

   cd "the highest level of this repository"

4. Uncomment the line where the censored data is loaded (`data/TXF_data_censored.dta`) and instead comment out the line where the normal data is loaded (`data/current_working_file_July24.dta`)
5. Select all and run the Do-File

Expected output: Figures 1-4 (in various sub-elements, including png and gph formats). Final figures, as displayed in the paper, were slightly modified using Adobe Illustrator.
Expected runtime: 2 mins 

## (4) Instructions for use 
You can run the STATA code on the demo data as described above. 

As outlined in our article's Data Availability statement, we cannot make the proprietary TXF transaction raw data files publicly available and hence the scripts in this repository will result in errors (except for the Demo outlined above). However, we provide a systematic description of all steps taken to generate the final dataset and figures. Below, we describe each step in detail.


## (5) Description of scripts in the repository

## Element 1

Name: `Element1_generate_energy_subset_TXF.do`: appends the data and creates the energy-related subset.

Description: In this DO-file, we generate the final energy data subset. We execute two main objectives: (i) exclusion of all non-energy related deals; and (ii) re-classification of deals that are falsely classified as non-energy related (e.g., LNG tankers). For a definition of 'energy sector', see Supplementary Table 2 and for a detailed re-classification procedure, see 'Methods - Classification of energy-related transactions' of the main article.

Specifically, we:
- Import original Excel files and change to STATA data files
- Import and append two data waves (2013-2022 and an update for 2023)
- Screen for additional deals in industries not evidently related to energy (e.g., ships or infrastructure) and due re-classification
- Classify in coarse energy sub-categories coal, oil, gas, oil and gas mixed (fossil fuels) and wind, solar, hydro and other RETs (RETs), and nuclear
- Classify in value chain elements and finer technology elements
- Remove all non-energy-related deals from the dataset and save a new version
- Change key variables from string to numeric (e.g., Year)
- Inflation-adjust the two key variables (ECA involvement and total deal volume) using the methodology described in the Main manuscript (see 'Methods - Inflation adjustment').  
- Remove non-official ECAs (see Supplementary Table 5 for all organizations that are considered non-official, including those that were part of our original dataset but that were not active in the energy sector).
- Generate switches for additional checks (e.g., domestic financing, guarantees vs loans).
- Generate additional variables (numeric energy source, type of borrower, periods, total energy finance by period and country, specific variables for Figure 3)
- Identify the Top 10 energy financing countries based on total energy commitments (to inform order of countries in Figure 3)
- Generate specific variables for technologies (coarse and fine versions)

## Element 2

Name: `Element2_figures.do`: creates Figures 1-4 and serves as code for the Demo. Unlike all other Elements, which will result in errors without the original and proprietary TXF transaction data, this script is designed to 'run smoothly' when one uses the separately uploaded, censored and reshuffled Demo data (approx. 10% sample size) instead.

Description: In this DO-file, we:
- Produce Figures 1-4 (in various subelements).
- Modify some of the variables created in Element 1 as per the filtering requirements for a given figure (e.g., subset to guarantees or lending only) 

## Element 3

Name: `Element3_SI_generate_subset_OCI.do`: creates the subset of the OCI data used for triangulation in the Supplementary Information. The methodological steps used to subset this dataset are further described in the SI's Supplementary Methods for Supplementary Figures 1-7.

Description: In this DO-file, we: 
- exclude certain sectors not covered by our energy sector definition (e.g., electric vehicles)
- carry out changes to make TXF and OCI data comparable (definition of 'year', deflation, definition of ECA countries, generation of comparable variables)
- save the processed OCI data in .DTA and .CSV format

## Element 4
Name: `Element4_create_oci_txf_merged_data.R`: creates the combined data frame of TXF and OCI data used as a robustness and validity check in the SI.

Description: In this R-script, we:
- load the TXF and OCI energy-related subsets created in previous files and harmonize their naming conventions and categories
- use the higher commitment volume of the two data sets for a given combination of variable values (e.g., all commitments by Germany for solar PV deals in Angola that closed in 2010)
- export the combined data sets as CSV files under `/data/filled_up_txf_oci`

## Element 5
Name: `Element5_SI_figures.do`: creates Supplementary Figures 1-5 and Supplementary Figure 7. These figures notably serve to triangulate TXF data presented in the main manuscript with openly accessible data from Oil Change International. 

Description: In this DO-file, we:
- Compare TXF and OCI data based on all commitments disaggregated by fossil commitments, RET commitments, and Grid commitments (Supplementary Fig. 1)
- Replicate Figures 1-3 of the main manuscript using filled-up values (Supplementary Figures 3-5; for methodology, see our SI's Supplementary Methods for Supplementary Figures 1-7)
- Generate additional Figures to fill in data gaps (Supplementary Figure, 1, 2a, 2b, 7) 
- Generate data frames and graphs about the difference of the two data frames on a country level for fossil, RET and grid commitments and separated by financial instrument (Supplementary Fig. 3a and 3b)

## Element 6

Name: `Element6_Censored_datafile.do`: creates the censored demo version of our energy subset (a randomly selected 10% of deals).

Description: In this DO-file, we:
- Subset the original dataset randomly to approx. 10% of all deals
- Remove all columns not required for the Demo DO-file and reshuffle all columns kept
- Export the censored and reshuffled dataset   

## Element 7

Name: `Element7_SI tables and notes.do`: creates additional calculations used in the Supplementary Notes and Tables. 

Description: In this DO-file, we:
- Create the statistics used to support Supplementary Note 2 on fossil fuel-dependent countries
- Create the ECA finance by OECD versus non-OECD countries (Supplementary Table 6 and 7)


## Element 8

Name: `Element8_figure_recipientcountry_distribution.R`: creates Figure 5 in R.

Description: In this R-script, we:
- Collapse cumulative ECA commitments by recipient country and technology group (renewables or fossils)
- Draw maps of recipient country shares using shapefiles from the `rnaturalearth` package (Fig. 5a)
- Collapse cumulative ECA commitments by deal location (domestic, same region, or different region) and plot as a bar chart (Fig. 5b)
- Collapse cumulative ECA commitments by phase and income level of the recipient country (as per World Bank data) and plot as a bar chart (Fig. 5c)

## Data files in the repository
1. `data/240219 WB Country and Lending Groups.xlsx`: data on the World Bank Country and Lending Groups (used to classify countries into Lower-/Middle-/High-Income in Figure 3c) taken from the World Bank Data Help Desk (URL: https://datahelpdesk.worldbank.org/knowledgebase/articles/906519-world-bank-country-and-lending-groups).
2. `data/240801 ISO3-ISO2-codes.xlsx`: data on mapping ISO2 to ISO3 codes (or vice-versa).
3. `data/240918 IMF IFS - US CPI.xlsx`: data on the US Consumer Price Index taken from the IMF (URL: https://data.imf.org/?sk=4c514d48-b6ba-49ed-8ab9-52b0c1a0179b&sid=1390030341854).
4. `data/OCI Public Finance for Energy Database 2024.xlsx`: a version of the OCI Public Finance for Energy database obtained from OCI in July 2024.
5. `data/txf_countrynames_iso3_matched.csv`: a manually created data frame that matches the country names in the raw TXF data to standardized ISO3 identifiers.
6. `data/TXF_data_censored.dta`: approx. 10% sample of the raw TXF transaction data but censored and reshuffled (as the data are proprietary), to be used for the Demo (see description above).
7. `SourceData_SupplementaryFigures.xlsx`: Source Data for Supplementary Fig. 1-7

Date stamps in the filenames indicate the download date.

### Additional subfolders used by the scripts
1. `data/filled_up_txf_oci`: The data sets combining the TXF and OCI commitment volumes are stored here
2. `data/intermediate`: Intermediate data sets used to create figures are stored here

### Confidential files used by the scripts that are not available in the public repository
1.  `data/sus1 18 06.xlsx`: TXF raw data covering deals between 2013-2022, directly provided by TXF Limited. DTA version of the same file: `data/TXF_data.dta`
3.  `data/2023_ef_fy.xlsx`: TXF raw data covering deals in 2023, directly provided by TXF Limited. DTA version of the same file: `data/Raw_data_2023_new.dta`
5.  `data/current_working_file_July24.dta`: clean and processed TXF data for energy-related subset. CSV version of the same file: `data/TXF_July 24.csv`
6.  `data/OCI_July_2024.dta`: clean and processed OCI data for energy-related subset. CSV version of the same file: `data/OCI_July_2024.csv`
7.  The OCI-TXF combined data sets stored under `data/filled_up_txf_oci`

## sessionInfo() in R
```
R version 4.3.1 (2023-06-16 ucrt)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows 11 x64 (build 22631)

Matrix products: default


locale:
[1] LC_COLLATE=English_United States.utf8  LC_CTYPE=English_United States.utf8    LC_MONETARY=English_United States.utf8
[4] LC_NUMERIC=C                           LC_TIME=English_United States.utf8    

time zone: Europe/Zurich
tzcode source: internal

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] labelled_2.13.0     haven_2.5.3         patchwork_1.2.0     rnaturalearth_0.3.4 readxl_1.4.3        sf_1.0-15          
 [7] ggpubr_0.6.0        janitor_2.2.0       lubridate_1.9.3     forcats_1.0.0       stringr_1.5.1       dplyr_1.1.3        
[13] purrr_1.0.2         readr_2.1.4         tidyr_1.3.0         tibble_3.2.1        ggplot2_3.5.0       tidyverse_2.0.0    

loaded via a namespace (and not attached):
 [1] gtable_0.3.5       rstatix_0.7.2      lattice_0.21-8     tzdb_0.4.0         vctrs_0.6.3        tools_4.3.1        generics_0.1.3    
 [8] proxy_0.4-27       fansi_1.0.5        pkgconfig_2.0.3    KernSmooth_2.23-21 lifecycle_1.0.4    compiler_4.3.1     munsell_0.5.1     
[15] carData_3.0-5      snakecase_0.11.1   class_7.3-22       pillar_1.9.0       car_3.1-2          classInt_0.4-10    abind_1.4-5       
[22] tidyselect_1.2.1   stringi_1.7.12     cowplot_1.1.1      grid_4.3.1         colorspace_2.1-0   cli_3.6.1          magrittr_2.0.3    
[29] utf8_1.2.4         broom_1.0.5        e1071_1.7-13       withr_3.0.1        scales_1.3.0       backports_1.4.1    sp_2.1-2          
[36] timechange_0.2.0   httr_1.4.7         gridExtra_2.3      ggsignif_0.6.4     cellranger_1.1.0   hms_1.1.3          rlang_1.1.1       
[43] Rcpp_1.0.11        glue_1.6.2         DBI_1.1.3          rstudioapi_0.15.0  jsonlite_1.8.7     R6_2.5.1           units_0.8-5 
```
