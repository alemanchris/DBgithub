* This code uses the cross section DADS_post to compute hourly wage growth 
*
*forval iii = 1/1 {
* Load data
	use "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\dadspost18.dta", clear

* Data cleaning

* Convert to lower case
	rename *,lower

* Count number of initial observations
	quietly des
	local obs = r(N)
	* 5,008,932
* Impute hours of the full time
	
	
* Drop if number of hours worked if empty ** EW : no negative 5M becomes 3.7M 
	drop if nbheur == . | nbheur <= 0
	quietly des
	local obs_nbheur = r(N)

	
* Drop if number of hours worked if empty in the previous year** * EW : no negative , 3.7M becomes 2.38M
	drop if nbheur_1 == . | nbheur_1 <= 0  
	quietly des
	local obs_nbheur_1 = r(N)
	
* Hours Weight
	gen hhweight = nbheur_1/2080
	
* I drop observations for which the siren is not well identified *
	drop if siren == "" | siren == "000000000"
** EW no delete
	
* Keep only private sector firms: Drop catjur 4, 7 and 9
	/*Aseem Code*/
	
	gen cj = substr(catjur, 1, 1)
	drop if cj=="4" | cj=="7" | cj=="9"
	* EW (709,490 observations deleted) * remains 1,670M
	*drop if cj=="1" | cj=="4" | cj=="7" | cj=="9"
	quietly des
	local obs_cj_select = r(N)	
	drop if catjur == ""
	quietly des
	local obs_cj_miss = r(N)	
	drop catjur
	
* Duration of the contract
	
	gen year = 2018
	gen date_cont = date(date_debut_contrat, "YMD") 
	gen year_start = year(date_cont)
	gen tenure = year-year_start
	gen ts4 = .
	replace ts4 = 1 if tenure<2
	replace ts4 = 0 if tenure<=20 & tenure>=2 & tenure!=.
	 
	
	/* Xabier suggestion to deal with private sector*/
	/*
	keep if domempl_empl == "4" ///
		| domempl_empl == "5" ///
		| domempl_empl == "6" ///
		| domempl_empl == "8" ///
		| domempl_empl == "9"
	
	keep if domempl == "4" ///
		| domempl == "5" ///
		| domempl == "6" ///
		| domempl == "8" ///
		| domempl == "9"
		
	keep if domempl_empl_1 == "4" ///
		| domempl_empl_1 == "5" ///
		| domempl_empl_1 == "6" ///
		| domempl_empl_1 == "8" ///
		| domempl_empl_1 == "9"
	
	keep if domempl_1 == "4" ///
		| domempl_1 == "5" ///
		| domempl_1 == "6" ///
		| domempl_1 == "8" ///
		| domempl_1 == "9"
	*/
		
		********* MOVED TO THE END***********************
* Keep Ordinary workers and firms with at least 10 employees
	*keep if typ_emploi =="O" /*keep ordinary, remove stagiaires*/
	*keep if typ_emploi_1 =="O"
** EW drop 46,618 and 8,694
	
* Keep firms with at laest 10 employees
	*keep if eff_0101>=10
    *keep if eff_0101_1>=10
	
* Nombre d'effectifs  2 is from 5 to 9 
	destring treffen, replace
	*keep if treffen>2 moved below

	***********************************************
	
* Industry (economic activity according to NAF classification) *
	
	encode apen, gen(sectt)
	
* Departement Remove SAUF FOTM and corse*
	*drop if dept =="971" /*Guadaloupe*/
	*drop if dept =="972" /*Martinique*/
	*drop if dept =="973" /*Guyane*/
	*drop if dept =="974" /*Reunion*/
	drop if dept =="975" /*Dont know*/
	drop if dept =="976" /*Mayotte*/
	drop if dept =="977" /*Dont Know  but few observations*/
	drop if dept =="978" /*Dont Know  but few observations*/
	drop if dept =="986" /*Dont Know  but few observations*/
	drop if dept =="987" /*Dont Know  but few observations*/
	drop if dept =="988" /*Dont Know  but few observations*/
	drop if dept =="2A" /*Corse du sud*/
	drop if dept =="2B" /*Haute Corse */
								
	encode dept, gen(regg)

* type of contract
	destring contrat_travail contrat_travail_1, replace /* CDD CDI*/

* National or not 
	gen national=1 if dep_naiss!=""  /* Department de naissance*/
	replace national=0 if dep_naiss=="96"
	replace national=0 if dep_naiss=="97"
	replace national=0 if dep_naiss=="98"
	replace national=0 if dep_naiss=="99"
	
* Keep those who work the full year
	gen ddur = .
	replace ddur = 1 if duree==duree_1	
	*keep if ddur ==1 & duree==360
	
	
* Consistent sample selection: Age and wages EW : drop 27,147
	drop if age<15 | age>65
	quietly des
	local obs_age = r(N)
	
* Create age caterogy
	gen age_g = .
	replace age_g = 15 if age>=15 & age<=19
	replace age_g = 20 if age>=20 & age<=24
	replace age_g = 25 if age>=25 & age<=34
	replace age_g = 35 if age>=35 & age<=44
	replace age_g = 45 if age>=45 & age<=54
	replace age_g = 55 if age>=55 & age<=65
	
* Alternative age grouping
	gen age_g2 = .
	replace age_g2 = 1525 if age<=25
	replace age_g2 = 2654 if age>=26 & age<=54
	replace age_g2 = 5565 if age>=55 & age<=65
	
* Eliminate negative salaries
	drop if s_brut<0 | s_brut==.
	quietly des
	local obs_brut = r(N)
	
	*drop if s_net<0 | s_net==.
	*quietly des
	*local obs_net = r(N)
	
* Keep only full time : EW drop 63,319
	
	*drop if cpfd !="C"
	quietly des
	local obs_fulltime = r(N)
	
* Keep only full time the previous year : EW drop 6,646 - remains 473,747

	*drop if cpfd_1 !="C"
	quietly des
	local obs_fulltime_1 = r(N)
	

* Convert nominal into real wages 
* Deflating gross and net wages

	
	gen cpi = .
	replace cpi=0.7806 if year == 1994
	replace cpi=0.7946 if year == 1995
	replace cpi=0.8104 if year == 1996
	replace cpi=0.8202 if year == 1997
	replace cpi=0.8255 if year == 1998
	replace cpi=0.8299 if year == 1999
	replace cpi=0.8438 if year == 2000
	replace cpi=0.8576 if year == 2001
	replace cpi=0.8741 if year == 2002
	replace cpi=0.8925 if year == 2003
	replace cpi=0.9116 if year == 2004
	replace cpi=0.9275 if year == 2005
	replace cpi=0.9431 if year == 2006
	replace cpi=0.9571 if year == 2007
	replace cpi=0.9840 if year == 2008
	replace cpi=0.9849 if year == 2009
	replace cpi=1.0000 if year == 2010
	replace cpi=1.0211 if year == 2011	
	replace cpi=1.0410 if year == 2012
	replace cpi=1.0500 if year == 2013
	replace cpi=1.0553 if year == 2014
	replace cpi=1.0557 if year == 2015
	replace cpi=1.058 if year == 2016
	replace cpi=1.069 if year == 2017
	replace cpi=1.088 if year == 2018
	replace cpi=1.100 if year == 2019
	replace cpi=1.106 if year == 2020
	replace cpi=1.124 if year == 2021
	replace cpi=1.183 if year == 2022
	
	
	gen cpi_1 = .
	replace cpi_1=0.7806 if year == 1995
	replace cpi_1=0.7946 if year == 1996
	replace cpi_1=0.8104 if year == 1997
	replace cpi_1=0.8202 if year == 1998
	replace cpi_1=0.8255 if year == 1999
	replace cpi_1=0.8299 if year == 2000
	replace cpi_1=0.8438 if year == 2001
	replace cpi_1=0.8576 if year == 2002
	replace cpi_1=0.8741 if year == 2003
	replace cpi_1=0.8925 if year == 2004
	replace cpi_1=0.9116 if year == 2005
	replace cpi_1=0.9275 if year == 2006
	replace cpi_1=0.9431 if year == 2007
	replace cpi_1=0.9571 if year == 2008
	replace cpi_1=0.9840 if year == 2009
	replace cpi_1=0.9849 if year == 2010
	replace cpi_1=1.0000 if year == 2011
	replace cpi_1=1.0211 if year == 2012	
	replace cpi_1=1.0410 if year == 2013
	replace cpi_1=1.0500 if year == 2014
	replace cpi_1=1.0553 if year == 2015
	replace cpi_1=1.0557 if year == 2016
	replace cpi_1=1.058 if year == 2017
	replace cpi_1=1.069 if year == 2018
	replace cpi_1=1.088 if year == 2019
	replace cpi_1=1.100 if year == 2020
	replace cpi_1=1.106 if year == 2021
	replace cpi_1=1.124 if year == 2022
	replace cpi_1=1.183 if year == 2023
	


	gen r_brut = s_brut/cpi
	gen r_net = s_net/cpi
	
	gen r_brut_1 = s_brut_1/cpi_1
	gen r_net_1 = s_net_1/cpi_1
	
*-------------------------------------------------------------------------*
	
	gen smic_h =. 
	label var smic_h "Hourly SMIC"
	
	replace smic_h = 9.43  if year ==2013
	replace smic_h = 9.53  if year ==2014
	replace smic_h = 9.61  if year ==2015
	replace smic_h = 9.67  if year ==2016
	replace smic_h = 9.76  if year ==2017
	replace smic_h = 9.88  if year ==2018
	replace smic_h = 10.03 if year ==2019
	
	gen smic_h_1 =. 
	label var smic_h_1 "Hourly SMIC Previous year"
	
	replace smic_h_1 = 9.43  if year ==2014
	replace smic_h_1 = 9.53  if year ==2015
	replace smic_h_1 = 9.61  if year ==2016
	replace smic_h_1 = 9.67  if year ==2017
	replace smic_h_1 = 9.76  if year ==2018
	replace smic_h_1 = 9.88  if year ==2019
	replace smic_h_1 = 10.03 if year ==2020
	
	
* Fix siren 
	gen f_1 = substr(siren, 1,1) 
	replace siren = substr(siren, 2,.) if f_1 == "P" | f_1 == "F" | f_1 == "S"
	drop f_1
	quietly des
	local fps_siren = r(N)
	
* Duplicates drop

	duplicates drop siren ident_s sexe age pcs nbheur s_brut datdeb datfin, force
	quietly des
	local dup_drop = r(N)

	
	sort ident_s siren  nic
	*browse siren nic ident_s datdeb datdeb2 datfin datfin1 duree nb_postes_du_nir r_net nbheur
 
* Remove  people who swiched firms within the year
* (That I cannot guarantee that they didnt switch last year)

* Identify those who have moved within the same firm

	duplicates tag siren ident_s, gen(sir_ident_dup)
	tab sir_ident_dup
* Identify those who potentially swiched firms or within a firm
	duplicates tag ident_s, gen(ident_dup)
	tab ident_dup

	
	*browse siren nic ident_s datdeb datdeb2 datfin datfin1 duree nb_postes_du_nir r_net nbheur sir_ident_dup ident_dup pps
	
	* if you have no duplicates whatsoever
	* if you didnt switch jobs at all
	gen ind1 = 0
	replace ind1 = 1 if sir_ident_dup==0 & ident_dup==0
	
	* if you have duplicates in both
	* An individual is of this type if it switched jobs within the same company
	* 
	gen ind2 = 0
	replace ind2 = 1 if sir_ident_dup>0 & ident_dup>0
	
	* This measures keeps those who didnt move and those who moved within firm
	gen ind3 = ind1+ind2
	
	* Mover (proxy for mover both within firm and across firms in a given year)
	
	gen mover = 0  /**/
	replace mover = 1 if ident_dup>0
	
	
	/* Deprecated: Used to keep only those who swiched within a firm, deleted twose who switched between a firm and then across frims 
	gen del_del = sir_ident_dup-ident_dup
	gen ind4 = 0
	replace ind4 = 1 if del_del==0
	*/
	
	*keep if ind4==1  
	* EW 367 indiv deleted 
	quietly des
	local obs_duplic = r(N)
	
* Keep those who had the same employer last year
	*gen sm_firm = .
	*replace sm_firm = 1 if siren_empl==siren_empl_1
	*keep if sm_firm==1
	
	sort ident_s siren
	
	*browse siren nic siren_empl siren_empl_1 ident_s
	
	
	drop ind1 ind2 ind3 
	*del_del
	
	* Remove aggriculture
	*drop if a6=="AZ"
** EW drop 22,731
	
	
	* Generate hourly wage 
	
	* Nominal
	
	gen s_bruth   = s_brut/nbheur
    gen s_bruth_1 = s_brut_1/nbheur_1
	gen dhsrw = (s_bruth/s_bruth_1)-1
	
	/*
	gen s_bruth   = s_brut
    gen s_bruth_1 = s_brut_1
	gen dhsrw = (s_bruth/s_bruth_1)-1
	*/
	
	
	* Drop those below the minimum wage 
	/*
	drop if  r_bruth_1<(smic_h_1/cpi_1)
	quietly des
	local obs_smic = r(N)
	
	drop if  s_bruth_1<(smic_h_1)
	quietly des
	local obs_smic_1s = r(N)
	
	drop if  s_bruth<(smic_h)
	quietly des
	local obs_smic_s = r(N)
	*/

	
	
	/*Nominal*/
*	_pctile s_bruth , p(25 75 10 90) * needs to be ordered
	_pctile s_bruth , p(10 25 75 90)

/*	gen hsrw_25 = r(r1)
	gen hsrw_75 = r(r2)
	gen hsrw_10 = r(r3)
	gen hsrw_90 = r(r4) */
	gen hsrw_10 = r(r1)
	gen hsrw_25 = r(r2)
	gen hsrw_75 = r(r3)
	gen hsrw_90 = r(r4)
	
	_pctile s_bruth , p(50)
	return list
	*gen hsrw_mult = s_bruth/r(r1)*100
	gen hsrw_mult = s_bruth/smic_h*100
	gen hsrw_med = r(r1)
	*gen smic_smult = (smic_h_1)/r(r1)*100
	replace hsrw_25 = hsrw_25/r(r1)*100
	replace hsrw_75 = hsrw_75/r(r1)*100
	replace hsrw_10 = hsrw_10/r(r1)*100
	replace hsrw_90 = hsrw_90/r(r1)*100
	
	_pctile s_bruth_1 , p(10 25 75 90)
	/*gen hsrw_25_1 = r(r1)
	gen hsrw_75_1 = r(r2)
	gen hsrw_10_1 = r(r3)
	gen hsrw_90_1 = r(r4)
	*/
	gen hsrw_10_1 = r(r1)
	gen hsrw_25_1 = r(r2)
	gen hsrw_75_1 = r(r3)
	gen hsrw_90_1 = r(r4)
	
	_pctile s_bruth_1 , p(50)
	*gen hsrw_mult_1 = s_bruth_1/r(r1)*100
	gen hsrw_mult_1 = s_bruth_1/smic_h_1*100
	gen hsrw_med_1 = r(r1)
	gen smic_smult_1 = (smic_h_1)/r(r1)*100	
	replace hsrw_25_1 = hsrw_25_1/r(r1)*100
	replace hsrw_75_1 = hsrw_75_1/r(r1)*100
	replace hsrw_10_1 = hsrw_10_1/r(r1)*100
	replace hsrw_90_1 = hsrw_90_1/r(r1)*100
	gen dhsrw_med = hsrw_med/hsrw_med_1-1
	
	* definitions added by Etienne July 2
	gen dhsrw_10 = hsrw_10/hsrw_10_1-1
	gen dhsrw_25 = hsrw_25/hsrw_25_1-1
	gen dhsrw_75 = hsrw_75/hsrw_25_1-1
	gen dhsrw_90 = hsrw_90/hsrw_90_1-1

	
	
	/*
	
	_pctile lhrrw , p(10,20,30,40,50,60,70,80,90)
	return list
	
	gen d1 = (lhrrw<=r(r1))
	gen d2 = (r(r1)<lhrrw & lhrrw<=r(r2))
	gen d3 = (r(r2)<lhrrw & lhrrw<=r(r3))
	gen d4 = (r(r3)<lhrrw & lhrrw<=r(r4))
	gen d5 = (r(r4)<lhrrw & lhrrw<=r(r5))
	gen d6 = (r(r5)<lhrrw & lhrrw<=r(r6))
	gen d7 = (r(r6)<lhrrw & lhrrw<=r(r7))
	gen d8 = (r(r7)<lhrrw & lhrrw<=r(r8))
	gen d9 = (r(r8)<lhrrw & lhrrw<=r(r9))
	gen d10 = (lhrrw>r(r9))
	*gen lhrrw_mult = lhrrw/r(r5)*100
	
	gen decile = 1 if d1 ==1
	replace decile = 2 if d2 ==1
	replace decile = 3 if d3 ==1
	replace decile = 4 if d4 ==1
	replace decile = 5 if d5 ==1
	replace decile = 6 if d6 ==1
	replace decile = 7 if d7 ==1
	replace decile = 8 if d8 ==1
	replace decile = 9 if d9 ==1
	replace decile = 10 if d10 ==1
	
	
	_pctile s_bruth , p(10,20,30,40,50,60,70,80,90)
	return list
	
	gen ds1 = (s_bruth<=r(r1))
	gen ds2 = (r(r1)<s_bruth & s_bruth<=r(r2))
	gen ds3 = (r(r2)<s_bruth & s_bruth<=r(r3))
	gen ds4 = (r(r3)<s_bruth & s_bruth<=r(r4))
	gen ds5 = (r(r4)<s_bruth & s_bruth<=r(r5))
	gen ds6 = (r(r5)<s_bruth & s_bruth<=r(r6))
	gen ds7 = (r(r6)<s_bruth & s_bruth<=r(r7))
	gen ds8 = (r(r7)<s_bruth & s_bruth<=r(r8))
	gen ds9 = (r(r8)<s_bruth & s_bruth<=r(r9))
	gen ds10 = (s_bruth>r(r9))
	*gen s_bruth_mult = s_bruth/r(r5)*100
	*gen lhrrw_mult = lhrrw/r(r5)*100
	
	gen deciles = 1 if ds1 ==1
	replace deciles = 2 if ds2 ==1
	replace deciles = 3 if ds3 ==1
	replace deciles = 4 if ds4 ==1
	replace deciles = 5 if ds5 ==1
	replace deciles = 6 if ds6 ==1
	replace deciles = 7 if ds7 ==1
	replace deciles = 8 if ds8 ==1
	replace deciles = 9 if ds9 ==1
	replace deciles = 10 if ds10 ==1
	
	tab deciles, summ(dhsrw)
	tab deciles, summ(s_bruth)
	*/
	
	gen ds100 = (hsrw_mult<=100)
	gen ds110 = (100<hsrw_mult & hsrw_mult<=110)
	gen ds120 = (110<hsrw_mult & hsrw_mult<=120)
	gen ds130 = (120<hsrw_mult & hsrw_mult<=130)
	gen ds140 = (130<hsrw_mult & hsrw_mult<=140)
	gen ds150 = (140<hsrw_mult & hsrw_mult<=150)
	gen ds160 = (150<hsrw_mult & hsrw_mult<=160)
	gen ds170 = (160<hsrw_mult & hsrw_mult<=170)
	gen ds180 = (170<hsrw_mult & hsrw_mult<=180)
	gen ds190 = (180<hsrw_mult & hsrw_mult<=190)
	gen ds200 = (190<hsrw_mult & hsrw_mult<=200)
	gen ds210 = (200<hsrw_mult & hsrw_mult<=210)
	gen ds220 = (210<hsrw_mult & hsrw_mult<=220)
	gen ds230 = (220<hsrw_mult & hsrw_mult<=230)
	gen ds240 = (230<hsrw_mult & hsrw_mult<=240)
	gen ds250 = (240<hsrw_mult & hsrw_mult<=250)
	gen ds260 = (250<hsrw_mult & hsrw_mult<=260)
	gen ds270 = (260<hsrw_mult & hsrw_mult<=270)
	gen ds280 = (270<hsrw_mult & hsrw_mult<=280)
	gen ds290 = (280<hsrw_mult & hsrw_mult<=290)
	gen ds300 = (290<hsrw_mult & hsrw_mult<=300)
	gen ds310 = (300<hsrw_mult & hsrw_mult<=310)
	gen ds320 = (310<hsrw_mult & hsrw_mult<=320)
	gen ds330 = (320<hsrw_mult & hsrw_mult<=330)
	gen ds340 = (330<hsrw_mult & hsrw_mult<=340)
	gen ds350 = (340<hsrw_mult & hsrw_mult<=350)
	gen ds360 = (350<hsrw_mult & hsrw_mult<=360)
	gen ds370 = (360<hsrw_mult & hsrw_mult<=370)
	gen ds380 = (370<hsrw_mult & hsrw_mult<=380)
	gen ds390 = (380<hsrw_mult & hsrw_mult<=390)
	gen ds400 = (390<hsrw_mult & hsrw_mult<=400)
	gen ds410 = (400<hsrw_mult & hsrw_mult<=410)
	gen ds420 = (410<hsrw_mult & hsrw_mult<=420)
	gen ds430 = (420<hsrw_mult & hsrw_mult<=430)
	gen ds440 = (430<hsrw_mult & hsrw_mult<=440)
	gen ds450 = (440<hsrw_mult & hsrw_mult<=450)
	gen ds460 = (450<hsrw_mult & hsrw_mult<=460)
	gen ds470 = (460<hsrw_mult & hsrw_mult<=470)
	gen ds480 = (470<hsrw_mult & hsrw_mult<=480)
	gen ds490 = (480<hsrw_mult & hsrw_mult<=490)
	gen ds500 = (490<hsrw_mult & hsrw_mult<=500)
	gen ds510 = (hsrw_mult>500)
	
		
	gen groupp1s = 100 if ds100==1	
	replace groupp1s=110 if ds110==1
	replace groupp1s=120 if ds120==1
	replace groupp1s=130 if ds130==1
	replace groupp1s=140 if ds140==1
	replace groupp1s=150 if ds150==1
	replace groupp1s=160 if ds160==1
	replace groupp1s=170 if ds170==1
	replace groupp1s=180 if ds180==1
	replace groupp1s=190 if ds190==1
	replace groupp1s=200 if ds200==1
	replace groupp1s=210 if ds210==1
	replace groupp1s=220 if ds220==1
	replace groupp1s=230 if ds230==1
	replace groupp1s=240 if ds240==1
	replace groupp1s=250 if ds250==1
	replace groupp1s=260 if ds260==1
	replace groupp1s=270 if ds270==1
	replace groupp1s=280 if ds280==1
	replace groupp1s=290 if ds290==1
	replace groupp1s=300 if ds300==1
	replace groupp1s=310 if ds310==1
	replace groupp1s=320 if ds320==1
	replace groupp1s=330 if ds330==1
	replace groupp1s=340 if ds340==1
	replace groupp1s=350 if ds350==1
	replace groupp1s=360 if ds360==1
	replace groupp1s=370 if ds370==1
	replace groupp1s=380 if ds380==1
	replace groupp1s=390 if ds390==1
	replace groupp1s=400 if ds400==1
	replace groupp1s=410 if ds410==1
	replace groupp1s=420 if ds420==1
	replace groupp1s=430 if ds430==1
	replace groupp1s=440 if ds440==1
	replace groupp1s=450 if ds450==1
	replace groupp1s=460 if ds460==1
	replace groupp1s=470 if ds470==1
	replace groupp1s=480 if ds480==1
	replace groupp1s=490 if ds490==1
	replace groupp1s=500 if ds500==1
	replace groupp1s=510 if ds510==1
	                         
	
	gen ds100_s = (hsrw_mult_1<=100)
	gen ds110_s = (100<hsrw_mult_1 & hsrw_mult_1<=110)
	gen ds120_s = (110<hsrw_mult_1 & hsrw_mult_1<=120)
	gen ds130_s = (120<hsrw_mult_1 & hsrw_mult_1<=130)
	gen ds140_s = (130<hsrw_mult_1 & hsrw_mult_1<=140)
	gen ds150_s = (140<hsrw_mult_1 & hsrw_mult_1<=150)
	gen ds160_s = (150<hsrw_mult_1 & hsrw_mult_1<=160)
	gen ds170_s = (160<hsrw_mult_1 & hsrw_mult_1<=170)
	gen ds180_s = (170<hsrw_mult_1 & hsrw_mult_1<=180)
	gen ds190_s = (180<hsrw_mult_1 & hsrw_mult_1<=190)
	gen ds200_s = (190<hsrw_mult_1 & hsrw_mult_1<=200)
	gen ds210_s = (200<hsrw_mult_1 & hsrw_mult_1<=210)
	gen ds220_s = (210<hsrw_mult_1 & hsrw_mult_1<=220)
	gen ds230_s = (220<hsrw_mult_1 & hsrw_mult_1<=230)
	gen ds240_s = (230<hsrw_mult_1 & hsrw_mult_1<=240)
	gen ds250_s = (240<hsrw_mult_1 & hsrw_mult_1<=250)
	gen ds260_s = (250<hsrw_mult_1 & hsrw_mult_1<=260)
	gen ds270_s = (260<hsrw_mult_1 & hsrw_mult_1<=270)
	gen ds280_s = (270<hsrw_mult_1 & hsrw_mult_1<=280)
	gen ds290_s = (280<hsrw_mult_1 & hsrw_mult_1<=290)
	gen ds300_s = (290<hsrw_mult_1 & hsrw_mult_1<=300)
	gen ds310_s = (300<hsrw_mult_1 & hsrw_mult_1<=310)
	gen ds320_s = (310<hsrw_mult_1 & hsrw_mult_1<=320)
	gen ds330_s = (320<hsrw_mult_1 & hsrw_mult_1<=330)
	gen ds340_s = (330<hsrw_mult_1 & hsrw_mult_1<=340)
	gen ds350_s = (340<hsrw_mult_1 & hsrw_mult_1<=350)
	gen ds360_s = (350<hsrw_mult_1 & hsrw_mult_1<=360)
	gen ds370_s = (360<hsrw_mult_1 & hsrw_mult_1<=370)
	gen ds380_s = (370<hsrw_mult_1 & hsrw_mult_1<=380)
	gen ds390_s = (380<hsrw_mult_1 & hsrw_mult_1<=390)
	gen ds400_s = (390<hsrw_mult_1 & hsrw_mult_1<=400)
	gen ds410_s = (400<hsrw_mult_1 & hsrw_mult_1<=410)
	gen ds420_s = (410<hsrw_mult_1 & hsrw_mult_1<=420)
	gen ds430_s = (420<hsrw_mult_1 & hsrw_mult_1<=430)
	gen ds440_s = (430<hsrw_mult_1 & hsrw_mult_1<=440)
	gen ds450_s = (440<hsrw_mult_1 & hsrw_mult_1<=450)
	gen ds460_s = (450<hsrw_mult_1 & hsrw_mult_1<=460)
	gen ds470_s = (460<hsrw_mult_1 & hsrw_mult_1<=470)
	gen ds480_s = (470<hsrw_mult_1 & hsrw_mult_1<=480)
	gen ds490_s = (480<hsrw_mult_1 & hsrw_mult_1<=490)
	gen ds500_s = (490<hsrw_mult_1 & hsrw_mult_1<=500)
	gen ds510_s = (hsrw_mult_1>500)
	
		
	gen groupp1s_1 = 100 if ds100_s ==1	
	replace groupp1s_1=110 if ds110_s ==1
	replace groupp1s_1=120 if ds120_s ==1
	replace groupp1s_1=130 if ds130_s ==1
	replace groupp1s_1=140 if ds140_s ==1
	replace groupp1s_1=150 if ds150_s ==1
	replace groupp1s_1=160 if ds160_s ==1
	replace groupp1s_1=170 if ds170_s ==1
	replace groupp1s_1=180 if ds180_s ==1
	replace groupp1s_1=190 if ds190_s ==1
	replace groupp1s_1=200 if ds200_s ==1
	replace groupp1s_1=210 if ds210_s ==1
	replace groupp1s_1=220 if ds220_s ==1
	replace groupp1s_1=230 if ds230_s ==1
	replace groupp1s_1=240 if ds240_s ==1
	replace groupp1s_1=250 if ds250_s ==1
	replace groupp1s_1=260 if ds260_s ==1
	replace groupp1s_1=270 if ds270_s ==1
	replace groupp1s_1=280 if ds280_s ==1
	replace groupp1s_1=290 if ds290_s ==1
	replace groupp1s_1=300 if ds300_s ==1
	replace groupp1s_1=310 if ds310_s ==1
	replace groupp1s_1=320 if ds320_s ==1
	replace groupp1s_1=330 if ds330_s ==1
	replace groupp1s_1=340 if ds340_s ==1
	replace groupp1s_1=350 if ds350_s ==1
	replace groupp1s_1=360 if ds360_s ==1
	replace groupp1s_1=370 if ds370_s ==1
	replace groupp1s_1=380 if ds380_s ==1
	replace groupp1s_1=390 if ds390_s ==1
	replace groupp1s_1=400 if ds400_s ==1
	replace groupp1s_1=410 if ds410_s ==1
	replace groupp1s_1=420 if ds420_s ==1
	replace groupp1s_1=430 if ds430_s ==1
	replace groupp1s_1=440 if ds440_s ==1
	replace groupp1s_1=450 if ds450_s ==1
	replace groupp1s_1=460 if ds460_s ==1
	replace groupp1s_1=470 if ds470_s ==1
	replace groupp1s_1=480 if ds480_s ==1
	replace groupp1s_1=490 if ds490_s ==1
	replace groupp1s_1=500 if ds500_s ==1
	replace groupp1s_1=510 if ds510_s ==1
	
		save "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\dadspost18_clean_before_trim.dta", replace
		
		*use "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\dadspost18_clean_before_trim.dta", clear
	
	**********************************************************************
	* TRIM Ordinary Workers and Self Employed
	**********************************************************************

	

	
	* Keep Ordinary workers and firms with at least 10 employees
	keep if typ_emploi =="O" /*keep ordinary, remove stagiaires*/
	keep if typ_emploi_1 =="O"
** EW drop 47,403 and 8,769 left 1,579,377
	
* Keep firms with at laest 10 employees
	*keep if eff_0101>=10
    *keep if eff_0101_1>=10
	
* Nombre d'effectifs  2 is from 5 to 9 
	*destring treffen, replace
	keep if treffen>2 
	** EW: drop another 548,901
	** EW left with 1,030M
	
	**********************************************************************
	* TRIM top 1% and bot 1%
	**********************************************************************
	
	* Here I get smaller growth
	/*
	_pctile s_bruth , p(1 99)
	drop if s_bruth<r(r1) | s_bruth>r(r2)
	** EW : 9,466 del
	
	_pctile s_bruth_1 , p(1 99)
	drop if s_bruth_1<r(r1) | s_bruth_1>r(r2)
			** EW : 9,278 del
*/
	
	
	* Here I get larger growth
	
	_pctile s_brut , p(1 99)
	drop if s_brut<r(r1) | s_brut>r(r2)
	* DROP 20,608
	
	_pctile s_brut_1 , p(1 99)
	drop if s_brut_1<r(r1) | s_brut_1>r(r2)
		* DROP 20,196 left 989,672
	
		* Same number of observations per bin
	
	xtile dd_del_aux = groupp1s_1, nq(42)
	egen groupp1s_1_51 = mean(groupp1s_1), by(dd_del_aux)
	

	
	
	/* Change in ranking Nominal*/
	gen dsrank = hsrw_mult-hsrw_mult_1
	gen share_pos_sg=.
	replace share_pos_sg=0 if  dsrank!=.
	replace share_pos_sg=1 if  dsrank>0 & share_pos_sg==0
	gen share_pos_sng=.
	replace share_pos_sng=0 if  dsrank!=.
	replace share_pos_sng=1 if  dsrank<0 & share_pos_sng==0
	
	
		/* For controls*/
	
	destring sexe, replace
	destring pps, replace    /* Poste Principal*/
	destring pps_1, replace /* Poste Principal last year*/
	destring filt, replace      /* 2 Poste annexe, I keep only 1*/
	destring filt_1, replace
	
	/*Express x axis in percentage terms  */
	replace  dhsrw =  dhsrw*100
/* COMMENTED AS PER CHRISTIAN juky 2
	replace  dhsrw_m =  dhsrw_m*100
	replace  dhsrw_25 =  dhsrw_25*100
	replace  dhsrw_10 =  dhsrw_10*100
	replace  dhsrw_90 =  dhsrw_90*100
	replace  dhsrw_75 =  dhsrw_75*100
*/	
	save "C:\Users\Public\Documents\Etienne-Pranav-Christian\DADS  Postes\dadspost18_clean_sept.dta", replace
	
	
