******************************************************************************
******************************************************************************
******************************************************************************
* This code generates plots of the hourly wage growth for 2018 by bins relative to the minimum wage.  SMIC then is normalized to 100
******************************************************************************
******************************************************************************
*******************************************************************************

use "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\dadspost18_clean_sept.dta", clear



*global  bbins = 1  /* Equidistant bins of SMIC*/


* Activate for same number of observations per bin option
global  bbins  "2"  /* Same number observations per bin of SMIC*/
drop groupp1s_1
rename groupp1s_1_51 groupp1s_1
*



* The loaded sample already trims by: 
/*
- unexistent SIREN
- regular workers /eliminates aprenticeships
- only private sector
- more than 9 workers 
- negative hours
- age 15-65
*/



* Trim the sample even further 



* Keep if it is poste principal
	*keep if pps==1
	*keep if pps_1==1
	
* Keep only if it is poste non-annexée
	*keep if filt ==1
	*keep if filt_1==1	
	
* Eliminate Agriculture
	* drop if a6=="AZ"   /*Deprecated*/
	
* Eliminate Movers
	keep if mover==0   
	global  mmmover  "0"  /* 0: No Movers, activate if keep if mover == 0 activated*/
	*global  mmover = 1  /* 0: No Movers, activate if keep if mover == 0 activated*/
	
* Keep if Full Time and Full Year (Moved Below)
	*drop if cpfd !="C"    /*Full Time this year*/
	*drop if cpfd_1 !="C"   /*Full Time the previous year*/
	*keep if ddur ==1 & duree==360 /*Full Year = - workers who worked a duation of 360 days in the current and previous year */
	

* Graph growth of only those who are below 4 times the SMIC 
	keep if groupp1s_1<400

	sort  dhsrw  s_bruth
	*browse cpfd* dhsrw dhrrw r_bruth* s_bruth* dlhrrw nbheur* r_brut* s_brut* if nbheur_1>=1000 & nbheur>=1000 & pps==1 & pps_1==1 & filt==1 & filt_1==1 & duree==360 & duree_1==360 & dhsrw<=1 & dhsrw>=-1
	
******************************************************************************
* GRAPHS*
******************************************************************************

************************************
* 			  Nominal
************************************
*            Full sample    Hours Not Weighted    *
************************************
* Control table for extraction 

bysort groupp1s_1: summ dhsrw hsrw_mult_1 hsrw_mult if groupp1s_1>=100

preserve

	collapse (mean)  dhsrw (max) hsrw_mult_1 hsrw_mult (median)  dhsrw_m=dhsrw  (p25)  dhsrw_25=dhsrw  (p75)  dhsrw_75=dhsrw  (p10)  dhsrw_10=dhsrw  (p90)  dhsrw_90=dhsrw, by(groupp1s_1)
	global weight  "0"
	**** En Anglais
	graph twoway (connected  dhsrw hsrw_mult_1 if hsrw_mult_1<=500 & hsrw_mult_1>=100, sort mcolor(red) lwidth(medthick)) ///
	(line  dhsrw_m hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(blue) lwidth(medthick)) ///
	(line  dhsrw_25 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) ///
	(line  dhsrw_75 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) , legend(off) ylabel(-5[5]35,  labsize(small))  ylabel(,grid glcolor(gs13))  xtitle("Nominal hourly wage as a share of SMIC" "(Truncation nominal wages)") ytitle("Change in Nominal hourly wage (%) ")	title("Annual Growth in hourly Nominal wages:"  "w/o movers, unweighted hours", size(small)) legend(on order(1 "Mean" 2 "Median" 3 "25p & 75p") size(large) ring(0) bplacement(north)) name(Nominal2,replace) saving("C:\Users\Public\Documents\Etienne-Pranav-Christian\DADSpanelGraphs_pm\Multiyear\Essai\g_sbrut_smic", replace)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_smic_bb${bbins}_movers${mmmover}_ww${weight}.png", replace 
	export delimited "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_smic_bb${bbins}_movers${mmmover}_ww${weight}.csv", replace
		
	*** En francais 
	graph twoway (connected  dhsrw hsrw_mult_1 if hsrw_mult_1<=500 & hsrw_mult_1>=100, sort mcolor(red) lwidth(medthick)) ///
	(line  dhsrw_m hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(blue) lwidth(medthick)) ///
	(line  dhsrw_25 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) ///
	(line  dhsrw_75 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) , legend(off) ylabel(-5[5]30,  labsize(small))  ylabel(,grid glcolor(gs13))  xtitle("Salaire Horaire Nominal en multiple de SMIC" "(Tronq. extr. 1% salaire nominal)") ytitle("Changement (%) du salaire horaire nominal ") ///
	title("Croissance annuelle salaire horaire nominal:" "salariés sans changement d'entreprise, sans pondération", size(small)) legend(on order(1 "Moyenne" 2 "Médiane" 3 "25p & 75p") size(large) ring(0) bplacement(north)) name(Nominal2,replace) saving("C:\Users\Public\Documents\Etienne-Pranav-Christian\DADSpanelGraphs_pm\Multiyear\Essai\g_sbrut_smicFR", replace)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_smicFR_bb${bbins}_movers${mmmover}_ww${weight}.png", replace 

restore


************************************
*            Full sample with 10p and 90p  Hours Not weighted        *
************************************
* Control table for extraction 

bysort groupp1s_1: summ dhsrw hsrw_mult_1 hsrw_mult if groupp1s_1>=100

preserve

	collapse (mean)  dhsrw (max) hsrw_mult_1 hsrw_mult (median)  dhsrw_m=dhsrw  (p25)  dhsrw_25=dhsrw  (p75)  dhsrw_75=dhsrw  (p10)  dhsrw_10=dhsrw  (p90)  dhsrw_90=dhsrw, by(groupp1s_1)
	global weight  "0"
	**** En Anglais
	graph twoway (connected  dhsrw hsrw_mult_1 if hsrw_mult_1<=500 & hsrw_mult_1>=100, sort mcolor(red) lwidth(medthick)) ///
	(line  dhsrw_m hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(blue) lwidth(medthick)) ///
	(line  dhsrw_25 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) ///
	(line  dhsrw_10 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick) lpattern(dash)) ///
	(line  dhsrw_90 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick) lpattern(dash)) ///
	(line  dhsrw_75 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) , legend(off) ylabel(-5[5]80,  labsize(small))  ylabel(,grid glcolor(gs13))  xtitle("Nominal hourly wage as a share of SMIC" "(Truncation nominal wages)") ytitle("Change in Nominal hourly wage (%) ") ///
	title("Annual Growth in hourly Nominal wages:" "w/o movers, unweighted hours", size(small)) legend(on order(1 "Mean" 2 "Median" 3 "25p & 75p" 4 "10p & 90p") size(large) ring(0) bplacement(north)) name(Nominal2,replace) saving("C:\Users\Public\Documents\Etienne-Pranav-Christian\DADSpanelGraphs_pm\Multiyear\Essai\g_sbrut_smic", replace)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_smic_bb${bbins}_movers${mmmover}_ww${weight}_1090.png", replace 
	export delimited "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_smic_bb${bbins}_movers${mmmover}_ww${weight}_1090.csv", replace
		
	*** En francais 
	graph twoway (connected  dhsrw hsrw_mult_1 if hsrw_mult_1<=500 & hsrw_mult_1>=100, sort mcolor(red) lwidth(medthick)) ///
	(line  dhsrw_m hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(blue) lwidth(medthick)) ///
	(line  dhsrw_25 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) ///
	(line  dhsrw_10 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick) lpattern(dash)) ///
	(line  dhsrw_90 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick) lpattern(dash)) ///
	(line  dhsrw_75 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) , legend(off) ylabel(-5[5]70,  labsize(small))  ylabel(,grid glcolor(gs13))  xtitle("Salaire Horaire Nominal en multiple de SMIC" "(Tronq. extr. 1% salaire nominal)") ytitle("Changement (%) du salaire horaire nominal ") ///
	title("Croissance annuelle salaire horaire nominal:" "salariés sans changement d'entreprise, sans pondération") legend(on order(1 "Moyenne" 2 "Médiane" 3 "25p & 75p" 4 "10p & 90p") size(large) ring(0) bplacement(north)) name(Nominal2,replace) saving("C:\Users\Public\Documents\Etienne-Pranav-Christian\DADSpanelGraphs_pm\Multiyear\Essai\g_sbrut_smicFR", replace)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_smicFR_bb${bbins}_movers${mmmover}_ww${weight}_1090.png", replace 

restore

***************************************************
*            Full sample   Hours Weighted      *
***************************************************
* Control table for extraction 

bysort groupp1s_1: summ dhsrw hsrw_mult_1 hsrw_mult if groupp1s_1>=100

preserve

	*collapse (mean)  dhsrw [aweight=hhweight] (max) hsrw_mult_1 hsrw_mult (median)  dhsrw_m=dhsrw [aweight=hhweight] (p25)  dhsrw_25=dhsrw  [aweight=hhweight] (p75)  dhsrw_75=dhsrw [aweight=hhweight] (p10)  dhsrw_10=dhsrw [aweight=hhweight] (p90) dhsrw_90=dhsrw [aweight=hhweight], by(groupp1s_1)
	
	collapse (mean)  dhsrw (max) hsrw_mult_1 (median)  dhsrw_m=dhsrw (p25)  dhsrw_25=dhsrw  (p75)  dhsrw_75=dhsrw (p10)  dhsrw_10=dhsrw (p90) dhsrw_90=dhsrw [aweight=hhweight], by(groupp1s_1)
	global weight  "1"
	**** En Anglais
	graph twoway (connected  dhsrw hsrw_mult_1 if hsrw_mult_1<=500 & hsrw_mult_1>=100, sort mcolor(red) lwidth(medthick)) ///
	(line  dhsrw_m hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(blue) lwidth(medthick)) ///
	(line  dhsrw_25 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) ///
	(line  dhsrw_75 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) , legend(off) ylabel(-5[5]35,  labsize(small))  ylabel(,grid glcolor(gs13))  xtitle("Nominal hourly wage as a share of SMIC" "(Truncation nominal wages)") ytitle("Change in Nominal hourly wage (%) ") ///
	title("Annual Growth in hourly Nominal wages:" "w/o movers, weighted hours", size(small)) legend(on order(1 "Mean" 2 "Median" 3 "25p & 75p") size(large) ring(0) bplacement(north)) name(Nominal2,replace) saving("C:\Users\Public\Documents\Etienne-Pranav-Christian\DADSpanelGraphs_pm\Multiyear\Essai\g_sbrut_smic", replace)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_smic_bb${bbins}_movers${mmmover}_ww${weight}.png", replace 
	export delimited "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_smic_bb${bbins}_movers${mmmover}_ww${weight}.csv", replace
		
	*** En francais 
	graph twoway (connected  dhsrw hsrw_mult_1 if hsrw_mult_1<=500 & hsrw_mult_1>=100, sort mcolor(red) lwidth(medthick)) ///
	(line  dhsrw_m hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(blue) lwidth(medthick)) ///
	(line  dhsrw_25 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) ///
	(line  dhsrw_75 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) , legend(off) ylabel(-5[5]30,  labsize(small))  ylabel(,grid glcolor(gs13))  xtitle("Salaire Horaire Nominal en multiple de SMIC" "(Tronq. extr. 1% salaire nominal)") ytitle("Changement (%) du salaire horaire nominal ") ///
	title("Croissance annuelle salaire horaire nominal:" "salariés sans changement d'entreprise, avec pondération par les heures travaillées") legend(on order(1 "Moyenne" 2 "Médiane" 3 "25p & 75p") size(large) ring(0) bplacement(north)) name(Nominal2,replace) saving("C:\Users\Public\Documents\Etienne-Pranav-Christian\DADSpanelGraphs_pm\Multiyear\Essai\g_sbrut_smicFR", replace)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_smicFR_bb${bbins}_movers${mmmover}_ww${weight}.png", replace 

restore

***************************************************
*            Full sample   with 10p and 90p Hours Weighted      *
***************************************************
* Control table for extraction 

bysort groupp1s_1: summ dhsrw hsrw_mult_1 hsrw_mult if groupp1s_1>=100

preserve

	collapse (mean)  dhsrw (max) hsrw_mult_1 (median)  dhsrw_m=dhsrw (p25)  dhsrw_25=dhsrw  (p75)  dhsrw_75=dhsrw (p10)  dhsrw_10=dhsrw (p90) dhsrw_90=dhsrw [aweight=hhweight], by(groupp1s_1)
	global weight "1"
	**** En Anglais
	graph twoway (connected  dhsrw hsrw_mult_1 if hsrw_mult_1<=500 & hsrw_mult_1>=100, sort mcolor(red) lwidth(medthick)) ///
	(line  dhsrw_m hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(blue) lwidth(medthick)) ///
	(line  dhsrw_25 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) ///
	(line  dhsrw_10 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick) lpattern(dash)) ///
	(line  dhsrw_90 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick) lpattern(dash)) ///
	(line  dhsrw_75 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) , legend(off) ylabel(-5[5]70,  labsize(small))  ylabel(,grid glcolor(gs13))  xtitle("Nominal hourly wage as a share of SMIC" "(Truncation nominal wages)") ytitle("Change in Nominal hourly wage (%) ") ///
	title("Annual Growth in hourly Nominal wages: w/o movers, weighted hours") legend(on order(1 "Mean" 2 "Median" 3 "25p & 75p " 4 "10p & 90p") size(large) ring(0) bplacement(north)) name(Nominal2,replace) saving("C:\Users\Public\Documents\Etienne-Pranav-Christian\DADSpanelGraphs_pm\Multiyear\Essai\g_sbrut_smic", replace)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_smic_bb${bbins}_movers${mmmover}_ww${weight}.png", replace 
	export delimited "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_smic_bb${bbins}_movers${mmmover}_ww${weight}.csv", replace
		
	*** En francais 
	graph twoway (connected  dhsrw hsrw_mult_1 if hsrw_mult_1<=500 & hsrw_mult_1>=100, sort mcolor(red) lwidth(medthick)) ///
	(line  dhsrw_m hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(blue) lwidth(medthick)) ///
	(line  dhsrw_25 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) ///
	(line  dhsrw_10 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick) lpattern(dash)) ///
	(line  dhsrw_90 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick) lpattern(dash)) ///
	(line  dhsrw_75 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) , legend(off) ylabel(-5[5]70,  labsize(small))  ylabel(,grid glcolor(gs13))  xtitle("Salaire Horaire Nominal en multiple de SMIC" "(Tronq. extr. 1% salaire nominal)") ytitle("Changement (%) du salaire horaire nominal ") ///
	title("Croissance annuelle salaire horaire nominal:" "salariés sans changement d'entreprise, avec pondération par les heures travaillées") legend(on order(1 "Moyenne" 2 "Médiane" 3 "25p & 75p" 4 "10p & 90p") size(large) ring(0) bplacement(north)) name(Nominal2,replace) saving("C:\Users\Public\Documents\Etienne-Pranav-Christian\DADSpanelGraphs_pm\Multiyear\Essai\g_sbrut_smicFR", replace)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_smicFR_bb${bbins}_movers${mmmover}_ww${weight}.png", replace 

restore

***************************************************
*            Full Time, Full Year  sample        *
***************************************************
* Control table for extraction 

bysort groupp1s_1: summ dhsrw hsrw_mult_1 hsrw_mult if groupp1s_1>=100

preserve

	drop if cpfd !="C"    /*Full Time this year*/
	drop if cpfd_1 !="C"   /*Full Time the previous year*/
	keep if ddur ==1 & duree==360 /*Full Year = - workers who worked a duation of 360 days in the current and previous year */
	

	collapse (mean)  dhsrw (max) hsrw_mult_1 hsrw_mult (median)  dhsrw_m=dhsrw  (p25)  dhsrw_25=dhsrw  (p75)  dhsrw_75=dhsrw  (p10)  dhsrw_10=dhsrw  (p90)  dhsrw_90=dhsrw, by(groupp1s_1)
	global weight "0"

	**** En Anglais
	graph twoway (connected  dhsrw hsrw_mult_1 if hsrw_mult_1<=500 & hsrw_mult_1>=100, sort mcolor(red) lwidth(medthick)) ///
	(line  dhsrw_m hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(blue) lwidth(medthick)) ///
	(line  dhsrw_25 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) ///
	(line  dhsrw_75 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) , legend(off) ylabel(-5[5]30,  labsize(small))  ylabel(,grid glcolor(gs13))  xtitle("Nominal hourly wage as a share of SMIC" "(Truncation nominal wages)") ytitle("Change in Nominal hourly wage (%) ") ///
	title("Annual Growth in hourly Nominal wages:  w/o movers, full time and full year") legend(on order(1 "Mean" 2 "Median" 3 "25p & 75p") size(large) ring(0) bplacement(north)) name(Nominal2,replace) saving("C:\Users\Public\Documents\Etienne-Pranav-Christian\DADSpanelGraphs_pm\Multiyear\Essai\g_sbrut_smic", replace)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_smic_bb${bbins}_movers${mmmover}_ww${weight}_FTFY.png", replace 
	export delimited "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_smic_bb${bbins}_movers${mmmover}_ww${weight}_FTFY.csv", replace
		
	*** En francais 
	graph twoway (connected  dhsrw hsrw_mult_1 if hsrw_mult_1<=500 & hsrw_mult_1>=100, sort mcolor(red) lwidth(medthick)) ///
	(line  dhsrw_m hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(blue) lwidth(medthick)) ///
	(line  dhsrw_25 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) ///
	(line  dhsrw_75 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) , legend(off) ylabel(-5[5]30,  labsize(small))  ylabel(,grid glcolor(gs13))  xtitle("Salaire Horaire Nominal en multiple de SMIC" "(Tronq. extr. 1% salaire nominal)") ytitle("Changement (%) du salaire horaire nominal ") ///
	title("Croissance annuelle salaire horaire nominal:" "salariés sans changement d'entreprise, travailleurs à temps plein et année complète") legend(on order(1 "Moyenne" 2 "Médiane" 3 "25p & 75p") size(large) ring(0) bplacement(north)) name(Nominal2,replace) saving("C:\Users\Public\Documents\Etienne-Pranav-Christian\DADSpanelGraphs_pm\Multiyear\Essai\g_sbrut_smicFR", replace)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_smicFR_bb${bbins}_movers${mmmover}_ww${weight}_FTFY.png", replace 

restore

***************************************************
*            Full Time, Full Year  sample   10p 90p    *
***************************************************
* Control table for extraction 

bysort groupp1s_1: summ dhsrw hsrw_mult_1 hsrw_mult if groupp1s_1>=100

preserve

	drop if cpfd !="C"    /*Full Time this year*/
	drop if cpfd_1 !="C"   /*Full Time the previous year*/
	keep if ddur ==1 & duree==360 /*Full Year = - workers who worked a duation of 360 days in the current and previous year */
	

	collapse (mean)  dhsrw (max) hsrw_mult_1 hsrw_mult (median)  dhsrw_m=dhsrw  (p25)  dhsrw_25=dhsrw  (p75)  dhsrw_75=dhsrw  (p10)  dhsrw_10=dhsrw  (p90)  dhsrw_90=dhsrw, by(groupp1s_1)
	global weight "0"

	**** En Anglais
	graph twoway (connected  dhsrw hsrw_mult_1 if hsrw_mult_1<=500 & hsrw_mult_1>=100, sort mcolor(red) lwidth(medthick)) ///
	(line  dhsrw_m hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(blue) lwidth(medthick)) ///
	(line  dhsrw_25 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) ///
	(line  dhsrw_10 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick) lpattern(dash)) ///
	(line  dhsrw_90 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick) lpattern(dash)) ///
	(line  dhsrw_75 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) , legend(off) ylabel(-5[5]70,  labsize(small))  ylabel(,grid glcolor(gs13))  xtitle("Nominal hourly wage as a share of SMIC" "(Truncation nominal wages)") ytitle("Change in Nominal hourly wage (%) ") ///
	title("Annual Growth in hourly Nominal wages:  w/o movers, full time and full year") legend(on order(1 "Mean" 2 "Median" 3 "25p & 75p" 4 "10p & 90p") size(large) ring(0) bplacement(north)) name(Nominal2,replace) saving("C:\Users\Public\Documents\Etienne-Pranav-Christian\DADSpanelGraphs_pm\Multiyear\Essai\g_sbrut_smic", replace)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_smic_bb${bbins}_movers${mmmover}_ww${weight}_FTFY_1090.png", replace 
	export delimited "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_smic_bb${bbins}_movers${mmmover}_ww${weight}_FTFY_1090.csv", replace
		
	*** En francais 
	graph twoway (connected  dhsrw hsrw_mult_1 if hsrw_mult_1<=500 & hsrw_mult_1>=100, sort mcolor(red) lwidth(medthick)) ///
	(line  dhsrw_m hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(blue) lwidth(medthick)) ///
	(line  dhsrw_25 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) ///
	(line  dhsrw_10 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick) lpattern(dash)) ///
	(line  dhsrw_90 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick) lpattern(dash)) ///
	(line  dhsrw_75 hsrw_mult_1 if hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) , legend(off) ylabel(-5[5]70,  labsize(small))  ylabel(,grid glcolor(gs13))  xtitle("Salaire Horaire Nominal en multiple de SMIC" "(Tronq. extr. 1% salaire nominal)") ytitle("Changement (%) du salaire horaire nominal ") ///
	title("Croissance annuelle salaire horaire nominal:" "salariés sans changement d'entreprise, travailleurs à temps plein et année complète") legend(on order(1 "Moyenne" 2 "Médiane" 3 "25p & 75p" 4 "10p & 90p") size(large) ring(0) bplacement(north)) name(Nominal2,replace) saving("C:\Users\Public\Documents\Etienne-Pranav-Christian\DADSpanelGraphs_pm\Multiyear\Essai\g_sbrut_smicFR", replace)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_smicFR_bb${bbins}_movers${mmmover}_ww${weight}_FTFY_1090.png", replace 

restore



	
*****************************************
* By age categories 3, full sample
*****************************************
* Control table for extraction 

bysort age_g2 groupp1s_1: summ dhsrw hsrw_mult_1 hsrw_mult if groupp1s_1>=100 
* Nominal
preserve

	collapse (mean)  dhsrw (max) hsrw_mult_1 hsrw_mult (median)  dhsrw_m=dhsrw  (p25)  dhsrw_25=dhsrw  (p75)  dhsrw_75=dhsrw  (p10)  dhsrw_10=dhsrw  (p90)  dhsrw_90=dhsrw, by(age_g2 groupp1s_1)
   	global weight "0"
	*drop if cpfd !="C"    /*Full Time this year*/
	*drop if cpfd_1 !="C"   /*Full Time the previous year*/
	*keep if ddur ==1 & duree==360 /*Full Year = - workers who worked a duation of 360 days in the current and previous year */

	
	**** En Anglais

	graph twoway (connected  dhsrw hsrw_mult_1 if  age_g2==1525 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort mcolor(red) lwidth(medthick)) ///
	(line  dhsrw_m hsrw_mult_1 if age_g==1525 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(blue) lwidth(medthick)) ///
	(line  dhsrw_25 hsrw_mult_1 if age_g==1525 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) ///
	(line  dhsrw_75 hsrw_mult_1 if age_g==1525 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) , legend(off)  ylabel(-5[5]30,  labsize(small))  ylabel(,grid glcolor(gs13)) xtitle("Nominal hourly wage as a share of SMIC" "(Truncation nominal wages)" , size(small)) ///
	title("Annual Growth in hourly" "Nominal wages age 16-25 in (%): w/o movers" , size(small))  name(Nominal1,replace) saving("C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\g_sbrut_1525_smic", replace)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_1525_smic_bb${bbins}_movers${mmmover}_ww${weight}.png", replace 
	
	graph twoway (connected  dhsrw hsrw_mult_1 if  age_g2==2654 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort mcolor(red) lwidth(medthick)) ///
	(line  dhsrw_m hsrw_mult_1 if age_g==2654 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(blue) lwidth(medthick)) ///
	(line  dhsrw_25 hsrw_mult_1 if age_g==2654 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) ///
	(line  dhsrw_75 hsrw_mult_1 if age_g==2654 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) , legend(off)  ylabel(-5[5]30,  labsize(small))  ylabel(,grid glcolor(gs13)) xtitle("Nominal hourly wage as a share of SMIC " "(Truncation nominal wages)" , size(small)) ///
	title("Annual Growth in hourly" "Nominal wages age 26-54  in (%): w/o movers" , size(small)) name(Nominal1,replace) saving("C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\g_sbrut_2654_smic", replace)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_2654_smic_bb${bbins}_movers${mmmover}_ww${weight}.png", replace 
	
	graph twoway (connected  dhsrw hsrw_mult_1 if  age_g2==5565 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort mcolor(red) lwidth(medthick)) ///
	(line  dhsrw_m hsrw_mult_1 if age_g==5565 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(blue) lwidth(medthick)) ///
	(line  dhsrw_25 hsrw_mult_1 if age_g==5565 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) ///
	(line  dhsrw_75 hsrw_mult_1 if age_g==5565 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) , legend(off)  ylabel(-5[5]30,  labsize(small))  ylabel(,grid glcolor(gs13)) xtitle("Nominal hourly wage as a share of SMIC" "(Truncation extr. 1% nominal wages)" , size(small)) ///
	title("Annual Growth in hourly" "Nominal wages age 55-65  in (%): w/o movers" , size(small)) legend(on order(1 "Mean" 2 "Median" 3 "25p & 75p" ) size(small) ring(0) bplacement(north)) name(Nominal1,replace) saving("C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\g_sbrut_5565_smic", replace)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_5565_smic_bb${bbins}_movers${mmmover}_ww${weight}.png", replace 
	
	cd "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes"
	graph combine "g_sbrut_1525_smic" "g_sbrut_2654_smic" "g_sbrut_5565_smic"  , col(2)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_ages2_smic_bb${bbins}_movers${mmmover}_ww${weight}.png", replace
	export delimited "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_ages2_smic_bb${bbins}_movers${mmmover}_ww${weight}.csv", replace

	
	**** En Francais

	graph twoway (connected  dhsrw hsrw_mult_1 if  age_g2==1525 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort mcolor(red) lwidth(medthick)) ///
	(line  dhsrw_m hsrw_mult_1 if age_g==1525 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(blue) lwidth(medthick)) ///
	(line  dhsrw_25 hsrw_mult_1 if age_g==1525 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) ///
	(line  dhsrw_75 hsrw_mult_1 if age_g==1525 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) , legend(off)  ylabel(-5[5]30,  labsize(small))  ylabel(,grid glcolor(gs13)) xtitle("Salaire Horaire Nominal en multiple de SMIC" "(Tronq. extr. 1% salaire nominal)" , size(small)) ///
	title("Changement (%) du salaire horaire nominal" "age 16-25: salariés sans changement d'entreprise" , size(small))  name(Nominal1,replace) saving("C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\g_sbrut_1525_smicFR", replace)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_1525_smicFR_bb${bbins}_movers${mmmover}_ww${weight}.png", replace 
	
	graph twoway (connected  dhsrw hsrw_mult_1 if  age_g2==2654 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort mcolor(red) lwidth(medthick)) ///
	(line  dhsrw_m hsrw_mult_1 if age_g==2654 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(blue) lwidth(medthick)) ///
	(line  dhsrw_25 hsrw_mult_1 if age_g==2654 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) ///
	(line  dhsrw_75 hsrw_mult_1 if age_g==2654 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) , legend(off)  ylabel(-5[5]30,  labsize(small))  ylabel(,grid glcolor(gs13)) xtitle("Salaire Horaire Nominal en multiple de SMIC" "(Tronq. extr. 1% salaire nominal)" , size(small)) ///
	title("Changement (%) du salaire horaire nominal" "age 26-54: salariés sans changement d'entreprise" , size(small)) name(Nominal1,replace) saving("C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\g_sbrut_2654_smicFR", replace)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_2654_smicFR_bb${bbins}_movers${mmmover}_ww${weight}.png", replace 
	
	graph twoway (connected  dhsrw hsrw_mult_1 if  age_g2==5565 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort mcolor(red) lwidth(medthick)) ///
	(line  dhsrw_m hsrw_mult_1 if age_g==5565 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(blue) lwidth(medthick)) ///
	(line  dhsrw_25 hsrw_mult_1 if age_g==5565 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) ///
	(line  dhsrw_75 hsrw_mult_1 if age_g==5565 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) , legend(off)  ylabel(-5[5]30,  labsize(small))  ylabel(,grid glcolor(gs13)) xtitle("Salaire Horaire Nominal en multiple de SMIC" "(Tronq. extr. 1% salaire nominal)" , size(small)) ///
	title("Changement (%) du salaire horaire nominal" "age 55-65: salariés sans changement d'entreprise" , size(small)) legend(on order(1 "Moyenne" 2 "Médiane" 3 "25p & 75p") size(small) ring(0) bplacement(north)) name(Nominal1,replace) saving("C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\g_sbrut_5565_smicFR", replace)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_5565_smicFR_bb${bbins}_movers${mmmover}_ww${weight}.png", replace 
	
	cd "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes"
	graph combine "g_sbrut_1525_smicFR" "g_sbrut_2654_smicFR" "g_sbrut_5565_smicFR"  , col(2)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_ages2_smicFR_bb${bbins}_movers${mmmover}_ww${weight}.png", replace
restore

	

******************************
* By tenure categories  full sample
******************************
* Control table for extraction 

bysort ts4 groupp1s_1: summ dhsrw hsrw_mult_1 hsrw_mult if groupp1s_1>=100 
* Nominal
preserve

    collapse (mean)  dhsrw (max) hsrw_mult_1 hsrw_mult (median)  dhsrw_m=dhsrw hsrw_mult_1_m= hsrw_mult_1 (p25)  dhsrw_25=dhsrw  (p75)  dhsrw_75=dhsrw  (p10)  dhsrw_10=dhsrw  (p90)  dhsrw_90=dhsrw, by(ts4 groupp1s_1)
   global weight "0"
	*drop if cpfd !="C"    /*Full Time this year*/
	*drop if cpfd_1 !="C"   /*Full Time the previous year*/
	*keep if ddur ==1 & duree==360 /*Full Year = - workers who worked a duation of 360 days in the current and previous year */


	**** En Anglais
	
	graph twoway (connected  dhsrw hsrw_mult_1 if  ts4==1 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort mcolor(red) lwidth(medthick)) ///
	(line  dhsrw_m hsrw_mult_1 if ts4==1 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(blue) lwidth(medthick)) ///
	(line  dhsrw_25 hsrw_mult_1 if ts4==1 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) ///
	(line  dhsrw_75 hsrw_mult_1 if ts4==1 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) , legend(off)  ylabel(-5[5]30,  labsize(small))  ylabel(,grid glcolor(gs13)) xtitle("Nominal hourly wage as a share of SMIC" "(Truncation nominal wages)", size(small)) ytitle("Change in Nominal hourly wage (%) ", size(small)) ///
	title("Annual Growth in hourly" "Nominal wages  Short Tenure <2 Years: w/o movers", size(small)) legend(on order(1 "Mean" 2 "Median" 3 "25p & 75p") size(small) ring(0) bplacement(north)) name(Nominal1,replace) saving("C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\g_sbrut_short_smic", replace)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_short_smic_bb${bbins}_movers${mmmover}_ww${weight}.png", replace 
	
	graph twoway (connected  dhsrw hsrw_mult_1 if  ts4==0 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort mcolor(red) lwidth(medthick)) ///
	(line  dhsrw_m hsrw_mult_1 if  ts4==0 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(blue) lwidth(medthick)) ///
	(line  dhsrw_25 hsrw_mult_1 if  ts4==0 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) ///
	(line  dhsrw_75 hsrw_mult_1 if  ts4==0 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) , legend(off)  ylabel(-5[5]30,  labsize(small))  ylabel(,grid glcolor(gs13)) xtitle("Nominal hourly wage as a share of SMIC" "(Truncation nominal wages)", size(small)) ytitle("Change in Nominal hourly wage (%) ", size(small)) ///
	title("Annual Growth in hourly" "Nominal wages  Long Tenure >=2 & <=20 Years: w/o movers", size(small)) legend(on order(1 "Mean" 2 "Median" 3 "25p & 75p") size(small) ring(0) bplacement(north)) name(Nominal2,replace) saving("C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\g_sbrut_long_smic", replace)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_long_smic_bb${bbins}_movers${mmmover}_ww${weight}.png", replace 

	
	cd "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes"
	graph combine  "g_sbrut_short_smic" "g_sbrut_long_smic" , col(3)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_tenure_smic_bb${bbins}_movers${mmmover}_ww${weight}.png", replace	
	export delimited "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_tenure_smic_bb${bbins}_movers${mmmover}_ww${weight}.csv", replace
	
	**** En Francais
	
	
	graph twoway (connected  dhsrw hsrw_mult_1 if  ts4==1 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort mcolor(red) lwidth(medthick)) ///
	(line  dhsrw_m hsrw_mult_1 if ts4==1 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(blue) lwidth(medthick)) ///
	(line  dhsrw_25 hsrw_mult_1 if ts4==1 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) ///
	(line  dhsrw_75 hsrw_mult_1 if ts4==1 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) , legend(off)  ylabel(-5[5]30,  labsize(small))  ylabel(,grid glcolor(gs13)) xtitle("Salaire Horaire Nominal en multiple de SMIC" "(Tronq. extr. 1% salaire nominal)", size(small)) ///
	title("Changement (%) du salaire horaire nominal" "Nominal wages  court durée <2 ans: sans mobilité", size(small)) legend(on order(1 "Moyenne" 2 "Médiane" 3 "25p & 75p") size(small) ring(0) bplacement(north)) name(Nominal1,replace) saving("C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\g_sbrut_short_smicFR", replace)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_short_smicFR_bb${bbins}_movers${mmmover}_ww${weight}.png", replace 
	
	graph twoway (connected  dhsrw hsrw_mult_1 if  ts4==0 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort mcolor(red) lwidth(medthick)) ///
	(line  dhsrw_m hsrw_mult_1 if  ts4==0 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(blue) lwidth(medthick)) ///
	(line  dhsrw_25 hsrw_mult_1 if  ts4==0 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) ///
	(line  dhsrw_75 hsrw_mult_1 if  ts4==0 & hsrw_mult_1<500 & hsrw_mult_1>=100, sort lcolor(green) lwidth(medthick)) , legend(off)  ylabel(-5[5]30,  labsize(small))  ylabel(,grid glcolor(gs13)) xtitle("Salaire Horaire Nominal en multiple de SMIC" "(Tronq. extr. 1% salaire nominal)", size(small)) ///
	title("Changement (%) du salaire horaire nominal" "Nominal wages  long durée >=2 & <=20 ans: sans mobilité", size(small)) legend(on order(1 "Moyenne" 2 "Médiane" 3 "25p & 75p") size(small) ring(0) bplacement(north)) name(Nominal2,replace) saving("C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\g_sbrut_long_smicFR", replace)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_long_smicFR_bb${bbins}_movers${mmmover}_ww${weight}.png", replace 

	
	cd "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes"
	graph combine  "g_sbrut_short_smicFR" "g_sbrut_long_smicFR" , col(3)
	graph export "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\gmean_sbrut_tenure_smicFR_bb${bbins}_movers${mmmover}_ww${weight}.png", replace	
	
	
restore



	
	
