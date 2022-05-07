
************************ Set up***************************

cd "C:\Users\user\Dropbox\내 PC (LAPTOP-ODROTJ7E)\Desktop\Dropbox\korea_ktx\JK\data\인구이동통계\netflow" 
use town_final_MK, clear
drop id_town name_town id_town_hk name_town_hk 
sort id_town year

* fill in missings

foreach x of varlist prov_city - dist_ktx2{
bysort id_town: replace `x'=`x'[_n-1] if `x'==.
}
foreach x of varlist dist_jejuap - dist_gangreung{
bysort id_town: replace `x'=`x'[_n-1] if `x'==.
}
foreach x of varlist id_cnty id_prov station {
bysort id_town: replace `x'=`x'[_n-1] if `x'==""	
}

merge m:1 station using ktx_id2, nogen

destring id_prov, gen(id_prov2)
destring id_cnty, gen(id_cnty2)
destring id_town, gen(id_town2)

format id_town2 %13.0g

****** drop observations

drop if id_prov2==50 // drop jejoo do
drop if id_prov2==42 // drop gangwon
drop if id_cnty2==47940 // drop uellueing island
drop if id_cnty2==28720 // drop oogjin gun island
drop if id_cnty2==46130 // drop nammyeon island

*keep if id_prov2==50 // keep jejoo do
*drop if id_prov2==45 // drop Jeolla N
*drop if id_prov2==46 // drop Jeolla S
*keep if id_prov2==45 | id_prov2==46 // jeolla only
*keep if id_prov2==42  // gangwon only

drop if year<=1993

**** drop vars
drop Lmed* Lmin* Lmax* Lstd*

** gen year var
gen yearopn = year-opening
gen yearann = year-announcement

**** gen post var
gen post2004 = (year>=2004)
gen postopn = (yearopn>=0)
gen postann = (yearann>=0)

**** gen distance from ktx * post treat
gen dist_post04 = dist_ktx*post2004
gen dist_postopn = dist_ktx*postopn
gen dist_postann = dist_ktx*postann

**** merge netflow_balanced.dta
merge m:m id_town_h using netflow_all.dta
drop if _merge!=3
sort id_town2

**** drop vars
drop *mrg Lsum sido sig emd_* _merge
order id_prov id_prov2 name_prov id_cnty id_cnty2 name_cnty id_town_h name_town_h year total_inflow total_outflow net_flow
sort id_town_h year

*************DID Graphs*************
**** 1. Whole sample
**1)opening
cd "C:\Users\user\Dropbox\RA\net"

#delimit ;
twoway (scatter net_flow dist_ktx if yearopn==-4, mcolor(black) msize(small) msymbol(circle)) 
(scatter net_flow dist_ktx if yearopn==0, mcolor(red) msize(small) msymbol(circle))
(scatter net_flow dist_ktx if yearopn==2, mcolor(orange) msize(small) msymbol(circle)) 
(scatter net_flow dist_ktx if yearopn==4, mcolor(mint) msize(small) msymbol(circle)) 
(scatter net_flow dist_ktx if yearopn==8, mcolor(blue) msize(small) msymbol(circle)) 
(lfit net_flow dist_ktx if yearopn==-4, lcolor(black) lwidth(medthick)) 
(lfit net_flow dist_ktx if yearopn==0, lcolor(red) lwidth(medthick)) 
(lfit net_flow dist_ktx if yearopn==2, lcolor(orange) lwidth(medthick)) 
(lfit net_flow dist_ktx if yearopn==4, lcolor(mint) lwidth(medthick)) 
(lfit net_flow dist_ktx if yearopn==8, lcolor(blue) lwidth(medthick)) if dist_ktx<=80& station=="osong", 
title("Net-Migration of townships across t1(opening)") ytitle("net-inflow") graphregion(color(white))
legend(order(1 "t1=-4" 2 "t1=0" 3 "t1=2" 4 "t1=4" 5 "t1=8"));
#delimit cr
graph save net_opening.gph,replace
graph export net_opening.pdf,replace


**2)announcement
#delimit ;
twoway (scatter net_flow dist_ktx if yearann==-4, mcolor(black) msize(small) msymbol(circle)) 
(scatter net_flow dist_ktx if yearann==0, mcolor(red) msize(small) msymbol(circle))
(scatter net_flow dist_ktx if yearann==2, mcolor(orange) msize(small) msymbol(circle)) 
(scatter net_flow dist_ktx if yearann==4, mcolor(mint) msize(small) msymbol(circle)) 
(scatter net_flow dist_ktx if yearann==8, mcolor(blue) msize(small) msymbol(circle)) 
(lfit net_flow dist_ktx if yearann==-4, lcolor(black) lwidth(medthick)) 
(lfit net_flow dist_ktx if yearann==0, lcolor(red) lwidth(medthick)) 
(lfit net_flow dist_ktx if yearann==2, lcolor(orange) lwidth(medthick)) 
(lfit net_flow dist_ktx if yearann==4, lcolor(mint) lwidth(medthick)) 
(lfit net_flow dist_ktx if yearann==8, lcolor(blue) lwidth(medthick)) if dist_ktx<=80, 
title("Net-Migration of townships across t2(announcement)") ytitle("net-inflow") graphregion(color(white))
legend(order(1 "t2=-4" 2 "t2=0" 3 "t2=2" 4 "t2=4" 5 "t2=8"));
#delimit cr
graph save net_announcement.gph,replace
graph export net_announcement.pdf,replace

**** 2. By station
ren yearopen t1
ren yearann t2

local station osong gimcheon-gumi woolsan
local time t1 t2

foreach x of local station{
	foreach t of local time{
		#delimit;
		twoway (scatter net_flow dist_ktx if `t'==-4, mcolor(black) msize(small) msymbol(circle)) 
		(scatter net_flow dist_ktx if `t'==0, mcolor(red) msize(small) msymbol(circle))
		(scatter net_flow dist_ktx if `t'==2, mcolor(orange) msize(small) msymbol(circle)) 
		(scatter net_flow dist_ktx if `t'==4, mcolor(mint) msize(small) msymbol(circle)) 
		(scatter net_flow dist_ktx if `t'==8, mcolor(blue) msize(small) msymbol(circle)) 
		(lfit net_flow dist_ktx if `t'==-4, lcolor(black) lwidth(medthick)) 
		(lfit net_flow dist_ktx if `t'==0, lcolor(red) lwidth(medthick)) 
		(lfit net_flow dist_ktx if `t'==2, lcolor(orange) lwidth(medthick)) 
		(lfit net_flow dist_ktx if `t'==4, lcolor(mint) lwidth(medthick)) 
		(lfit net_flow dist_ktx if `t'==8, lcolor(blue) lwidth(medthick)) if dist_ktx<=80& station=="`x'", 
		title("Net-Migration of townships near `x' station across `t'") ytitle("net-inflow") graphregion(color(white))
		legend(order(1 "`t'=-4" 2 "`t'=0" 3 "`t'=2" 4 "`t'=4" 5 "`t'=8"));

		#delimit cr
		graph save net_opening_`x'_`t'.gph,replace
		graph export net_opening_`x'_`t'.pdf,replace
		}
	}



**2)announcement




**** 2. DID graphs by announcement


/*
**** treatment dummy (treatment is median value of distance from ktx)
sum dist_ktx,d
gen treat_med = (dist_ktx<=r(p50))
*gen treat_med = (dist_ktx<=r(p25))
*gen treat_med = (dist_ktx<=r(p10))


** gen year var
gen yearopn = year-opening
gen yearann = year-announcement

**** gen post var
gen post2004 = (year>=2004)
gen postopn = (yearopn>=0)
gen postann = (yearann>=0)

**** gen post * treatment
gen post_treat = post2004*treat
gen postopn_treat = postopn*treat
gen postann_treat = postann*treat

**** gen distance from ktx * post treat
gen dist_post04 = dist_ktx*post2004
gen dist_postopn = dist_ktx*postopn
gen dist_postann = dist_ktx*postann

**** gen distance ktx * each year for all years (yr1994 omitted)
foreach x of num 1995(1)2013 {
    gen py`x' = (year==`x')
}
foreach x of num 1995(1)2013 {
    gen dst_py`x' = dist_ktx * py`x'
}

**** gen distance from ktx squared 
gen dist_sq = dist_ktx^2
gen dist_sq_p04 = dist_sq*post2004


**** gen county*year FE
egen cnty_year = group(id_cnty2 year)

save temp , replace



* Diff and Diff 

** county FE / county*year FE

use temp, clear

*Lmean
areg Lmean treat post2004 post_treat Lc, absorb(id_cnty2) vce(cluster id_cnty2)
areg Lmean treat postopn postopn_treat Lc, absorb(id_cnty2) vce(cluster id_cnty2)
areg Lmean treat postann postann_treat Lc, absorb(id_cnty2) vce(cluster id_cnty2)

areg Lmean treat post_treat Lc, absorb(cnty_year) vce(cluster cnty_year)
areg Lmean treat postopn_treat Lc, absorb(cnty_year) vce(cluster cnty_year)
areg Lmean treat postann_treat Lc, absorb(cnty_year) vce(cluster cnty_year)

* busi_total
areg busi_total treat post2004 post_treat Lc, absorb(id_cnty2) vce(cluster id_cnty2)
areg busi_total treat postopn postopn_treat Lc, absorb(id_cnty2) vce(cluster id_cnty2)
areg busi_total treat postann postann_treat Lc, absorb(id_cnty2) vce(cluster id_cnty2)

areg busi_total treat post_treat Lc, absorb(cnty_year) vce(cluster cnty_year)
areg busi_total treat postopn_treat Lc, absorb(cnty_year) vce(cluster cnty_year)
areg busi_total treat postann_treat Lc, absorb(cnty_year) vce(cluster cnty_year)

* pop
areg pop treat post2004 post_treat Lc, absorb(id_cnty2) vce(cluster id_cnty2)
areg pop treat postopn postopn_treat Lc, absorb(id_cnty2) vce(cluster id_cnty2)
areg pop treat postann postann_treat Lc, absorb(id_cnty2) vce(cluster id_cnty2)

areg pop treat post_treat Lc, absorb(cnty_year) vce(cluster cnty_year)
areg pop treat postopn_treat Lc, absorb(cnty_year) vce(cluster cnty_year)
areg pop treat postann_treat Lc, absorb(cnty_year) vce(cluster cnty_year)



****************************************************************
********************* DiD Graph by year ************************
****************************************************************

* edit: 0813, 0816


use temp, clear

**** gen treat*year dummies

foreach x of num 1994(1)2019 {
    gen treat_`x' = treat_med * (year==`x')
}

	* opn

	local t_opn t_16 t_15 t_14 t_13 t_12 t_11 t_10 t_9 t_8 t_7 t_6 t_5 t_4 t_3 t_2 t_1 t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15

	local y_opn -16 -15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15

	local num : word count `t_opn'

	forvalues n = 1/`num' {
		local i : word `n' of `t_opn'
		local j : word `n' of `y_opn'

		gen treatopn_`i' = treat_med * (yearopn==`j')
	}


	* ann

	local t_ann t_16 t_15 t_14 t_13 t_12 t_11 t_10 t_9 t_8 t_7 t_6 t_5 t_4 t_3 t_2 t_1 t1 t2 t3 t4 t5 t6 t7 t8 t9 t10 t11 t12 t13 t14 t15 t16 t17 t18 t19 t20 t21 t22 t23 t24 t25 t26

	local y_ann -16 -15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 

	local num : word count `t_ann'

	forvalues n = 1/`num' {
		local i : word `n' of `t_ann'
		local j : word `n' of `y_ann'

		gen treatann_`i' = treat_med * (yearann==`j')
	}
	
	gen zero = 0

	
	
	
* Labels	
	
	* treatopn(-16~15)
	forvalues x=1(1)16 {
	label variable treatopn_t_`x'  " " 
	}

	forvalues x=1(1)15 {
	label variable treatopn_t`x'  " " 
	}

	* treatann(-16~26)
	forvalues x=1(1)16 {
	label variable treatann_t_`x'  " " 
	}
	forvalues x=1(1)26 {
	label variable treatann_t`x'  " " 
	}
		
	* t=zero	
	label variable zero "0"	

	* express labels for every five years

	forvalues x=3(3)16 {
	label variable treatopn_t_`x'  "-`x'" 
	}	
	forvalues x=3(3)15 {
	label variable treatopn_t`x'  "`x'" 
	}

	forvalues x=3(3)16 {
	label variable treatann_t_`x'  "-`x'" 
	}	
	forvalues x=3(3)26 {
	label variable treatann_t`x'  "`x'" 
	}


**** gen county*year FE
egen cnty_yearann = group(id_cnty2 yearann)
egen cnty_yearopn = group(id_cnty2 yearopn)
	
save temp2, replace	


*******0816******
* specification editted : remove postopn postann 
		
***** Lmean*****

* open

use temp2, clear
*keep if gyungbu ==1

	local outcomes Lmean
	
	foreach x of local outcomes{		
	areg `x' treat_med treatopn_t_16-treatopn_t_1 zero treatopn_t1-treatopn_t9 Lc, absorb(cnty_yearopn) vce(cluster cnty_yearopn)
	
	coefplot, omitted levels(95) keep(zero treatopn*) vertical ///
	yline(0, lp(dash) lc(grey)) xtitle("Years from opening") ///
	ytitle("Coef.(95%CI)") ///
	title("`x'") /// 
	graphregion(color(white)) 		
	
	graph save Graph ./results/0816/`x'_opn.gph, replace
	}	
	
	
* announce

	local outcomes Lmean

	foreach x of local outcomes{
		
	areg `x' treat_med treatann_t_16-treatann_t_1 zero treatann_t1-treatann_t20 Lc, absorb(cnty_yearann) vce(cluster cnty_yearann)
	
	coefplot, omitted levels(95) keep(zero treatann*) vertical ///
	yline(0, lp(dash) lc(grey)) xtitle("Years from announcing") ///
	ytitle("Coef.(95%CI)") ///
	title("`x'") ///
	graphregion(color(white)) 		
	
	graph save Graph ./results/0816/`x'_ann.gph, replace
	}			
	

***** pop *****

* open

	local outcomes pop
	
	foreach x of local outcomes{
		
	areg `x' treat_med treatopn_t_12-treatopn_t_1 zero treatopn_t1-treatopn_t9 Lc, absorb(cnty_yearopn) vce(cluster cnty_yearopn)
	
	coefplot, omitted levels(95) keep(zero treatopn*) vertical ///
	yline(0, lp(dash) lc(grey)) xtitle("Years from opening") ///
	ytitle("Coef.(95%CI)") ///
	title("`x'") ///
	graphregion(color(white)) 		
	
	graph save Graph ./results/0816/`x'_opn.gph, replace
	}		
	
* announce

	local outcomes pop
	foreach x of local outcomes{
		
	areg `x' treat_med treatann_t_12-treatann_t_1 zero treatann_t1-treatann_t20 Lc, absorb(cnty_yearann) vce(cluster cnty_yearann)
	
	coefplot, omitted levels(95) keep(zero treatann*) vertical ///
	yline(0, lp(dash) lc(grey)) xtitle("Years from announcing") ///
	ytitle("Coef.(95%CI)") ///
	title("`x'") ///
	graphregion(color(white)) 		
	
	graph save Graph ./results/0816/`x'_ann.gph, replace
	}			
		


***** busi *****

* open

	local outcomes busi_total busi_ag busi_manu busi_svc busi_retl busi_htlres busi_trns
	
	foreach x of local outcomes{
		
	areg `x' treat_med treatopn_t_16-treatopn_t_1 zero treatopn_t1-treatopn_t9 Lc, absorb(cnty_yearopn) vce(cluster cnty_yearopn)
	
	coefplot, omitted levels(95) keep(zero treatopn*) vertical ///
	yline(0, lp(dash) lc(grey)) xtitle("Years from opening") ///
	ytitle("Coef.(95%CI)") ///
	title("`x'") ///
	graphregion(color(white)) 		
	
	graph save Graph ./results/0816/`x'_opn.gph, replace
	}		
	
* announce

	local outcomes busi_total busi_ag busi_manu busi_svc busi_retl busi_htlres busi_trns

	foreach x of local outcomes{
		
	areg `x' treat_med treatann_t_16-treatann_t_1 zero treatann_t1-treatann_t20 Lc, absorb(cnty_yearann) vce(cluster cnty_yearann)
	
	coefplot, omitted levels(95) keep(zero treatann*) vertical ///
	yline(0, lp(dash) lc(grey)) xtitle("Years from announcing") ///
	ytitle("Coef.(95%CI)") ///
	title("`x'") ///
	graphregion(color(white)) 		
	
	graph save Graph ./results/0816/`x'_ann.gph, replace
	}				
	
* Combine graphs
	
	graph combine "./results/0816/Lmean_opn.gph" ///
	"./results/0816/Lmean_ann.gph" ///
	"./results/0816/pop_opn.gph" ///
	"./results/0816/pop_ann.gph" ///
		,
		graph save Graph ./results/0816/1.gph, replace
		graph export ./results/0816/1.pdf, replace		    

	
	graph combine "./results/0816/busi_total_opn.gph" ///
	"./results/0816/busi_total_ann.gph" ///
	"./results/0816/busi_ag_opn.gph" ///
	"./results/0816/busi_ag_ann.gph" ///
		,
		graph save Graph ./results/0816/2.gph, replace
		graph export ./results/0816/2.pdf, replace		  
			
	graph combine "./results/0816/busi_manu_opn.gph" ///
	"./results/0816/busi_manu_ann.gph" ///
	"./results/0816/busi_svc_opn.gph" ///
	"./results/0816/busi_svc_ann.gph" ///
		,
		graph save Graph ./results/0816/3.gph, replace
		graph export ./results/0816/3.pdf, replace		  
		

***0813***

use temp2, clear

***** Lmean*****
* open

	local outcomes Lmean
	
	foreach x of local outcomes{		
	areg `x' treat_med treatopn_t_16-treatopn_t_1 zero treatopn_t1-treatopn_t9 postopn Lc, absorb(cnty_year) vce(cluster cnty_year)
	
	coefplot, omitted levels(95) keep(zero treatopn*) vertical ///
	yline(0, lp(dash) lc(grey)) xtitle("Years from opening") ///
	ytitle("Coef.(95%CI)") ///
	title("`x'") /// 
	graphregion(color(white)) 		
	
	graph save Graph ./results/0813/`x'_opn.gph, replace
	}	
		

	local outcomes Lmean
			
	foreach x of local outcomes{		
	areg `x' treat_med treatopn_t_16-treatopn_t_1 zero treatopn_t1-treatopn_t9 postopn Lc, absorb(cnty_year) vce(cluster cnty_year)
	
	coefplot, omitted levels(95) keep(zero treatopn*) vertical ///
	yline(0, lp(dash) lc(grey)) xtitle("Years from opening") ///
	ytitle("Coef.(95%CI)") ///
	title("`x'") /// 
	graphregion(color(white)) 	
	}
	
		
* announce

	local outcomes Lmean

	foreach x of local outcomes{
		
	areg `x' treat_med treatann_t_16-treatann_t_1 zero treatann_t1-treatann_t20 postann Lc, absorb(cnty_year) vce(cluster cnty_year)
	
	coefplot, omitted levels(95) keep(zero treatann*) vertical ///
	yline(0, lp(dash) lc(grey)) xtitle("Years from announcing") ///
	ytitle("Coef.(95%CI)") ///
	title("`x'") ///
	graphregion(color(white)) 		
	
	graph save Graph ./results/0813/`x'_ann.gph, replace
	}			
	

***** pop *****

* open

	local outcomes pop
	
	foreach x of local outcomes{
		
	areg `x' treat_med treatopn_t_12-treatopn_t_1 zero treatopn_t1-treatopn_t9 postopn Lc, absorb(cnty_year) vce(cluster cnty_year)
	
	coefplot, omitted levels(95) keep(zero treatopn*) vertical ///
	yline(0, lp(dash) lc(grey)) xtitle("Years from opening") ///
	ytitle("Coef.(95%CI)") ///
	title("`x'") ///
	graphregion(color(white)) 		
	
	graph save Graph ./results/0813/`x'_opn.gph, replace
	}		
	
* announce

	local outcomes pop
	foreach x of local outcomes{
		
	areg `x' treat_med treatann_t_12-treatann_t_1 zero treatann_t1-treatann_t20 postann Lc, absorb(cnty_year) vce(cluster cnty_year)
	
	coefplot, omitted levels(95) keep(zero treatann*) vertical ///
	yline(0, lp(dash) lc(grey)) xtitle("Years from announcing") ///
	ytitle("Coef.(95%CI)") ///
	title("`x'") ///
	graphregion(color(white)) 		
	
	graph save Graph ./results/0813/`x'_ann.gph, replace
	}			
		


***** busi *****

* open

	local outcomes busi_total busi_ag busi_manu busi_svc busi_retl busi_htlres busi_trns
	
	foreach x of local outcomes{
		
	areg `x' treat_med treatopn_t_16-treatopn_t_1 zero treatopn_t1-treatopn_t9 postopn Lc, absorb(cnty_year) vce(cluster cnty_year)
	
	coefplot, omitted levels(95) keep(zero treatopn*) vertical ///
	yline(0, lp(dash) lc(grey)) xtitle("Years from opening") ///
	ytitle("Coef.(95%CI)") ///
	title("`x'") ///
	graphregion(color(white)) 		
	
	graph save Graph ./results/0813/`x'_opn.gph, replace
	}		
	
* announce

	local outcomes busi_total busi_ag busi_manu busi_svc busi_retl busi_htlres busi_trns

	foreach x of local outcomes{
		
	areg `x' treat_med treatann_t_16-treatann_t_1 zero treatann_t1-treatann_t20 postann Lc, absorb(cnty_year) vce(cluster cnty_year)
	
	coefplot, omitted levels(95) keep(zero treatann*) vertical ///
	yline(0, lp(dash) lc(grey)) xtitle("Years from announcing") ///
	ytitle("Coef.(95%CI)") ///
	title("`x'") ///
	graphregion(color(white)) 		
	
	graph save Graph ./results/0813/`x'_ann.gph, replace
	}			
	
		
	
* Combine graphs
	
	graph combine "./results/0813/Lmean_opn.gph" ///
	"./results/0813/Lmean_ann.gph" ///
	"./results/0813/pop_opn.gph" ///
	"./results/0813/pop_ann.gph" ///
		,
		graph save Graph ./results/0813/1_gbu.gph, replace
		graph export ./results/0813/1_gbu.pdf, replace		    

	
	graph combine "./results/0813/busi_total_opn.gph" ///
	"./results/0813/busi_total_ann.gph" ///
	"./results/0813/busi_ag_opn.gph" ///
	"./results/0813/busi_ag_ann.gph" ///
		,
		graph save Graph ./results/0813/2_gbu.gph, replace
		graph export ./results/0813/2_gbu.pdf, replace		  
			
	graph combine "./results/0813/busi_manu_opn.gph" ///
	"./results/0813/busi_manu_ann.gph" ///
	"./results/0813/busi_svc_opn.gph" ///
	"./results/0813/busi_svc_ann.gph" ///
		,
		graph save Graph ./results/0813/3_gbu.gph, replace
		graph export ./results/0813/3_gbu.pdf, replace		
		
		
		
		
		
*********************************************************
***************** Compare gyungbu and ktx ***************
*********************************************************


use temp2, clear
keep if gyungbu ==1
replace gyungbu_stn=0 if gyungbu_stn==.	
drop if name_town == "물금읍" // 지하철

/*keep if station == "cheonan_asan" | station == "daejeon" | ///
station == "dong-daegoo" | station == "gimcheon-gumi" | station == "jinyoung" |  ///
station == "milyang" | station == "osong" | station == "soowon"
*/

gen ktx_cnty = (name_cnty == "아산시" | name_cnty == "김천시" | name_cnty == "김해시" | ///
name_cnty == "밀양시" | name_cnty == "청주시 흥덕구")

gen gyungbu_cnty = (name_cnty == "경산시" | name_cnty == "양산시" | ///
name_cnty == "영동군" | name_cnty == "옥천군" | name_cnty == "천안시 서북구" | ///
name_cnty == "칠곡군" | name_cnty == "평택시" )

keep if ktx_cnty ==1 | gyungbu_cnty ==1

gen open_2004 = (opening ==2004 & ktx_cnty ==1)
gen open_2010 = (opening ==2010 & ktx_cnty ==1)


 /*

keep if gyungbu_stn==1

keep if dist_ktx < = 10



tab name_town if gyungbu_stn==1

summ dist_ktx, de
gen dist_ktx_p10 = (dist_ktx<=r(p10)) // 22.8km
gen dist_ktx_p25 = (dist_ktx<=r(p25)) // 22.8km
gen dist_ktx_p50 = (dist_ktx<=r(p50)) // 37.31km

tab gyungbu_stn dist_ktx_p10

*keep if gyungbu_stn==1 | dist_ktx_p10==1
*keep if gyungbu_stn==1 | dist_ktx_p25==1

*replace opening = . if gyungbu_stn == 1
*/


local outcomes pop busi_total emp_total Lmean

collapse (median) dist_ktx `outcomes' , by (year gyungbu_cnty ktx_cnty open_2004 open_2010)

local outcomes pop busi_total emp_total Lmean

foreach x of local outcomes{
graph twoway (line `x' year if gyungbu_cnty==1 & `x'!=0) ///
(line `x' year if ktx_cnty==1 & open_2004 ==1 & `x'!=0) ///
(line `x' year if ktx_cnty==1 & open_2010 ==1 & `x'!=0), ///
title("`x'") ytitle("")	graphregion(color(white)) ///
legend(label(1 "County with Gyungbu Station") label(2 "County with 2004 KTX Station") ///
label(3 "County with 2010 KTX Station"))
graph save Graph ./results/0828/compare_`x'.gph, replace	
}


graph combine "./results/0828/compare_pop.gph" ///
	"./results/0828/compare_busi_total.gph" ///
	"./results/0828/compare_emp_total.gph" ///
	"./results/0828/compare_Lmean.gph" ///
		,
		graph save Graph ./results/0828/compare.gph, replace
		graph export ./results/0828/compare.pdf, replace		    

		


local outcomes pop busi_total emp_total Lmean

collapse (mean) dist_ktx `outcomes' , by (year gyungbu_cnty)

foreach x of local outcomes{
graph twoway (line `x' year if gyungbu_cnty==1 & `x'!=0) ///
(line `x' year if gyungbu_cnty==0 & `x'!=0), ///
title("`x'") ytitle("")	graphregion(color(white)) ///
legend(label(1 "County with Gyungbu Station") label(2 "County with 2004 KTX Station") ///
label(3 "County with 2010 KTX Station"))
graph save Graph ./results/0828/compare_`x'.gph, replace	
}


graph combine "./results/0828/compare_pop.gph" ///
	"./results/0828/compare_busi_total.gph" ///
	"./results/0828/compare_emp_total.gph" ///
	"./results/0828/compare_Lmean.gph" ///
		,
		graph save Graph ./results/0828/compare.gph, replace
		graph export ./results/0828/compare.pdf, replace		   		
		
		
*** 0827 ***

	
		
* Exclusion Restriction

* Median
		
use temp2, clear
keep if gyungbu ==1
replace gyungbu_stn=0 if gyungbu_stn==.	
drop if name_town == "물금읍" // 지하철

keep if station == "cheonan_asan" | station == "daejeon" | ///
station == "dong-daegoo" | station == "gimcheon-gumi" | station == "jinyoung" |  ///
station == "milyang" | station == "osong" | station == "soowon"

/*
gen ktx_cnty = (name_cnty == "아산시" | name_cnty == "김천시" | name_cnty == "김해시" | ///
name_cnty == "밀양시" | name_cnty == "청주시 흥덕구")

gen gyungbu_cnty = (name_cnty == "경산시" | name_cnty == "양산시" | ///
name_cnty == "영동군" | name_cnty == "옥천군" | name_cnty == "천안시 서북구" | ///
name_cnty == "칠곡군" | name_cnty == "평택시" )

keep if ktx_cnty ==1 | gyungbu_cnty ==1
*/


gen open_2004 = (opening ==2004 & gyungbu_stn==0)
gen open_2010 = (opening ==2010 & gyungbu_stn==0)

tab name_town if gyungbu_stn==1

summ dist_ktx, de
gen dist_ktx_p10 = (dist_ktx<=r(p10)) // 22.8km
gen dist_ktx_p25 = (dist_ktx<=r(p25)) // 22.8km
gen dist_ktx_p50 = (dist_ktx<=r(p50)) // 37.31km

tab gyungbu_stn dist_ktx_p25

*keep if gyungbu_stn==1 | dist_ktx_p10==1
keep if gyungbu_stn==1 | dist_ktx_p25==1

*replace opening = . if gyungbu_stn == 1
	
preserve

local outcomes pop busi_total emp_total Lmean

collapse (mean) dist_ktx `outcomes' , by (year gyungbu_stn)

foreach x of local outcomes{
graph twoway (line `x' year if gyungbu_stn==1 & `x'!=0) ///
(line `x' year if gyungbu_stn==0 & `x'!=0), ///
title("`x'") ytitle("")	graphregion(color(white)) ///
legend(label(1 "Gyungbu") label(2 "KTX_Q3"))
graph save Graph ./results/0828/compare_`x'.gph, replace	
}


graph combine "./results/0828/compare_pop.gph" ///
	"./results/0828/compare_busi_total.gph" ///
	"./results/0828/compare_emp_total.gph" ///
	"./results/0828/compare_Lmean.gph" ///
		,
		graph save Graph ./results/0828/compare_1.gph, replace
		graph export ./results/0828/compare_1.pdf, replace		   		
		
restore
preserve

local outcomes pop busi_total emp_total Lmean

collapse (median) dist_ktx `outcomes' , by (year gyungbu_stn)

foreach x of local outcomes{
graph twoway (line `x' year if gyungbu_stn==1 & `x'!=0) ///
(line `x' year if gyungbu_stn==0 & `x'!=0), ///
title("`x'") ytitle("")	graphregion(color(white)) ///
legend(label(1 "Gyungbu") label(2 "KTX_Q3"))
graph save Graph ./results/0828/compare_`x'.gph, replace	
}


graph combine "./results/0828/compare_pop.gph" ///
	"./results/0828/compare_busi_total.gph" ///
	"./results/0828/compare_emp_total.gph" ///
	"./results/0828/compare_Lmean.gph" ///
		,
		graph save Graph ./results/0828/compare_2.gph, replace
		graph export ./results/0828/compare_2.pdf, replace		

restore
preserve		

local outcomes pop busi_total emp_total Lmean

collapse (mean) dist_ktx `outcomes' , by (year gyungbu_stn open_2004 open_2010)

foreach x of local outcomes{
graph twoway (line `x' year if gyungbu_stn==1 & `x'!=0) ///
(line `x' year if gyungbu_stn==0 & open_2004 ==1 & `x'!=0) ///
(line `x' year if gyungbu_stn==0 & open_2010 ==1 &`x'!=0), ///
title("`x'") ytitle("")	graphregion(color(white)) ///
legend(label(1 "Gyungbu") ///
label(2 "2004 KTX_Q3") ///
label(3 "2010 KTX_Q3"))
graph save Graph ./results/0828/compare_`x'.gph, replace	
}

graph combine "./results/0828/compare_pop.gph" ///
	"./results/0828/compare_busi_total.gph" ///
	"./results/0828/compare_emp_total.gph" ///
	"./results/0828/compare_Lmean.gph" ///
		,
		graph save Graph ./results/0828/compare_3.gph, replace
		graph export ./results/0828/compare_3.pdf, replace		   		
		
restore
preserve	
			
collapse (median) dist_ktx `outcomes' , by (year gyungbu_stn open_2004 open_2010)

foreach x of local outcomes{
graph twoway (line `x' year if gyungbu_stn==1 & `x'!=0) ///
(line `x' year if gyungbu_stn==0 & open_2004 ==1 & `x'!=0) ///
(line `x' year if gyungbu_stn==0 & open_2010 ==1 &`x'!=0), ///
title("`x'") ytitle("")	graphregion(color(white)) ///
legend(label(1 "Gyungbu") ///
label(2 "2004 KTX_Q3") ///
label(3 "2010 KTX_Q3"))
graph save Graph ./results/0828/compare_`x'.gph, replace	
}

graph combine "./results/0828/compare_pop.gph" ///
	"./results/0828/compare_busi_total.gph" ///
	"./results/0828/compare_emp_total.gph" ///
	"./results/0828/compare_Lmean.gph" ///
		,
		graph save Graph ./results/0828/compare_4.gph, replace
		graph export ./results/0828/compare_4.pdf, replace						
		*/
