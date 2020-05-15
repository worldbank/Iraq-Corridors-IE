* Create Dataset of Household Survey with Key Variables
* Iraq IE

* Filepaths --------------------------------------------------------------------
global filepath "C:/Users/wb521633/Dropbox/World Bank/IEs/Iraq IE"

* Prep HH Data Modules ---------------------------------------------------------
use "$filepath/Data/RawData/LSMS/IRQ_2012_IHSES_v01_M_Stata8/2012ihses00_cover_page.dta", clear
	rename q00_18 latitude
	rename q00_19 longitude
	keep cluster hh latitude longitude governorate qhada stratum weight weight_s7_adult weight_s21 weight_s24 
	tempfile cover_page
	save `cover_page'
	
use "$filepath/Data/RawData/LSMS/IRQ_2012_IHSES_v01_M_Stata8/2012ihses21_time_use.dta", clear
	gen minutes_work_commute = q2102_d_h*60 + q2102_d_m
	gen minutes_school_commute = q2102_f_h*60 + q2102_f_m
	
	collapse (mean) minutes_work_commute minutes_school_commute, by(hh cluster )
	
	tempfile commute_time
	save `commute_time'
	
use "$filepath/Data/RawData/LSMS/IRQ_2012_IHSES_v01_M_Stata8/2012ihses12_p1_diary_expenditure.dta", clear
	rename q1203 expenditure
	rename q1204 main_source
	rename hsize hh_size

	keep if main_source == 1
	
	collapse (sum) expenditure (mean) hh_size, by(cluster hh)
	
	tempfile expenditure
	save `expenditure'
	 
use "$filepath/Data/RawData/LSMS/IRQ_2012_IHSES_v01_M_Stata8/2012ihses23_life_satisfaction.dta", clear
	rename q2302_1 satis_food
	rename q2302_2 satis_housing
	rename q2302_3 satis_income
	rename q2302_4 satis_health
	rename q2302_5 satis_work
	rename q2302_6 satis_local_security
	rename q2302_7 satis_education
	rename q2302_8 satis_freedom_choice
	rename q2302_9 satis_control_over_life
	rename q2302_10 satis_trust_acc_comm
	rename q2302_11 satis_life_overall
	rename q2303 hh_situation

	foreach var of varlist satis_food-satis_life_overall{
		* Replace "Do not know/no answer" with blank observation
		replace `var' = . if `var' == 5
		replace `var' = 5 - `var' // convert to "satisfied index" (larger number = more satisfied)
	}
	*
	
	replace hh_situation = 5 - hh_situation

	keep cluster hh satis_food-hh_situation

	* Collapse to HH Level
	collapse (mean) satis_food-hh_situation, by(cluster hh)
	
	foreach var of varlist satis_food-hh_situation{
		replace `var' = round(`var')
	}
	*
	
	tempfile life_satisfaction
	save `life_satisfaction'
	
use "$filepath/Data/RawData/LSMS/IRQ_2012_IHSES_v01_M_Stata8/2012ihses04_housing.dta", clear
	rename q0442 min_income_needed

	keep cluster hh min_income_needed

	tempfile housing
	save `housing'
	
use "$filepath/Data/FinalData/LSMS/Individual Files/geodata.dta"

	tempfile geodata
	save `geodata'
	
* Merge Data -------------------------------------------------------------------
use `cover_page', clear
merge 1:1 cluster hh using `life_satisfaction', nogen
merge 1:1 cluster hh using `housing', nogen
merge 1:1 cluster hh using `geodata', nogen
merge 1:1 cluster hh using `commute_time', nogen
merge 1:1 cluster hh using `expenditure', nogen

* Export Data ------------------------------------------------------------------
save "$filepath/Data/FinalData/LSMS/lsms_2012_merged_hh.dta", replace

	
	
	
	

