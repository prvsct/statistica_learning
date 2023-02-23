
use "$elearn/elearn_reg_data_teacher.dta", clear

unab prepped: _* 



foreach v in t_preptime  {
sum `v' if treatmentschool==0  
local m_`v'=`r(mean)'
pdslasso `v' treatmentschool  (`prepped' $strata `v'_bl_mi)  , partial($strata `v'_bl_mi _`v'_bl)  cluster(school_code)
outreg2 using tableA5, replace dta label keep(treatment*) addstat(Control mean, `m_`v'')
}


foreach v in t_private_tuitions t_weekly_classes  {
sum `v' if treatmentschool==0  
local m_`v'=`r(mean)'
pdslasso `v' treatmentschool  (`prepped' $strata `v'_bl_mi)  , partial($strata `v'_bl_mi _`v'_bl)  cluster(school_code)
outreg2 using tableA5, append dta label keep(treatment*) addstat(Control mean, `m_`v'')
}

foreach v in  t_extra_classes  {
sum `v' if treatment==0  
local m_`v'=`r(mean)'
pdslasso `v' treatmentschool  (`prepped' $strata )  , partial($strata _`v'_bl_mi _`v'_bl)  cluster(school_code)
outreg2 using tableA5, append dta label keep(treatment*) addstat(Control mean, `m_`v'')
}


foreach v in   t_outofclass_veryoften {
sum `v' if treatmentschool==0  
local m_`v'=`r(mean)'
pdslasso `v' treatmentschool  (`prepped' $strata )  , partial($strata _t_outofclass_rare_bl_mi _`v'_bl)  cluster(school_code)
outreg2 using tableA5, append dta label keep(treatment*) addstat(Control mean, `m_`v'')
}


 
use tableA5_dta, clear
export excel using "$app_tab/tableA5" , sheet("tableA5", replace)

cap rm "tableA5_dta.dta"
cap rm "tableA5.txt"




