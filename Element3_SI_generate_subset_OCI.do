*** Prepare OCI Data

*** BEFORE RUN: --> change the current directory in the line below to the highest repository level and ensure that user-written STATA commands are installed (see README)

clear all

*** Set the working directory
cd "C:/Users/pwaidelich/Downloads/GitHub - Local/eca_energyfinance"

*** Insert your filepath here, where you have stored the OCI Excel database used for this publication 
import excel "data/OCI Public Finance for Energy Database 2024.xlsx", sheet("Dataset") firstrow


*** only retain 2013-2023 

drop if visible == "" // remove 13 empty rows 

drop if stage == "Electric Vehicles" // not part of the energy sector (12 observations)
drop if sector == "Climate" // delete 1 non-energy related transaction 
drop if stage == "Petrochemical" // delete 62 non-energy petrochemical transactions (18.64989 bn)

keep if institutionKind == "Export Credit"

gen closingyear = substr(date, 1, 4)

gen year = 0 
replace year = 2012 if closingyear == "2012"
replace year = 2013 if closingyear == "2013"
replace year = 2014 if closingyear == "2014"
replace year = 2015 if closingyear == "2015"
replace year = 2016 if closingyear == "2016"
replace year = 2017 if closingyear == "2017"
replace year = 2018 if closingyear == "2018"
replace year = 2019 if closingyear == "2019"
replace year = 2020 if closingyear == "2020"
replace year = 2021 if closingyear == "2021"
replace year = 2022 if closingyear == "2022"
replace year = 2023 if closingyear == "2023"

gen closingyear2 = substr(date, 5, 8)
replace year = 2012 if closingyear2 == "2012"
replace year = 2013 if closingyear2 == "2013"
replace year = 2014 if closingyear2 == "2014"
replace year = 2015 if closingyear2 == "2015"
replace year = 2016 if closingyear2 == "2016"
replace year = 2017 if closingyear2 == "2017"
replace year = 2018 if closingyear2 == "2018"
replace year = 2019 if closingyear2 == "2019"
replace year = 2020 if closingyear2 == "2020"
replace year = 2021 if closingyear2 == "2021"
replace year = 2022 if closingyear2 == "2022"
replace year = 2023 if closingyear2 == "2023"

gen closingyear3 = substr(date, 6, 9)
replace year = 2012 if closingyear3 == "2012"
replace year = 2013 if closingyear3 == "2013"
replace year = 2014 if closingyear3 == "2014"
replace year = 2015 if closingyear3 == "2015"
replace year = 2016 if closingyear3 == "2016"
replace year = 2017 if closingyear3 == "2017"
replace year = 2018 if closingyear3 == "2018"
replace year = 2019 if closingyear3 == "2019"
replace year = 2020 if closingyear3 == "2020"
replace year = 2021 if closingyear3 == "2021"
replace year = 2022 if closingyear3 == "2022"
replace year = 2023 if closingyear3 == "2023"

gen closingyear4 = substr(date, 7, 10)
replace year = 2012 if closingyear4 == "2012"
replace year = 2013 if closingyear4 == "2013"
replace year = 2014 if closingyear4 == "2014"
replace year = 2015 if closingyear4 == "2015"
replace year = 2016 if closingyear4 == "2016"
replace year = 2017 if closingyear4 == "2017"
replace year = 2018 if closingyear4 == "2018"
replace year = 2019 if closingyear4 == "2019"
replace year = 2020 if closingyear4 == "2020"
replace year = 2021 if closingyear4 == "2021"
replace year = 2022 if closingyear4 == "2022"
replace year = 2023 if closingyear4 == "2023"

drop if year == 2012 // drop 8 observations

drop if inlist(institutionAbbr, "BNDES", "JICA") // remove DFIs; only 3 observations


*** generate Unique ID 

gen unique_tranche_id = 0 
replace unique_tranche_id = _n

egen tag = tag(project)

gen unique_project_id = 0 
replace unique_project_id = _n if tag == 1 

order unique_tranche_id, first

clonevar v = amountUSD // creates 1 missing value 

* convert one transaction only in CAD into USD, and then into 'v' (only transaction not in USD)
replace amountUSD = 500000*.71309 if unique_tranche_id == 2346
replace v = 500000*.71309 if unique_tranche_id == 2346


* deflate with base year 2020 (using CPI from the US, Source: IMF)

local cpi_2013 = 0.900104452
local cpi_2014 = 0.914706153
local cpi_2015 = 0.915791243
local cpi_2016 = 0.927344711
local cpi_2017 = 0.947098174
local cpi_2018 = 0.970231836
local cpi_2019 = 0.987814475
local cpi_2020 = 1
local cpi_2021 = 1.046978589
local cpi_2022 = 1.130766189
local cpi_2023 = 1.177312352

forv i = 2013(1)2022 {
	replace v = v/`cpi_`i'' if year == `i'
}

forv i = 2013(1)2022 {
	replace v = v/`cpi_`i'' if year == `i'
}

gen v_bn = v / 1000000000
* convert one transaction only in CAD into USD, and then into 'v' (only transaction not in USD)
replace amountUSD = 500000*.71309 if unique_tranche_id == 2280
replace v = 500000*.71309 if unique_tranche_id == 2280



*** replace with ECA countries 

gen ecacountry = 0 
replace ecacountry = 1 if inlist(institutionAbbr, "NEXI", "JBIC")
replace ecacountry = 2 if inlist(institutionAbbr, "Sinosure", "Chexim")
replace ecacountry = 3 if inlist(institutionAbbr, "K-sure", "Kexim", "K-SURE, KEXIM", "Ksure")
replace ecacountry = 4 if inlist(institutionAbbr, "EDC")
replace ecacountry = 5 if inlist(institutionAbbr, "SACE")
replace ecacountry = 6 if inlist(institutionAbbr, "Hermes")
replace ecacountry = 7 if inlist(institutionAbbr, "EXIM US")
replace ecacountry = 8 if inlist(institutionAbbr, "UKEF")
replace ecacountry = 9 if inlist(institutionAbbr, "EXIAR") // Russia
replace ecacountry = 10 if inlist(institutionAbbr, "EXIM India")
replace ecacountry = 11 if inlist(institutionAbbr, "Bancomext")
replace ecacountry = 12 if inlist(institutionAbbr, "ECIC") // South Africa
replace ecacountry = 13 if inlist(institutionAbbr, "EFIC") // Australia
replace ecacountry = 14 if inlist(institutionAbbr, "TurkExImBank") // Turkey
replace ecacountry = 15 if inlist(institutionAbbr, "BPI", "COFACE") // France
replace ecacountry = 16 if inlist(institutionAbbr, "IEB") // Indonesia

label define ecacountries 1 "Japan" 2 "China" 3 "Korea" 4 "Canada" ///
5 "Italy" 6 "Germany" 7 "United States" 8 "United Kingdom" 9 "Russian Federation" 10 "India" 11 "Mexico" ///
12 "South Africa" 13 "Australia" 14 "Turkey" 15 "France" 16 "Indonesia"

label values ecacountry ecacountries

decode ecacountry, gen(ecacountry2)

drop ecacountry 

ren ecacountry2 ecacountry

gen guarantee = 0
replace guarantee = 1 if inlist(mechanism, "Guarantee")

gen dl = 0
replace dl = 1 if inlist(mechanism, "Loan", "loan")

gen other_instrument = 0 
replace other_instrument = 1 if inlist(mechanism, "Bond", "Equity", "Financing", "Grant" ///
"Insurance", "Mixed", "Risk Management")

*** Mixed: 100.2247 billion USD (EDC and Korea only!)

*** create comparable variables 

gen ff = 0 
replace ff = 1 if category == "Fossil Fuel"
replace ff = 0 if stage == "Transmission & Distribution" 

gen re = 0 
replace re = 1 if category == "Clean"
replace re = 1 if inlist(sector, "Hydro - Large", "Hydro - Small", ///
"Hydro - large", "Biomass", "Biofuels", "Renewables - Other")
replace re = 0 if sector == "Climate" // remove non-energy climate transactions 
replace re = 0 if sector == "Fuel Cells + Hydrogen" // remove hydrogen transactions related to transport 
replace re = 0 if stage == "Transmission & Distribution"
replace re = 0 if sector == "Batteries"

gen grid = 0 
replace grid = 1 if sector == "Batteries" 
replace grid = 1 if stage == "Transmission & Distribution" 
 
gen other = 0 
replace other = 1 if ///
ff != 1 & re != 1 & grid != 1 


gen p1 = 0
replace p1 = 1 if inlist(year, 2013, 2014, 2015)
gen p2 = 0
replace p2 = 1 if inlist(year, 2016, 2017, 2018, 2019) 
gen p3 = 0
replace p3 = 1 if inlist(year, 2020, 2021) 
gen p4 = 0
replace p4 = 1 if inlist(year, 2022, 2023) 


gen period = 0
replace period = 1 if p1 == 1 
replace period = 2 if p2 == 1
replace period = 3 if p3 == 1
replace period = 4 if p4 == 1

label define period_labs 1 "Pre-Paris" 2 "Post-Paris" 3 "Pandemic" 4 "Post-Glasgow"

label values period period_labs


*** Variables for Fig 1 (main)
 
ren guarantee gua
ren other_instrument o_i

gen ff_mixed = 0
replace ff_mixed = 1 if inlist(sector, "Mixed or unclear - Fossil", "Efficiency - Fossil", "Oil and Gas") 

gen re_mixed = 0 
replace re_mixed = 1 if inlist(sector, "Batteries,Fuel Cells + Hydrogen", "Biofuels", "Biomass", "Efficiency - Clean", ///
"Geothermal") | /// 
inlist(sector, "Mixed or unclear - Other", /// this is one renewables deal by ECIC in DRC
"Hydrogen - Clean", "Mixed or unclear - Clean", "Wind and Solar", "Renewables - Other", "Wave") | /// 
inlist(sector, "Renewables - Clean")

gen hydro = 0 
replace hydro = 1 if ///
inlist(sector, "Hydro - Large", "Hydro - Small", "Hydro - large")

*** Remove grid deals that were classified as hydro 

replace hydro = 0 if unique_tranche_id == 272
replace hydro = 0 if unique_tranche_id == 629
replace hydro = 0 if unique_tranche_id == 909
replace hydro = 0 if unique_tranche_id == 1566
replace hydro = 0 if unique_tranche_id == 1783


gen energy_source = 0 
replace energy_source = 1 if sector == "Coal"
replace energy_source = 2 if sector == "Oil"
replace energy_source = 3 if sector == "Natural Gas"
replace energy_source = 4 if ff_mixed == 1 
replace energy_source = 5 if sector == "Wind"
replace energy_source = 6 if sector == "Solar"
replace energy_source = 7 if re_mixed == 1 
replace energy_source = 8 if sector == "Nuclear"
replace energy_source = 9 if grid == 1
replace energy_source = 10 if hydro == 1

label define energy_source_labels 1 "Coal" 2 "Oil" 3 "Gas" 4 "Other fossil" 5 "Wind" 6 "Solar" 7 "Other RETs" ///
 8 "Nuclear" 9 "Grid" 10 "Hydro"

label values energy_source energy_source_labels


foreach var of varlist gua dl o_i {

bys year: egen tot_coal_`var' = total(v_bn) if energy_source == 1 & `var' == 1
bys year: egen tot_oil_`var' = total(v_bn) if energy_source == 2 & `var' == 1
bys year: egen tot_gas_`var' = total(v_bn) if energy_source == 3 & `var' == 1
bys year: egen tot_ff_mixed_`var' = total(v_bn) if energy_source == 4 & `var' == 1
bys year: egen tot_wind_`var' = total(v_bn) if energy_source == 5 & `var' == 1
bys year: egen tot_solar_`var' = total(v_bn) if energy_source == 6 & `var' == 1
bys year: egen tot_re_mixed_`var' = total(v_bn) if inlist(energy_source, 7, 10) & `var' == 1
bys year: egen tot_nuclear_`var' = total(v_bn) if energy_source == 8 & `var' == 1
bys year: egen tot_grid_`var' = total(v_bn) if energy_source == 9 & `var' == 1 
}


*** Variables for Fig 2 (main)

*** Fossil
gen v_c = 0

replace v_c = 1 if ///
stage == "Exploration - Fossil" | ///
stage == "Exploration/Extraction" | ///
stage == "Extraction"

replace v_c = 2 if ///
stage == "Transportation" & ff == 1 | ///
stage == "Storage" & ff == 1

replace v_c = 3 if ///
stage == "Refining" 

replace v_c = 4 if /// see dealsubindustries in 'Power' and 'Renewables', including potentially non-power generating deals like geothermal, solar thermal, or hydrogen. only elements that belong to upstream or Electricity infrastructure (16)
stage=="Distributed Renewables" | ///
stage=="CHP"| ///
stage=="Electricity Production"| ///
stage=="Electricity production"| ///
category=="Clean"

replace v_c = 5 if /// all other categories for which we have the fuel but not the exact value chain stage
inlist(stage, "Heating", "Point of Use", "Point of use", "Unclear or mixed")

label define value_chain 1 "Upstream" 2 "Midstream" 3 "Downstream" 4 "Power generation" 5 "Unclear/mixed"

label values v_c value_chain


*** RETs
gen re_energy_source = 0 
replace re_energy_source=1 if sector == "Wind"
replace re_energy_source=2 if inlist(sector, "Solar") // solar
replace re_energy_source=3 if inlist(sector, "Hydro - Large", "Hydro - Small", "Hydro - large") // hydro 
replace re_energy_source=4 if re == 1 & ///
!inlist(sector, "Wind", "Solar", "Hydro - Large", "Hydro - Small", "Hydro - large") // other RETs 


*** Variables for Fig 3 (main)


gen e3f = 0 
replace e3f = 1 if inlist(ecacountry, "France", "Germany", "Italy", "United Kingdom")

gen oecd = 0 
replace oecd = 1 if !inlist(ecacountry, "China", "South Africa", "Russian Federation", "India", "Indonesia")

*** Indonesia now has accession negotiations with OECD, South Africa is 'Key partner' since 2007

clonevar ecacountry_e3f = ecacountry

replace ecacountry_e3f = "Non-E3F" if e3f == 0 
replace ecacountry_e3f = "E3F" if e3f == 1 

clonevar ecacountry_oecd = ecacountry 

replace ecacountry_oecd = "OECD" if oecd == 1
replace ecacountry_oecd = "Non-OECD" if oecd == 0


*** Final edits


drop source projectDesc // to not generate noisy csvs 


*** re-classify 7 hydro that are hydro and grid 

replace energy_source = 9 if unique_tranche_id == 272
replace grid = 0 if unique_tranche_id == 386
replace energy_source = 9 if unique_tranche_id == 629
replace grid = 0 if unique_tranche_id == 619
replace energy_source = 9 if unique_tranche_id == 909
replace energy_source = 9 if unique_tranche_id == 1566
replace energy_source = 9 if unique_tranche_id == 1783

*** re-classify 40 grid deals --> that erreneously have a v_c classification

replace v_c = 0 if grid == 1 & v_c != 0

save "data/OCI_July_2024.dta", replace

export delimited using "data/OCI_July_2024.csv", replace
