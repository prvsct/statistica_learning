 
capture log close
capture clear mata
drop _all
set more off

set matsize 1000
capture clear matrix
set maxvar 32767


#delimit;
	
use "pmiu_attendancedata.dta", clear; 	
ren emis emiscode;
ren school_name_el school;
** match data to old emis codes;

************************** 

*** CODE OMMMITED (USES PII)

*************************

merge m:1 school using "treatmentstatus.dta";

keep if _m==3;
bysort school_code Visited_Date: gen dup=_n; 
tab dup;
drop dup;

gen month=month(Visited_Date);
gen year=year(Visited_Date);

gen monyear=ym(year,month);
format monyear %tmMCY;
keep if year>=2015;
drop if month<=2 & year==2015;
drop if year>=2018; 
egen strata=group(city gender);

foreach v of varlist *_Presence {;
replace `v'=`v'/100;
};


tempfile monthly_attendance;
save `monthly_attendance', replace; 



use "elearn_school_lassoClean.dta", clear;


bysort school_code: g dup=_n ;
keep if dup==1;
keep school_code _*;

merge 1:m school_code using `monthly_attendance';
drop _merge;
reshape wide Teacher_Presence Student_Presence Functioning_Of_Facilities School_Cleanliness Non_Teacher_Presence Admin_Visits DTE_Visits, i(school_code month) j(after);

bysort school_code: egen avg_Teacher_Presence0=mean(Teacher_Presence0);
gen Teacher_Presence0_nm= Teacher_Presence0;
*bysort month: egen mean_Teacher_Presence0=mean(Teacher_Presence0);
replace Teacher_Presence0_nm= avg_Teacher_Presence0 if Teacher_Presence0==.;
gen Teacher_Presence0_dum= Teacher_Presence0==.;


gen Rollout=(month==10 | month==11 | month==12 | month==1 | month==2); 
label var Rollout "Post Rollout";
gen monthsincetr=0 if month==10;
replace monthsincetr=1 if month==11;
replace monthsincetr=2 if month==12;
replace monthsincetr=3 if month==1;
replace monthsincetr=4 if month==2;
replace monthsincetr=0 if monthsincetr==.;

*** interactions ;
gen TrxRollout = Rollout*TREATMENTSCHOOL;
gen Trxmonthsincetr = monthsincetr*TREATMENTSCHOOL;
label var Trxmonthsincetr "Treatment x Months after Intervention";
label var TrxRollout "Treatment x Post Rollout";
gen TrxRolloutxmonthsincetr = Rollout*TREATMENTSCHOOL*monthsincetr;
label var TrxRolloutxmonthsincetr "Treatment x Post Rollout x Months since Rollout";
label var TREATMENTSCHOOL "Treatment";
gen Rolloutxmonthsincetr = Rollout*monthsincetr;

qui tab strata, gen(strataFE);
qui tab month, gen(monthFE);


keep if Rollout==1;

save "elearn_reg_data_teacherattendance", replace;

	
	
	
	
