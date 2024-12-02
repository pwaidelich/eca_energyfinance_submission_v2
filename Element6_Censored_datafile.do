*** BEFORE RUN: --> change the current directory in the line below to the highest repository level and ensure that user-written STATA commands are installed (see README)

clear all 

*** Set the working directory
cd "/Users/pcenskow/Documents/Full Github Repo/eca_energyfinance-philipp_submission_files 2"

use "data/current_working_file_July24.dta"

*** drop unnecessary variables for (censored) reproduction of Figures
drop b c borrowerindustry borrowercountry borrowerrating exporter exportercountry exporterindustry ///
borrowerregion useofproceed wbcountryclassification producttype countryoecdrisk typeoffinancing ///
typeofcredit isgreen issocial issustainable ag localcurrencyname lendername lenderroleonthedeal ///
lendercountry lenderregion lendercompanytype lenderinvolvementonthedeali mlainvolvementonthedealin ///
ecacompanytype green_category social_category tranchelocalcurrencyvolume benchmark pricing ///
ecaserialno commercialrisk politicalrisk tranch_overallrisk legalname legalroleonthedeal ///
legalcountry legalinvolvementonthedealin jurisdiction assetindustry assettype manufacturer model msnimo

*** censor key identifiers
     
replace dealtitle = "XXX"
replace description = "XXX"
replace borrower = "XXX"


*** shuffle key values at random 

ssc install shufflevar

ren ecainvolvementonthedealin eca_involvement

shufflevar *

keep *_shuffled

foreach var of varlist _all {
    if strpos("`var'", "_shuffled") {
        local newname = substr("`var'", 1, strlen("`var'") - strlen("_shuffled"))
        rename `var' `newname'
    }
}

ren eca_involvement ecainvolvementonthedealin

bys tmddealid: gen u = runiform() if _n == 1
bys tmddealid: egen uu = total(u)
keep if uu < .1 // keep a random 10% of observations 
drop u uu

save "data/TXF_data_censored.dta", replace

