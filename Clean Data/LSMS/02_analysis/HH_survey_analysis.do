* HH Survey Analysis
* Iraq IE

* Filepaths --------------------------------------------------------------------
global filepath "/Users/robmarty/Dropbox/Iraq IE"

* Load Data --------------------------------------------------------------------
use "$filepath/Data/LSMS/LSMS 2012 Merged/lsms_2012_merged_hh.dta", clear

* Population Along Expressway --------------------------------------------------

gen weight_hhsize = weight*hh_size

sum weight_hhsize if dist_road_r7_r8ab <= 10
di `r(N)' * `r(mean)'

* Correlation Between NTL and Economic Variables -------------------------------
gen num_hh = 1
collapse (sum) viirs_2012 viirs_2013 viirs_2014 viirs_2015 viirs_2016 viirs_2017 ///
                expenditure weight_hhsize weight num_hh /// 
		 (mean) satis_food satis_housing satis_income satis_health satis_work /// 
		        satis_local_security satis_education satis_freedom_choice /// 
				satis_control_over_life satis_trust_acc_comm satis_life_overall ///
				hh_situation min_income_needed expenditure_avg=expenditure, by(NAME_2)
				
drop if NAME_2 == ""
rename NAME_2 name_2	

tempfile hhdata_adm2
save `hhdata_adm2'

* Merge in VIIRS from Geoquery
import delimited "$filepath/Data/Geoquery/geoquery_ntl_adm2.csv", clear
rename v5 viirs_2012_sum
rename v6 viirs_2012_mean
rename v7 viirs_2012_max
rename v8 viirs_2013_sum
rename v9 viirs_2013_mean
rename v10 viirs_2013_max
keep name_2 viirs_2012_sum-viirs_2013_max
merge 1:1 name_2 using `hhdata_adm2'
keep if _merge == 3
drop _merge

* Prep Variables
gen viirs_2013_mean_ln = ln(viirs_2013_mean+1)
gen viirs_2013_max_ln = ln(viirs_2013_max+1)

gen expend_total = (expenditure/num_hh) * weight

* Correlation
pwcorr viirs_2013_mean_ln weight_hhsize, sig
pwcorr viirs_2013_mean_ln expend_total, sig
pwcorr viirs_2013_mean_ln min_income_needed, sig


xx


cor viirs_2013_max_ln weight_hhsize


cor viirs_2013_mean_ln expenditure
cor viirs_2013_max_ln expenditure

cor viirs_2013_mean_ln expend_total
cor viirs_2013_max_ln expend_total


