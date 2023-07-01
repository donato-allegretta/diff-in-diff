
clear all

import delimited "C:\Users\donat\OneDrive\Desktop\Tesi\final_dataset.csv
//drop if stationname != "Middlemoor"

//create the identifier for each property and for postcode
egen newid = group(postcode paon saon street locality city district county), missing
egen postcode_id = group(postcode)

gen dh = clock(date, "YMDhm") //make date as a variable
gen date_house = dofc(dh) + 1
format date_house %td
gen year_house = year(date_house)
rename year year_powerplant
format year_powerplant %ty
format year_house %ty

//not taking into account the additional price entry and duplicates by 2 or more plants in the same radius
duplicates drop newid date_house, force

gen ln_price = ln(price) // log of price

//dummies for property types, newly built houses, and leasehold
gen detached = (property_type == "D")
gen semidetached = (property_type == "S")
gen terraced = (property_type == "T")
gen flat = (property_type == "F")
gen other = (property_type == "O")
gen new = (oldnew == "Y")
gen leasehold = (duration == "L")


//mean values by postcodes for 
collapse (mean) ln_price detached semidetached terraced flat other new leasehold, by(postcode_id km stationname companyname technology capacitymw year_powerplant date_house year_house)


gen ccgt =(technology == "CCGT")
gen ocgt =(technology == "OCGT")
gen wind_on =(technology == "Wind (Onshore)")
gen solar =(technology == "Solar")
gen bioenergy =(technology == "Bioenergy")
gen conventional_steam =(technology == "Conventional Steam")

//Create a dummy variable to indicate the time when the treatment started.
gen time = (year_house >= year_powerplant)

//Create a dummy variable to identify the group exposed to the treatment.
//gen treated = (km <= 3)

generate treated = 0 if km > 10
replace treated = 1 if km <= 3
replace treated = . if missing(treated)

gen did = time*treated //interaction term
tabulate did

reg ln_price time treated did, vce(robust)
reg ln_price time treated did semidetached terraced flat other new leasehold ocgt wind_on solar bioenergy conventional_steam
reg ln_price km semidetached terraced flat other new leasehold ocgt wind_on solar bioenergy conventional_steam


diff ln_price, t(treated) p(time) 
diff ln_price, t(treated) p(time) cov(semidetached terraced flat other new leasehold ocgt wind_on solar bioenergy conventional_steam) report
diff ln_price, t(treated) p(time) cov(semidetached terraced flat other new leasehold ocgt wind_on solar bioenergy conventional_steam) test

//collapse (mean) ln_price, by(year_house treated)
//twoway (line ln_price year_house if treated==1) (line ln_price year_house if treated==0), xline(2004) legend(label(1 Treated) label(2 Control))

//PANEL

xtset postcode_id date_house

xtreg ln_price time treated did semidetached terraced flat other new leasehold ocgt wind_on solar bioenergy conventional_steam, fe
estimates store fe
xtreg ln_price time treated did semidetached terraced flat other new leasehold ocgt wind_on solar bioenergy conventional_steam, re
estimates store re
hausman fe re


//mixed ln_price time##i.year_house || postcode_id: time if year_house < year_powerplant, vce(robust) reml


