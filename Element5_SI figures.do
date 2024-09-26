*** Creation of SI figures

*** BEFORE RUN: --> change the current directory in the line below to the highest repository level and ensure that user-written STATA commands are installed (see README)

clear all

* Create locals for file paths

*** Set the working directory
cd "C:/Users/pwaidelich/Downloads/GitHub - Local/eca_energyfinance"

*** Insert your filepath to where you want to store the generated SI Figures 
local figure_path "graphs"

*** Insert your filepath to where you want to store interim datasets 
local data_path "data/intermediate"

*** Insert your filepath where you export to/import from import the filled up values (joined dataframes) between TXF and OCI (for methodology, see SI Note on mMethods for Supplementary Figures 1-7)   
local filled_up_data "data/filled_up_txf_oci"

* Import and save filled up data frames in .DTA format

* Fintype

clear 

import delimited using "`filled_up_data'/df_combined_tech_year_ecacountry_fintype.csv" // import csv

save "`filled_up_data'/oci_txf_combined_SI_all.dta", replace


* Value chain type

clear 

import delimited using "`filled_up_data'/df_combined_tech_year_ecacountry_vc.csv" // import csv

save "`filled_up_data'/oci_txf_combined_vc.dta", replace


* dealcountry 

clear 

import delimited using "`filled_up_data'/df_combined_tech_year_ecacountry_dealcountry.csv" // import csv

save "`filled_up_data'/oci_txf_combined_dealcountry.dta", replace


* Comparison all commitments OCI versus TXF

*** SI Figure 1

*** Overall comparison (all instruments): OCI versus TXF 

use "data/OCI_July_2024.dta"

preserve 
drop if ecacountry == "Canada"
egen tot_ff = total(v_bn) if ff == 1, by(year)
egen tot_re = total(v_bn) if re == 1, by(year)
egen tot_grid = total(v_bn) if grid == 1, by(year)
collapse (max) tot_ff tot_re tot_grid, by(year)
	foreach x of varlist tot_ff tot_re tot_grid {
	replace `x' = 0 if (`x' == .) 
	}
list
graph twoway line tot_ff tot_re tot_grid year, lc(gs1*0.6 green*0.6 orange*0.6) ///
lw(thick thick thick) yla(0(10)70, angle(0)) xla(2013(2)2023) ///
legend(order(1 "Fossil" 2 "RETs" 3 "Grid") r(1) size(small) region(lp(blank))) ///
title(OCI - All commitments) xtitle("") ytitle(USD billion{sub:2020})
graph save "`figure_path'/tot_oci.gph", replace 
lab var year "Year"
	lab var tot_ff "Total commitment (fossil)"
	lab var tot_re "Total commitment (RET)"
	lab var tot_grid "Total commitment (grid)"
	export excel year tot_ff tot_re tot_grid using "Sourcefile.xlsx", sheet("SI_Fig_1", modify) cell(A2) firstrow(varl) 
restore 

clear all
use "data/current_working_file_July24.dta"

preserve 
egen tot_ff = total(v_bn) if ff == 1, by(year)
egen tot_re = total(v_bn) if re == 1, by(year)
egen tot_grid = total(v_bn) if grid == 1, by(year)
collapse (max) tot_ff tot_re tot_grid, by(year)
	foreach x of varlist tot_ff tot_re tot_grid {
	replace `x' = 0 if (`x' == .) 
	}
list
graph twoway line tot_ff tot_re tot_grid year, lc(gs1*0.6 green*0.6 orange*0.6) ///
lw(thick thick thick) yla(0(10)70, angle(0)) xla(2013(2)2023) ///
legend(order(1 "Fossil" 2 "RETs" 3 "Grid") r(1) size(small) region(lp(blank))) ///
title(TXF - All commitments) xtitle("") ytitle(USD billion{sub:2020})
graph save "`figure_path'/tot_txf.gph", replace 
lab var year "Year"
	lab var tot_ff "Total commitment (fossil)"
	lab var tot_re "Total commitment (RET)"
	lab var tot_grid "Total commitment (grid)"
	export excel year tot_ff tot_re tot_grid using "Sourcefile.xlsx", sheet("SI_Fig_1", modify) cell(A16) firstrow(varl) 
restore 

grc1leg2 "`figure_path'/tot_oci.gph" "`figure_path'/tot_txf.gph"

graph export "`figure_path'/SI_Fig1_final.png", replace


*** SI Figures 2a-b 
* Creation of difference dataframes by country and financial instrument (cumulative USD 2020)

*** OCI data per country (cumulative)

clear all

use "data/OCI_July_2024.dta"

preserve 
keep if ff == 1 | re == 1 | grid == 1
keep if gua == 1
drop if year == 2023
egen tot_ff_country_g = total(v_bn) if ff == 1 & gua == 1, by(ecacountry)
egen tot_re_country_g = total(v_bn) if re == 1 & gua == 1, by(ecacountry)
egen tot_grid_country_g = total(v_bn) if grid == 1 & gua == 1, by(ecacountry)
collapse (max) tot_ff_country_g tot_re_country_g tot_grid_country_g, by(ecacountry) 
foreach x of varlist tot_ff_country_g tot_re_country_g tot_grid_country_g {
	replace `x' = 0 if(`x' == .) 
	}
	ren tot_ff_country_g tot_ff_country_g2
	ren tot_re_country_g tot_re_country_g2
	ren tot_grid_country_g tot_grid_country_g2
	list, clean noobs
	save "`data_path'/fig_4_SI_g_oci.dta", replace
restore

preserve 
keep if ff == 1 | re == 1 | grid == 1
keep if dl == 1
drop if year == 2023
egen tot_ff_country_dl = total(v_bn) if ff == 1 & dl == 1, by(ecacountry)
egen tot_re_country_dl = total(v_bn) if re == 1 & dl == 1, by(ecacountry)
egen tot_grid_country_dl = total(v_bn) if grid == 1 & dl == 1, by(ecacountry)
collapse (max) tot_ff_country_dl tot_re_country_dl tot_grid_country_dl, by(ecacountry) 
foreach x of varlist tot_ff_country_dl tot_re_country_dl tot_grid_country_dl {
	replace `x' = 0 if(`x' == .) 
	}
	ren tot_ff_country_dl tot_ff_country_dl2
	ren tot_re_country_dl tot_re_country_dl2
	ren tot_grid_country_dl tot_grid_country_dl2
	list, clean noobs
	save "`data_path'/fig_4_SI_dl_oci.dta", replace
restore

*** TXF data per country (cumulative)

clear all

use "data/current_working_file_July24_incl_CAN.dta"

preserve 
keep if ff == 1 | re == 1 | grid == 1
keep if gua == 1
drop if year == 2023
egen tot_ff_country_g = total(v_bn) if ff == 1 & gua == 1, by(ecacountry)
egen tot_re_country_g = total(v_bn) if re == 1 & gua == 1, by(ecacountry)
egen tot_grid_country_g = total(v_bn) if grid == 1 & gua == 1, by(ecacountry)
collapse (max) tot_ff_country_g tot_re_country_g tot_grid_country_g, by(ecacountry) 
foreach x of varlist tot_ff_country_g tot_re_country_g tot_grid_country_g {
	replace `x' = 0 if(`x' == .) 
	}
	list, clean noobs
	save "`data_path'/fig_4_SI_g_txf.dta", replace
restore

preserve 
gen dl = 0 
replace dl = 1 if direct_lending == 1
keep if ff == 1 | re == 1 | grid == 1
keep if dl == 1
drop if year == 2023
egen tot_ff_country_dl = total(v_bn) if ff == 1 & dl == 1, by(ecacountry)
egen tot_re_country_dl = total(v_bn) if re == 1 & dl == 1, by(ecacountry)
egen tot_grid_country_dl = total(v_bn) if grid == 1 & dl == 1, by(ecacountry)
collapse (max) tot_ff_country_dl tot_re_country_dl tot_grid_country_dl, by(ecacountry) 
foreach x of varlist tot_ff_country_dl tot_re_country_dl tot_grid_country_dl {
	replace `x' = 0 if(`x' == .) 
	}
	list, clean noobs
	sort ecacountry
	save "`data_path'/fig_4_SI_dl_txf.dta", replace
restore


*** take the difference between the two dataframes (for each country where possible)

*** Guarantees 

clear all

use "`data_path'/fig_4_SI_g_txf.dta"

joinby ecacountry using "`data_path'/fig_4_SI_g_oci.dta", unmatched(both)


foreach x of varlist tot_ff_country_g tot_re_country_g tot_grid_country_g  tot_ff_country_g2 tot_re_country_g2 tot_grid_country_g2 {
	replace `x' = 0 if(`x' == .) 
	}

	
gen tot_ff_country_g_diff = 0 

foreach varname of var ecacountry {
		replace tot_ff_country_g_diff = tot_ff_country_g-tot_ff_country_g2
} 	

gen tot_re_country_g_diff = 0 

foreach varname of var ecacountry {
		replace tot_re_country_g_diff = tot_re_country_g-tot_re_country_g2
} 	

gen tot_grid_country_g_diff = 0 

foreach varname of var ecacountry {
		replace tot_grid_country_g_diff = tot_grid_country_g-tot_grid_country_g2
} 	

keep ecacountry tot_ff_country_g_diff tot_re_country_g_diff tot_grid_country_g_diff

save "`data_path'/fig_4_SI_g_diff.dta", replace

	
*** Direct lending 

clear all

use "`data_path'/fig_4_SI_dl_txf.dta"

joinby ecacountry using "`data_path'/fig_4_SI_dl_oci.dta", unmatched(both)


foreach x of varlist tot_ff_country_dl tot_re_country_dl tot_grid_country_dl  tot_ff_country_dl2 tot_re_country_dl2 tot_grid_country_dl2 {
	replace `x' = 0 if(`x' == .) 
	}

	
gen tot_ff_country_dl_diff = 0 

foreach varname of var ecacountry {
		replace tot_ff_country_dl_diff = tot_ff_country_dl-tot_ff_country_dl2
} 	

gen tot_re_country_dl_diff = 0 

foreach varname of var ecacountry {
		replace tot_re_country_dl_diff = tot_re_country_dl-tot_re_country_dl2
} 	

gen tot_grid_country_dl_diff = 0 

foreach varname of var ecacountry {
		replace tot_grid_country_dl_diff = tot_grid_country_dl-tot_grid_country_dl2
} 	

keep ecacountry tot_ff_country_dl_diff tot_re_country_dl_diff tot_grid_country_dl_diff

save "`data_path'/fig_4_SI_dl_diff.dta", replace


* Create SI Figure 2a

*** Guarantees 

clear all 

use "`data_path'/fig_4_SI_g_diff.dta"

preserve

keep in 1/14
 
graph hbar tot_ff_country_g_diff tot_re_country_g_diff tot_grid_country_g_diff, ///
bar(1, color(gs1*0.6)) ///
bar(2, color(green*0.6)) /// 
bar(3, color(orange*0.6)) ///
over(ecacountry) ///
yscale(range(-20 20)) ///
ylab(-20(10)20) ///
legend(order(1 "Fossil" 2 "RETs" 3 "Grid") r(1) size(small) region(lp(blank))) 
graph save "`figure_path'/Fig4_SI_g_14.gph", replace
	lab var tot_ff_country_g_diff "Difference guarantees (Fossil)"
	lab var tot_re_country_g_diff "Difference guarantees (RETs)"
	lab var tot_grid_country_g_diff "Difference guarantees (Grid)"
    export excel ecacountry tot_ff_country_g_diff tot_re_country_g_diff tot_grid_country_g_diff using "Sourcefile.xlsx", sheet("SI_Fig_2a_b", modify) cell(A2) firstrow(varl)
restore


preserve
keep in 15/28
graph hbar tot_ff_country_g_diff tot_re_country_g_diff tot_grid_country_g_diff, ///
bar(1, color(gs1*0.6)) ///
bar(2, color(green*0.6)) /// 
bar(3, color(orange*0.6)) ///
over(ecacountry) ///
yscale(range(-10 10)) ///
ylab(-10(5)10) ///
legend(order(1 "Fossil" 2 "RETs" 3 "Grid") r(1) size(small) region(lp(blank))) 
graph save "`figure_path'/Fig4_SI_g_28.gph", replace
	lab var tot_ff_country_g_diff "Difference guarantees (Fossil)"
	lab var tot_re_country_g_diff "Difference guarantees (RETs)"
	lab var tot_grid_country_g_diff "Difference guarantees (Grid)"
    export excel ecacountry tot_ff_country_g_diff tot_re_country_g_diff tot_grid_country_g_diff using "Sourcefile.xlsx", sheet("SI_Fig_2a_b", modify) cell(A17) firstrow(varl)
restore


grc1leg2 "`figure_path'/Fig4_SI_g_14.gph" "`figure_path'/Fig4_SI_g_28.gph", r(1) title(TXF minus OCI Guarantees (USD billion{sub:2020}), size(small))

graph export "`figure_path'/SI_Fig2a_final.png", replace

*** Direct lending 

clear all 

use "`data_path'/fig_4_SI_dl_diff.dta"

preserve

keep in 1/13
 
graph hbar tot_ff_country_dl_diff tot_re_country_dl_diff tot_grid_country_dl_diff, ///
bar(1, color(gs1*0.6)) ///
bar(2, color(green*0.6)) /// 
bar(3, color(orange*0.6)) ///
over(ecacountry) ///
yscale(range(-40 40)) ///
ylab(-40(15)40) ///
legend(order(1 "Fossil" 2 "RETs" 3 "Grid") r(1) size(small) region(lp(blank))) 
graph save "`figure_path'/Fig4_SI_dl_14.gph", replace
	lab var tot_ff_country_dl_diff "Difference guarantees (Fossil)"
	lab var tot_re_country_dl_diff "Difference guarantees (RETs)"
	lab var tot_grid_country_dl_diff "Difference guarantees (Grid)"
    export excel ecacountry tot_ff_country_dl_diff tot_re_country_dl_diff tot_grid_country_dl_diff using "Sourcefile.xlsx", sheet("SI_Fig_2a_b", modify) cell(G2) firstrow(varl)
restore

preserve
keep in 14/25
graph hbar tot_ff_country_dl_diff tot_re_country_dl_diff tot_grid_country_dl_diff, ///
bar(1, color(gs1*0.6)) ///
bar(2, color(green*0.6)) /// 
bar(3, color(orange*0.6)) ///
over(ecacountry) ///
yscale(range(-3 3)) ///
ylab(-3(1)3) ///
legend(order(1 "Fossil" 2 "RETs" 3 "Grid") r(1) size(small) region(lp(blank))) 
graph save "`figure_path'/Fig4_SI_dl_27.gph", replace
	lab var tot_ff_country_dl_diff "Difference guarantees (Fossil)"
	lab var tot_re_country_dl_diff "Difference guarantees (RETs)"
	lab var tot_grid_country_dl_diff "Difference guarantees (Grid)"
    export excel ecacountry tot_ff_country_dl_diff tot_re_country_dl_diff tot_grid_country_dl_diff using "Sourcefile.xlsx", sheet("SI_Fig_2a_b", modify) cell(G17) firstrow(varl)
restore

grc1leg2 "`figure_path'/Fig4_SI_dl_14.gph" "`figure_path'/Fig4_SI_dl_27.gph", r(1) title(TXF minus OCI Direct Lending (USD billion{sub:2020}), size(small))

graph export "`figure_path'/SI_Fig2b_final.png", replace


*** Replication Figures Main 

************************************************************************************
************************************************************************************
****************************** SI Figure 3)*********************************
************************************************************************************
************************************************************************************

clear all 

use "`filled_up_data'/oci_txf_combined_SI_all.dta" 

*** Guarantees (SWITCH)

preserve
drop if year == 2023
drop if ecacountry == "Canada"
keep if eca_commitment_type == "Guarantee"
// regenerate for guarantees only
bys year: egen total_coal = sum(v_bn_larger) if energy_source == "Coal"
bys year: egen total_oil = sum(v_bn_larger) if energy_source == "Oil"
bys year: egen total_gas = sum(v_bn_larger) if energy_source == "Gas"
bys year: egen total_other_ff = sum(v_bn_larger) if energy_source == "Other fossil"
bys year: egen total_wind = sum(v_bn_larger) if energy_source == "Wind"
bys year: egen total_solar = sum(v_bn_larger) if energy_source == "Solar"
bys year: egen total_other_rets = sum(v_bn_larger) if inlist(energy_source, "Other RETs", "Hydro")
bys year: egen total_nuclear = sum(v_bn_larger) if energy_source == "Nuclear"
bys year: egen total_grid = sum(v_bn_larger) if energy_source == "Grid"


	collapse (max) total_coal total_oil total_gas total_other_ff total_wind total_solar total_other_rets total_nuclear total_grid, by(year)
	foreach x of varlist total_coal total_oil total_gas total_other_ff total_wind total_solar total_other_rets total_nuclear total_grid {
	replace `x' = 0 if(`x' == .) 
	}
	gen sum1 = total_coal + total_oil
	gen sum2 = (sum1 + total_gas)
	gen sum3 = (sum2 + total_other_ff) 
	gen sum4 = (sum3 + total_wind)
	gen sum5 = (sum4 + total_solar)
	gen sum6 = (sum5 + total_other_rets)
	gen sum7 = (sum6 + total_nuclear)
	gen sum8 = (sum7 + total_grid)
	gen zero = 0
	twoway rarea zero total_coal year, color(gs1*0.8) ///
	|| rarea total_coal sum1 year, color(gs1*0.6)  ///
	|| rarea sum1 sum2 year, color(gs1*0.4) ///
	|| rarea sum2 sum3 year, color(gs1*0.2) ///
	|| rarea sum3 sum4 year, color(green*1.2) ///
	|| rarea sum4 sum5 year, color(green*0.7) ///
	|| rarea sum5 sum6 year, color(green*0.3) ///
	|| rarea sum6 sum7 year, color(yellow*0.4) ///
	|| rarea sum7 sum8 year, color(orange*0.6) ///
	||, legend(order(1 "Coal" 2 "Oil" 3 "Gas" 4 "Other Fossil" 5 "Wind" 6 "Solar" 7 "Other RETs" 8 "Nuclear" 9 "Grid") pos(3) r(9) size(small) symxsize(4) symysize(4) region(lp(blank))) ///
	xla(2013(1)2022, nolab notick grid) ///
	yla(0(10)50, grid angle(0) labsize(small)) xtitle("") ///
	xline(2015.5 2019.5 2021.5, lp(dash) lc(red) lwidth(medthick)) scheme(s1mono)
	 graph save "`figure_path'/SI_Fig3_guarantees_only.gph", replace
	 list year sum1-sum8, clean noobs
	 return list
	 lab var year "Year"
	 lab var total_coal "Coal" 
	lab var total_oil "Oil" 
	lab var total_gas "Gas" 
	lab var total_other_ff "Other Fossil" 
	lab var total_wind "Wind" 
	lab var total_solar "Solar" 
	lab var total_other_rets "Other RETs" 
	lab var total_nuclear "Nuclear" 
	lab var total_grid "Grid" 
	 export excel year total_coal total_oil total_gas total_other_ff total_wind total_solar total_other_rets total_nuclear total_grid using "Sourcefile.xlsx", sheet("SI_Fig_3", modify) cell(A2) firstrow(varl)
restore


*** Direct lending (SWITCH)

preserve
keep if eca_commitment_type == "Direct lending"
drop if year == 2023
drop if ecacountry == "Canada"
// regenerate for direct lending only
bys year: egen total_coal = sum(v_bn_larger) if energy_source == "Coal"
bys year: egen total_oil = sum(v_bn_larger) if energy_source == "Oil"
bys year: egen total_gas = sum(v_bn_larger) if energy_source == "Gas"
bys year: egen total_other_ff = sum(v_bn_larger) if energy_source == "Other fossil"
bys year: egen total_wind = sum(v_bn_larger) if energy_source == "Wind"
bys year: egen total_solar = sum(v_bn_larger) if energy_source == "Solar"
bys year: egen total_other_rets = sum(v_bn_larger) if inlist(energy_source, "Other RETs", "Hydro")
bys year: egen total_nuclear = sum(v_bn_larger) if energy_source == "Nuclear"
bys year: egen total_grid = sum(v_bn_larger) if energy_source == "Grid"

	collapse (max) total_coal total_oil total_gas total_other_ff total_wind total_solar total_other_rets total_nuclear total_grid, by(year)
	foreach x of varlist total_coal total_oil total_gas total_other_ff total_wind total_solar total_other_rets total_nuclear total_grid {
	replace `x' = 0 if(`x' == .) 
	}
	gen sum1 = total_coal + total_oil
	gen sum2 = (sum1 + total_gas)
	gen sum3 = (sum2 + total_other_ff) 
	gen sum4 = (sum3 + total_wind)
	gen sum5 = (sum4 + total_solar)
	gen sum6 = (sum5 + total_other_rets)
	gen sum7 = (sum6 + total_nuclear)
	gen sum8 = (sum7 + total_grid)
	gen zero = 0
	twoway rarea zero total_coal year, color(gs1*0.8) ///
	|| rarea total_coal sum1 year, color(gs1*0.6)  ///
	|| rarea sum1 sum2 year, color(gs1*0.4) ///
	|| rarea sum2 sum3 year, color(gs1*0.2) ///
	|| rarea sum3 sum4 year, color(green*1.2) ///
	|| rarea sum4 sum5 year, color(green*0.7) ///
	|| rarea sum5 sum6 year, color(green*0.3) ///
	|| rarea sum6 sum7 year, color(yellow*0.4) ///
	|| rarea sum7 sum8 year, color(orange*0.6) ///
	||, legend(off) /// 
      ytitle("") ///
		xla(2013(1)2022, nolab notick grid) ///
		yla(0(10)50, grid angle(0) labsize(small)) ///
		xtitle("") ///
		xline(2015.5 2019.5 2021.5, lp(dash) lc(red) lwidth(medthick)) scheme(s1mono)
	 	graph save "`figure_path'/SI_Fig3_directlending_only.gph", replace
		list year sum3 sum6 sum8, clean noobs
	lab var year "Year"
	lab var total_coal "Coal" 
	lab var total_oil "Oil" 
	lab var total_gas "Gas" 
	lab var total_other_ff "Other Fossil" 
	lab var total_wind "Wind" 
	lab var total_solar "Solar" 
	lab var total_other_rets "Other RETs" 
	lab var total_nuclear "Nuclear" 
	lab var total_grid "Grid" 
	export excel year total_coal total_oil total_gas total_other_ff total_wind total_solar total_other_rets total_nuclear total_grid using "Sourcefile.xlsx", sheet("SI_Fig_3", modify) cell(A16) firstrow(varl)
restore


*** Other instrument (OCI only)

preserve
keep if eca_commitment_type == "Other instrument"
drop if year == 2023
drop if ecacountry == "Canada"
// regenerate for direct lending only
bys year: egen total_coal = sum(v_bn_larger) if energy_source == "Coal"
bys year: egen total_oil = sum(v_bn_larger) if energy_source == "Oil"
bys year: egen total_gas = sum(v_bn_larger) if energy_source == "Gas"
bys year: egen total_other_ff = sum(v_bn_larger) if energy_source == "Other fossil"
bys year: egen total_wind = sum(v_bn_larger) if energy_source == "Wind"
bys year: egen total_solar = sum(v_bn_larger) if energy_source == "Solar"
bys year: egen total_other_rets = sum(v_bn_larger) if inlist(energy_source, "Other RETs", "Hydro")
bys year: egen total_nuclear = sum(v_bn_larger) if energy_source == "Nuclear"
bys year: egen total_grid = sum(v_bn_larger) if energy_source == "Grid"

	collapse (max) total_coal total_oil total_gas total_other_ff total_wind total_solar total_other_rets total_nuclear total_grid, by(year)
	foreach x of varlist total_coal total_oil total_gas total_other_ff total_wind total_solar total_other_rets total_nuclear total_grid {
	replace `x' = 0 if(`x' == .) 
	}
	gen sum1 = total_coal + total_oil
	gen sum2 = (sum1 + total_gas)
	gen sum3 = (sum2 + total_other_ff) 
	gen sum4 = (sum3 + total_wind)
	gen sum5 = (sum4 + total_solar)
	gen sum6 = (sum5 + total_other_rets)
	gen sum7 = (sum6 + total_nuclear)
	gen sum8 = (sum7 + total_grid)
	gen zero = 0
	twoway rarea zero total_coal year, color(gs1*0.8) ///
	|| rarea total_coal sum1 year, color(gs1*0.6)  ///
	|| rarea sum1 sum2 year, color(gs1*0.4) ///
	|| rarea sum2 sum3 year, color(gs1*0.2) ///
	|| rarea sum3 sum4 year, color(green*1.2) ///
	|| rarea sum4 sum5 year, color(green*0.7) ///
	|| rarea sum5 sum6 year, color(green*0.3) ///
	|| rarea sum6 sum7 year, color(yellow*0.4) ///
	|| rarea sum7 sum8 year, color(orange*0.6) ///
	||, legend(off) /// 
      ytitle("") ///
		xla(2013(1)2022, nolab notick grid) ///
		yla(0(10)50, grid angle(0) labsize(small)) ///
		xtitle("") ///
		xline(2015.5 2019.5 2021.5, lp(dash) lc(red) lwidth(medthick)) scheme(s1mono)
	 	graph save "`figure_path'/SI_Fig3_other_instrument_only.gph", replace
		list year sum3 sum6 sum8, clean noobs
	lab var year "Year"
	lab var total_coal "Coal" 
	lab var total_oil "Oil" 
	lab var total_gas "Gas" 
	lab var total_other_ff "Other Fossil" 
	lab var total_wind "Wind" 
	lab var total_solar "Solar" 
	lab var total_other_rets "Other RETs" 
	lab var total_nuclear "Nuclear" 
	lab var total_grid "Grid" 
	export excel year total_coal total_oil total_gas total_other_ff total_wind total_solar total_other_rets total_nuclear total_grid using "Sourcefile.xlsx", sheet("SI_Fig_3", modify) cell(A30) firstrow(varl)
restore


* Share RE over all direct lending 
* Shares RE Guarantees & Direct lending  

preserve 
drop if year == 2023
drop if ecacountry == "Canada"
bys year: egen tot_en_dl = total(v_bn_larger) if eca_commitment_type == "Direct lending"
bys year: egen tot_re_dl = total(v_bn_larger) if re_ff_grid == "Renewables" & eca_commitment_type == "Direct lending"
bys year: egen tot_en_g = total(v_bn_larger) if eca_commitment_type == "Guarantee"
bys year: egen tot_re_g = total(v_bn_larger) if re_ff_grid == "Renewables" & eca_commitment_type == "Guarantee"
bys year: egen tot_en_o_i = total(v_bn_larger) if eca_commitment_type == "Other instrument"
bys year: egen tot_re_o_i = total(v_bn_larger) if re_ff_grid == "Renewables" & eca_commitment_type == "Other instrument"

collapse (max) tot_en_dl tot_re_dl tot_en_g tot_re_g tot_en_o_i tot_re_o_i, by(year)
forvalues i=2013(1)2022 {
	gen share_dl_`i' = tot_re_dl/tot_en_dl if year == `i'
	gen share_g_`i' = tot_re_g/tot_en_g if year == `i'
	gen share_o_i_`i' = tot_re_o_i/tot_en_o_i if year == `i'
	list share_dl_`i' share_g_`i' year, clean noobs
}
gen share_re_dl = 0 
gen share_re_g = 0 
gen share_re_o_i = 0
forv i = 2013(1)2022 {
replace share_re_dl = (share_dl_`i')*100 if year == `i'
replace share_re_g = (share_g_`i')*100 if year == `i'
replace share_re_o_i = (share_o_i_`i')*100 if year == `i'
}
list year share_re_dl share_re_g share_re_o_i, clean noobs
twoway (line share_re_dl year, lc(dkgreen) lpattern(solid)) ///
(line share_re_g year, lc(dkgreen) lpattern(shortdash)) ///
, xla(2013(1)2022) ///
ylab(0(10)40, grid angle(0) labsize(small)) ///
legend(order(1 "Direct lending" 2 "Guarantees" 3) c(2)) ///
xtitle("") xline(2015.5 2019.5 2021.5, lp(dash) lc(red) lwidth(medthick)) 
graph save "`figure_path'/SI_Fig3_RE_share.gph", replace
	lab var year "Year"
	lab var tot_en_dl "Total energy lending"
	lab var tot_re_dl "Total RET lending"
	lab var tot_en_g "Total energy guarantees"
	lab var tot_re_g "Total RET guarantees"
	lab var tot_en_o_i "Total other energy commitments"
	lab var tot_re_o_i "Total other RET instruments"
	lab var share_re_dl "RET share lending"
	lab var share_re_g "RET share guarantees"
	lab var share_re_o_i "RET share other instruments"
export excel year tot_en_dl tot_re_dl tot_en_g tot_re_g tot_en_o_i tot_re_o_i share_re_dl share_re_g share_re_o_i using "Sourcefile.xlsx", sheet("SI_Fig_3", modify) cell(A44) firstrow(varl) 
restore 

grc1leg2 "`figure_path'/SI_Fig3_guarantees_only.gph" "`figure_path'/SI_Fig3_directlending_only.gph" "`figure_path'/SI_Fig3_other_instrument_only.gph" "`figure_path'/SI_Fig3_RE_share.gph", r(4) leg("`figure_path'/SI_Fig3_guarantees_only.gph") pos(3) lr(9) 


graph export "`figure_path'/SI_Fig3_final.png", replace


************************************************************************************
************************************************************************************
****************************** Figure SI 4 *********************************
************************************************************************************
************************************************************************************


clear all 

use "`filled_up_data'/oci_txf_combined_vc.dta"

replace v_c = "Unclear/mixed" if v_c == "0" // recode 21 unclear or mixed deals 

encode period, gen(period2) 

drop period 
ren period2 period

label def v_c_label 1 "Upstream" 2 "Midstream" 3 "Downstream" 4  "Power generation" 5 "Unclear/mixed" 
encode v_c, gen(better_v_c)  label(v_c_label)

drop v_c 
ren better_v_c v_c

drop if year == 2023 // drop year 2023 (not in OCI data)
drop if ecacountry == "Canada"


preserve
keep if energy_source == "Coal"
forv i = 1(1)5 {
	bys period: egen v_c`i'_coal = sum(v_bn_larger) if v_c==`i' 
}
collapse (max) v_c1_coal-v_c5_coal, by(period)
forvalues i = 1(1)5 {
	replace v_c`i'_coal = (v_c`i'_coal / 3) if period==1
}
forvalues i = 1(1)5 {
	replace v_c`i'_coal = (v_c`i'_coal / 4) if period==2
}
forvalues i = 1(1)5 {
	replace v_c`i'_coal = (v_c`i'_coal / 2) if period==3
}
forvalues i = 1(1)5 {
	replace v_c`i'_coal = v_c`i'_coal if period==4
}
graph bar v_c1_coal-v_c5_coal, ///
over(period, relabel(1 "P1" 2 "P2" 3 "P3" 4 "P4{superscript:*}")) ///
stack ///
title(Coal, box bexpand bcolor(gs1*0.4)) ///
bar(1, col("237 248 251") lp(solid) lw(vthin)) ///
bar(2, col("179 205 227") lp(solid) lw(vthin)) ///
bar(3, col("140 150 198") lp(solid) lw(vthin)) ///
bar(4, col("136 65 157") fi(inten30) lp(solid) lw(vthin) lc("136 65 157%30")) ///
bar(5, col("70 20 50") fi(inten30) lp(solid) lw(vthin) lc("136 65 157%30")) ///
graphregion(color(white)) yla(0(4)28, angle(0)) ///
legend(order(1 "Upstream" 2 "Midstream" 3 "Downstream" 4 "Power" 5 "Unclear/mixed") title("Value chain stage - Fossil", size(small)) pos(6) col(5) size(vsmall) region(lp(blank)))
graph save "`figure_path'/SI_Fig4_Coal.gph", replace
	lab var period "Period"
	lab var v_c1_coal "Coal_upstream"
	lab var v_c2_coal "Coal_midstream"
	lab var v_c3_coal "Coal_downstream"
	lab var v_c4_coal "Coal_power"
	lab var v_c5_coal "Coal_unclear"
export excel period v_c1_coal-v_c5_coal using "Sourcefile.xlsx", sheet("SI_Fig_4", modify) cell(A2) firstrow(varl) 
restore 



preserve 
keep if energy_source == "Oil"

forv i = 1(1)5 {
	bys period: egen v_c`i'_oil = sum(v_bn_larger) if v_c==`i' 
}

collapse (max) v_c1_oil-v_c5_oil, by(period)
forvalues i = 1(1)5 {
	replace v_c`i'_oil = (v_c`i'_oil / 3) if period==1
}
forvalues i = 1(1)5 {
	replace v_c`i'_oil = (v_c`i'_oil / 4) if period==2
}
forvalues i = 1(1)5 {
	replace v_c`i'_oil = (v_c`i'_oil / 2) if period==3
}
forvalues i = 1(1)5 {
	replace v_c`i'_oil = v_c`i'_oil if period==4
}
graph bar v_c1_oil-v_c5_oil, ///
over(period, relabel(1 "P1" 2 "P2" 3 "P3" 4 "P4{superscript:*}")) stack leg(off) title(Oil, box bexpand bcolor(gs1*0.3)) ///
bar(1, col("237 248 251") lp(solid) lw(vthin)) ///
bar(2, col("179 205 227") lp(solid) lw(vthin)) ///
bar(3, col("140 150 198") lp(solid) lw(vthin)) ///
bar(4, col("136 65 157") fi(inten30) lp(solid) lw(vthin) lc("136 65 157%30")) ///
bar(5, col("70 20 50") fi(inten30) lp(solid) lw(vthin) lc("136 65 157%30")) ///
graphregion(color(white)) yla(0(4)28, nolab)
graph save "`figure_path'/SI_Fig4_Oil.gph", replace
	lab var period "Period"
	lab var v_c1_oil "Oil_upstream"
	lab var v_c2_oil "Oil_midstream"
	lab var v_c3_oil "Oil_downstream"
	lab var v_c4_oil "Oil_power"
	lab var v_c5_oil "Oil_unclear"
export excel using "Sourcefile.xlsx", sheet("SI_Fig_4", modify) cell(A9) firstrow(varl) 
restore 



preserve 
keep if energy_source == "Gas"

forv i = 1(1)5 {
	bys period: egen v_c`i'_gas = sum(v_bn_larger) if v_c==`i' 
}
collapse (max) v_c1_gas-v_c5_gas, by(period)
forvalues i = 1(1)5 {
	replace v_c`i'_gas = (v_c`i'_gas / 3) if period==1
}

forvalues i = 1(1)5 {
	replace v_c`i'_gas = (v_c`i'_gas / 4) if period==2
}

forvalues i = 1(1)5 {
	replace v_c`i'_gas = (v_c`i'_gas / 2) if period==3
}

forvalues i = 1(1)5 {
	replace v_c`i'_gas = v_c`i'_gas if period==4
}

graph bar v_c1_gas-v_c5_gas, ///
over(period, relabel(1 "P1" 2 "P2" 3 "P3" 4 "P4{superscript:*}")) stack ///
title(Gas, box bexpand bcolor(gs1*0.2)) ///
leg(off) ///
bar(1, col("237 248 251") lp(solid) lw(vthin)) ///
bar(2, col("179 205 227") lp(solid) lw(vthin)) ///
bar(3, col("140 150 198") lp(solid) lw(vthin)) ///
bar(4, col("136 65 157") fi(inten30) lp(solid) lw(vthin) lc("136 65 157%30")) ///
bar(5, col("70 20 50") fi(inten30) lp(solid) lw(vthin) lc("136 65 157%30")) ///
graphregion(color(white)) yla(0(4)28, nolab)
graph save "`figure_path'/SI_Fig4_Gas.gph", replace
	lab var period "Period"
	lab var v_c1_gas "Gas_upstream"
	lab var v_c2_gas "Gas_midstream"
	lab var v_c3_gas "Gas_downstream"
	lab var v_c4_gas "Gas_power"
	lab var v_c5_gas "Gas_unclear"
export excel using "Sourcefile.xlsx", sheet("SI_Fig_4", modify) cell(A16) firstrow(varl) 
restore 


preserve

keep if inlist(energy_source, "Wind", "Solar", "Hydro", "Other RETs")

label def re_source_label 1 "Wind" 2 "Solar" 3 "Hydro" 4  "Other RETs" 
encode energy_source, gen(energy_source2) label(re_source_label)

drop energy_source

ren energy_source2 energy_source

tab energy_source
codebook energy_source

forv i = 1(1)4 {
bys period: egen tech_fine_`i' = sum(v_bn_larger) if energy_source == `i'
}

forv i = 1(1)4 {
replace tech_fine_`i' = (tech_fine_`i'/3) if period==1
}
forv i = 1(1)4 {
replace tech_fine_`i' = (tech_fine_`i'/4) if period==2
}
forv i = 1(1)4 {
replace tech_fine_`i' = (tech_fine_`i'/2) if period==3
}
forv i = 1(1)4 {
replace tech_fine_`i' = tech_fine_`i' if period==4 // only 2022
}

collapse (max) tech_fine_1-tech_fine_4, by(period)
graph bar tech_fine_1-tech_fine_4, ///
over(period, relabel(1 "P1" 2 "P2" 3 "P3" 4 "P4{superscript:*}")) ///
stack ///
title(Renewables, box bexpand bcolor(green*0.2)) ///
bar(1, col(green*1.2) lp(solid) fi(inten100)) ///
bar(2, col(green*0.15) lp(solid) fi(inten30)) ///
bar(3, col(green*0.4) lp(sold) fi(inten40)) ///
bar(4, col(green*0.8) lp(solid) fi(inten60)) ///
graphregion(color(white)) yla(0(4)28, grid nolab) ///
legend(order(4 "Other/mixed RETs" 3 "Hydro" 2 "Solar" 1 "Wind") ///
title(Power generation - Renewables, size(small)) size(vsmall) pos(3) c(1))
graph save "`figure_path'/SI_Fig4_Renewables.gph", replace
	lab var period "Period"
	lab var tech_fine_1 "Wind"
	lab var tech_fine_2 "Solar"
	lab var tech_fine_3 "Hydro"
	lab var tech_fine_4 "Other RETs"
export excel period tech_fine_1-tech_fine_4 using "Sourcefile.xlsx", sheet("SI_Fig_4", modify) cell(A23) firstrow(varl) 
restore 


grc1leg2 "`figure_path'/SI_Fig4_Coal.gph" "`figure_path'/SI_Fig4_Oil.gph" "`figure_path'/SI_Fig4_Gas.gph" "`figure_path'/SI_Fig4_Renewables.gph", r(1) loff graphregion(color(white)) ycom 

graph export "`figure_path'/SI_Fig4_final.png", replace 



************************************************************************************
************************************************************************************
****************************** Figure SI 5 *********************************
************************************************************************************
************************************************************************************


clear all 

use "`filled_up_data'/oci_txf_combined_SI_all.dta"

drop if year == 2023 // drop year 2023 (not in OCI data)
drop if ecacountry == "Canada" // Drop canada

*** Fig3: Upper element of the graph  

drop e3f

gen e3f = 0 
replace e3f = 1 if inlist(ecacountry, "Belgium", "Denmark", "Finland", "France", "Germany") | ///
inlist(ecacountry, "Italy", "Netherlands", "Spain", "Sweden", "United Kingdom")

gen oecd = 0 
replace oecd = 1 if !inlist(ecacountry, "China", "India", "Indonesia", "Malaysia", "Russian Federation") & ///
!inlist(ecacountry, "Saudi Arabia", "South Africa", "Thailand", "United Arab Emirates")

encode period, gen(period2) 
drop period 
ren period2 period

gen ff = 0 
replace ff = 1 if inlist(energy_source, "Coal", "Oil", "Gas", "Other fossil")

gen re = 0 
replace re = 1 if inlist(energy_source, "Wind", "Solar", "Other RETs")

gen grid = 0 
replace grid = 1 if energy_source == "Grid"

* Upper element of the graph 

preserve 
clonevar ecacountry5 = ecacountry
replace ecacountry5 = "Non-E3F" if e3f == 0 
replace ecacountry5 = "E3F" if e3f == 1 
forv i = 1(1)4 {
bys ecacountry5: egen tot_en_p`i' = sum(v_bn_larger) if period == `i' 
}
forv i = 1(1)4 {
bys ecacountry5: egen tot_ff_p`i' = sum(v_bn_larger) if ff == 1 & period == `i' 
}
forv i = 1(1)4 {
bys ecacountry5: egen tot_re_p`i' = sum(v_bn_larger) if re == 1 & period == `i' 
}
forv i = 1(1)4 {
bys ecacountry5: egen tot_other_p`i' = sum(v_bn_larger) if grid == 1 & period == `i' 
}
	collapse (max) tot_en_p1  tot_en_p2 tot_en_p3 tot_en_p4 tot_ff_p1 tot_ff_p2 tot_ff_p3 tot_ff_p4 tot_re_p1 tot_re_p2 tot_re_p3 tot_re_p4 tot_other_p1 tot_other_p2	tot_other_p3 tot_other_p4, by(ecacountry5)
	foreach x of varlist tot_en_p1 tot_en_p2 tot_en_p3 tot_en_p4 tot_ff_p1 tot_ff_p2 tot_ff_p3 tot_ff_p4 tot_re_p1 tot_re_p2 tot_re_p3 tot_re_p4 tot_other_p1 tot_other_p2 tot_other_p3 tot_other_p4 {
	replace `x' = 0 if (`x' == .) 
	}
		foreach var of varlist tot_en_p1 tot_ff_p1 tot_re_p1 tot_other_p1 {
	gen av_`var' = `var'/ 3 
	}
	foreach var of varlist tot_en_p2 tot_ff_p2 tot_re_p2 tot_other_p2 {
	gen av_`var' = `var'/ 4 
	}
	foreach var of varlist tot_en_p3 tot_ff_p3 tot_re_p3 tot_other_p3 {
	gen av_`var' = `var'/ 2
	}
	foreach var of varlist tot_en_p4 tot_ff_p4 tot_re_p4 tot_other_p4 {
	gen av_`var' = `var'
	}
	graph bar (mean) av_tot_ff_p1 av_tot_re_p1 av_tot_other_p1, ///
	over(ecacountry5, rev label(labsize(medium))) ///
	stack yla(0(10)60, angle(0) labsize(medium)) /// 
	bar(1, color(gs1*0.6) ls(none)) ///
	bar(2, color(green*0.6) ls(none)) ///
	bar(3, color(orange*0.6) ls(none)) ///
	title(Pre-Paris (2013-2015), size(medium) box bexpand bcolor(gs1*0.1)) ///
	legend(order(1 "Fossil" 2 "Renewables" 3 "Grid") col(3) region(lcolor(none))) 
	graph save "`figure_path'/SI_Fig5_p1.gph", replace
	graph bar (mean) av_tot_ff_p2 av_tot_re_p2 av_tot_other_p2, ///
	over(ecacountry5, rev label(labsize(medium))) ///
	stack yla(0(10)60, nolab) ///
	bar(1, color(gs1*0.6) ls(none)) ///
	bar(2, color(green*0.6) ls(none)) ///
	bar(3, color(orange*0.6) ls(none)) ///
	title(Post-Paris (2016-2019), size(medium) box bexpand bcolor(gs1*0.1))
	graph save "`figure_path'/SI_Fig5_p2.gph", replace
	graph bar (mean) av_tot_ff_p3 av_tot_re_p3 av_tot_other_p3, ///
	over(ecacountry5, rev label(labsize(medium))) ///
	stack yla(0(10)60, nolab) ///
	bar(1, color(gs1*0.6) ls(none)) ///
	bar(2, color(green*0.6) ls(none)) ///
	bar(3, color(orange*0.6) ls(none)) ///
	title(Pandemic (2020-2021), size(medium) box bexpand bcolor(gs1*0.1))
	graph save "`figure_path'/SI_Fig5_p3.gph", replace
	graph bar (mean) av_tot_ff_p4 av_tot_re_p4 av_tot_other_p4, ///
	over(ecacountry5, rev label(labsize(medium))) ///
	stack yla(0(10)60, nolab) ///
	bar(1, color(gs1*0.6) ls(none)) ///
	bar(2, color(green*0.6) ls(none)) ///
	bar(3, color(orange*0.6) ls(none)) ///
	title(Post-Glasgow (2022 only), size(medium) box bexpand bcolor(gs1*0.1))
	graph save "`figure_path'/SI_Fig5_p4.gph", replace
	lab var ecacountry5 "Country"
	lab var tot_en_p1 "Total energy commitment (within period)"
	lab var av_tot_ff_p1 "Average annual commitment (fossil)"
	lab var av_tot_re_p1 "Average annual commitment (RET)"
	lab var av_tot_other_p1 "Average annual commitment (grid)"
	export excel ecacountry5 tot_en_p1 av_tot_ff_p1 av_tot_re_p1 av_tot_other_p1 using "Sourcefile.xlsx", sheet("SI_Fig_5", modify) cell(A2) firstrow(varl) 
	lab var tot_en_p2 "Total energy commitment (within period)"
	lab var av_tot_ff_p2 "Average annual commitment (fossil)"
	lab var av_tot_re_p2 "Average annual commitment (RET)"
	lab var av_tot_other_p2 "Average annual commitment (grid)"
	export excel ecacountry5 tot_en_p2 av_tot_ff_p2 av_tot_re_p2 av_tot_other_p2 using "Sourcefile.xlsx", sheet("SI_Fig_5", modify) cell(A7) firstrow(varl) 
	lab var tot_en_p3 "Total energy commitment (within period)"
	lab var av_tot_ff_p3 "Average annual commitment (fossil)"
	lab var av_tot_re_p3 "Average annual commitment (RET)"
	lab var av_tot_other_p3 "Average annual commitment (grid)"
	export excel ecacountry5 tot_en_p3 av_tot_ff_p3 av_tot_re_p3 av_tot_other_p3 using "Sourcefile.xlsx", sheet("SI_Fig_5", modify) cell(A12) firstrow(varl) 
	lab var tot_en_p4 "Total energy commitment (within period)"
	lab var av_tot_ff_p4 "Average annual commitment (fossil)"
	lab var av_tot_re_p4 "Average annual commitment (RET)"
	lab var av_tot_other_p4 "Average annual commitment (grid)"
	export excel ecacountry5 tot_en_p4 av_tot_ff_p4 av_tot_re_p4 av_tot_other_p4 using "Sourcefile.xlsx", sheet("SI_Fig_5", modify) cell(A17) firstrow(varl) 
restore


grc1leg2 "`figure_path'/SI_Fig5_p1.gph" "`figure_path'/SI_Fig5_p2.gph" "`figure_path'/SI_Fig5_p3.gph" "`figure_path'/SI_Fig5_p4.gph", r(1) pos(6) saving(SI_Fig5_upper, replace)


*** Figure 3: Middle element, non-E3F countries by period 

* Identification of Top 10 Energy finance countries

preserve 
bys ecacountry: egen tot_en_country = sum(v_bn_larger)
collapse (max) tot_en_country, by(ecacountry)
gsort -tot_en_country
keep in 1/10
list, clean noobs
restore


* Korea
preserve 
egen tot_ff = total(v_bn_larger) if ff == 1, by(period ecacountry)
egen tot_re = total(v_bn_larger) if re == 1, by(period ecacountry)
egen tot_other = total(v_bn_larger) if grid == 1, by(period ecacountry)
keep if ecacountry == "Korea"
	collapse (mean) tot_ff tot_re tot_other, by(period)
	foreach x of varlist tot_ff tot_re tot_other {
	replace `x' = 0 if (`x' == .) 
	}
	list 
	gen p1 = tot_ff / (tot_ff + tot_re + tot_other)*100 
	gen p2 = (tot_ff + tot_re) /  (tot_ff + tot_re + tot_other)*100
	gen p3 = 100
	gen zero = 0
	twoway rarea zero p1 period, fcolor(gs1*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p1 p2 period, fcolor(green*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p2 p3 period, fcolor(orange*0.6) lc(black) lw(vthin) lstyle(solid) ///
	||, legend(order(1 "Fossil" 2 "Renewables" 3 "Grid")) /// 
    ytitle("") ylab(, angle(0) labsize(medium)) ///
	 title(Korea (32%), size(medium) box bexpand bcolor(gs1*0.1)) xtitle("") ///
	 xla(1 "P1" 2 "P2" 3 "P3" 4 "P4", labsize(medium))
	 list, clean noobs
	graph save "`figure_path'/si_korea_rel.gph", replace
	lab var period "Period"
	lab var tot_ff "Total commitment (fossil)"
	lab var tot_re "Total commitment (RET)"
	lab var tot_other "Total commitment (grid)"
	export excel period tot_ff tot_re tot_other using "Sourcefile.xlsx", sheet("SI_Fig_5", modify) cell(A22) firstrow(varl) 
restore



* Japan
preserve 
egen tot_ff = total(v_bn_larger) if ff == 1, by(period ecacountry)
egen tot_re = total(v_bn_larger) if re == 1, by(period ecacountry)
egen tot_other = total(v_bn_larger) if grid == 1, by(period ecacountry)
keep if ecacountry == "Japan"
	collapse (mean) tot_ff tot_re tot_other, by(period)
	foreach x of varlist tot_ff tot_re tot_other {
	replace `x' = 0 if (`x' == .) 
	}
	list  
	gen p1 = (tot_ff / (tot_ff + tot_re + tot_other))*100 
	gen p2 = ((tot_ff + tot_re) /  (tot_ff + tot_re + tot_other))*100
	gen p3 = 100
	gen zero = 0
	twoway rarea zero p1 period, fcolor(gs1*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p1 p2 period, fcolor(green*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p2 p3 period, fcolor(orange*0.6) lc(black) lw(vthin) lstyle(solid) ///
	||, legend(order(1 "Fossil" 2 "Renewables" 3 "Grid") r(1) size(small) region(lp(blank))) /// 
     ytitle("") yla(0(20)100, angle(0) nolab) ///
	 title(Japan (27%), size(medium) box bexpand bcolor(gs1*0.1)) xtitle("") ///
	 xla(1 "P1" 2 "P2" 3 "P3" 4 "P4", labsize(medium))
	 graph save "`figure_path'/si_japan_rel.gph", replace
	lab var period "Period"
	lab var tot_ff "Total commitment (fossil)"
	lab var tot_re "Total commitment (RET)"
	lab var tot_other "Total commitment (grid)"
	 export excel period tot_ff tot_re tot_other using "Sourcefile.xlsx", sheet("SI_Fig_5", modify) cell(A36) firstrow(varl) 
restore


* China 
preserve 
egen tot_ff = total(v_bn_larger) if ff == 1, by(period ecacountry)
egen tot_re = total(v_bn_larger) if re == 1, by(period ecacountry)
egen tot_other = total(v_bn_larger) if grid == 1, by(period ecacountry)
keep if ecacountry == "China"
	collapse (mean) tot_ff tot_re tot_other, by(period)
	foreach x of varlist tot_ff tot_re tot_other {
	replace `x' = 0 if (`x' == .) 
	}
	list  
	gen p1 = (tot_ff / (tot_ff + tot_re + tot_other))*100 
	gen p2 = ((tot_ff + tot_re) /  (tot_ff + tot_re + tot_other))*100
	gen p3 = 100
	gen zero = 0
	twoway rarea zero p1 period, fcolor(gs1*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p1 p2 period, fcolor(green*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p2 p3 period, fcolor(orange*0.6) lc(black) lw(vthin) lstyle(solid) ///
	||, legend(order(1 "Fossil" 2 "Renewables" 3 "Grid") r(1) size(small) region(lp(blank))) /// 
     ytitle("") yla(0(20)100, angle(0) nolab) ///
	 title(China (26%), size(medium) box bexpand bcolor(gs1*0.1)) xtitle("") ///
	 xla(1 "P1" 2 "P2" 3 "P3" 4 "P4", labsize(medium))
	 graph save "`figure_path'/si_china_rel.gph", replace
	lab var period "Period"
	lab var tot_ff "Total commitment (fossil)"
	lab var tot_re "Total commitment (RET)"
	lab var tot_other "Total commitment (grid)"
	 export excel period tot_ff tot_re tot_other using "Sourcefile.xlsx", sheet("SI_Fig_5", modify) cell(A29) firstrow(varl) 
restore


* Other non-E3F countries 
preserve 
clonevar ecacountry7 = ecacountry
replace ecacountry7 = "Other Non-E3F" if e3f == 0 & !inlist(ecacountry, "Japan", "Korea", "China")
egen tot_ff = total(v_bn_larger) if ff == 1, by(period ecacountry)
egen tot_re = total(v_bn_larger) if re == 1, by(period ecacountry)
egen tot_other = total(v_bn_larger) if grid == 1, by(period ecacountry)
keep if ecacountry7 == "Other Non-E3F"
	collapse (mean) tot_ff tot_re tot_other, by(period)
	foreach x of varlist tot_ff tot_re tot_other {
	replace `x' = 0 if (`x' == .) 
	}
	list 
	gen p1 = tot_ff / (tot_ff + tot_re + tot_other) 
	gen p2 = (tot_ff + tot_re) /  (tot_ff + tot_re + tot_other)
	gen p3 = 1
	gen zero = 0
	twoway rarea zero p1 period, fcolor(gs1*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p1 p2 period, fcolor(green*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p2 p3 period, fcolor(orange*0.6) lc(black) lw(vthin) lstyle(solid) ///
	||, legend(order(1 "Fossil" 2 "Renewables" 3 "Grid")) /// 
    ytitle("") ylab(, nolabel grid) ///
	 title(Other non-E3F (15%), size(medium) box bexpand bcolor(gs1*0.1)) ///
	 xtitle("") xla(1 "P1" 2 "P2" 3 "P3" 4 "P4", labsize(medium))
	graph save "`figure_path'/si_non_e3f_rel.gph", replace
	lab var period "Period"
	lab var tot_ff "Total commitment (fossil)"
	lab var tot_re "Total commitment (RET)"
	lab var tot_other "Total commitment (grid)"
	export excel period tot_ff tot_re tot_other using "Sourcefile.xlsx", sheet("SI_Fig_5", modify) cell(A43) firstrow(varl) 
restore

* Additional calculation Figure 3: Country share over total by group (Non-E3F)
preserve 
clonevar ecacountry_none3f = ecacountry
replace ecacountry_none3f = "Korea" if ecacountry == "Korea"
replace ecacountry_none3f = "Japan" if ecacountry == "Japan"
replace ecacountry_none3f = "China" if ecacountry == "China"
replace ecacountry_none3f = "Other Non-E3F" if e3f == 0 & !inlist(ecacountry, "Japan", "Korea", "China")
keep if e3f != 1 
egen tot_en_all_years = sum(v_bn_larger)
bys ecacountry_none3f: egen tot_en_country = sum(v_bn_larger)
collapse (max) tot_en_country tot_en_all_years, by(ecacountry_none3f)
gen share_total = tot_en_country/tot_en_all_years
gsort -tot_en_country
list, clean noobs
restore 

* Portfolio shifts E3F countries
* Italy
preserve 
egen tot_ff = total(v_bn_larger) if ff == 1, by(period ecacountry)
egen tot_re = total(v_bn_larger) if re == 1, by(period ecacountry)
egen tot_other = total(v_bn_larger) if grid == 1, by(period ecacountry)
keep if ecacountry == "Italy"
	collapse (mean) tot_ff tot_re tot_other, by(period)
	foreach x of varlist tot_ff tot_re tot_other {
	replace `x' = 0 if (`x' == .) 
	}
	list 
	gen p1 = tot_ff / (tot_ff + tot_re + tot_other)*100 
	gen p2 = (tot_ff + tot_re) /  (tot_ff + tot_re + tot_other)*100
	gen p3 = 100
	gen zero = 0
	twoway rarea zero p1 period, fcolor(gs1*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p1 p2 period, fcolor(green*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p2 p3 period, fcolor(orange*0.6) lc(black) lw(vthin) lstyle(solid) ///
	||, legend(order(1 "Fossil" 2 "Renewables" 3 "Grid")) /// 
    ytitle("") yla(0(20)100, angle(0) labsize(medium)) ///
	 title(Italy (25%), size(medium) box bexpand bcolor(gs1*0.1)) xtitle("") ///
	 xla(1 "P1" 2 "P2" 3 "P3" 4 "P4",  labsize(medium))
	 graph save "`figure_path'/si_italy_rel.gph", replace
	lab var period "Period"
	lab var tot_ff "Total commitment (fossil)"
	lab var tot_re "Total commitment (RET)"
	lab var tot_other "Total commitment (grid)"
	 export excel period tot_ff tot_re tot_other using "Sourcefile.xlsx", sheet("SI_Fig_5", modify) cell(A50) firstrow(varl) 
restore


* Germany
preserve 
egen tot_ff = total(v_bn_larger) if ff == 1, by(period ecacountry)
egen tot_re = total(v_bn_larger) if re == 1, by(period ecacountry)
egen tot_other = total(v_bn_larger) if grid == 1, by(period ecacountry)
keep if ecacountry == "Germany"
	collapse (mean) tot_ff tot_re tot_other, by(period)
	foreach x of varlist tot_ff tot_re tot_other {
	replace `x' = 0 if (`x' == .) 
	}
	list 
	gen p1 = tot_ff / (tot_ff + tot_re + tot_other) 
	gen p2 = (tot_ff + tot_re) /  (tot_ff + tot_re + tot_other)
	gen p3 = 1
	gen zero = 0
	twoway rarea zero p1 period, fcolor(gs1*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p1 p2 period, fcolor(green*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p2 p3 period, fcolor(orange*0.6) lc(black) lw(vthin) lstyle(solid) ///
	||, legend(order(1 "Fossil" 2 "Renewables" 3 "Grid")) /// 
     ytitle("") ylab(, nolabel grid) ///
	 title(Germany (23%), size(medium) box bexpand bcolor(gs1*0.1)) xtitle("") ///
	 xla(1 "P1" 2 "P2" 3 "P3" 4 "P4", labsize(medium))
	graph save "`figure_path'/si_germany_rel.gph", replace
	list period p1 p2 p3, clean noobs
	lab var period "Period"
	lab var tot_ff "Total commitment (fossil)"
	lab var tot_re "Total commitment (RET)"
	lab var tot_other "Total commitment (grid)"
	export excel period tot_ff tot_re tot_other using "Sourcefile.xlsx", sheet("SI_Fig_5", modify) cell(A57) firstrow(varl) 
restore



* Denmark
preserve 
egen tot_ff = total(v_bn_larger) if ff == 1, by(period ecacountry)
egen tot_re = total(v_bn_larger) if re == 1, by(period ecacountry)
egen tot_other = total(v_bn_larger) if grid == 1, by(period ecacountry)
keep if ecacountry == "Denmark"
	collapse (mean) tot_ff tot_re tot_other, by(period)
	foreach x of varlist tot_ff tot_re tot_other {
	replace `x' = 0 if (`x' == .) 
	}
	list 
	gen p1 = tot_ff / (tot_ff + tot_re + tot_other) 
	gen p2 = (tot_ff + tot_re) /  (tot_ff + tot_re + tot_other)
	gen p3 = 1
	gen zero = 0
	twoway rarea zero p1 period, fcolor(gs1*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p1 p2 period, fcolor(green*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p2 p3 period, fcolor(orange*0.6) lc(black) lw(vthin) lstyle(solid) ///
	||, legend(order(1 "Fossil" 2 "Renewables" 3 "Grid")) /// 
    ytitle("") ylab(, nolabel grid) ///
	 title(Denmark (16%), size(medium) box bexpand bcolor(gs1*0.1)) xtitle("") ///
	 xla(1 "P1" 2 "P2" 3 "P3" 4 "P4",  labsize(medium))
	graph save "`figure_path'/si_denmark_rel.gph", replace
	lab var period "Period"
	lab var tot_ff "Total commitment (fossil)"
	lab var tot_re "Total commitment (RET)"
	lab var tot_other "Total commitment (grid)"
	export excel period tot_ff tot_re tot_other using "Sourcefile.xlsx", sheet("SI_Fig_5", modify) cell(A64) firstrow(varl) 
restore

* Other E3F countries 
preserve 
gen all_others_e3f = 0
replace all_others_e3f = 1 if !inlist(ecacountry, "Italy", "Denmark", "Germany") & e3f == 1
egen tot_ff = total(v_bn_larger) if ff == 1, by(period ecacountry)
egen tot_re = total(v_bn_larger) if re == 1, by(period ecacountry)
egen tot_other = total(v_bn_larger) if grid == 1, by(period ecacountry)
keep if all_others_e3f == 1 
	collapse (mean) tot_ff tot_re tot_other, by(period)
	foreach x of varlist tot_ff tot_re tot_other {
	replace `x' = 0 if (`x' == .) 
	}
	list 
	gen p1 = tot_ff / (tot_ff + tot_re + tot_other) 
	gen p2 = (tot_ff + tot_re) /  (tot_ff + tot_re + tot_other)
	gen p3 = 1
	gen zero = 0
	twoway rarea zero p1 period, fcolor(gs1*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p1 p2 period, fcolor(green*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p2 p3 period, fcolor(orange*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p2 p3 period, fcolor(orange*0.6) lc(black) lw(vthin) lstyle(solid) ///
	||, legend(order(1 "Fossil" 2 "Renewables" 3 "Grid")) /// 
     ytitle("") ylab(, nolabel grid) ///
	 title(All other E3F (36%), size(medium) box bexpand bcolor(gs1*0.1)) /// 
	  xtitle("") xla(1 "P1" 2 "P2" 3 "P3" 4 "P4", labsize(medium))
	graph save "`figure_path'/si_all_others_e3f_rel.gph", replace
	lab var period "Period"
	lab var tot_ff "Total commitment (fossil)"
	lab var tot_re "Total commitment (RET)"
	lab var tot_other "Total commitment (grid)"
	export excel period tot_ff tot_re tot_other using "Sourcefile.xlsx", sheet("SI_Fig_5", modify) cell(A71) firstrow(varl) 
restore

* Additional calculation Figure 3: Country share over total by group 

* E3F
preserve 
gen e3f_other = 0
replace e3f_other = 1 if inlist(ecacountry, "Spain", "France", "Netherlands", "Sweden", "Finland", "Belgium", "United Kingdom")
clonevar ecacountry_e3f = ecacountry
replace ecacountry_e3f = "All other E3F" if e3f_other == 1
keep if e3f == 1 
egen tot_en_all_years = sum(v_bn_larger)
bys ecacountry_e3f: egen tot_en_country = sum(v_bn_larger)
collapse (max) tot_en_country tot_en_all_years, by(ecacountry_e3f)
gen share_total = tot_en_country/tot_en_all_years
gsort -tot_en_country
list, clean noobs
restore 


grc1leg2 "`figure_path'/SI_Fig5_p1.gph" "`figure_path'/SI_Fig5_p2.gph" "`figure_path'/SI_Fig5_p3.gph" "`figure_path'/SI_Fig5_p4.gph" ///
"`figure_path'/si_korea_rel.gph" "`figure_path'/si_japan_rel.gph" "`figure_path'/si_china_rel.gph" "`figure_path'/si_non_e3f_rel.gph" ///
"`figure_path'/si_italy_rel.gph" "`figure_path'/si_germany_rel.gph" "`figure_path'/si_denmark_rel.gph" "`figure_path'/si_all_others_e3f_rel.gph", r(3) loff 
graph export "`figure_path'/SI_Fig5_final.png", replace


************************************************************************************
************************************************************************************
****************************** SI Figure 7 *********************************
************************************************************************************
************************************************************************************

*** Additional analysis Canada


clear all 

use "`filled_up_data'/oci_txf_combined_SI_all.dta"

gen ff = 0 
replace ff = 1 if inlist(energy_source, "Coal", "Oil", "Gas", "Other fossil")

gen re = 0 
replace re = 1 if inlist(energy_source, "Wind", "Solar", "Other RETs", "Hydro")

gen grid = 0 
replace grid = 1 if energy_source == "Grid"

gen nuclear = 0 
replace nuclear = 1 if energy_source == "Nuclear"

encode period, gen(period2) 
drop period 
ren period2 period

* DL
preserve 
keep if ecacountry == "Canada"
drop if year == 2023
keep if eca_commitment_type == "Direct lending"
egen tot_ff = total(v_bn_larger) if ff == 1, by(year)
egen tot_re = total(v_bn_larger) if re == 1, by(year)
egen tot_grid = total(v_bn_larger) if grid == 1, by(year)
collapse (max) tot_ff tot_re tot_grid, by(year)
	foreach x of varlist tot_ff tot_re tot_grid {
	replace `x' = 0 if (`x' == .) 
	}
list
graph twoway line tot_ff tot_re tot_grid year, lc(gs1*0.6 green*0.6 orange*0.6) ///
lw(thick thick thick) yla(0(2)10, angle(0)) xla(2013(2)2022) ///
legend(order(1 "Fossil" 2 "RETs" 3 "Grid") r(1) size(small) region(lp(blank))) ///
title(Direct lending) xtitle("") ytitle(USD billion{sub:2020})
graph save "`figure_path'/tot_canada_dl.gph", replace 
lab var year "Year"
	lab var tot_ff "Lending (fossil)"
	lab var tot_re "Lending (RET)"
	lab var tot_grid "Lending (grid)"
	export excel year tot_ff tot_re tot_grid using "Sourcefile.xlsx", sheet("SI_Fig_7", modify) cell(A2) firstrow(varl) 
restore 


* G
preserve 
keep if ecacountry == "Canada"
drop if year == 2023
keep if eca_commitment_type == "Guarantee"
egen tot_ff = total(v_bn_larger) if ff == 1, by(year)
egen tot_re = total(v_bn_larger) if re == 1, by(year)
egen tot_grid = total(v_bn_larger) if grid == 1, by(year)
collapse (max) tot_ff tot_re tot_grid, by(year)
	foreach x of varlist tot_ff tot_re tot_grid {
	replace `x' = 0 if (`x' == .) 
	}
list
graph twoway line tot_ff tot_re tot_grid year, lc(gs1*0.6 green*0.6 orange*0.6) ///
lw(thick thick thick) yla(0(2)10, angle(0)) xla(2013(2)2022) ///
legend(order(1 "Fossil" 2 "RETs" 3 "Grid") r(1) size(small) region(lp(blank))) ///
title(Guarantees) xtitle("") ytitle(USD billion{sub:2020})
graph save "`figure_path'/tot_canada_g.gph", replace 
lab var year "Year"
	lab var tot_ff "Guarantees (fossil)"
	lab var tot_re "Guarantees (RET)"
	lab var tot_grid "Guarantees (grid)"
	export excel year tot_ff tot_re tot_grid using "Sourcefile.xlsx", sheet("SI_Fig_7", modify) cell(A14) firstrow(varl) 
restore 

* Other
preserve 
keep if ecacountry == "Canada"
drop if year == 2023
keep if eca_commitment_type == "Other instrument"
egen tot_ff = total(v_bn_larger) if ff == 1, by(year)
egen tot_re = total(v_bn_larger) if re == 1, by(year)
egen tot_grid = total(v_bn_larger) if grid == 1, by(year)
collapse (max) tot_ff tot_re tot_grid, by(year)
	foreach x of varlist tot_ff tot_re tot_grid {
	replace `x' = 0 if (`x' == .) 
	}
list
graph twoway line tot_ff tot_re tot_grid year, lc(gs1*0.6 green*0.6 orange*0.6) ///
lw(thick thick thick) yla(0(3)15, angle(0)) xla(2013(2)2022) ///
legend(order(1 "Fossil" 2 "RETs" 3 "Grid") r(1) size(small) region(lp(blank))) ///
title(Other instruments/Mixed) xtitle("") ytitle(USD billion{sub:2020})
graph save "`figure_path'/tot_canada_o.gph", replace 
lab var year "Year"
	lab var tot_ff "Other instruments (fossil)"
	lab var tot_re "Other instruments (RET)"
	lab var tot_grid "Other instruments (grid)"
	export excel year tot_ff tot_re tot_grid using "Sourcefile.xlsx", sheet("SI_Fig_7", modify) cell(A26) firstrow(varl) 
restore 

* Relative shares
preserve 
drop if year == 2023
egen tot_ff = total(v_bn_larger) if ff == 1, by(period ecacountry)
egen tot_re = total(v_bn_larger) if re == 1, by(period ecacountry)
egen tot_other = total(v_bn_larger) if grid == 1, by(period ecacountry)
keep if ecacountry == "Canada"
	collapse (mean) tot_ff tot_re tot_other, by(period)
	foreach x of varlist tot_ff tot_re tot_other {
	replace `x' = 0 if (`x' == .) 
	}
	list 
	gen p1 = tot_ff / (tot_ff + tot_re + tot_other)*100 
	gen p2 = (tot_ff + tot_re) /  (tot_ff + tot_re + tot_other)*100
	gen p3 = 1*100
	gen zero = 0
	twoway rarea zero p1 period, fcolor(gs1*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p1 p2 period, fcolor(green*0.6) lc(black) lw(vthin) lstyle(solid) ///
	|| rarea p2 p3 period, fcolor(orange*0.6) lc(black) lw(vthin) lstyle(solid) ///
	||, legend(order(1 "Fossil" 2 "Renewables" 3 "Grid") r(1) region(lp(blank))) /// 
     ytitle(Percent) ylab(,grid angle(0)) ///
	 title(Portfolio shares) xtitle("") ///
	 xla(1 "P1" 2 "P2" 3 "P3" 4 "P4{superscript:*}", labsize(medium))
	graph save "`figure_path'/si_canada_rel.gph", replace
	list period p1 p2 p3, clean noobs
	lab var period "Period"
	lab var tot_ff "Total commitment (fossil)"
	lab var tot_re "Total commitment (RET)"
	lab var tot_other "Total commitment (grid)"
	export excel period tot_ff tot_re tot_other using "Sourcefile.xlsx", sheet("SI_Fig_7", modify) cell(A38) firstrow(varl) 
restore


grc1leg2 "`figure_path'/tot_canada_dl.gph" "`figure_path'/tot_canada_g.gph" "`figure_path'/tot_canada_o.gph" "`figure_path'/si_canada_rel.gph", ///
r(2) loff 
graph export "`figure_path'/SI_Fig7_final.png", replace




