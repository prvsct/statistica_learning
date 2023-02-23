 
capture log close
capture clear mata
drop _all
set more off

set matsize 1000
capture clear matrix
set maxvar 32767

#delimit;

	
use "`for_analysis'teachersurvey.dta", clear;
	ren *_other* *_o*;
	ren * t_*;
	foreach v in school_code treatment_school treatmentschool enum_code_bl enum_code district_code tehsil_code enumeratorname_bl school_name_bl enum_name district_name tehsil_name school_name{;
	ren t_`v' `v';
	};
	*** teacher preptime in hours in endline ;
	replace t_preptime=t_preptime*60;
	label var t_preptime "Minutes spent preparing for class";
	merge m:1 school_code using "headsurvey.dta";
	drop _m;
	gen female=gender=="Female";
	gen trXfemale=treatmentschool*female;
	gen t_contract_empl_bl=t_employment_status_bl==2;
	replace t_contract_empl_bl=. if t_employment_status_bl==.;
	label var t_contract_empl_bl "Teacher is a contract Employee";
	tempfile teacherdata;
	save `teacherdata', replace;

	local all_controls_cont meaneng_pec_2016 meanmath_pec_2016 meansci_pec_2016
	totenroll8_bl sections8_bl class_size totpresent8_bl head_age_bl head_tenure_bl  
	school_fees_collection_bl school_electricity_bl school_library_bl school_securityguard_bl schools_funds_private_bl  
	school_playground_bl school_watercooler_bl school_latrine_bl school_handmade_chart_bl school_posters_walls_bl 
	school_computerlab_bl school_boundarywall_bl school_runningwater_bl pca_* *sum facilities 
	t_age_bl t_tenure_total_bl t_experience_current_bl t_experience_public_bl t_preptime_bl 
	t_transport_bl t_commute_time_bl t_english_bl t_trainings_bl 
	t_weekly_classes_bl t_guides_use_bl  t_usetech_prep_bl t_usetech_class_bl 
	t_duties_bl t_duties_time_bl t_subs_bl t_subs_time_bl t_taleemi_bl t_extra_classes_bl t_private_tuitions_bl t_evening_academy_bl t_pvt_tuitions_time_bl 
	t_outofclass_rare_bl t_outofclass_veryoften_bl t_outofclass_often_bl 
	t_studentabsent*_bl t_learning_hurdles_*_bl t_class_*_bl;
	
	
	
	local all_controls_discont t_gender_bl t_transport_bl t_qualification_bl t_bps_scale_bl t_contract_length_bl t_employment_status_bl 
	head_qualification_bl head_gender_bl school_level_bl;
	
	lassoClean `all_controls_cont', to_indicator(`all_controls_discont');

	preserve
	local t_varlist_balance_rep t_usetech_prep_bl t_usetech_class_bl t_tenure_total_bl t_teachereduc_masters_bl t_contract_empl_bl t_trainings_bl t_preptime_bl
	label var t_usetech_prep_bl "Use technology to prepare for class"
	label var t_usetech_class_bl "Use technology in class"
	keep school_code treatment `t_varlist_balance_rep'
	gen t_id=_n
	save "elearn_teacher_balance", replace
	restore
	
	
	qui tab strata, gen(strataFE)

	
	keep school_code _* strataFE* treatmentschool t_trainings_term t_usetech_prep t_usetech_class t_preptime t_private_tuitions t_weekly_classes t_extra_classes t_outofclass_veryoften 	 t_training_bl_mi t_usetech_prep_bl_mi t_usetech_class_bl_mi t_preptime_bl_mi t_private_tuitions_bl_mi t_weekly_classes_bl_mi 

label var t_usetech_class "Uses Technology in the Classroom"
label var t_usetech_prep "Uses Technology to Prepare for lessons"
label var t_trainings_term "Number of Inservice Trainings this Year"
	
save "elearn_reg_data_teacher", replace

	

	
	
	
	
	
