**** Uses data after LassoClean to original dataset
use "$elearn/elearn_reg_data.dta", clear

unab prepped: _* 

local conditions_proj tooktest_el==1 
local conditions_pec took_std==1 

/**** 

Col 1 -3

***/


foreach outcome of varlist  z_irt_total_el {

pdslasso `outcome' treatment trXz_score_total_bl_qFE2 trXz_score_total_bl_qFE3 trXz_score_total_bl_qFE4  (`prepped' $strata z_score_total_bl_qFE*) if `conditions_proj', partial($strata $partialled_proj z_score_total_bl_qFE*) cluster(school_code) 
test trXz_score_total_bl_qFE2+treatment=0
local pvalue2=r(p)
test trXz_score_total_bl_qFE3+treatment=0
local pvalue3=r(p)
test trXz_score_total_bl_qFE4+treatment=0
local pvalue4=r(p)
outreg2 using panelA, replace dta label keep(treatment* trX*) ///
addstat(pvalue (q2), `pvalue2', pvalue (q3), `pvalue3', pvalue (q4), `pvalue4')

pdslasso `outcome' treatment trXavg_total_score_qFE2 trXavg_total_score_qFE3 trXavg_total_score_qFE4  (`prepped' $strata avg_total_score_qFE*) if `conditions_proj', partial($strata $partialled_proj avg_total_score_qFE*) cluster(school_code) 
test trXavg_total_score_qFE2+treatment=0
local pvalue2=r(p)
test trXavg_total_score_qFE3+treatment=0
local pvalue3=r(p)
test trXavg_total_score_qFE4+treatment=0
local pvalue4=r(p)
outreg2 using panelB, replace dta label keep(treatment* trX*) ///
addstat( pvalue (q2), `pvalue2', pvalue (q3), `pvalue3', pvalue (q4), `pvalue4')

pdslasso `outcome' treatment treatmentXfemale (`prepped' $strata ) if `conditions_proj', partial($strata $partialled_proj) cluster(school_code) 
test treatment+treatmentXfemale=0
local pval=`r(p)'
outreg2 using panelC, replace dta label keep(treatment* trX*)  addstat( pvalue Female, `pval')

}


foreach outcome of varlist  z_scoreindex_el {



pdslasso `outcome' treatment trXz_score_total_bl_qFE2 trXz_score_total_bl_qFE3 trXz_score_total_bl_qFE4 (`prepped' $strata z_score_total_bl_qFE* ) if `conditions_proj' & `conditions_pec', partial($strata $partialled_proj $partialled_pec z_score_total_bl_qFE* ) cluster(school_code) 
test trXz_score_total_bl_qFE2+treatment=0
local pvalue2=r(p)
test trXz_score_total_bl_qFE3+treatment=0
local pvalue3=r(p)
test trXz_score_total_bl_qFE4+treatment=0
local pvalue4=r(p)

outreg2 using panelA, append dta label keep(treatment* trX* ) ///
addstat(pvalue (q2), `pvalue2', pvalue (q3), `pvalue3', pvalue (q4), `pvalue4')

pdslasso `outcome' treatment trXavg_total_score_qFE2 trXavg_total_score_qFE3 trXavg_total_score_qFE4 (`prepped' $strata avg_total_score_qFE* ) if `conditions_proj' & `conditions_pec', partial($strata $partialled_proj $partialled_pec avg_total_score_qFE* ) cluster(school_code) 
test trXavg_total_score_qFE2+treatment=0
local pvalue2=r(p)
test trXavg_total_score_qFE3+treatment=0
local pvalue3=r(p)
test trXavg_total_score_qFE4+treatment=0
local pvalue4=r(p)
outreg2 using panelB, append dta label keep(treatment* trX* ) ///
addstat(pvalue (q2), `pvalue2', pvalue (q3), `pvalue3', pvalue (q4), `pvalue4')


pdslasso `outcome' treatment treatmentXfemale (`prepped' $strata ) if `conditions_proj' & `conditions_pec', partial($strata $partialled_proj $partialled_pec) cluster(school_code) 
test treatment+treatmentXfemale=0
local pval=`r(p)'
outreg2 using panelC, append dta label keep(treatment*) addstat(pvalue Female, `pval')


}


/**** 

Col 4 

***/


use "$tablets/elearn_tablets_reg_data.dta", clear

unab prepped: _* 
local conditions tooktest_el==1



foreach outcome of varlist  z_score_total_el {



pdslasso `outcome' treatment trXz_score_total_bl_qFE2 trXz_score_total_bl_qFE3 trXz_score_total_bl_qFE4  (`prepped' $strata z_score_total_bl_qFE*) if `conditions', partial($strata $partialled_tablet z_score_total_bl_qFE*) cluster(school_code) 
test treatment+trXz_score_total_bl_qFE2 =0
local pvalue2=r(p)
test treatment+trXz_score_total_bl_qFE3 =0
local pvalue3=r(p)
test treatment+trXz_score_total_bl_qFE4 =0
local pvalue4=r(p)

outreg2 using panelA, append dta label keep(treatment* trX* ) ///
addstat(pvalue (q2), `pvalue2', pvalue (q3), `pvalue3', pvalue (q4), `pvalue4')



pdslasso `outcome'  treatment trXavg_total_score_qFE2 trXavg_total_score_qFE3 trXavg_total_score_qFE4 (`prepped' $strata avg_total_score_qFE*) if `conditions', partial($strata $partialled_tablet avg_total_score_qFE*) cluster(school_code) 
test treatment+trXavg_total_score_qFE2=0
local pvalue2=r(p)
test treatment+trXavg_total_score_qFE3=0
local pvalue3=r(p)
test treatment+trXavg_total_score_qFE4=0
local pvalue4=r(p)
outreg2 using panelB, append dta label keep(treatment* trX* ) ///
addstat(pvalue (q2), `pvalue2', pvalue (q3), `pvalue3', pvalue (q4), `pvalue4')

pdslasso `outcome' treatment treatmentXfemale (`prepped' $strata female) if `conditions', partial($strata $partialled_tablet female) cluster(school_code) 
test treatment+treatmentXfemale=0
local pval=`r(p)'
outreg2 using panelC, append dta label keep(treatment*) addstat(pvalue Female, `pval')



}




foreach f in panelA panelB panelC {
	use `f'_dta, clear
	export excel using "$app_tab/tableA6" , sheet("`f'", replace)
	cap rm `f'_dta.dta
	cap rm `f'.txt
}
	
