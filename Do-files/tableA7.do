**** Uses data after LassoClean to original dataset
use "$elearn/elearn_reg_data.dta", clear

unab prepped: _* 

local conditions_proj tooktest_el==1 
local conditions_pec took_std==1 

	cap rm "tableA7_dta.dta"
	cap rm "tableA7.txt"

******** BY DIFFICULTY 
foreach outcome of varlist z_irt_diff*_el {
pdslasso `outcome' treatment (`prepped' $strata ) if `conditions_proj', partial($strata $partialled_proj) cluster(school_code) 
outreg2 using tableA7, append dta label keep(treatment*) 
}	


	foreach f in tableA7 {
	use `f'_dta, clear
	export excel using "$app_tab/tableA7" , sheet("`f'", replace)
	cap rm "`f'_dta.dta"
	cap rm "`f'.txt"
	}
	
	
	

