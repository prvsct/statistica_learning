/********

Column 1-2 

****/
use "$elearn/elearn_reg_data_teacherattendance.dta", clear

unab prepped: _* 


local month "monthFE*" 
local lagged_dv Teacher_Presence0_nm Teacher_Presence0_dum
local main_x TREATMENTSCHOOL

sum Teacher_Presence0_nm if  Teacher_Presence0_dum==0
local m_t_attend_0=r(mean)



pdslasso Teacher_Presence1 `main_x' (`prepped' $strata `month' `lagged_dv') , partial($strata `month' `lagged_dv') cluster(school_code)
outreg2 using table4, dta replace label keep(TREATMENTSCHOOL) addstat(Mean Attendance in 2015, `m_t_attend_0')

pdslasso Teacher_Presence1 `main_x' Trxmonthsincetr (`prepped' $strata `month' `lagged_dv'), partial($strata `month' `lagged_dv') cluster(school_code)
outreg2 using table4, dta append label keep(TREATMENTSCHOOL Trxmonthsincetr) addstat(Mean Attendance in 2015, `m_t_attend_0')

/********

Column 3-4

****/


use "$tablets/elearn_tablets_reg_data_teacherattendance.dta", clear

unab prepped: _* 
local month "monthFE*" 
local lagged_dv teacher_presence0_nm teacher_presence0_dum
local main_x treatment

sum teacher_presence0_nm if teacher_presence0_dum==0
local m_t_attend_0=r(mean)

pdslasso teacher_presence1 `main_x' (`prepped' $strata `month' `lagged_dv'), partial($strata `month' `lagged_dv') cluster(school_code)
outreg2 using table4, dta append label keep(treatment Trxmonthsincetr) ///
addstat(Mean Attendance in 2015, `m_t_attend_0')

pdslasso teacher_presence1 `main_x' Trxmonthsincetr (`prepped' $strata `month' `lagged_dv'), partial($strata `month' `lagged_dv') cluster(school_code)
outreg2 using table4, dta append label keep(treatment Trxmonthsincetr) ///
addstat(Mean Attendance in 2015, `m_t_attend_0')


	
	use table4_dta, clear
	export excel using "$pap_tab/table4" , sheet("table4", replace)
	rm  table4_dta.dta
	rm table4.txt




	

