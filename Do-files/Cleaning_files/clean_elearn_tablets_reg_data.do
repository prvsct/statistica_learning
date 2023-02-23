clear all
set more off

global 	path ""


************************************************************
* This file imports the raw test score data; merges it with the survey data, and cleans controls for PDS lasso          
************************************************************

use "tablet_t_survey_bl.dta", clear


g t_masters= t_qualification==3
g t_tech_classes_yn = t_tech_classes!=7 
replace t_tech_classes_yn=0 if t_tech_classes==.
g t_tech_prep_yn = t_tech_prep!=9
replace t_tech_prep_yn=. if t_tech_prep==.
	
g t_contract_empl=t_employment_status	==2
g 	t_private_tuitions=t_pvt_tuitions==1
g t_duties_yn = t_duties==1	
g 	t_outofclass_veryoften=t_outofclass==4
egen t_trainings=rowtotal(t_govt_trainings t_ngo_trainings)	
g t_trainings_yn=	t_trainings>0

local varlist_balance_t t_tech_prep_yn t_tech_classes_yn  t_tenure_total t_masters  t_contract_empl t_trainings t_private_tuitions t_duties_yn t_weekly_classes t_extra_classes t_outofclass_veryoften t_preptime  

keep if t_math==1 | t_sci==1


preserve 

local varlist_balance_t_rep t_tech_prep_yn t_tech_classes_yn  t_tenure_total t_masters  t_contract_empl t_trainings t_preptime 

label var t_tech_prep_yn "Uses Technology to Prepare for Class"
label var t_tech_classes_yn "Uses Technology in Class"
label var t_tenure_total "Years of Teaching Experience"
label var t_masters "Has an Advanced Degree"
label var t_contract_empl "Contract Employee"
label var t_trainings "Trainings"
label var t_preptime "Minutes Planning Lessons"

egen school_code =group(school_emis_code)  
keep school_code treatment  `varlist_balance_t_rep'
save "elearn_tablets_teacher_balance", replace
restore 



by school_emis_code: g teacher_num=_n
reshape wide t_*, i(school_emis_code) j(teacher_num)
merge 1:1 school_emis_code using "tablet_ht_survey_bl.dta"
drop _merge 
ren school_emis_code School_EMIS
tostring School_EMIS, replace
merge 1:m School_EMIS using  "tablet_scores_bl_el.dta", gen(_m2)
drop _m*

merge 1:1  School_EMIS_CODE Unique_IDs using "tablet_survey_bl"

*** drop the students with surveys and not tests 
keep if _merge==3
drop _m* 

save "tablet_survey_test_merged.dta", replace 



use "treatmentlist.dta", clear
foreach v of varlist  location gender enrollment math science cumulative { 
ren `v' sch_`v'
}
foreach v of varlist  district schoolname { 
ren `v' `v'_admindata
}

keep school_emis_code district_admindata schoolname_admindata sch_* treatment strata* 
tostring school_emis_code, replace
ren school_emis_code School_EMIS
merge 1:m School_EMIS using  "tablet_survey_test_merged.dta", gen(_m2)


foreach v in math sci total  { 
sum score_`v'_bl 
g z_score_`v'_bl=(score_`v'_bl-r(mean))/r(sd)
g z_score_`v'_el=(score_`v'_el-r(mean))/r(sd)
}
sum z_*
foreach v of varlist theta_sci_*l theta_total_*l theta_math_*l { 
sum `v' if treatment==0 
g z_`v'=(`v'-r(mean))/r(sd)
}

***** clean student controls 
foreach v in district_admindata sch_location sch_gender { 
encode `v', gen (`v'_code)
}

ren Parent_s_Relationship_Status Parent_s_Relationship

foreach v of varlist Who_Pays_Student_s_Fee Parent_s_Relationship s_Father_Occupation s_Mother_Occupation s_Father_Education s_Mother_Education s_Mode_of_Transporation Schooling_Expectation Reason_for_Absence Type_of_Techaid_Used { 
encode `v', g (`v'_cod)
}

destring Number_of_Years_Spent_in_Current s_Commute_Time_to_School s_Weekly_Work_Hours Hours_Spent_on_Tuition Time_Spent_on_Homework Does_Student_Use_Any_Techaid_for, replace

*** clean school controls 

ren t_taleemi_calendar_observed* t_taleemi_calendar_obs*
ren t_reading_materials_visible* t_read_mat_vis*
ren t_chalkboard_duster_avail* t_chalk_duster_avail*

foreach v in school_electricity school_water school_walls school_library school_computerlab school_educational_poster school_student_crafts school_latrine school_watercooler school_playground school_security { 
replace `v'=0 if `v'==1
replace `v'=1 if `v'==2 
}

foreach v of varlist t_visual_teaching_aid* t_have_a_desk_and_chair* t_stu_desks_chairs* t_read_mat_vis* t_resources_visible* t_chalk_duster_avail* { 
replace `v'=0 if `v'==1
replace `v'=1 if `v'==2 
} 


egen school_facilities=rowmean( school_electricity school_water school_walls school_library school_computerlab school_educational_poster school_student_crafts school_latrine school_watercooler school_playground school_security)
egen classroom_facilities=rowmean(t_visual_teaching_aid* t_have_a_desk_and_chair* t_stu_desks_chairs* t_read_mat_vis* t_resources_visible* t_chalk_duster_avail*)


g h_masters= ht_qualification==2
replace h_masters= 99 if ht_qualification==.



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

g trXz_score_total_bl_pcFE1=treatment*z_score_total_bl_pcFE1

**** SCH LEVEL AVG 

bysort School_EMIS: egen avg_total_score=mean(z_score_total_bl)
bysort School_EMIS: gen unisch=_n
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


bysort School_EMIS: gen unisch=_n

g has_a_Computer_in_the_Ho_yn= has_a_Computer_in_the_Ho>0
g  s_Mother_Education_none=s_Mother_Education=="Did not go to school"
replace s_Mother_Education_none=. if s_Mother_Education==""
g  s_Father_Education_none=s_Father_Education=="Did not go to school"
replace s_Father_Education_none=. if s_Father_Education==""

g expect_college=Schooling_Expectation=="Undergraduate" | Schooling_Expectation=="Masters or more"
g cellphone_yn = Number_of_Cellphone_Student_has>0


label var z_score_total_bl "Combined Math and Science Score"
label var Age "Age"
label var Number_of_Days_Student_was_Absen "Days Absent Last Month"
label var s_Mother_Education_none "Mother has no formal Schooling"
label var  s_Father_Education_none "father has no formal Schooling"
label var Number_of_Siblings_Student_Has "Number of Siblings"
label var  Does_the_Student_take_Extratuiti "Extra Tuition"
label var Does_the_Student_Own_All_Courseb "Owns all Course books"
label var has_a_Computer_in_the_Ho_yn "Has a Computer at Home"
label var Works_Outside_of_School "Works Outside School"
label var Does_Student_get_Homework_from_S "Homework from School"
label var Time_Spent_on_Homework "Time Spent on Homework"
label var parent_visit "Parents visit school to meet T or HT"
label var expect_college "Expect to attend college"	


local varlist_balance_s z_score_total_bl Age Number_of_Days_Student_was_Absen s_Mother_Education_none s_Father_Education_none ///
		Number_of_Siblings_Student_Has Does_the_Student_take_Extratuiti Does_the_Student_Own_All_Courseb has_a_Computer_in_the_Ho_yn cellphone_yn ///
		Works_Outside_of_School Does_Student_get_Homework_from_S  Time_Spent_on_Homework parent_visit expect_college 


local varlist_balance_sch school_grade6_enrollment school_grade6_sections ///
school_library school_playground school_computerlab school_electricity school_security ///
school_latrine school_walls school_water    ///
ht_masters ht_tenure ///
st_lessthancollege st_college st_masters st_tenure_total mt_lessthancollege mt_college mt_masters mt_tenure_total 
 
**** save dataset for balance 
preserve 
g school_code=group(School_EMIS) 
keep school_code unisch treatment z_score_total_bl Age Number_of_Days_Student_was_Absen s_Mother_Education_none s_Father_Education_none has_a_Computer_in_the_Ho_yn Number_of_Siblings_Student_Has Does_the_Student_take_Extratuiti Does_the_Student_Own_All_Courseb Works_Outside_of_School Does_Student_get_Homework_from_S  Time_Spent_on_Homework parent_visit expect_college school_library school_playground school_computerlab  school_security school_latrine school_water school_grade6_enrollment school_grade6_sections 

save "elearn_tablets_balance_data", replace
restore  
 



**** Prepare Dataset for Lasso 



local all_controls_cont z_score_*bl Age Number_of_Siblings_Student_Has Number_of_Members_in_Student_s_H ///
Latrines_in_House_are_opened_or Does_the_Student_Own_All_Courseb has_a_TV_in_the_House has_a_Computer_in_the_Ho Does_the_Student_Have_Internet_a ///
Number_of_Cellphone_Student_has Does_Student_Use_Computer_or_TV ///
Number_of_Years_Spent_in_Current s_Commute_Time_to_School Works_Outside_of_School s_Weekly_Work_Hours ///
Time_Spent_on_Homework Does_the_Student_take_Extratuiti Hours_Spent_on_Tuition Does_Student_get_Homework_from_S ///
Does_Student_Use_Any_Techaid_for Reads_0n_Course_Books Seeks_Guidance_from_Fami parent_visit Number_of_Days_Student_was_Absen ///
sch_enrollment sch_math sch_science sch_cumulative ///
ht_age ht_tenure ht_female ht_principal  ///
school_age school_fee school_fee_collection school_total_classrooms school_grade6_sections school_grade6_enrollment school_female ///
 school_investment school_electricity school_water school_walls school_library ///
 school_computerlab school_educational_poster school_student_crafts school_latrine school_watercooler school_playground school_security ///
 t_age* t_commute_time* t_tenure_total* t_experience_current* t_experience_public* t_govt_trainings* t_ngo_trainings* ///
 t_enrolment_observed* t_attendance_observed*  t_female* t_gradestaught_only6* /// 
 t_visual_teaching_aid* t_have_a_desk_and_chair* t_stu_desks_chairs* t_read_mat_vis* t_resources_visible* t_chalk_duster_avail* ///
 t_weekly_classes* t_preptime* t_duties_time* t_subs_time* t_extra_classes* t_pvt_tuitions_time* ///
 t_student_absent*  t_duties1 t_duties2 t_taleemi1 t_taleemi2 ///
 t_taleemi_calendar1 t_taleemi_calendar2 t_taleemi_calendar_obs* ///
 t_contract_length* t_math* t_sci* ///


local all_controls_discont *_cod *_code ht_qualification ht_desig ht_learning_outcomes ht_student_absenteeism ht_parent_engagement school_level ///
 t_qualification* t_employment_status* t_bps_scale* t_language* t_outofclass* t_guides_use*  ///
t_pvt_tuitions* t_student_absent_reasons* 

**** USING LASSO CLEAN COMMAND [this part of the program takes a while to run]
lassoClean `all_controls_cont', to_indicator(`all_controls_discont')

save "tablet_analysis_merged_lassoClean.dta", replace


replace s_Mother_Education_cod=99 if s_Mother_Education_cod==.
replace  mt_lessthancollege=99 if mt_qualification==.
replace  st_lessthancollege=99 if st_qualification==.


destring School_EMIS, replace 
tab strata, gen(strataFE)

g female=sch_gender=="Female"
g treatmentXfemale=treatment*female

g treatmentXBLScore=treatment*z_score_total_bl
g tooktest_el = testsample==3


** SAVE CLEAN FILE 

egen school_code=group(School_EMIS)
ren Unique_IDs child_code


label var z_score_total_el "E-learn Tablets Standardized Combined Math and Sci Score" 
label var z_score_math_el "E-learn Tablets Standardized Math Score" 
label var z_score_sci_el "E-learn Tablets Standardized Sci Score" 
label var tooktest_el "E-learn Tablets Present at Follow-up (Took follow-up exam)"

keep school_code child_code _* $strata tooktest_el treatment z_score_*_el z_score_total_bl Age s_Mother_Education_cod school_facilities h_master mt_lessthancollege st_lessthancollege school_grade6_enrollment  district_admindata_code female treatmentXfemale treatmentXBLScore trXavg_total_score_qFE2 trXavg_total_score_qFE3 trXavg_total_score_qFE4 avg_total_score_qFE* trXz_score_total_bl_qFE2 trXz_score_total_bl_qFE3 trXz_score_total_bl_qFE4 z_score_total_bl_qFE* excessproportion_el_reg

save "elearn_tablets_reg_data", replace





