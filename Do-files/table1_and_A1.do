

/************** 
PANEL A and C COLUMNS 1-3
*************/




	use "$elearn/elearn_balance_data", clear 
	
	local varlist_balance_rep z_score_total_bl age_bl attendance_bl m_ed_noschool f_ed_noschool Student_siblings_bl extratuitions_bl textbook_bl computer_yn_bl  work_bl homework_bl homework_time_bl parents_visits_bl expect_college_bl 
 	
local varlist_sch_balance_rep totenroll8_bl sections8_bl school_library_bl school_playground_bl school_computerlab_bl school_securityguard_bl school_latrine_bl  school_runningwater_bl 

	order `varlist_balance_rep'
	qui bysort treatment: outreg2 using sumstatsv2, dta replace sum(log) label keep(`varlist_balance_rep') eqkeep(N mean sd)
	order `varlist_sch_balance_rep'
	qui bysort treatment: outreg2 using sumstats_schv2 if uni_sch==1, dta replace sum(log)  keep(`varlist_sch_balance_rep') eqkeep(N mean sd)

	
	preserve
	use sumstatsv2_dta, clear
	export excel using "$pap_tab/table1_and_A1" , sheet("panelA_Col1_2", modify)
	use sumstats_schv2_dta, clear
	export excel using "$pap_tab/table1_and_A1" , sheet("PanelC_Col1_2", modify)
	restore
	
	***** Baseline Balance---student outcomes 
	
	cap rm "balance2v2_dta.dta"
	cap rm "balance2v2.txt"
	***** Baseline Balance--student level outcomes
	foreach v of varlist `varlist_balance_rep' {
	reg `v' treatment if child_interviewed_bl==1, cluster(school_code)
	outreg2 using balance2v2, append dta label keep(treatment)
	}
	
	preserve
	use balance2v2_dta, clear
	export excel using "$pap_tab/table1_and_A1" , sheet("balance_panelA_Col3", replace)
	restore

	***** Baseline Balance--school level outcomes
	cap rm "balance_schv2_dta.dta"
	cap rm "balance_schv2.txt"
	foreach v of varlist `varlist_sch_balance_rep' {
	reg `v' treatment if uni_sch==1, cluster(school_code)
	outreg2 using balance_schv2, append dta label keep(treatment)
	}
	
	preserve
	use balance_schv2_dta, clear
	export excel using "$pap_tab/table1_and_A1" , sheet("balance_panelC_Col3", replace)
	restore

/************** 
PANEL B COLUMNS 1-3
*************/
	
	use "$elearn/elearn_teacher_balance.dta"
	
	local t_varlist_balance_rep t_usetech_prep_bl t_usetech_class_bl t_tenure_total_bl t_teachereduc_masters_bl t_contract_empl_bl t_trainings_bl t_preptime_bl		
	
	* SUMSTATS TABLES
	set matsize 8000
	cap rm t_balance_dta.dta
	cap rm t_balance.txt
	
	order `t_varlist_balance_rep'
	qui bysort treatmentschool: outreg2 using t_sumstats, dta replace sum(log) label keep(`t_varlist_balance_rep') eqkeep(N mean sd)
		
	preserve
	use t_sumstats_dta, clear
	export excel using "$pap_tab/table1_and_A1" , sheet("PanelB_Col1_2", modify)
	restore
	
	
	foreach v in `t_varlist_balance_rep' {
	reg `v' treatmentschool, cluster(school_code)
	outreg2 using t_balance, append dta label keep(treatment)
	}
	
	preserve
	use t_balance_dta, clear
	export excel using "$pap_tab/table1_and_A1" , sheet("balance_panelB_Col3", replace)
	restore

	
/************** 
PANEL A/C COLUMNS 4-6
*************/	
	
use "$tablets/elearn_tablets_balance_data", clear

local varlist_balance_s z_score_total_bl Age Number_of_Days_Student_was_Absen s_Mother_Education_none s_Father_Education_none has_a_Computer_in_the_Ho_yn Number_of_Siblings_Student_Has Does_the_Student_take_Extratuiti Does_the_Student_Own_All_Courseb Works_Outside_of_School Does_Student_get_Homework_from_S  Time_Spent_on_Homework parent_visit expect_college 

local varlist_balance_sch school_library school_playground school_computerlab  school_security school_latrine school_water school_grade6_enrollment school_grade6_sections 

	order `varlist_balance_s' 
	qui bysort treatment: outreg2 using sumstats, dta replace sum(log) label keep(`varlist_balance_s') eqkeep(N mean sd)
	
	order `varlist_balance_sch'
	qui bysort treatment: outreg2 using sumstats_sch if unisch==1, dta replace sum(log) label keep(`varlist_balance_sch') eqkeep(N mean sd)
	
	
	preserve
	use sumstats_dta, clear
	export excel using "$pap_tab/table1_and_A1" , sheet("panelA_Col4_5", modify)
	use sumstats_sch_dta, clear
	export excel using "$pap_tab/table1_and_A1" , sheet("panelC_Col4_5", modify)
	restore
	


	cap rm "balance_dta.dta" 
	cap rm "balance.txt" 

	
	foreach v of varlist `varlist_balance_s' {
	reg `v' treatment , cluster(school_code)
	outreg2 using balance, append dta label keep(treatment)
	}
	
	foreach v of varlist `varlist_balance_sch' {
	reg `v' treatment if unisch==1, cluster(school_code)
	outreg2 using balance_sch, append dta label keep(treatment)
	}
	
	
	use balance_dta, clear
	export excel using "$pap_tab/table1_and_A1" , sheet("balance_panelA_Col6", replace)
	use balance_sch_dta, clear
	export excel using "$pap_tab/table1_and_A1" , sheet("balance_panelC_Col6", replace)

	

	/************** 
PANEL B COLUMNS 4-6
*************/	
	

	use "$tablets/elearn_tablets_teacher_balance", clear
	
local varlist_balance_t_rep t_tech_prep_yn t_tech_classes_yn  t_tenure_total t_masters  t_contract_empl t_trainings t_preptime 

			
order `varlist_balance_t_rep'
qui bysort treatment: outreg2 using sumstats_t, dta replace sum(log) label keep(`varlist_balance_t_rep') eqkeep(N mean sd)
	
cap rm "balance_t_dta.dta"
cap rm "balance_t.txt"

foreach v of varlist `varlist_balance_t_rep' {
	reg `v' treatment , cluster(school_code)
	outreg2 using balance_t, append dta label keep(treatment)
	}
		
	
	
	use sumstats_t_dta, clear
	export excel using "$pap_tab/table1_and_A1" , sheet("panelB_Col4_5", replace)
	use balance_t_dta, clear
	export excel using "$pap_tab/table1_and_A1" , sheet("balance_panelB_Col6", replace)
	

	
	foreach f in balance sumstats_sch sumstats t_balance t_sumstats balance_schv2 balance2v2 sumstats_schv2 sumstatsv2 balance balance_sch balance_t sumstats_t{ 
		cap rm "`f'_dta.dta"
		cap rm "`f'.txt"
	}
	
