**** Uses data after LassoClean to original dataset
use "$elearn/elearn_reg_data.dta", clear

unab prepped: _* 

/**** 

Col 1-4 

***/


cap rm attrition_dta.dta
cap rm attrition.txt


foreach outcome of varlist tooktest_el took_std_matched {
sum `outcome' if treatment==0
local m_`outcome'=`r(mean)'
pdslasso `outcome' treatment (`prepped' $strata ) , partial($strata $partialled_proj) cluster(school_code) 
outreg2 using attrition, append dta label keep(treatment*) addstat(Control mean, `m_`outcome'')

pdslasso `outcome' treatment treatmentXBLScore (`prepped' $strata ) , partial($strata _z_irt_total_bl) cluster(school_code) 
outreg2 using attrition, append dta label keep(treatment*) 
}
 

/**** 

Col 5-6 

***/
use "$tablets/elearn_tablets_reg_data.dta", clear

unab prepped: _* 
	

foreach outcome of varlist  tooktest_el  {
sum `outcome' if treatment==0
local m_`outcome'=`r(mean)'
pdslasso `outcome' treatment (`prepped' $strata ) , partial($strata $partialled_tablet) cluster(school_code) 
outreg2 using attrition, append dta label keep(treatment*) addstat(Control mean, `m_`outcome'')

pdslasso `outcome' treatment treatmentXBLScore  (`prepped' $strata ) , partial($strata _z_score_total_bl) cluster(school_code) 
outreg2 using attrition, append dta label keep(treatment*) 

}


	use attrition_dta, clear
	export excel using "$pap_tab/table3" , sheet("table3", replace)
	cap rm attrition_dta.dta
	cap rm attrition.txt

