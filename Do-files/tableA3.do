use "$elearn/elearn_reg_data.dta", clear

unab prepped: _* 

local conditions_proj tooktest_el==1 
local conditions_pec took_std==1 



/**** 

Panel A 

***/


pdslasso z_irt_math_el treatment (`prepped' $strata ) if `conditions_proj', partial($strata $partialled_proj) cluster(school_code) 
outreg2 using panelA, replace dta label keep(treatment*) 

pdslasso z_irt_sci_el treatment (`prepped' $strata ) if `conditions_proj', partial($strata $partialled_proj) cluster(school_code) 
outreg2 using panelA, append dta label keep(treatment*) 

/**** PEC SCORE OUTCOME (not in dataset)

foreach outcome of varlist z_st_score_math z_st_score_sci z_st_score_allother {
pdslasso `outcome' treatment (`prepped' $strata ) if `conditions_pec', partial($strata $partialled_proj $partialled_pec) cluster(school_code) 
outreg2 using panelA, append dta label keep(treatment*) 
}
*/

/**** 

Panel B 

***/

use "$tablets/elearn_tablets_reg_data.dta", clear

unab prepped: _* 
local conditions tooktest_el==1

pdslasso z_score_math_el treatment (`prepped' $strata ) if `conditions', partial($strata $partialled_tablet) cluster(school_code) 
outreg2 using panelB, replace dta label keep(treatment*) 

pdslasso z_score_sci_el treatment (`prepped' $strata ) if `conditions', partial($strata $partialled_tablet) cluster(school_code) 
outreg2 using panelB, append dta label keep(treatment*) 
	
foreach f in panelA panelB {
	use `f'_dta, clear
	export excel using "$app_tab/tableA3" , sheet("`f'", replace)
	cap rm `f'_dta.dta
	cap rm `f'.txt
}
	
