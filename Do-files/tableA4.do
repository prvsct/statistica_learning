**** Uses data after LassoClean to original dataset
use "$elearn/elearn_reg_data.dta", clear

local conditions_proj tooktest_el==1 
local conditions_pec took_std==1 

local controls_picked_lasso _mt_duties_time_bl _mt_bps_scale_bli2 _mt_bps_scale_bli3 _parents_bli4 _mother_occupation_bli2 _mt_extra_classes_bl_sq

/**** 

Col 1-2

***/



	sort treatment school_code child_code
	set seed 30293
	g randnum=runiform() 
    bys treatment: gen total_bl_by_tr=_N
    bys treatment: egen proportion_el=mean(tooktest_el)
    egen minproportion_el=min(proportion_el)
    gen excessproportion_el=proportion_el-minproportion_el
    gen excesscount_el=excessproportion_el*total_bl_by_tr

    sort tooktest_el treatment _z_irt_total_bl randnum
    by tooktest_el treatment: gen scoreranklow_el=_n
    g lee_keeptop=(scoreranklow_el>excesscount_el) & tooktest_el==1

    gsort tooktest_el treatment -_z_irt_total_bl randnum
    by tooktest_el treatment: gen scorerankhigh_el=_n
    g lee_keepbot=(scorerankhigh_el>excesscount_el) & tooktest_el==1
    
	
	cap rm tableA4_dta.dta
	cap rm tableA4.txt
	
	
	foreach p in top bot {
	local conditions lee_keep`p'==1
	reg z_irt_total_el treatment  $strata $partialled_proj `controls_picked_lasso' if `conditions_proj' & `conditions', cluster(school_code) 
	outreg2 using tableA4, append dta label keep(treatment* _z_irt_math_bl _z_irt_sci_bl _meanmath_pec_2016 _meansci_pec_2016 _meaneng_pec_2016)
	}

/**** 

Col 3-4

***/	
	
use "$tablets/elearn_tablets_reg_data.dta", clear

unab prepped: _* 
local conditions tooktest_el==1
local controls_picked_lasso2 _t_govt_trainings_received1 _t_weekly_classes2 _ht_parent_engagementi5 _t_employment_status2i2 _t_bps_scale1i4 _t_language1i1 _t_outofclass2i1 _t_enrolment_observed2_sq _s_Weekly_Work_Hours_mi


sort treatment school_code child_code
	set seed 30293
	g randnum=runiform() 
    bys treatment: gen total_bl_by_tr=_N
    bys treatment: egen proportion_el=mean(tooktest_el)
    egen minproportion_el=min(proportion_el)
    gen excessproportion_el=proportion_el-minproportion_el
	
    gen excesscount_el=excessproportion_el*total_bl_by_tr

    sort tooktest_el treatment _z_score_total_bl randnum
    by tooktest_el treatment: gen scoreranklow_el=_n
    g lee_keeptop=(scoreranklow_el>excesscount_el) & tooktest_el==1

    gsort tooktest_el treatment -_z_score_total_bl randnum
    by tooktest_el treatment: gen scorerankhigh_el=_n
    g lee_keepbot=(scorerankhigh_el>excesscount_el) & tooktest_el==1
    

	foreach p in top bot {
	local conditions_lee lee_keep`p'==1
	reg z_score_total_el treatment  $strata $partialled_tablet `controls_picked_lasso2' if `conditions_lee' & `conditions', cluster(school_code) 
	outreg2 using tableA4, append dta label keep(treatment*) 
	}
	
	
	use tableA4_dta, clear
	export excel using "$app_tab/tableA4" , sheet("tableA4", replace)
	cap rm tableA4_dta.dta
	cap rm tableA4.txt
	

