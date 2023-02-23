clear all
set more off

global 	path ""

************************************************************
* Integrating raw elearn classrooms student and teacher data with test score and cleaning controls for PDS lasso          
************************************************************


use "`for_analysis'student_data.dta", clear
keep if tooktest_bl==1

qui tab strata, gen(strataFE)


local all_controls_cont z_irt_math_bl z_irt_sci_bl z_irt_total_bl meaneng_pec_2016 meanmath_pec_2016 meansci_pec_2016 ///
	totenroll8_bl sections8_bl class_size totpresent8_bl h_age_bl h_tenure_bl school_fees_collection_bl ///
	 facilities ///
	school_electricity_bl school_library_bl school_securityguard_bl school_playground_bl school_posters_walls_bl /// 
	school_computerlab_bl school_boundarywall_bl school_runningwater_bl school_latrine_bl school_handmade_chart_bl *_sum ///
st_age_bl st_tenure_total_bl st_experience_current_bl st_experience_public_bl st_preptime_bl ///
	st_transport_bl st_commute_time_bl st_english_bl st_trainings_bl ///
	st_weekly_classes_bl st_guides_use_bl  st_usetech_prep_bl st_usetech_class_bl ///
	st_duties_bl st_duties_time_bl st_subs_bl st_subs_time_bl st_taleemi_bl st_extra_classes_bl st_private_tuitions_bl st_evening_academy_bl st_pvt_tuitions_time_bl ///
	st_outofclass_rare_bl st_outofclass_veryoften_bl st_outofclass_often_bl ///
mt_age_bl mt_tenure_total_bl mt_experience_current_bl mt_experience_public_bl  mt_preptime_bl ///
	mt_transport_bl mt_commute_time_bl mt_english_bl mt_trainings_bl ///
	mt_weekly_classes_bl mt_guides_use_bl  mt_usetech_prep_bl mt_usetech_class_bl ///
	mt_duties_bl mt_duties_time_bl mt_subs_bl mt_subs_time_bl mt_taleemi_bl mt_extra_classes_bl mt_private_tuitions_bl mt_evening_academy_bl mt_pvt_tuitions_time_bl ///
	mt_outofclass_rare_bl mt_outofclass_veryoften_bl mt_outofclass_often_bl ///	
mt_class_big_bl mt_class_languageproblems_bl mt_class_absenteeism_bl mt_class_discipline_bl mt_class_facilities_bl mt_class_workload_bl ///
	mt_student_absent_bl mt_studentabsent_financial_bl mt_studentabsent_importance_bl mt_studentabsent_interest_bl mt_studentabsent_rules_bl mt_studentabsent_commute_bl ///
	mt_learning_hurdles_work_bl mt_learning_hurdles_cur_bl mt_learning_hurdles_tests_bl mt_learning_hurdles_mot_bl ///
st_class_big_bl st_class_languageproblems_bl st_class_absenteeism_bl st_class_discipline_bl st_class_facilities_bl st_class_workload_bl ///
	st_learning_hurdles_work_bl st_learning_hurdles_cur_bl st_learning_hurdles_tests_bl st_learning_hurdles_mot_bl 


 
local all_controls_discont h_qualification_bl h_gender_bl school_level_bl  /// 
st_gender_bl mt_gender_bl st_qualification_bl mt_qualification_bl st_employment_status_bl mt_employment_status_bl ///
st_bps_scale_bl mt_bps_scale_bl mt_contract_length_bl st_contract_length_bl

local controls_student_cont age_bl house_member_bl father_alive_bl mother_alive_bl Student_siblings_bl experience_bl extratuitions_bl homework_bl readings_bl  techcom_bl techmob_bl techtv_bl techcd_bl techother_bl parents_visits_bl work_bl cellphone_bl computer_bl vain_bl bicycles_bl textbook_bl attendance_bl motorbikes_bl car_bl tractor_bl latrine_bl house_ownership_bl
local controls_student_discont gender_bl guardian_bl parents_bl father_occupation_bl mother_occupation_bl father_education_bl mother_education_bl payment_bl schooling_expect_bl transport_bl



**** USING LASSO CLEAN COMMAND 


preserve
**** clean only school and teacher level controls 
lassoClean `all_controls_cont', to_indicator(`all_controls_discont')
save "elearn_school_lassoClean.dta", replace

restore


lassoClean `all_controls_cont' `controls_student_cont' , to_indicator(`all_controls_discont' `controls_student_discont')

merge 1:1 school_code section_code child_code using  "testscoredata.dta"
drop _m 
merge 1:1 child_name using  "pectestscoredata.dta"

drop _merge

ren z_irt_diff*0 z_irt_diff*_bl
ren z_irt_diff*1 z_irt_diff*_el


** gen quartiles of student test score 

sum z_score_total_bl, d
g z_score_total_bl_q=0 if z_score_total_bl<=r(p25)
replace z_score_total_bl_q=1 if z_score_total_bl>r(p25) & z_score_total_bl<=r(p50)
replace z_score_total_bl_q=2 if z_score_total_bl>r(p50) & z_score_total_bl<=r(p75)
replace z_score_total_bl_q=3 if z_score_total_bl>r(p75) 
tab z_score_total_bl_q, g(z_score_total_bl_qFE)

foreach v of varlist z_score_total_bl_qFE* { 
g trX`v'=treatment*`v'
}
xtile z_score_total_bl_pctile=z_irt_total_bl, nq(10)
tab z_score_total_bl_pctile, g(z_score_total_bl_pcFE)

g trXz_score_total_bl_pcFE1=treatment*z_score_total_bl_pcFE1

********** TEACHER EXPERIENCE AND PEERS DUMMIES 

foreach v in st_experience_public_bl mt_experience_public_bl {
sum `v', d
g `v'_med = `v'>=r(p50)
replace  `v'_med=99 if `v'==.
}



g inexperieced_any= st_experience_public_bl_med==0 | mt_experience_public_bl_med==0


g num_peers=0 
replace num_peers=1 if st_sciteachers_bl==2 | st_mathteachers_bl==2
replace num_peers=2 if st_sciteachers_bl==2 & st_mathteachers_bl==2

g peers= num_peers>0
g t_missing= st_mathteachers_bl==0



**** SCH LEVEL AVG 

bysort school_code: egen avg_total_score=mean(z_irt_total_bl)
bysort school_code: gen unisch=_n
sum avg_total_score if unisch==1, d
g avg_total_score_abovemed= avg_total_score>=r(p50)
tab avg_total_score_abovemed if unisch==1
sum avg_total_score if unisch==1, d
g avg_total_score_q=0 if avg_total_score<=r(p25)
replace avg_total_score_q=1 if avg_total_score>r(p25) & avg_total_score<=r(p50)
replace avg_total_score_q=2 if avg_total_score>r(p50) & avg_total_score<=r(p75)
replace avg_total_score_q=3 if avg_total_score>r(p75) 
tab avg_total_score_q, g (avg_total_score_qFE)
foreach v of varlist avg_total_score_qFE* { 
g trX`v'=treatment*`v'
}



pca z_irt_math_el z_irt_sci_el z_st_score_math z_st_score_sci
predict scoreindex_el
foreach s in scoresum_pec_project scoreindex_el {
        sum `s' if treatment==0 & tooktest_el==1 & took_std==1
            g mean_`s'=r(mean)
            g sd_`s'=r(sd)
        g z_`s'=(`s'-mean_`s')/sd_`s'
drop mean_`s'* sd_`s'
}

g school_female= school_gender==2
gen treatmentXfemale=treatment*school_female
gen treatmentXBLScore=treatment*z_irt_total_bl

gen z_st_score_passlevel=student_status=="PASS" | student_status=="PROMOTED" | student_status=="PASS WITH GRACE MARKS"

** clean other controls 

foreach s in s m {
gen `s't_lessthancollege = `s't_qualification_bl ==1
gen `s't_college =`s't_qualification_bl==2
gen `s't_masters =`s't_qualification_bl==3
gen `s't_phd =`s't_qualification_bl==4
}

foreach s in s m {
foreach v in t_lessthancollege t_college t_masters t_phd { 
replace `s'`v'=99 if `s't_qualification_bl==.
}
}

egen school_facilities=rowmean(school_electricity_bl school_library_bl school_securityguard_bl school_playground_bl ///
 school_latrine_bl  school_computerlab_bl school_boundarywall_bl school_runningwater_bl)
replace mother_education_bl=99 if mother_education_bl==.

g  age_bl_mi= age_bl==.
sum age_bl
replace  age_bl= r(mean) if age_bl==.


g h_phd= h_qualification_bl>=4
replace h_phd= 99 if h_qualification_bl==.


***** SAVE CLEAN FILE 

gen pec_matched= study_vs_pec==3
g took_std_matched=took_std==1 & pec_matched==1
label var took_std_matched "Elearn Classrooms: Matched and Took Pec"
label var z_irt_total_el "Elearn Classrooms Standardized Combined Math and Science Test Score (Project)"
label var z_st_score_total "Elearn Classrooms Standardized PEC Total"
label var z_scoreindex_el "Elearn Classrooms Standardized Combined Project and PEC"
label var z_st_score_passlevel "Elearn Classrooms Standardized Passed the PEC"
label var tooktest_el "Elearn Classrooms -- Took Follow-up Exam"
label var z_st_score_math "Elearn Classrooms Standardized PEC Math"
label var z_st_score_sci "Elearn Classrooms Standardized PEC Sci"
label var z_st_score_allother "Elearn Classrooms Standardized PEC All Other"


	preserve
		local varlist_balance_rep z_score_total_bl age_bl attendance_bl m_ed_noschool f_ed_noschool Student_siblings_bl extratuitions_bl textbook_bl computer_yn_bl  work_bl homework_bl homework_time_bl parents_visits_bl expect_college_bl
 	
		local varlist_sch_balance_rep totenroll8_bl sections8_bl school_library_bl school_playground_bl school_computerlab_bl school_securityguard_bl school_latrine_bl  school_runningwater_bl; 
	keep school_code treatment `varlist_balance_rep' `varlist_sch_balance_rep' uni_sch child_interviewed_bl
	gen student_id=_n
	save "elearn_balance_data", replace
	restore


keep school_code child_code _* $strata age_bl age_bl_mi mother_education_bl school_facilities st_lessthancollege mt_lessthancollege h_phd totenroll8_bl z_irt_math_el z_irt_sci_el z_irt_total_el z_irt_total_bl z_scoreindex_el z_irt_diff1_el z_irt_diff2_el z_irt_diff3_el z_irt_diff4_el tooktest_el took_std peers inexperieced_any t_missing treatment treatmentXBLScore treatmentXfemale school_female z_score_total_bl_qFE1 z_score_total_bl_qFE2 z_score_total_bl_qFE3 z_score_total_bl_qFE4 trXz_score_total_bl_qFE1 trXz_score_total_bl_qFE2 trXz_score_total_bl_qFE3 trXz_score_total_bl_qFE4 trXavg_total_score_qFE1 trXavg_total_score_qFE2 trXavg_total_score_qFE3 trXavg_total_score_qFE4 avg_total_score_qFE1 avg_total_score_qFE2 avg_total_score_qFE3 avg_total_score_qFE4 took_std_matched 
save "{CELAN DATA}/elearn_reg_data", replace
