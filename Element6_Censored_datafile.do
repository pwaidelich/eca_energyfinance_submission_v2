*** BEFORE RUN: --> change the current directory in the line below to the highest repository level and ensure that user-written STATA commands are installed (see README)

clear all 

*** Set the working directory
cd "C:/Users/pwaidelich/Downloads/GitHub - Local/eca_energyfinance"

use "data/current_working_file_July24.dta"

*** censor key identifiers
     
replace dealtitle = "XXX"
replace description = "XXX"
replace borrower = "XXX"
replace exporter = "XXX"
replace lendername = "XXX"
replace lendercountry = "XXX"


*** shuffle key values at random 

ssc install shufflevar

shufflevar tmddealid closingdate dealcountry uniquetrancheid ecaname ecacountry

drop tmddealid closingdate dealcountry uniquetrancheid ecaname ecacountry

ren tmddealid_shuffled tmddealid
ren closingdate_shuffled closingdate
ren dealcountry_shuffled dealcountry
ren uniquetrancheid_shuffled uniquetrancheid
ren ecaname_shuffled ecaname 
ren ecacountry_shuffled ecacountry

order tmddealid closingdate dealcountry uniquetrancheid ecaname ecacountry, after(c)


bys tmddealid: gen u = runiform() if _n == 1
bys tmddealid: egen uu = total(u)
keep if uu < .1 // keep a random 10% of observations 
drop u uu

save "data/TXF_data_censored.dta", replace

