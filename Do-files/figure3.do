#delimit;


capture log close;
log using "figure3.log", text replace;

*******************;
**program name: figure3.do;
**purpose: 
    1) creates elearn figure 3--summary of use of elements of eLearn Classrooms 
**************************;

capture clear mata;
drop _all;
capture clear matrix;
set matsize 600;
set maxvar 20000;
set more off;
set seed 801;

**The chart**;
use "elearn_tablets_use_data.dta", clear;
**The data for this chart are confidential, but may be obtained with Data Use Agreements with the Punjab Information Technology Board. Researchers interested in access to the data may contact info@pitb.gov.pk, also see https://www.pitb.gov.pk/;
    g outsch_videos=asch_videos+bsch_videos;
    g outsch_simulations=asch_simulations_accessed+bsch_simulations_accessed;
    g outsch_questions=asch_questions_accessed+bsch_questions_accessed;   
    rename wisch_videos_played wisch_videos;
    rename wisch_simulations_accessed wisch_simulations;
    rename wisch_questions_accessed wisch_questions;
    rename asch_questions_accessed asch_questions;
    rename bsch_questions_accessed bsch_questions;
    foreach i in videos simulations questions{;
        g any_`i'=(asch_`i'+bsch_`i'+wisch_`i')>=1;
    };

preserve;
    collapse (sum) wisch_videos outsch_videos wisch_simulations outsch_simulations
        wisch_questions outsch_questions;
    foreach x in videos simulations questions{;
        g pwi_`x'=wisch_`x'/(wisch_`x'+outsch_`x');
        };
    restore;
        
    collapse (mean) wisch_videos outsch_videos 
        wisch_simulations outsch_simulations
        wisch_questions outsch_questions any_videos any_simulations any_questions, by(month);

    sort month; *months from 201610 to 201702;
    g mocount=[_n];
    
    label define moname 1 "October" 2 "November" 3 "December" 4 "January" 5 "February";
    label values mocount moname;
    label variable mocount "Month";
    
    foreach x in videos simulations questions{;
        label variable wisch_`x' "During School";
        label variable outsch_`x' "Before or After School";
        g tot_`x'=wisch_`x'+outsch_`x';
        g per_wisch_`x'=wisch_`x'/tot_`x';
        };
    
    twoway (line wisch_videos mocount, lwidth(medthick)) 
        (line outsch_videos mocount, lwidth(medthick) lpattern(dash)), 
        title("Panel A: Videos Accessed")
        graphregion(fcolor(white))
        ytitle(Number Accessed, margin(small)) 
        xtitle(Month, margin(small)) 
        xlabel(, valuelabel) 
        legend(region(lwidth(none)))
        name(videos);

    twoway (line wisch_questions mocount, lwidth(medthick)) 
        (line outsch_questions mocount, lwidth(medthick) lpattern(dash)), 
        title("Panel B: Questions Accessed")
        graphregion(fcolor(white))
        ytitle(Number Accessed, margin(small)) 
        xtitle(Month, margin(small)) 
        xlabel(, valuelabel) 
        legend(region(lwidth(none)))
        name(questions);

    twoway (line wisch_simulations mocount, lwidth(medthick)) 
        (line outsch_simulations mocount, lwidth(medthick) lpattern(dash)), 
        title("Panel C: Simulations Accessed")
        graphregion(fcolor(white))
        ytitle(Number Accessed, margin(small)) 
        xtitle(Month, margin(small)) 
        xlabel(, valuelabel) 
        legend(region(lwidth(none)))
        name(simulations);

    graph combine videos questions simulations , 
        altshrink graphregion(fcolor(white))
       
        name(techuse);
        
    graph export elearn_techuse.emf, replace;

    
    exit;
