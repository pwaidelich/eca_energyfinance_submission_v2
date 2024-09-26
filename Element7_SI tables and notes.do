*** BEFORE RUN: --> change the current directory in the line below to the highest repository level and ensure that user-written STATA commands are installed (see README)

clear all

*** Set the working directory
cd "C:/Users/pwaidelich/Downloads/GitHub - Local/eca_energyfinance"

* Create locals for file paths

*** Insert your filepath to where original TXF and OCI data are stored  
local source_data "data"

*** Insert your filepath to where you want to store the generated SI Figures 
local figure_path "graphs"

*** Insert your filepath to where you want to store interim datasets 
local data_path "data/intermediate"

*** Insert your filepath where you export to/import from import the filled up values (joined dataframes) between TXF and OCI (for methodology, see SI Note on mMethods for Supplementary Figures 1-7)   
local filled_up_data "data/filled_up_txf_oci"


clear all 

use "`source_data'/current_working_file_July24.dta"



************************************************************************************
************************************************************************************
****************************** SI Note 2 on Fossil fuel dependent countries*********************************
************************************************************************************
************************************************************************************

*** SI Note 2 

bys year: egen tot_en_dv = sum(dv_bn)
bys year: egen tot_eca = sum(v_bn)


*** Additional calculations

*** OECD versus non-OECD countries

gen oecd = 0 
replace oecd = 1 if !inlist(ecacountry, "China", "India", "Indonesia", "Malaysia", "Russian Federation") & ///
!inlist(ecacountry, "Saudi Arabia", "South Africa", "Thailand", "United Arab Emirates")


total v_bn if oecd == 1 

total v_bn if oecd == 0


*** ECA finance and fossil-fuel dependency
*** check all 114 dealcountries on their FF-dependency 

gen dealcountry_ff = 0 
replace dealcountry_ff = 1 if ///
inlist(dealcountry, "Yemen", "Chad", "Mozambique", "South Sudan", "Sudan") | ///
inlist(dealcountry, "Mongolia", "Papua New Guinea", "Timor-Leste") | ///
inlist(dealcountry, "Uzbekistan", "Bolivia", "Algeria", "Egypt", "Iran") | ///
inlist(dealcountry, "Angola", "Cameroon", "Congo, Democratic Republic of the", ///
"Ghana", "Nigeria") | ///
inlist(dealcountry, "Malaysia", "Azerbaijan", "Kazakhstan", ///
"Russian Federation", "Turkmenistan") | ///
inlist(dealcountry, "Colombia", "Ecuador", "Surinam", ///
"Venezuela", "Iraq") | ///
inlist(dealcountry, "Libya", "Equatorial Guinea", "Gabon", ///
"Brunei Darussalam", "Norway") | ///
inlist(dealcountry, "Trinidad and Tobago", "Bahrain", "Kuwait", ///
"Oman", "Qatar") | ///
inlist(dealcountry, "Saudi Arabia", "United Arab Emirates") 



total v_bn if dealcountry_ff == 1 & ff == 1
total v_bn if dealcountry_ff == 0 & ff == 1


total v_bn if dealcountry_ff == 1
total v_bn if dealcountry_ff == 0 


preserve
keep if dealcountry_ff ==1
keep if ff == 1
bys dealcountry: egen tot_ff_dealcounty = total(v_bn)
collapse (max) tot_ff_dealcounty, by (dealcountry dealcountry_ff)
gsort -tot_ff_dealcounty
label variable tot_ff_dealcounty "Cumulative ECA commitments (fossil only, in USD2020 billion)"
label var dealcountry "ECA project host country"
list dealcountry tot_ff_dealcounty , clean noobs
export excel "SI Note 2", firstrow(varl) replace
restore

preserve
keep if dealcountry_ff ==1
keep if re == 1
bys dealcountry: egen tot_ff_dealcounty = total(v_bn)
collapse (max) tot_ff_dealcounty, by (dealcountry dealcountry_ff)
gsort -tot_ff_dealcounty
label variable tot_ff_dealcounty "Cumulative ECA commitments (RET only, in USD2020 billion)"
label var dealcountry "ECA project host country"
list dealcountry tot_ff_dealcounty , clean noobs
export excel "SI Note 2", firstrow(varl) sheet("final", modify)
restore

preserve
keep if dealcountry_ff ==1
keep if grid == 1
bys dealcountry: egen tot_ff_dealcounty = total(v_bn)
collapse (max) tot_ff_dealcounty, by (dealcountry dealcountry_ff)
gsort -tot_ff_dealcounty
label variable tot_ff_dealcounty "Cumulative ECA commitments (grid only, in USD2020 billion)"
label var dealcountry "ECA project host country"
list dealcountry tot_ff_dealcounty , clean noobs
export excel "SI Note 2", firstrow(varl) sheet("final RE", modify) 
restore



************************************************************************************
************************************************************************************
****************************** SI Table 6 *********************************
************************************************************************************
************************************************************************************

*** Individual country trends of non-OECD + Canada using filled up data 


clear all 

use "`filled_up_data'/oci_txf_combined_SI_all.dta"


*** Figure 3: Middle element, non-E3F countries by period 

* Identification of non-OECD countries 


gen oecd = 0 
replace oecd = 1 if !inlist(ecacountry, "China", "India", "Indonesia", "Malaysia", "Russian Federation") & ///
!inlist(ecacountry, "Saudi Arabia", "South Africa", "Thailand", "United Arab Emirates")


preserve 
keep if oecd == 0 
bys ecacountry: egen tot_en_country = sum(v_bn_larger)
collapse (max) tot_en_country, by(ecacountry)
gsort -tot_en_country
list, clean noobs
restore

encode period, gen(period2) 
drop period 
ren period2 period

gen ff = 0 
replace ff = 1 if inlist(energy_source, "Coal", "Oil", "Gas", "Other fossil")

gen re = 0 
replace re = 1 if inlist(energy_source, "Wind", "Solar", "Other RETs", "Hydro")

gen grid = 0 
replace grid = 1 if energy_source == "Grid"

gen nuclear = 0 
replace nuclear = 1 if energy_source == "Nuclear"


preserve 
keep if oecd == 0 
egen tot_en_all_years = sum(v_bn_larger)
bys ecacountry: egen tot_en_country = sum(v_bn_larger)
bys ecacountry: egen tot_ff_country = sum(v_bn_larger) if ff == 1 
bys ecacountry: egen tot_re_country = sum(v_bn_larger) if re == 1 
bys ecacountry: egen tot_grid_country = sum(v_bn_larger) if grid == 1 
bys ecacountry: egen tot_nuclear_country = sum(v_bn_larger) if nuclear == 1 
collapse (max) tot_ff_country tot_re_country tot_grid_country tot_nuclear_country tot_en_country tot_en_all_years, by(ecacountry)
gen share_total = tot_en_country/tot_en_all_years
gsort -tot_en_country
list, clean noobs
export excel "SI Table 6", firstrow(varl)
restore 


************************************************************************************
************************************************************************************
****************************** SI Table 7 *********************************
************************************************************************************
************************************************************************************

*** Individual country trends of non-OECD + Canada using filled up data 


clear all 

/*

import delimited using "df_combined_tech_year_ecacountry_dealcountry.csv" // import csv

save oci_txf_combined_dealcountry

*/

use "`filled_up_data'/oci_txf_combined_SI_all.dta"

*** Figure 3: Middle element, non-E3F countries by period 

* Identification of non-OECD countries 


gen oecd = 0 
replace oecd = 1 if !inlist(ecacountry, "China", "India", "Indonesia", "Malaysia", "Russian Federation") & ///
!inlist(ecacountry, "Saudi Arabia", "South Africa", "Thailand", "United Arab Emirates")


preserve 
keep if oecd == 1 
bys ecacountry: egen tot_en_country = sum(v_bn_larger)
collapse (max) tot_en_country, by(ecacountry)
gsort -tot_en_country
keep in 1/10
list, clean noobs
restore


gen ff = 0 
replace ff = 1 if inlist(energy_source, "Coal", "Oil", "Gas", "Other fossil")

gen re = 0 
replace re = 1 if inlist(energy_source, "Wind", "Solar", "Other RETs", "Hydro")

gen grid = 0 
replace grid = 1 if energy_source == "Grid"

gen nuclear = 0 
replace nuclear = 1 if energy_source == "Nuclear"


preserve 
keep if oecd == 1
egen tot_en_all_years = sum(v_bn_larger)
bys ecacountry: egen tot_en_country = sum(v_bn_larger)
bys ecacountry: egen tot_ff_country = sum(v_bn_larger) if ff == 1 
bys ecacountry: egen tot_re_country = sum(v_bn_larger) if re == 1 
bys ecacountry: egen tot_grid_country = sum(v_bn_larger) if grid == 1 
bys ecacountry: egen tot_nuclear_country = sum(v_bn_larger) if nuclear == 1 
collapse (max) tot_ff_country tot_re_country tot_grid_country tot_nuclear_country tot_en_country tot_en_all_years, by(ecacountry)
gen share_total = tot_en_country/tot_en_all_years
gsort -tot_en_country
list, clean noobs
export excel "SI Table 7", firstrow(varl) 
restore 



