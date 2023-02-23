 
capture log close
capture clear mata
drop _all


set more off

set matsize 1000
capture clear matrix
set maxvar 32767
\
import excel "pmiu_attendence_tablets.xlsx", sheet("Sheet1") firstrow clear	


gen month=month(visited_date)
gen year=year(visited_date)

gen monyear=ym(year,month)
format monyear %tmMCY
keep if year>=2015
drop if month<=2 & year==2015
drop if year>=2018 

tostring School_EMIS, replace 
tempfile monthly_attendance
save `monthly_attendance', replace

 

use "tablet_analysis_merged_lassoClean.dta", clear

bysort School_EMIS: g dup=_n 
keep if dup==1
keep School_EMIS _sch_* _school_* _ht_* _t_* _district* treatment strata

merge 1:m School_EMIS using `monthly_attendance'
drop _merge
reshape wide teacher_presence student_presence, i(School_EMIS month) j(after)

bysort School_EMIS: egen avg_teacher_presence0=mean(teacher_presence0)
gen teacher_presence0_nm= teacher_presence0

replace teacher_presence0_nm= avg_teacher_presence0 if teacher_presence0==.
gen teacher_presence0_dum= teacher_presence0==.


gen Rollout=(month==12 | month==1 | month==2)
label var Rollout "Post Rollout"
gen monthsincetr=0 if month==12
replace monthsincetr=1 if month==1
replace monthsincetr=2 if month==2
replace monthsincetr=0 if monthsincetr==.

*** interactions
gen TrxRollout = Rollout*treatment
gen Trxmonthsincetr = monthsincetr*treatment
label var Trxmonthsincetr "Treatment x Months after Intervention"
label var TrxRollout "Treatment x Post Rollout"
gen TrxRolloutxmonthsincetr = Rollout*treatment*monthsincetr
label var TrxRolloutxmonthsincetr "Treatment x Post Rollout x Months since Rollout"
label var treatment "Treatment"
gen Rolloutxmonthsincetr = Rollout*monthsincetr

qui tab strata, gen(strataFE)
qui tab month, gen(monthFE)


destring School_EMIS, replace
ren School_EMIS school_code 
keep if Rollout==1

save "elearn_tablets_reg_data_teacherattendance", replace 
	

	
	
	
	
	
	
