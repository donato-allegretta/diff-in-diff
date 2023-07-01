clear all

import delimited "C:\Users\donat\OneDrive\Desktop\Tesi\final_dataset.csv
//import delimited "C:\Users\donat\OneDrive\Desktop\Tesi\solar.csv
//import delimited "C:\Users\donat\OneDrive\Desktop\Tesi\wind.csv
//import delimited "C:\Users\donat\OneDrive\Desktop\Tesi\ccgt.csv
//import delimited "C:\Users\donat\OneDrive\Desktop\Tesi\bioenergy.csv
//import delimited "C:\Users\donat\OneDrive\Desktop\Tesi\conventional_steam.csv
//import delimited "C:\Users\donat\OneDrive\Desktop\Tesi\ocgt.csv
//drop if stationname != "Beckburn"
//drop if strpos(county,"YORKSHIRE") == 0

//create the identifier for each property and for postcode
egen newid = group(postcode paon saon street locality city district county), missing
egen postcode_id = group(postcode)
//egen street_id = group(street locality city district county), missing
//egen county_id = group(county)

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

//mean values by postcodes for day
collapse (mean) ln_price price detached semidetached terraced flat other new leasehold, by(postcode_id km stationname companyname technology capacitymw year_powerplant date_house year_house)


//collapse (mean) ln_price price detached semidetached terraced flat other new leasehold, by(postcode_id county_id km stationname companyname technology capacitymw year_powerplant date_house year_house)
//collapse (mean) ln_price price detached semidetached terraced flat other new leasehold km, by(street_id stationname companyname technology capacitymw year_powerplant date_house year_house)
//collapse (mean) ln_price price detached semidetached terraced flat other new leasehold, by(postcode_id km stationname companyname technology capacitymw year_powerplant year_house)

//duplicates drop postcode_id date_house, force

//Create a dummy variable to indicate the time when the treatment started.
gen time = (year_house >= year_powerplant)
//Create a dummy variable to identify the group exposed to the treatment.
gen treated = (km <= 3)
//generate treated = 0 if km > 10
//replace treated = 1 if km <= 3
//replace treated = . if missing(treated)

//gen treated = (km <= 2)
//gen treated = (km <= 4)
//gen treated = (km <= 8)
gen did = time*treated //interaction term
tabulate did

drop if year_house != 2008
tabulate treated, summarize(price)
tab treated
drop did
drop treated
/*
tabulate year_house, summarize(postcode_id)
tabulate treated, summarize(price)
tabulate treated, summarize(detached)
tabulate treated, summarize(semidetached)
tabulate treated, summarize(terraced)
tabulate treated, summarize(flat)
tabulate treated, summarize(other)

reg ln_price time treated did, vce(cluster postcode_id)
reg ln_price time treated did semidetached terraced flat other new leasehold
reg ln_price km semidetached terraced flat other new leasehold
diff ln_price, t(treated) p(time) 
diff ln_price, t(treated) p(time) cov(semidetached terraced flat other new leasehold) report
diff ln_price, t(treated) p(time) cov(semidetached terraced flat other new leasehold) test
*/

//drop if capacitymw > 50
//drop if capacitymw <= 50 | capacitymw > 100
//drop if capacitymw <= 100 | capacitymw > 250
//drop if capacitymw <= 250 | capacitymw > 400
//drop if capacitymw <= 400 | capacitymw > 1000
//drop if capacitymw <= 1000

//bysort postcode_id (year_house): egen tokeep = max(year_house == 2000)
//keep if tokeep
//drop if year_house < 2000
//egen wanted = total(inrange(year_house, 2000, 2020)), by(postcode_id)
//drop if wanted != 21

//PANEL
//xtset postcode_id year_house
xtset postcode_id date_house
//xtset street_id date_house

didregress (ln_price) (did), group(postcode_id) time(date_house) vce(cluster postcode_id)
reg ln_price time treated did, vce(cluster postcode_id)

xtreg ln_price time treated did, fe vce(cluster postcode_id)
xtreg ln_price time treated did i.year_house, fe vce(cluster postcode_id)



xtreg ln_price time treated did semidetached terraced flat other new leasehold i.year_house, fe vce(cluster postcode_id)
xtreg ln_price time did semidetached terraced flat other new leasehold i.year_house, fe vce(cluster street_id)

xtreg ln_price time treated did semidetached terraced flat other new leasehold i.year_house i.county_id, fe vce(cluster postcode_id)
xtreg ln_price time treated did semidetached terraced flat other new leasehold i.year_house treated##c.year_house, fe vce(cluster postcode_id)
xtreg ln_price time treated did semidetached terraced flat other new leasehold i.year_house c.year_house##i.county_id, fe vce(cluster postcode_id)

xtreg ln_price time treated did semidetached terraced flat other new leasehold treated##c.year_house, fe vce(cluster postcode_id)

estimates store fe
xtreg ln_price time treated did semidetached terraced flat other new leasehold, re vce(cluster postcode_id)
estimates store re
hausman fe re

vif, uncentered
corr

reg ln_price time treated did, vce(cluster postcode_id)
outreg2 using didregressions.doc, replace ctitle(basic)



xtlogit detached treated time did i.year_house, fe
xtlogit semidetached treated time did, fe
xtlogit terraced treated time did i.year_house, fe
xtlogit flat treated time did i.year_house, fe
xtlogit leasehold treated time did i.year_house, fe
xtlogit new treated time did i.year_house, fe



by postcode_id , sort: generate y = _n == 1
tabulate y if km <= 1
tabulate y if km <= 2
tabulate y if km <= 3
tabulate y if km <= 4
tabulate y if km <= 8
tabulate y if km <= 15
drop y


collapse (mean) ln_price, by(year_house treated)
twoway (line ln_price year_house if treated==1) (line ln_price year_house if treated==0), xline(2011) legend(label(1 Treated) label(2 Control))

gen howmanytrans = 1
collapse (sum) howmanytrans (mean) detached semidetached terraced flat other new leasehold, by(postcode_id km stationname companyname technology capacitymw year_powerplant year_house)
gen time = (year_house >= year_powerplant)
gen treated = (km <= 3)
gen did = time*treated
reg howmanytrans time treated did, vce(cluster postcode_id)
reg howmanytrans time treated did semidetached terraced flat other new leasehold, vce(cluster postcode_id)
reg howmanytrans time treated did semidetached terraced flat other new leasehold i.year_house, vce(cluster postcode_id)
xtset postcode_id year_house
xtreg howmanytrans time treated did semidetached terraced flat other new leasehold i.year_house, fe vce(cluster postcode_id)
