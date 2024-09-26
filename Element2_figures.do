*** Final figures

*** CODE FOR DEMO ANALYSIS (follow instructions in the README)

*** BEFORE RUN: --> change the current directory in the line below to the highest repository level and ensure that user-written STATA commands are installed (see README)

clear all 

cd "C:/Users/pwaidelich/Downloads/GitHub - Local/eca_energyfinance"

* if you have access to the full dataset and want to reproduce the final figures, use the following line:
use "data/current_working_file_July24.dta"

* if you use the publicly available, censored data for the Demo Analysis, comment out the previous line and use the following line instead:
* use "data/TXF_data_censored.dta"



************************************************************************************
************************************************************************************
****************************** Figure 1*********************************
************************************************************************************
************************************************************************************

*** Guarantees (SWITCH)

preserve
keep if guarantees == 1
// regenerate for guarantees only
bys year: egen total_coal = sum(v/1000) if coal==1
bys year: egen total_oil = sum(v/1000) if oil==1
bys year: egen total_gas = sum(v/1000) if gas==1
bys year: egen total_other_ff = sum(v/1000) if energy_source == 4
bys year: egen total_wind = sum(v/1000) if wind==1
bys year: egen total_solar = sum(v/1000) if solar==1
bys year: egen total_other_rets = sum(v/1000) if energy_source == 7
bys year: egen total_nuclear = sum(v/1000) if nuclear==1
bys year: egen total_grid = sum(v/1000) if grid == 1


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
	xla(2013(1)2023, nolab notick grid) ///
	yla(0(5)27, grid angle(0) labsize(small)) xtitle("") ///
	xline(2015.5 2019.5 2021.5, lp(dash) lc(red) lwidth(medthick)) scheme(s1mono)
	 graph save "guarantees_only", replace
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
	 export excel year total_coal total_oil total_gas total_other_ff total_wind total_solar total_other_rets total_nuclear total_grid using "Sourcefile.xlsx", sheet("Fig 1", modify) cell(A2) firstrow(varl)
restore


*** Direct lending (SWITCH)

preserve
keep if direct_lending == 1 
// regenerate for direct lending only
bys year: egen total_coal = sum(v/1000) if coal==1
bys year: egen total_oil = sum(v/1000) if oil==1
bys year: egen total_gas = sum(v/1000) if gas==1
bys year: egen total_other_ff = sum(v/1000) if energy_source == 4
bys year: egen total_wind = sum(v/1000) if wind==1
bys year: egen total_solar = sum(v/1000) if solar==1
bys year: egen total_other_rets = sum(v/1000) if energy_source == 7
bys year: egen total_nuclear = sum(v/1000) if nuclear==1
bys year: egen total_grid = sum(v/1000) if grid == 1

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
		xla(2013(1)2023, nolab notick grid) ///
		yla(0(5)27, grid angle(0) labsize(small)) ///
		xtitle("") ///
		xline(2015.5 2019.5 2021.5, lp(dash) lc(red) lwidth(medthick)) scheme(s1mono)
	 	graph save "directlending_only", replace
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
	export excel year total_coal total_oil total_gas total_other_ff total_wind total_solar total_other_rets total_nuclear total_grid using "Sourcefile.xlsx", sheet("Fig 1", modify) cell(A16) firstrow(varl)
restore


* Share RE over all direct lending 

bys year: egen tot_en_dl = total(v/1000) if direct_lending == 1
bys year: egen tot_re_dl = total(v/1000) if re == 1 & direct_lending == 1
bys year: egen tot_en_g = total(v/1000) if guarantees == 1
bys year: egen tot_re_g = total(v/1000) if re == 1 & guarantees == 1


* Shares RE Guarantees & Direct lending  

preserve 
collapse (max) tot_en_dl tot_re_dl tot_en_g tot_re_g, by(year)
forvalues i=2013(1)2023 {
	gen share_dl_`i' = tot_re_dl/tot_en_dl if year == `i'
	gen share_g_`i' = tot_re_g/tot_en_g if year == `i'
	list share_dl_`i' share_g_`i' year, clean noobs
}
gen share_re_dl = 0 
gen share_re_g = 0 
forv i = 2013(1)2023 {
replace share_re_dl = (share_dl_`i')*100 if year == `i'
replace share_re_g = (share_g_`i')*100 if year == `i'
}
list year share_re_dl share_re_g, clean noobs
twoway (line share_re_dl year, lc(dkgreen) lpattern(solid)) ///
(line share_re_g year, lc(dkgreen) lpattern(shortdash)) ///
, xla(2013(1)2023) ///
ylab(0(15)70, grid angle(0) labsize(small)) ///
legend(order(1 "Direct lending" 2 "Guarantees")) ///
xtitle("") xline(2015.5 2019.5 2021.5, lp(dash) lc(red) lwidth(medthick)) 
graph save "RE_share", replace
	lab var year "Year"
	lab var tot_en_dl "Total energy lending"
	lab var tot_re_dl "Total RET lending"
	lab var tot_en_g "Total energy guarantees"
	lab var tot_re_g "Total RET guarantees"
	lab var share_re_dl "RET share lending"
	lab var share_re_g "RET share guarantees" 
export excel year tot_en_dl tot_re_dl tot_en_g tot_re_g share_re_dl share_re_g using "Sourcefile.xlsx", sheet("Fig 1", modify) cell(A30) firstrow(varl) 
restore 


grc1leg2 guarantees_only.gph directlending_only.gph RE_share.gph, r(3) leg(guarantees_only.gph) pos(3) lr(9) 


graph export "graphs/Fig1_final.png", replace


* Figure caption

*** Other fossil
preserve 
keep if energy_source == 4
tab dealsubindustry if volumein != 0
restore 

***Other RETs
preserve 
keep if energy_source == 7 // Other RETs 
tab dealsubindustry if volumein != 0
restore 


************************************************************************************
************************************************************************************
****************************** Figure 2 *********************************
************************************************************************************
************************************************************************************


// Figure 2 Value chains FF by type of energy and period

preserve
keep if energy_source == 1
forv i = 1(1)5 {
	bys period: egen v_c`i'_coal = sum(v/1000) if v_c==`i' 
}

collapse (max) v_c1_coal-v_c4_coal, by(period)
forvalues i = 1(1)4 {
	replace v_c`i'_coal = (v_c`i'_coal / 3) if period==1
}
forvalues i = 1(1)4 {
	replace v_c`i'_coal = (v_c`i'_coal / 4) if period==2
}
forvalues i = 1(1)4 {
	replace v_c`i'_coal = (v_c`i'_coal / 2) if period==3
}
forvalues i = 1(1)4 {
	replace v_c`i'_coal = (v_c`i'_coal / 2) if period==4
}
graph bar v_c1_coal-v_c4_coal, ///
over(period, relabel(1 "P1" 2 "P2" 3 "P3" 4 "P4")) ///
stack ///
title(Coal, box bexpand bcolor(gs1*0.4)) ///
bar(1, col("237 248 251") lp(solid) lw(vthin)) ///
bar(2, col("179 205 227") lp(solid) lw(vthin)) ///
bar(3, col("140 150 198") lp(solid) lw(vthin)) ///
bar(4, col("136 65 157") fi(inten30) lp(solid) lw(vthin) lc("136 65 157%30")) ///
graphregion(color(white)) yla(0(2)17, angle(0)) ///
legend(order(1 "Upstream" 2 "Midstream" 3 "Downstream" 4 "Power generation - Fossil") title("Value chain stage - Fossil", size(small)) pos(6) col(4) size(vsmall) region(lp(blank)))
graph save "Coal", replace
	lab var period "Period"
	lab var v_c1_coal "Coal_upstream"
	lab var v_c2_coal "Coal_midstream"
	lab var v_c3_coal "Coal_downstream"
	lab var v_c4_coal "Coal_power"
export excel period v_c1_coal-v_c4_coal using "Sourcefile.xlsx", sheet("Fig 2", modify) cell(A2) firstrow(varl) 
save "data/intermediate/fig_2_Coal_txf.dta", replace
restore 



preserve 
keep if energy_source == 2

forv i = 1(1)5 {
	bys period: egen v_c`i'_oil = sum(v/1000) if v_c==`i' 
}

collapse (max) v_c1_oil-v_c4_oil, by(period)
forvalues i = 1(1)4 {
	replace v_c`i'_oil = (v_c`i'_oil / 3) if period==1
}

forvalues i = 1(1)4 {
	replace v_c`i'_oil = (v_c`i'_oil / 4) if period==2
}

forvalues i = 1(1)4 {
	replace v_c`i'_oil = (v_c`i'_oil / 2) if period==3
}

forvalues i = 1(1)4 {
	replace v_c`i'_oil = (v_c`i'_oil / 2) if period==4
}

graph bar v_c1_oil-v_c4_oil, ///
over(period, relabel(1 "P1" 2 "P2" 3 "P3" 4 "P4")) stack leg(off) title(Oil, box bexpand bcolor(gs1*0.3)) ///
bar(1, col("237 248 251") lp(solid) lw(vthin)) ///
bar(2, col("179 205 227") lp(solid) lw(vthin)) ///
bar(3, col("140 150 198") lp(solid) lw(vthin)) ///
bar(4, col("136 65 157") fi(inten30) lp(solid) lw(vthin) lc("136 65 157%30")) ///
graphregion(color(white)) yla(0(2)17, nolab)
graph save "Oil", replace
	lab var period "Period"
	lab var v_c1_oil "Oil_upstream"
	lab var v_c2_oil "Oil_midstream"
	lab var v_c3_oil "Oil_downstream"
	lab var v_c4_oil "Oil_power"
export excel using "Sourcefile.xlsx", sheet("Fig 2", modify) cell(A9) firstrow(varl) 
save "data/intermediate/fig_2_Oil_txf.dta", replace
restore 




preserve 
keep if energy_source == 3

forv i = 1(1)5 {
	bys period: egen v_c`i'_gas = sum(v/1000) if v_c==`i' 
}
collapse (max) v_c1_gas-v_c4_gas, by(period)
forvalues i = 1(1)4 {
	replace v_c`i'_gas = (v_c`i'_gas / 3) if period==1
}

forvalues i = 1(1)4 {
	replace v_c`i'_gas = (v_c`i'_gas / 4) if period==2
}

forvalues i = 1(1)4 {
	replace v_c`i'_gas = (v_c`i'_gas / 2) if period==3
}

forvalues i = 1(1)4 {
	replace v_c`i'_gas = (v_c`i'_gas / 2) if period==4
}

graph bar v_c1_gas-v_c4_gas, ///
over(period, relabel(1 "P1" 2 "P2" 3 "P3" 4 "P4")) stack ///
title(Gas, box bexpand bcolor(gs1*0.2)) ///
leg(off) ///
bar(1, col("237 248 251") lp(solid) lw(vthin)) ///
bar(2, col("179 205 227") lp(solid) lw(vthin)) ///
bar(3, col("140 150 198") lp(solid) lw(vthin)) ///
bar(4, col("136 65 157") fi(inten30) lp(solid) lw(vthin) lc("136 65 157%30")) ///
graphregion(color(white)) yla(0(2)17, nolab)
graph save "Gas", replace
	lab var period "Period"
	lab var v_c1_gas "Gas_upstream"
	lab var v_c2_gas "Gas_midstream"
	lab var v_c3_gas "Gas_downstream"
	lab var v_c4_gas "Gas_power"
export excel using "Sourcefile.xlsx", sheet("Fig 2", modify) cell(A16) firstrow(varl) 
save "data/intermediate/fig_2_Gas_txf.dta", replace
restore 


preserve
gen re_energy_source = 0 
replace re_energy_source=1 if tech_fine ==8 // offshore
replace re_energy_source=2 if tech_fine ==9 // onshore 
replace re_energy_source=3 if solar == 1 // solar
replace re_energy_source=4 if tech ==7 // hydro 
replace re_energy_source=5 if re == 1 & !inlist(tech_fine, 8, 9) ///
& tech != 7 & solar != 1
keep if re_energy_source != 0
codebook tmddealid
codebook tmddealid if re_energy_source == 5
tab dealsubindustry if re_energy_source == 5 & volumein != 0
codebook tmddealid if energy_source == 7
forv i = 1(1)5 {
bys period: egen tech_fine_`i' = sum(v/1000) if re_energy_source==`i'
}
forv i = 1(1)5 {
replace tech_fine_`i' = (tech_fine_`i'/3) if period == 1
}
forv i = 1(1)5 {
replace tech_fine_`i' = (tech_fine_`i'/4) if period == 2
}
forv i = 1(1)5 {
replace tech_fine_`i' = (tech_fine_`i'/2) if period == 3
}
forv i = 1(1)5 {
replace tech_fine_`i' = (tech_fine_`i'/2) if period == 4
}
collapse (max) tech_fine_1-tech_fine_5, by(period)
graph bar tech_fine_1-tech_fine_5, ///
over(period, relabel(1 "P1" 2 "P2" 3 "P3" 4 "P4")) ///
stack ///
title(Renewables, box bexpand bcolor(green*0.2)) ///
bar(1, col(green*1.2) lp(solid) fi(inten100)) ///
bar(2, col(green*1.2) lp(solid) fi(inten80)) ///
bar(3, col(green*0.15) lp(solid) fi(inten30)) ///
bar(4, col(green*0.4) lp(sold) fi(inten40)) ///
bar(5, col(green*0.8) lp(solid) fi(inten60)) ///
graphregion(color(white)) yla(0(2)17, grid nolab) ///
legend(order(5 "Other or mixed" 4 "Hydro" 3 "Solar" 2 "Wind (onshore)" 1 "Wind (offshore)" ///
 ) title(Power generation - Renewables, size(small)) size(vsmall) pos(3) c(1))
graph save "Renewables", replace
list period tech_fine_1-tech_fine_5, clean noobs
	lab var period "Period"
	lab var tech_fine_1 "Offshore wind"
	lab var tech_fine_2 "Onshore wind"
	lab var tech_fine_3 "Solar"
	lab var tech_fine_4 "Hydro"
	lab var tech_fine_5 "Other RETs"
export excel period tech_fine_1-tech_fine_5 using "Sourcefile.xlsx", sheet("Fig 2", modify) cell(A23) firstrow(varl) 
save "data/intermediate/fig_2_Clean_txf.dta", replace
restore 

grc1leg2 Coal.gph Oil.gph Gas.gph Renewables.gph, r(1) loff graphregion(color(white)) ycom 

graph export "graphs/Fig2_final.png", replace 

* Figure caption
*** 'Other or mixed' Renewables  
preserve 
keep if re == 1 & !inlist(tech_fine, 8, 9) ///
& tech != 7 & solar != 1
tab dealsubindustry if volumein != 0
restore 

************************************************************************************
************************************************************************************
****************************** Figure 3 *********************************
************************************************************************************
************************************************************************************


*** Fig3: Upper element of the graph  

gen e3f = 0 
replace e3f = 1 if inlist(ecacountry, "Belgium", "Denmark", "Finland", "France", "Germany") | ///
inlist(ecacountry, "Italy", "Netherlands", "Spain", "Sweden", "United Kingdom")

gen oecd = 0 
replace oecd = 1 if !inlist(ecacountry, "China", "India", "Indonesia", "Malaysia", "Russian Federation") & ///
!inlist(ecacountry, "Saudi Arabia", "South Africa", "Thailand", "United Arab Emirates")


* Upper element of the graph 

preserve 
clonevar ecacountry5 = ecacountry

replace ecacountry5 = "Non-E3F" if e3f == 0 
replace ecacountry5 = "E3F" if e3f == 1 

forv i = 1(1)4 {
bys ecacountry5: egen tot_en_p`i' = sum(v/1000) if p`i' == 1 
}
forv i = 1(1)4 {
bys ecacountry5: egen tot_ff_p`i' = sum(v/1000) if ff == 1 & p`i' == 1 
}
forv i = 1(1)4 {
bys ecacountry5: egen tot_re_p`i' = sum(v/1000) if re == 1 & p`i' == 1 
}
forv i = 1(1)4 {
bys ecacountry5: egen tot_other_p`i' = sum(v/1000) if grid == 1 & p`i' == 1 
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
	gen av_`var' = `var'/ 2
	}
	graph bar (mean) av_tot_ff_p1 av_tot_re_p1 av_tot_other_p1, ///
	over(ecacountry5, rev label(labsize(medium))) ///
	stack yla(0(5)27, nolab) /// 
	bar(1, color(gs1*0.6) ls(none)) ///
	bar(2, color(green*0.6) ls(none)) ///
	bar(3, color(orange*0.6) ls(none)) ///
	title(Pre-Paris (2013-2015), size(medium) box bexpand bcolor(gs1*0.1)) ///
	legend(order(1 "Fossil" 2 "Renewables" 3 "Grid") col(3) region(lcolor(none))) 
	graph save p1, replace
	graph bar (mean) av_tot_ff_p2 av_tot_re_p2 av_tot_other_p2, ///
	over(ecacountry5, rev label(labsize(medium))) ///
	stack yla(0(5)27, nolab) ///
	bar(1, color(gs1*0.6) ls(none)) ///
	bar(2, color(green*0.6) ls(none)) ///
	bar(3, color(orange*0.6) ls(none)) ///
	title(Post-Paris (2016-2019), size(medium) box bexpand bcolor(gs1*0.1))
	graph save p2, replace
	graph bar (mean) av_tot_ff_p3 av_tot_re_p3 av_tot_other_p3, ///
	over(ecacountry5, rev label(labsize(medium))) ///
	stack yla(0(5)27, nolab) ///
	bar(1, color(gs1*0.6) ls(none)) ///
	bar(2, color(green*0.6) ls(none)) ///
	bar(3, color(orange*0.6) ls(none)) ///
	title(Pandemic (2020-2021), size(medium) box bexpand bcolor(gs1*0.1))
	graph save p3, replace
	graph bar (mean) av_tot_ff_p4 av_tot_re_p4 av_tot_other_p4, ///
	over(ecacountry5, rev label(labsize(medium))) ///
	stack yla(0(5)27, nolab) ///
	bar(1, color(gs1*0.6) ls(none)) ///
	bar(2, color(green*0.6) ls(none)) ///
	bar(3, color(orange*0.6) ls(none)) ///
	title(Post-Glasgow (2022-2023), size(medium) box bexpand bcolor(gs1*0.1))
	graph save p4, replace
	lab var ecacountry5 "Country"
	lab var tot_en_p1 "Total energy commitment (within period)"
	lab var av_tot_ff_p1 "Average annual commitment (fossil)"
	lab var av_tot_re_p1 "Average annual commitment (RET)"
	lab var av_tot_other_p1 "Average annual commitment (grid)"
	export excel ecacountry5 tot_en_p1 av_tot_ff_p1 av_tot_re_p1 av_tot_other_p1 using "Sourcefile.xlsx", sheet("Fig 3", modify) cell(A2) firstrow(varl) 
	lab var tot_en_p2 "Total energy commitment (within period)"
	lab var av_tot_ff_p2 "Average annual commitment (fossil)"
	lab var av_tot_re_p2 "Average annual commitment (RET)"
	lab var av_tot_other_p2 "Average annual commitment (grid)"
	export excel ecacountry5 tot_en_p2 av_tot_ff_p2 av_tot_re_p2 av_tot_other_p2 using "Sourcefile.xlsx", sheet("Fig 3", modify) cell(A7) firstrow(varl) 
	lab var tot_en_p3 "Total energy commitment (within period)"
	lab var av_tot_ff_p3 "Average annual commitment (fossil)"
	lab var av_tot_re_p3 "Average annual commitment (RET)"
	lab var av_tot_other_p3 "Average annual commitment (grid)"
	export excel ecacountry5 tot_en_p3 av_tot_ff_p3 av_tot_re_p3 av_tot_other_p3 using "Sourcefile.xlsx", sheet("Fig 3", modify) cell(A12) firstrow(varl) 
	lab var tot_en_p4 "Total energy commitment (within period)"
	lab var av_tot_ff_p4 "Average annual commitment (fossil)"
	lab var av_tot_re_p4 "Average annual commitment (RET)"
	lab var av_tot_other_p4 "Average annual commitment (grid)"
	save ///
	"data/intermediate/fig_3_upper_txf.dta", replace 
	export excel ecacountry5 tot_en_p4 av_tot_ff_p4 av_tot_re_p4 av_tot_other_p4 using "Sourcefile.xlsx", sheet("Fig 3", modify) cell(A17) firstrow(varl) 
restore

grc1leg2 p1.gph p2.gph p3.gph p4.gph, r(1) pos(6) saving(Fig3_upper, replace)


*** Figure 3: Middle element, non-E3F countries by period 

* Identification of Top 10 Energy finance countries

preserve 
bys ecacountry: egen tot_en_country = sum(v/1000)
collapse (max) tot_en_country, by(ecacountry)
gsort -tot_en_country
keep in 1/10
list, clean noobs
restore

* Japan
preserve 
egen tot_ff = total(v/1000) if ff == 1, by(period ecacountry)
egen tot_re = total(v/1000) if re == 1, by(period ecacountry)
egen tot_other = total(v/1000) if grid == 1, by(period ecacountry)
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
	 title(Japan (39%), size(medium) box bexpand bcolor(gs1*0.1)) xtitle("") ///
	 xla(1 "P1" 2 "P2" 3 "P3" 4 "P4", labsize(medium))
	 graph save japan_rel, replace
	lab var period "Period"
	lab var tot_ff "Total commitment (fossil)"
	lab var tot_re "Total commitment (RET)"
	lab var tot_other "Total commitment (grid)"
	 export excel period tot_ff tot_re tot_other using "Sourcefile.xlsx", sheet("Fig 3", modify) cell(A22) firstrow(varl) 
restore

* Korea
preserve 
egen tot_ff = total(v/1000) if ff == 1, by(period ecacountry)
egen tot_re = total(v/1000) if re == 1, by(period ecacountry)
egen tot_other = total(v/1000) if grid == 1, by(period ecacountry)
keep if ecacountry == "Korea"
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
	 title(Korea (27%), size(medium) box bexpand bcolor(gs1*0.1)) xtitle("") ///
	 xla(1 "P1" 2 "P2" 3 "P3" 4 "P4", labsize(medium))
	 list, clean noobs
	graph save korea_rel, replace
	lab var period "Period"
	lab var tot_ff "Total commitment (fossil)"
	lab var tot_re "Total commitment (RET)"
	lab var tot_other "Total commitment (grid)"
	export excel period tot_ff tot_re tot_other using "Sourcefile.xlsx", sheet("Fig 3", modify) cell(A29) firstrow(varl) 
restore

* China (+ other non-OECD)
preserve 
clonevar ecacountry6 = ecacountry
replace ecacountry6 = "Non-OECD Non-E3F" if oecd == 0 & e3f == 0
replace ecacountry6 = "OECD Non-E3F" if oecd == 1 & e3f == 0
list ecacountry6 
egen tot_ff = total(v/1000) if ff == 1, by(period ecacountry6)
egen tot_re = total(v/1000) if re == 1, by(period ecacountry6)
egen tot_other = total(v/1000) if grid == 1, by(period ecacountry6)
keep if ecacountry6 == "Non-OECD Non-E3F"
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
	 title(China + other non-OECD (19%), size(medium) box bexpand bcolor(gs1*0.1)) xtitle("") ///
	 xla(1 "P1" 2 "P2" 3 "P3" 4 "P4", labsize(medium))
	graph save non_OECD_rel, replace
	lab var period "Period"
	lab var tot_ff "Total commitment (fossil)"
	lab var tot_re "Total commitment (RET)"
	lab var tot_other "Total commitment (grid)"
	export excel period tot_ff tot_re tot_other using "Sourcefile.xlsx", sheet("Fig 3", modify) cell(A36) firstrow(varl) 
restore

* Other OECD non-E3F countries 
preserve 
clonevar ecacountry7 = ecacountry
replace ecacountry7 = "Other OECD Non-E3F" if oecd == 1 & e3f == 0 & !inlist(ecacountry, "Japan", "Korea")
egen tot_ff = total(v/1000) if ff == 1, by(period ecacountry7)
egen tot_re = total(v/1000) if re == 1, by(period ecacountry7)
egen tot_other = total(v/1000) if grid == 1, by(period ecacountry7)
keep if ecacountry7 == "Other OECD Non-E3F"
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
	 title(Other OECD non-E3F (15%), size(medium) box bexpand bcolor(gs1*0.1)) ///
	 xtitle("") xla(1 "P1" 2 "P2" 3 "P3" 4 "P4", labsize(medium))
	graph save oecd_non_e3f_rel, replace
	lab var period "Period"
	lab var tot_ff "Total commitment (fossil)"
	lab var tot_re "Total commitment (RET)"
	lab var tot_other "Total commitment (grid)"
	export excel period tot_ff tot_re tot_other using "Sourcefile.xlsx", sheet("Fig 3", modify) cell(A43) firstrow(varl) 
restore

* Additional calculation Figure 3: Country share over total by group (Non-E3F)
preserve 
clonevar ecacountry_none3f = ecacountry
replace ecacountry_none3f = "Japan" if ecacountry == "Japan"
replace ecacountry_none3f = "Korea" if ecacountry == "Korea"
replace ecacountry_none3f = "Non-OECD Non-E3F" if oecd == 0 & e3f == 0
replace ecacountry_none3f = "Other OECD Non-E3F" if oecd == 1 & e3f == 0 & !inlist(ecacountry, "Japan", "Korea")
keep if e3f != 1 
egen tot_en_all_years = sum(v/1000)
bys ecacountry_none3f: egen tot_en_country = sum(v/1000)
collapse (max) tot_en_country tot_en_all_years, by(ecacountry_none3f)
gen share_total = tot_en_country/tot_en_all_years
gsort -tot_en_country
list, clean noobs
restore 

* Portfolio shifts E3F countries
* Italy
preserve 
egen tot_ff = total(v/1000) if ff == 1, by(period ecacountry)
egen tot_re = total(v/1000) if re == 1, by(period ecacountry)
egen tot_other = total(v/1000) if grid == 1, by(period ecacountry)
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
    ytitle("") yla(0(20)100, angle(0) nolab) ///
	 title(Italy (28%), size(medium) box bexpand bcolor(gs1*0.1)) xtitle("") ///
	 xla(1 "P1" 2 "P2" 3 "P3" 4 "P4",  labsize(medium))
	 graph save italy_rel, replace
	lab var period "Period"
	lab var tot_ff "Total commitment (fossil)"
	lab var tot_re "Total commitment (RET)"
	lab var tot_other "Total commitment (grid)"
	 export excel period tot_ff tot_re tot_other using "Sourcefile.xlsx", sheet("Fig 3", modify) cell(A50) firstrow(varl) 
restore

* Denmark
preserve 
egen tot_ff = total(v/1000) if ff == 1, by(period ecacountry)
egen tot_re = total(v/1000) if re == 1, by(period ecacountry)
egen tot_other = total(v/1000) if grid == 1, by(period ecacountry)
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
	 title(Denmark (20%), size(medium) box bexpand bcolor(gs1*0.1)) xtitle("") ///
	 xla(1 "P1" 2 "P2" 3 "P3" 4 "P4",  labsize(medium))
	graph save denmark_rel, replace
	lab var period "Period"
	lab var tot_ff "Total commitment (fossil)"
	lab var tot_re "Total commitment (RET)"
	lab var tot_other "Total commitment (grid)"
	export excel period tot_ff tot_re tot_other using "Sourcefile.xlsx", sheet("Fig 3", modify) cell(A57) firstrow(varl) 
restore

* Germany
preserve 
egen tot_ff = total(v/1000) if ff == 1, by(period ecacountry)
egen tot_re = total(v/1000) if re == 1, by(period ecacountry)
egen tot_other = total(v/1000) if grid == 1, by(period ecacountry)
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
	 title(Germany (19%), size(medium) box bexpand bcolor(gs1*0.1)) xtitle("") ///
	 xla(1 "P1" 2 "P2" 3 "P3" 4 "P4", labsize(medium))
	graph save germany_rel, replace
	list period p1 p2 p3, clean noobs
	lab var period "Period"
	lab var tot_ff "Total commitment (fossil)"
	lab var tot_re "Total commitment (RET)"
	lab var tot_other "Total commitment (grid)"
	export excel period tot_ff tot_re tot_other using "Sourcefile.xlsx", sheet("Fig 3", modify) cell(A64) firstrow(varl) 
restore

* Other E3F countries 
preserve 
gen all_others_e3f = 0
replace all_others_e3f = 1 if !inlist(ecacountry, "Italy", "Denmark", "Germany") & e3f == 1
egen tot_ff = total(v/1000) if ff == 1, by(period all_others_e3f)
egen tot_re = total(v/1000) if re == 1, by(period all_others_e3f)
egen tot_other = total(v/1000) if grid == 1, by(period all_others_e3f)
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
	 title(All other E3F (32%), size(medium) box bexpand bcolor(gs1*0.1)) /// 
	  xtitle("") xla(1 "P1" 2 "P2" 3 "P3" 4 "P4", labsize(medium))
	graph save all_others_e3f_rel, replace
	lab var period "Period"
	lab var tot_ff "Total commitment (fossil)"
	lab var tot_re "Total commitment (RET)"
	lab var tot_other "Total commitment (grid)"
	export excel period tot_ff tot_re tot_other using "Sourcefile.xlsx", sheet("Fig 3", modify) cell(A71) firstrow(varl) 
restore

* Additional calculation Figure 3: Country share over total by group 

* E3F
preserve 
gen e3f_other = 0
replace e3f_other = 1 if inlist(ecacountry, "Spain", "France", "Netherlands", "Sweden", "Finland", "Belgium", "United Kingdom")
clonevar ecacountry_e3f = ecacountry
replace ecacountry_e3f = "All other E3F" if e3f_other == 1
keep if e3f == 1 
egen tot_en_all_years = sum(v/1000)
bys ecacountry_e3f: egen tot_en_country = sum(v/1000)
collapse (max) tot_en_country tot_en_all_years, by(ecacountry_e3f)
gen share_total = tot_en_country/tot_en_all_years
gsort -tot_en_country
list, clean noobs
restore 

grc1leg2 p1.gph p2.gph p3.gph p4.gph ///
japan_rel.gph korea_rel.gph non_OECD_rel.gph oecd_non_e3f_rel.gph ///
italy_rel.gph denmark_rel.gph germany_rel.gph all_others_e3f_rel.gph, r(3) loff 
graph export "graphs/Fig3_final.png", replace


************************************************************************************
************************************************************************************
****************************** Figure 4 *********************************
************************************************************************************
************************************************************************************


* in total deal volume  

preserve 
collapse(max) dv_bn, by(tmddealid energy_source)
keep if inlist(energy_source, 1, 2, 3, 5, 6, 7, 9)
graph hbox dv_bn, over(energy_source) asyvars showyvars leg(off) /// 
yla(0(4)22, grid angle(0)) ytitle("") ///
box(1, color(gs1*0.8) lp(solid) lw(medium)) ///
box(2, color(gs1*0.6)  lp(solid) lw(medium)) ///
box(3, color(gs1*0.4) lp(solid) lw(medium)) ///
box(4, color(green*1.2) lp(solid) lw(medium)) ///
box(5, color(green*0.8) lp(solid) lw(medium)) ///
box(6, color(green*0.4) lp(solid) lw(medium)) ///
box(7, color(orange*0.8) lp(solid) lw(medium)) ///
marker(1, mcolor(gs1*0.8)) ///
marker(2, mcolor(gs1*0.6)) ///
marker(3, mcolor(gs1*0.4)) ///
marker(4, mcolor(green*1.2)) ///
marker(5, mcolor(green*0.8)) ///
marker(6, mcolor(green*0.4)) ///
marker(7, mcolor(orange*0.8))
codebook tmddealid
graph save dealvolumes, replace
graph export "graphs/Fig4_1_final.png", replace
	lab var dv_bn "Total deal volume (USD billion)"
	lab var tmddealid "Unique identifier (confidential)"
	lab var energy_source "Energy source"
export excel using "Sourcefile.xlsx", sheet("Fig 4", modify) cell(A2) firstrow(varl) 
su dv_bn if energy_source == 1, d
su dv_bn if energy_source == 2, d
su dv_bn if energy_source == 3, d
su dv_bn if energy_source == 5, d
su dv_bn if energy_source == 6, d
su dv_bn if energy_source == 7, d
su dv_bn if energy_source == 9, d
restore 


* Zoom-in  

preserve 
keep if inlist(energy_source, 1, 2, 3, 5, 6, 7, 9)
collapse(max) dv, by(tmddealid energy_source) 
graph hbox dv, over(energy_source) asyvars showyvars leg(off) /// 
yla(0(400)2450, grid angle(0)) ytitle("") ///
box(1, color(gs1*0.8) lp(solid) lw(medium)) ///
box(2, color(gs1*0.6)  lp(solid) lw(medium)) ///
box(3, color(gs1*0.4) lp(solid) lw(medium)) ///
box(4, color(green*1.2) lp(solid) lw(medium)) ///
box(5, color(green*0.8) lp(solid) lw(medium)) ///
box(6, color(green*0.4) lp(solid) lw(medium)) ///
box(7, color(orange*0.8) lp(solid) lw(medium)) ///
marker(1, mcolor(gs1*0.8)) ///
marker(2, mcolor(gs1*0.6)) ///
marker(3, mcolor(gs1*0.4)) ///
marker(4, mcolor(green*1.2)) ///
marker(5, mcolor(green*0.8)) ///
marker(6, mcolor(green*0.4)) ///
marker(7, mcolor(orange*0.8)) nooutsides 
graph save zoom_in_dealvolumes, replace
graph export "graphs/Fig4_2_final_zoomin.png", replace
	lab var dv "Total deal volume (USD million)"
	lab var tmddealid "Unique identifier (confidential)"
	lab var energy_source "Energy source"
export excel using "Sourcefile.xlsx", sheet("Fig 4", modify) cell(E2) firstrow(variables) 
codebook tmddealid
su dv if energy_source == 9, d 
restore 


*D Tenor by period and energy 

preserve 
keep if inlist(energy_source, 1, 2, 3, 5, 6, 7, 9)
egen tag = tag(uniquetrancheid)
keep if tag == 1 
collapse(max) tenor, by(uniquetrancheid energy_source)
graph hbox tenor, over(energy_source, relabel(1 "Coal" 2 "Oil" 3 "Gas" 4 "Wind" 5 "Solar" 6 "Other RET" 7 "Grid") label(nolab)) asyvars showyvars leg(off) /// 
yla(0(10)42, grid angle(0)) ytitle("") ///
box(1, color(gs1*0.8) lp(solid) lw(medium)) ///
box(2, color(gs1*0.6)  lp(solid) lw(medium)) ///
box(3, color(gs1*0.4) lp(solid) lw(medium)) ///
box(4, color(green*1.2) lp(solid) lw(medium)) ///
box(5, color(green*0.8) lp(solid) lw(medium)) ///
box(6, color(green*0.4) lp(solid) lw(medium)) ///
box(7, color(orange*0.8) lp(solid) lw(medium)) ///
marker(1, mcolor(gs1*0.8)) ///
marker(2, mcolor(gs1*0.6)) ///
marker(3, mcolor(gs1*0.4)) ///
marker(4, mcolor(green*1.2)) ///
marker(5, mcolor(green*0.8)) ///
marker(6, mcolor(green*0.4)) ///
marker(7, mcolor(orange*0.8)) 
graph save Tenor, replace
graph export "graphs/Fig4_3_final.png", replace
	lab var tenor "Tenor (number of years)"
	lab var uniquetrancheid "Unique identifier (confidential)"
	lab var energy_source "Energy source"
export excel using "Sourcefile.xlsx", sheet("Fig 4", modify) cell(I2) firstrow(variables)
codebook uniquetrancheid 
restore 



* E Borrower type 

preserve 
keep if inlist(energy_source, 1, 2, 3, 5, 6, 7, 9)
egen tag = tag(uniquetrancheid)
codebook uniquetrancheid
codebook tag
keep if tag == 1 // only keep unique tranches 
gen borrowertype2 = 0 
replace borrowertype2 = 1 if borrowertype == "SPV"
replace borrowertype2 = 2 if inlist(borrowertype, "Private company", "Listed company", ///
"Financial institution", "Investment manager")
replace borrowertype2 = 3 if inlist(borrowertype, "Government owned company", "Government", "ECA", ///
"MFI/DFI", "Public Private partnership")
replace borrowertype2 = 4 if !inlist(borrowertype, "SPV", "Private company", ///
"Government owned company", "Listed company", "Government") & ///
!inlist(borrowertype, "MFI/DFI", "Financial institution", "Investment Manager", ///
"ECA", "Public Private partnership")

label define b_type 1 "Special purpose vehicle" 2 "Other private" 3 "Public" 4 "Other"

label values borrowertype2 b_type

tab borrowertype2
collapse(count) uniquetrancheid, by(energy_source borrowertype2)
forv i = 1(1)4 {
	egen coal_`i' = sum(uniquetrancheid) if borrowertype2 == `i' & energy_source==1
}
forv i = 1(1)4 {
	egen oil_`i' = sum(uniquetrancheid) if borrowertype2 == `i' & energy_source==2
}
forv i = 1(1)4 {
	egen gas_`i' = sum(uniquetrancheid) if borrowertype2 == `i' & energy_source==3
}
forv i = 1(1)4 {
	egen wind_`i' = sum(uniquetrancheid) if borrowertype2 == `i' & energy_source==5
}
forv i = 1(1)4 {
	egen solar_`i' = sum(uniquetrancheid) if borrowertype2 == `i' & energy_source==6
}
forv i = 1(1)4 {
	egen other_rets_`i' = sum(uniquetrancheid) if borrowertype2 == `i' & energy_source==7
}
forv i = 1(1)4 {
	egen grid_`i' = sum(uniquetrancheid) if borrowertype2 == `i' & energy_source==9
}

graph hbar (sum) coal_1-coal_3 oil_1-oil_3 gas_1-gas_3 wind_1-wind_3 solar_1-solar_3 ///
other_rets_1-other_rets_3 grid_1-grid_3, over(energy_source) percentage stack ///
bar(1, color("237 248 251") lc(black) lw(vthin) lstyle(solid)) ///
bar(2, color("179 205 227") lc(black) lw(vthin) lstyle(solid)) ///
bar(3, color("136 65 157") lc(black) lw(vthin) lstyle(solid)) ///
bar(4, color("237 248 251") lc(black) lw(vthin) lstyle(solid)) ///
bar(5, color("179 205 227") lc(black) lw(vthin) lstyle(solid)) ///
bar(6, color("136 65 157") lc(black) lw(vthin) lstyle(solid)) ///
bar(7, color("237 248 251") lc(black) lw(vthin) lstyle(solid)) ///
bar(8, color("179 205 227") lc(black) lw(vthin) lstyle(solid)) ///
bar(9, color("136 65 157") lc(black) lw(vthin) lstyle(solid)) ///
bar(10, color("237 248 251") lc(black) lw(vthin) lstyle(solid)) ///
bar(11, color("179 205 227") lc(black) lw(vthin) lstyle(solid)) ///
bar(12, color("136 65 157") lc(black) lw(vthin) lstyle(solid)) ///
bar(13, color("237 248 251") lc(black) lw(vthin) lstyle(solid)) ///
bar(14, color("179 205 227") lc(black) lw(vthin) lstyle(solid)) ///
bar(15, color("136 65 157") lc(black) lw(vthin) lstyle(solid)) ///
bar(16, color("237 248 251") lc(black) lw(vthin) lstyle(solid)) ///
bar(17, color("179 205 227") lc(black) lw(vthin) lstyle(solid)) ///
bar(18, color("136 65 157") lc(black) lw(vthin) lstyle(solid)) ///
bar(19, color("237 248 251") lc(black) lw(vthin) lstyle(solid)) ///
bar(20, color("179 205 227") lc(black) lw(vthin) lstyle(solid)) ///
bar(21, color("136 65 157") lc(black) lw(vthin) lstyle(solid)) ///
yla(, angle(0)) legend(order(1 "Special purpose vehicle" 2 "Other private" 3 "Public") r(1) ///
size(small) symxsize(4) symysize(4) region(lp(blank))) ///
intensity(*0.7) graphregion(color(white)) ytitle("") 
graph save bt, replace
graph export "graphs/Fig4_4_final.png", replace
	lab var energy_source "Energy source"
	lab var borrowertype2 "Borrower type"
	lab var uniquetrancheid "Sum of unqiue tranches"
export excel energy_source borrowertype2 uniquetrancheid using "Sourcefile.xlsx", sheet("Fig 4", modify) cell(M2) firstrow(variables)
restore 


* Tranche structure 

preserve 
keep if inlist(energy_source, 1, 2, 3, 5, 6, 7, 9)
egen tag = tag(uniquetrancheid)
keep if tag == 1 
gen fintype = 0 
replace fintype = 1 if inlist(tranchestructure, "ECA-backed buyer credit", "ECA-backed buyer credit (DCM)")
replace fintype = 2 if inlist(tranchestructure, "ECA-backed supplier credit", "ECA-Backed Islamic Finance", "ECA-backed  general purpose LOC", "ECA-backed performance bond", "ECA-Direct Loan") 
replace fintype = 3 if inlist(tranchestructure, "DFI/MDB Direct Loan", "DFI/MDB-backed Loan")
replace fintype = 4 if !inlist(fintype, 1, 2, 3) 

label define fin_type 1 "ECA-backed loans (via guarantees)" 2 "Other ECA instruments (e.g., loans)" 3 "Other public"  4 "Other private"

label values fintype fin_type

collapse (count) uniquetrancheid, by(energy_source fintype)
forv i = 1(1)4 {
	egen coal_`i' = sum(uniquetrancheid) if fintype == `i' & energy_source==1
}
forv i = 1(1)4 {
	egen oil_`i' = sum(uniquetrancheid) if fintype == `i' & energy_source==2
}
forv i = 1(1)4 {
	egen gas_`i' = sum(uniquetrancheid) if fintype == `i' & energy_source==3
}
forv i = 1(1)4 {
	egen wind_`i' = sum(uniquetrancheid) if fintype == `i' & energy_source==5
}
forv i = 1(1)4 {
	egen solar_`i' = sum(uniquetrancheid) if fintype == `i' & energy_source==6
}
forv i = 1(1)4 {
	egen other_rets_`i' = sum(uniquetrancheid) if fintype == `i' & energy_source==7
}
forv i = 1(1)4 {
	egen grid_`i' = sum(uniquetrancheid) if fintype == `i' & energy_source==9
}

graph hbar (sum) coal_1-coal_4 oil_1-oil_4 gas_1-gas_4 wind_1-wind_4 solar_1-solar_4 ///
other_rets_1-other_rets_4 grid_1-grid_4, over(energy_source, label(nolab)) percentage stack ///
bar(1, color("255 255 204") lc(black) lw(vthin) lstyle(solid)) ///
bar(2, color("161 218 180") lc(black) lw(vthin) lstyle(solid)) ///
bar(3, color(" 65 182 196") lc(black) lw(vthin) lstyle(solid)) ///
bar(4, color("44 127 184") lc(black) lw(vthin) lstyle(solid)) ///
bar(5, color("255 255 204") lc(black) lw(vthin) lstyle(solid)) ///
bar(6, color("161 218 180") lc(black) lw(vthin) lstyle(solid)) ///
bar(7, color(" 65 182 196") lc(black) lw(vthin) lstyle(solid)) ///
bar(8, color("44 127 184") lc(black) lw(vthin) lstyle(solid)) ///
bar(9, color("255 255 204") lc(black) lw(vthin) lstyle(solid)) ///
bar(10, color("161 218 180") lc(black) lw(vthin) lstyle(solid)) ///
bar(11, color(" 65 182 196") lc(black) lw(vthin) lstyle(solid)) ///
bar(12, color("44 127 184") lc(black) lw(vthin) lstyle(solid)) ///
bar(13, color("255 255 204") lc(black) lw(vthin) lstyle(solid)) ///
bar(14, color("161 218 180") lc(black) lw(vthin) lstyle(solid)) ///
bar(15, color(" 65 182 196") lc(black) lw(vthin) lstyle(solid)) ///
bar(16, color("44 127 184") lc(black) lw(vthin) lstyle(solid)) ///
bar(17, color("255 255 204") lc(black) lw(vthin) lstyle(solid)) ///
bar(18, color("161 218 180") lc(black) lw(vthin) lstyle(solid)) ///
bar(19, color(" 65 182 196") lc(black) lw(vthin) lstyle(solid)) ///
bar(20, color("44 127 184") lc(black) lw(vthin) lstyle(solid)) ///
bar(21, color("255 255 204") lc(black) lw(vthin) lstyle(solid)) ///
bar(22, color("161 218 180") lc(black) lw(vthin) lstyle(solid)) ///
bar(23, color(" 65 182 196") lc(black) lw(vthin) lstyle(solid)) ///
bar(24, color("44 127 184") lc(black) lw(vthin) lstyle(solid)) ///
bar(25, color("255 255 204") lc(black) lw(vthin) lstyle(solid)) ///
bar(26, color("161 218 180") lc(black) lw(vthin) lstyle(solid)) ///
bar(27, color(" 65 182 196") lc(black) lw(vthin) lstyle(solid)) ///
bar(28, color("44 127 184") lc(black) lw(vthin) lstyle(solid)) ///
yla(, angle(0)) legend(order(1 "ECA-backed loans (via guarantees)" 2 "Other ECA instruments (e.g., loans)" ///
3 "Other public (e.g., MDBs)" 4 "Other private (e.g., term loans)") ///
r(3) ///
size(small) symxsize(4) symysize(4) region(lp(blank))) ///
intensity(*0.7) graphregion(color(white)) ytitle("") 
graph save tranche_type, replace
graph export "graphs/Fig4_5_final.png", replace
	lab var energy_source "Energy source"
	lab var fintype "Financial instrument type"
	lab var uniquetrancheid "Sum of unique tranches"
export excel energy_source fintype uniquetrancheid using "Sourcefile.xlsx", sheet("Fig 4", modify) cell(Q2) firstrow(variables)
restore 


*** Caption Fig-. 4

*** Number of deals 
preserve 
keep if inlist(energy_source, 1, 2, 3, 5, 6, 7, 9)
codebook tmddealid
restore 

*** Number of tranches  
preserve 
keep if inlist(energy_source, 1, 2, 3, 5, 6, 7, 9)
egen tag = tag(uniquetrancheid)
codebook tag
keep if tag == 1 // only keep unique tranches 
codebook tmddealid
codebook uniquetrancheid
restore 

*** Figure caption 
*** Borrower types (omitted category 'Other')  
preserve 
keep if inlist(energy_source, 1, 2, 3, 5, 6, 7, 9)
tab borrowertype if !inlist(borrowertype, "SPV", "Private company", ///
"Government owned company", "Listed company", "Government") & ///
!inlist(borrowertype, "MFI/DFI", "Financial institution", "Investment Manager", ///
"ECA", "Public Private partnership") // only type 'other'
codebook tmddealid if !inlist(borrowertype, "SPV", "Private company", ///
"Government owned company", "Listed company", "Government") & ///
!inlist(borrowertype, "MFI/DFI", "Financial institution", "Investment Manager", ///
"ECA", "Public Private partnership") // 3 deals 
codebook uniquetrancheid if !inlist(borrowertype, "SPV", "Private company", ///
"Government owned company", "Listed company", "Government") & ///
!inlist(borrowertype, "MFI/DFI", "Financial institution", "Investment Manager", ///
"ECA", "Public Private partnership") // 5 tranches 
restore 

*** Financial instruments
preserve 
keep if inlist(energy_source, 1, 2, 3, 5, 6, 7, 9)
egen tag = tag(uniquetrancheid)
keep if tag == 1 
gen fintype = 0 
replace fintype = 1 if inlist(tranchestructure, "ECA-backed buyer credit", "ECA-backed buyer credit (DCM)")
replace fintype = 2 if inlist(tranchestructure, "ECA-backed supplier credit", "ECA-Backed Islamic Finance", "ECA-backed  general purpose LOC", "ECA-backed performance bond", "ECA-Direct Loan") 
replace fintype = 3 if inlist(tranchestructure, "DFI/MDB Direct Loan", "DFI/MDB-backed Loan")
replace fintype = 4 if !inlist(fintype, 1, 2, 3) 
tab tranchestructure if fintype == 2
tab tranchestructure if !inlist(fintype, 1, 2, 3) // large majority are term loans 
tab tranchestructure if inlist(tranchestructure, "ECA-backed supplier credit", "ECA-Backed Islamic Finance", "ECA-backed  general purpose LOC", "ECA-backed performance bond", "ECA-Direct Loan") // see percentages
tab tranchestructure if inlist(tranchestructure, "DFI/MDB Direct Loan", "DFI/MDB-backed Loan")
restore 
