use "$elearn/elearn_reg_data_teacher.dta", clear

unab prepped: _* 


foreach v in t_trainings_term {
sum `v' if treatment==0  
local m_`v'=`r(mean)'
pdslasso `v' treatmentschool  (`prepped' $strata t_training_bl_mi)  , partial($strata t_training_bl_mi _t_trainings_bl)  cluster(school_code) 
outreg2 using table5, replace dta label keep(treatment*) addstat(Control mean, `m_`v'')
}


foreach v in t_usetech_prep t_usetech_class {
sum `v' if treatmentschool==0  
local m_`v'=`r(mean)'
pdslasso `v' treatmentschool  (`prepped' $strata `v'_bl_mi)  , partial($strata `v'_bl_mi _`v'_bl)  cluster(school_code) 
outreg2 using table5, append dta label keep(treatment*) addstat(Control mean, `m_`v'')
}

 
use table5_dta, clear
export excel using "$pap_tab/table5" , sheet("table5", replace)

cap rm "table5_dta.dta"
cap rm "table5.txt"




	

