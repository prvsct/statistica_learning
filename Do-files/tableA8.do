**** Uses data after LassoClean to original dataset
use "$elearn/elearn_reg_data.dta", clear

unab prepped: _* 

local conditions_pec took_std==1 


pdslasso z_scoreindex_el treatment c.treatment#c.inexperieced_any  (`prepped' $strata inexperieced_any) if `conditions_pec', partial($strata $partialled_pec $partialled_proj inexperieced_any) cluster(school_code) 
test treatment+c.treatment#c.inexperieced_any=0
outreg2 using tableA8, replace dta label keep(treatment c.treatment#c.inexperieced_any) addstat(pvalue, `r(p)')


pdslasso z_scoreindex_el treatment c.treatment#c.peers c.treatment#c.t_missing (`prepped' $strata peers t_missing) if `conditions_pec', partial($strata $partialled_pec $partialled_proj peers t_missing) cluster(school_code) 
outreg2 using tableA8, append dta label keep(treatment c.treatment#c.peers)


	foreach f in tableA8 {
	use `f'_dta, clear
	export excel using "$app_tab/tableA8" , sheet("`f'", replace)
	cap rm "`f'_dta.dta"
	cap rm "`f'.txt"
	}





	

