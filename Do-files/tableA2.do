**** Uses data after LassoClean to original dataset
use "$elearn/elearn_reg_data.dta", clear

local conditions_proj tooktest_el==1 
local conditions_pec took_std==1 


local controls_1 age_bl age_bl_mi i.mother_education_bl 
local controls_3 age_bl age_bl_mi i.mother_education_bl school_facilities i.st_lessthancollege i.mt_lessthancollege i.h_phd totenroll8_bl


/**** 

Panel A/B Col 1-4 

***/

foreach outcome of varlist z_irt_total_el {
reg `outcome' treatment _z_irt_math_bl _z_irt_sci_bl `controls_1' $strata if `conditions_proj', cluster(school_code) 
outreg2 using panelA, replace dta label keep(treatment*) 

reg `outcome' treatment _z_irt_math_bl _z_irt_sci_bl `controls_3' $strata if `conditions_proj', cluster(school_code) 
outreg2 using panelB, replace dta label keep(treatment*) 

}


foreach outcome of varlist z_scoreindex_el {

reg `outcome' treatment _z_irt_math_bl _z_irt_sci_bl `controls_1' $partialled_pec  $strata if `conditions_pec' & `conditions_proj', cluster(school_code) 
outreg2 using panelA, append dta label keep(treatment*) 

reg `outcome' treatment _z_irt_math_bl _z_irt_sci_bl `controls_3' $partialled_pec  $strata if `conditions_pec' & `conditions_proj', cluster(school_code) 
outreg2 using panelB, append dta label keep(treatment* ) 

}


/**** PEC SCORE OUTCOMES (not in dataset)
foreach outcome of varlist z_st_score_total  {

reg `outcome' treatment _z_irt_math_bl _z_irt_sci_bl `controls_1' $partialled_pec  $strata if `conditions_pec', cluster(school_code) 
outreg2 using panelA, append dta label keep(treatment* _z_irt_math_bl _z_irt_sci_bl _meanmath_pec_2016 _meansci_pec_2016 _meaneng_pec_2016) 

reg `outcome' treatment _z_irt_math_bl _z_irt_sci_bl `controls_3' $partialled_pec  $strata if `conditions_pec', cluster(school_code) 
outreg2 using panelB, append dta label keep(treatment* _z_irt_math_bl _z_irt_sci_bl _meanmath_pec_2016 _meansci_pec_2016 _meaneng_pec_2016) 

}

foreach outcome of varlist z_st_score_passlevel  {

reg `outcome' treatment _z_irt_math_bl _z_irt_sci_bl `controls_1' $partialled_pec  $strata if `conditions_pec', cluster(school_code) 
outreg2 using panelA, append dta label keep(treatment* _z_irt_math_bl _z_irt_sci_bl _meanmath_pec_2016 _meansci_pec_2016 _meaneng_pec_2016) 

reg `outcome' treatment _z_irt_math_bl _z_irt_sci_bl `controls_3' $partialled_pec  $strata if `conditions_pec', cluster(school_code) 
outreg2 using panelB, append dta label keep(treatment* _z_irt_math_bl _z_irt_sci_bl _meanmath_pec_2016 _meansci_pec_2016 _meaneng_pec_2016) 

}
*/

/**** 

Panel A/B Col 5

***/

use "$tablets/elearn_tablets_reg_data.dta", clear

local controls_tab_1 Age i.s_Mother_Education_cod 
local controls_tab_3 Age i.s_Mother_Education_cod school_facilities i.h_master i.mt_lessthancollege i.st_lessthancollege school_grade6_enrollment  i.district_admindata_code female

reg z_score_total_el treatment `controls_tab_1' $strata $partialled_tablet if tooktest_el==1,  cluster(school_code) 

outreg2 using panelA, append dta label keep(treatment*) 


reg z_score_total_el treatment `controls_tab_3' $strata $partialled_tablet if tooktest_el==1,  cluster(school_code) 

outreg2 using panelB, append dta label keep(treatment* ) 



	
	foreach f in panelA panelB {
	use `f'_dta, clear
	export excel using "$app_tab/tableA2" , sheet("`f'", replace)
	rm "`f'_dta.dta"
	rm "`f'.txt"
	}
	
	


