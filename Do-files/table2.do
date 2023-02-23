**** Uses data after LassoClean to original dataset
use "$elearn/elearn_reg_data.dta", clear

unab prepped: _* 

local conditions_proj tooktest_el==1 
local conditions_pec took_std==1 

/**** 

Panel A Col 1-4 

***/


foreach outcome of varlist z_irt_total_el {
reg `outcome' treatment $partialled_proj $strata if `conditions_proj', cluster(school_code) 
outreg2 using panelA, replace dta label keep(treatment*)
}


foreach outcome of varlist z_scoreindex_el {
sum `outcome' if treatment==0 & `conditions_proj' & `conditions_pec'
local m_`outcome'=`r(mean)'
reg `outcome' treatment  $partialled_proj $partialled_pec $strata if `conditions_pec' & `conditions_proj', cluster(school_code) 
outreg2 using panelA, append dta label keep(treatment*) addstat(Control mean, `m_`outcome'')
}


/**** PEC SCORE OUTCOMES (not in dataset)
foreach outcome of varlist z_st_score_total  {
sum `outcome' if treatment==0 & `conditions_pec'
local m_`outcome'=`r(mean)'
reg `outcome' treatment $partialled_proj $partialled_pec $strata if `conditions_pec', cluster(school_code) 
outreg2 using panelA, append dta label keep(treatment*) addstat(Control mean, `m_`outcome'')
}

foreach outcome of varlist z_st_score_passlevel  {
sum `outcome' if treatment==0 & `conditions_pec'
local m_`outcome'=`r(mean)'
reg `outcome' treatment $partialled_proj $partialled_pec $strata if `conditions_pec', cluster(school_code) 
outreg2 using panelA, append dta label keep(treatment*) addstat(Control mean, `m_`outcome'')
}
*/

/**** 

Panel B Col 1-4 

***/



foreach outcome of varlist z_irt_total_el {
pdslasso `outcome' treatment (`prepped' $strata ) if `conditions_proj', partial($strata $partialled_proj) cluster(school_code) 
outreg2 using PanelB, replace dta label keep(treatment*) 
}



foreach outcome of varlist  z_scoreindex_el {
pdslasso `outcome' treatment (`prepped' $strata ) if `conditions_proj' & `conditions_pec', partial($strata $partialled_proj $partialled_pec) cluster(school_code) 
outreg2 using PanelB, append dta label keep(treatment*) 
}


/**** PEC SCORE OUTCOMES (not in dataset)

foreach outcome of varlist z_st_score_total  {
sum `outcome' if treatment==0 & `conditions_pec'
local m_`outcome'=`r(mean)'
pdslasso `outcome' treatment (`prepped' $strata ) if `conditions_pec', partial($strata $partialled_proj $partialled_pec) cluster(school_code) 
outreg2 using PanelB, append dta label keep(treatment*) addstat(Control mean, `m_`outcome'')
}
foreach outcome of varlist z_st_score_passlevel {
sum `outcome' if treatment==0 & `conditions_pec'
local m_`outcome'=`r(mean)'
pdslasso `outcome' treatment (`prepped' $strata ) if `conditions_pec', partial($strata $partialled_proj $partialled_pec) cluster(school_code) 
outreg2 using PanelB, append dta label keep(treatment*) addstat(Control mean, `m_`outcome'')
}
*/

/**** 

Panel A Col 5 

***/

use "$tablets/elearn_tablets_reg_data.dta", clear

unab prepped: _* 
local conditions tooktest_el==1

foreach outcome of varlist  z_score_total_el  {

reg `outcome' treatment $strata $partialled_tablet if `conditions',cluster(school_code) 
outreg2 using PanelA, append dta label keep(treatment*) 

}


/**** 

Panel B Col 5 

***/


foreach outcome of varlist  z_score_total_el {

pdslasso `outcome' treatment (`prepped' $strata ) if `conditions', partial($strata $partialled_tablet) cluster(school_code) 
outreg2 using PanelB, append dta label keep(treatment*) 
}




	
	foreach f in panelA panelB {
	use `f'_dta, clear
	export excel using "$pap_tab/table2" , sheet("`f'", replace)
	cap rm `f'_dta.dta
	cap rm `f'.txt
	}
	
