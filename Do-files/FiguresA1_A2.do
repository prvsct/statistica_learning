

 
capture log close
capture clear mata
drop _all
set seed 1234
local it = 1000


set more off

set matsize 11000
capture clear matrix
set maxvar 32767

use  "$elearn/elearn_reg_data.dta", clear

local controls age_bl age_bl_mi i.mother_education_bl school_facilities i.st_lessthancollege i.mt_lessthancollege i.h_phd _totenroll8_bl

kdensity z_irt_total_bl ,  xtitle("") ytitle("") title("") note("") graphregion(color(white))
graph export "$fig/FigureA1_PanelA.pdf", as(pdf) replace


** get residuals 

*
*** if  you want to use the same controls for the residual 
foreach v in z_irt_total_bl z_irt_total_el   {
	reg `v' `controls' strataFE* , vce(cluster school_code) 
	predict Resid_`v', resid

}




keep school_code treatment Resid*   

tempfile temp
save `temp', replace

foreach v in  z_irt_total_el   {
			
			use `temp', clear
			qui egen kernel_range = fill(.01(.01)1)
				qui replace kernel_range = . if kernel_range>1
				mkmat kernel_range if kernel_range != .
				matrix diff = kernel_range
				matrix x = kernel_range


				forvalues j = 1(1)`it' {
				use `temp', clear
				bsample, strata(treatment) cluster(school_code)


				bysort treatment: egen rank`v' = rank(Resid_`v'), unique
				bysort treatment: egen max_rank`v' = max(rank`v')
				bysort treatment: gen PctileResid_`v' = rank`v'/max_rank`v' 

				bysort treatment: egen rankz_irt_total_bl = rank(Resid_z_irt_total_bl), unique
				bysort treatment: egen max_rankz_irt_total_bl = max(rankz_irt_total_bl)
				bysort treatment: gen PctileResid_z_irt_total_bl = rankz_irt_total_bl/max_rankz_irt_total_bl 
					
					
					egen kernel_range = fill(.01(.01)1)
					qui replace kernel_range = . if kernel_range>1

					*regressing endline scores on percentile rankings
					lpoly Resid_`v' PctileResid_z_irt_total_bl if treatment==0 , gen(xcon pred_con) at (kernel_range) nograph bwidth(0.1)
					lpoly Resid_`v' PctileResid_z_irt_total_bl if treatment==1 , gen(xtre pred_tre) at (kernel_range) nograph bwidth(0.1)
	
						
					mkmat pred_tre if pred_tre != . 
					mkmat pred_con if pred_con != . 
					matrix diff = diff, pred_tre - pred_con

				}

				matrix diff = diff'



				*each variable is a percentile that is being estimated (can sort by column to get 2.5th and 97.5th confidence interval)
				svmat diff
				keep diff* 

				matrix conf_int = J(100, 2, 100)
				qui drop if _n == 1

				*sort each column (percentile) and saving 25th and 975th place in a matrix
				forvalues i = 1(1)100{
				sort diff`i'
				matrix conf_int[`i', 1] = diff`i'[0.025*`it']
				matrix conf_int[`i', 2] = diff`i'[0.975*`it']	
				}



		*******************Graphs for control, treatment, and difference using actual data (BASELINE)*************************************
				use `temp', clear

				
				bysort treatment: egen rank`v' = rank(Resid_`v'), unique
				bysort treatment: egen max_rank`v' = max(rank`v')
				bysort treatment: gen PctileResid_`v' = rank`v'/max_rank`v' 
				
				bysort treatment: egen rankz_irt_total_bl = rank(Resid_z_irt_total_bl), unique
				bysort treatment: egen max_rankz_irt_total_bl = max(rankz_irt_total_bl)
				bysort treatment: gen PctileResid_z_irt_total_bl = rankz_irt_total_bl/max_rankz_irt_total_bl 
				
				egen kernel_range = fill(.01(.01)1)
				qui replace kernel_range = . if kernel_range>1
		

				lpoly Resid_`v' PctileResid_z_irt_total_bl if treatment==0 , gen(xcon pred_con) at (kernel_range) nograph bwidth(0.1)
				lpoly Resid_`v' PctileResid_z_irt_total_bl if treatment==1 , gen(xtre pred_tre) at (kernel_range) nograph bwidth(0.1)

				gen diff = pred_tre - pred_con

				
				*variables for confidence interval bands
				svmat conf_int


		
	graph twoway (line pred_con xcon, lcolor(blue) lpattern("--.....") legend(lab(1 "Control"))) ///
				(line pred_tre xtre, lcolor(red) lpattern(longdash) legend(lab(2 "Treatment"))) ///
				(line diff xcon, lcolor(black) lpattern(solid) legend(lab(3 "Difference"))) ///
				,yline(0, lcolor(gs10)) xtitle(Percentile of residual baseline score) ytitle(Residual endline test score) legend(order(1 2 3 4)) ///
				 graphregion(color(white))
	graph export "$fig/FigureA2_PanelA.pdf", as(pdf) replace
		
}

**** To replicate panel B replace "z_irt_total_el" with PEC score

capture log close
capture clear mata
drop _all
set seed 1234
local it = 1000


set more off

set matsize 11000
capture clear matrix
set maxvar 32767

use "$tablets/elearn_tablets_reg_data.dta", clear 

local controls_selfdefine3 Age i.s_Mother_Education_cod school_facilities i.h_master i.mt_lessthancollege i.st_lessthancollege school_grade6_enrollment  i.district_admindata_code female


kdensity z_score_total_bl ,  xtitle("") ytitle("") title("") note("") graphregion(color(white)) bwidth(0.3)
graph export "$fig/FigureA1_PanelB.pdf", as(pdf) replace


** get residuals 


foreach v in z_score_total_bl z_score_total_el {
	reg `v' `controls_selfdefine3' strataFE* , vce(cluster school_code) 
	predict Resid_`v', resid

}

keep school_code treatment Resid*   

tempfile tempBoot
save `tempBoot', replace

foreach v in  z_score_total_el {
			
			use `tempBoot', clear
			qui egen kernel_range = fill(.01(.01)1)
				qui replace kernel_range = . if kernel_range>1
				mkmat kernel_range if kernel_range != .
				matrix diff = kernel_range
				matrix x = kernel_range


				forvalues j = 1(1)`it' {
				use `tempBoot', clear
				bsample, strata(treatment) cluster(school_code)


				bysort treatment: egen rank`v' = rank(Resid_`v'), unique
				bysort treatment: egen max_rank`v' = max(rank`v')
				bysort treatment: gen PctileResid_`v' = rank`v'/max_rank`v' 

				
				bysort treatment: egen rankz_score_total_bl = rank(Resid_z_score_total_bl), unique
				bysort treatment: egen max_rankz_score_total_bl = max(rankz_score_total_bl)
				bysort treatment: gen PctileResid_z_score_total_bl = rankz_score_total_bl/max_rankz_score_total_bl 

				
					egen kernel_range = fill(.01(.01)1)
					qui replace kernel_range = . if kernel_range>1

					*regressing endline scores on percentile rankings
					lpoly Resid_`v' PctileResid_z_score_total_bl if treatment==0 , gen(xcon pred_con) at (kernel_range) nograph bwidth(0.1)
					lpoly Resid_`v' PctileResid_z_score_total_bl if treatment==1 , gen(xtre pred_tre) at (kernel_range) nograph bwidth(0.1)
	
						
					mkmat pred_tre if pred_tre != . 
					mkmat pred_con if pred_con != . 
					matrix diff = diff, pred_tre - pred_con

				}

				matrix diff = diff'



				*each variable is a percentile that is being estimated (can sort by column to get 2.5th and 97.5th confidence interval)
				svmat diff
				keep diff* 

				matrix conf_int = J(100, 2, 100)
				qui drop if _n == 1

				*sort each column (percentile) and saving 25th and 975th place in a matrix
				forvalues i = 1(1)100{
				sort diff`i'
				matrix conf_int[`i', 1] = diff`i'[0.025*`it']
				matrix conf_int[`i', 2] = diff`i'[0.975*`it']	
				}



		*******************Graphs for control, treatment, and difference *************************************
				use `tempBoot', clear

				
				bysort treatment: egen rank`v' = rank(Resid_`v'), unique
				bysort treatment: egen max_rank`v' = max(rank`v')
				bysort treatment: gen PctileResid_`v' = rank`v'/max_rank`v' 
				
				bysort treatment: egen rankz_score_total_bl = rank(Resid_z_score_total_bl), unique
				bysort treatment: egen max_rankz_score_total_bl = max(rankz_score_total_bl)
				bysort treatment: gen PctileResid_z_score_total_bl = rankz_score_total_bl/max_rankz_score_total_bl
				
				egen kernel_range = fill(.01(.01)1)
				qui replace kernel_range = . if kernel_range>1
		

				lpoly Resid_`v' PctileResid_z_score_total_bl if treatment==0 , gen(xcon pred_con) at (kernel_range) nograph bwidth(0.1)
				lpoly Resid_`v' PctileResid_z_score_total_bl if treatment==1 , gen(xtre pred_tre) at (kernel_range) nograph bwidth(0.1)

				gen diff = pred_tre - pred_con

				
				*variables for confidence interval bands
				svmat conf_int

	graph twoway (line pred_con xcon, lcolor(blue) lpattern("--.....") legend(lab(1 "Control"))) ///
				(line pred_tre xtre, lcolor(red) lpattern(longdash) legend(lab(2 "Treatment"))) ///
				(line diff xcon, lcolor(black) lpattern(solid) legend(lab(3 "Difference"))) ///
				,yline(0, lcolor(gs10)) xtitle(Percentile of residual baseline score) ytitle(Residual endline test score) legend(order(1 2 3 4)) ///
				 graphregion(color(white))
	graph export "$fig/FigureA2_PanelC.pdf", as(pdf) replace				

	
}
