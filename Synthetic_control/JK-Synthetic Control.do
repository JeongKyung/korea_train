cd "C:\Users\user\Dropbox\내 PC (LAPTOP-ODROTJ7E)\Desktop\ktx Dropbox\Won JeongKyung\korea_ktx\JK\synth"

****************************************************************************
************************** MK8: Synthetic Control***************************
****************************************************************************

***** Prepration****

use town_final_MK, clear

drop if year<=1993
destring id_prov, gen(id_prov2)
destring id_cnty, gen(id_cnty2)
destring id_town, gen(id_town2)
format id_town2 %15.0g

/*
drop if Lmean==.
drop if emp_num==.
drop if busi_num==.

bysort id_town: gen count = _N
drop if count!=20
drop count
*/

drop if id_prov2==50 // drop jejoo do
drop if id_prov2==42 // drop gangwon
drop if id_cnty2==47940 // drop uellueing island
drop if id_cnty2==28720 // drop oogjin gun island
drop if id_cnty2==46130 // drop nammyeon island


* KTX station

* Osong : 청주시 흥덕구 오송읍 Osong-eup 431132250
* Cheonan-Asan : 아산시 배방읍 Baebang-eup 44200253
* Gimcheon-Gumi : 김천시 남면 Nam-myeon 47150320

gen osong_ktx = (id_town2==43113250)
gen asan_ktx = (id_town2==44200253)
gen gimcheon_ktx = (id_town2==47150320)

* Near Osong : 청주시 흥덕구 강내면 옥산면 , 세종시 조치원읍 연동면 부강면
* Near Cheonan-Asan : 아산시 송악면 탕정면 온양6동 , 천안시동암구 풍세면 광덕면 신방동 
* Near Gimcheon-Gumi : 김천시 아포읍 농소면 개령면 , 성주시 초전면,  칠곡군 북삼읍

gen osong_near = (id_town2==43113310 | id_town2==43113320 | id_town2==36110250 | id_town2==36110320| id_town2 == 36110330)
gen asan_near = (id_town2 == 44200310 | id_town2==44200330 | id_town2==44131310 | id_town2==44131320)
gen gimcheon_near = (id_town2==47150250 | id_town2==47150310 | id_town2==47150340 | id_town2==47840380|id_town2==47850253)

save temp, replace


* Lmean (1994~2013)

use temp, clear

drop if Lmean==.
bysort id_town: gen count = _N
drop if count!=20 // 1994~2013

tsset id_town2 year
local outcomes Lmean
local regionlist 43113250 44200253 47150320 // 오송, 천안아산, 김천구미
local t1 1994  // start period
local t2i 2004 2010  // intervention
local t3 2013  // end period

*  Lmean

	foreach i of local regionlist { 
		foreach y of local outcomes {
			foreach t2 of local t2i {
			
			local predictor ""
			forvalues k = `t1'(2)`t2'{
			local predictor "`predictor' `y'(`k')"
			}			
			
			synth 	`y' `predictor', ///	
			trunit(`i') trperiod(`t2') ///
			mspeperiod(`t1'(1)`t2') resultsperiod(`t1'(1)`t3') ///
			keep(../synth/results/0805_`i'_`y'_`t2'.dta) replace fig
			mat list e(V_matrix)		
			graph save ../synth/graphs/0805_`i'_`y'_`t2'.gph, replace
			}
		}
	}

	
	
	
* emp_num busi_num (1994~2018)

use temp, clear
drop if4 year>2018

drop if emp_num==.
drop if busi_num==.
bysort id_town: gen count = _N
drop if count!=25 // 1994~2018
drop count

tsset id_town2 year
	
local outcomes emp_num busi_num
local regionlist 43113250 44200253 47150320 // 오송, 천안아산, 김천구미
local t1 1994  // start period
local t2i 2004 2010  // intervention
local t3 2018  // end period

*  Lmean emp_num busi_num

	foreach i of local regionlist { 
		foreach y of local outcomes {
			foreach t2 of local t2i {
			
			local predictor ""
			forvalues k = `t1'(1)`t2'{
			local predictor "`predictor' `y'(`k')"
			}			
			
			synth 	`y' `predictor', ///	
			trunit(`i') trperiod(`t2') ///
			mspeperiod(`t1'(1)`t2') resultsperiod(`t1'(1)`t3') ///
			keep(./results/synth/0802_`i'_`y'.dta) replace fig
			mat list e(V_matrix)		
			graph save Graph ./results/synth/0802_`i'_`y'_`t2'.gph, replace
			}
		}
	}


* Population (1994~2019)

use temp, clear

drop if pop==.
bysort id_town: gen count = _N
drop if count!=22 // 1998~2019
drop count

tsset id_town2 year
	local outcomes pop
	local regionlist 43113250 44200253 47150320 // 오송, 천안아산, 김천구미
	local t1 1998  // start period
	local t2i 2004 2010  // intervention
	local t3 2019  // end period


	foreach i of local regionlist { 
		foreach y of local outcomes { 
			foreach t2 of local t2i {
			
			local predictor ""
			forvalues k = `t1'(1)`t2'{
			local predictor "`predictor' `y'(`k')"
			}			
			
			synth `y' `predictor', ///	
			trunit(`i') trperiod(`t2') ///
			mspeperiod(`t1'(1)`t2') resultsperiod(`t1'(1)`t3') ///
			keep(./results/synth/0802_`i'_`y'.dta) replace fig
			mat list e(V_matrix)		
			graph save Graph ./results/synth/0802_`i'_`y'_`t2'.gph, replace
			}
		}
	}

*Graph Merge

	local regionlist 43113250 44200253 47150320 // 오송, 천안아산, 김천구미
	local regionname Osong CheonanAsan GimcheonGumi
	local t2i 2004 2010  // intervention

	local num : word count `regionlist'

	forvalues n = 1/`num' {
	local i : word `n' of `regionlist'
	local j : word `n' of `regionname'

		foreach t2 of local t2i {

		graph combine "./results/synth/0802_`i'_Lmean_`t2'.gph" ///
		"./results/synth/0802_`i'_emp_num_`t2'.gph" ///
		"./results/synth/0802_`i'_busi_num_`t2'.gph" ///
		"./results/synth/0802_`i'_pop_`t2'.gph", ///
		rows(2) cols(2) title(`j')
		graph save Graph ./results/synth/0802/`j'_`t2'.gph, replace
		graph export ./results/synth/0802/`j'_`t2'.pdf, replace	
		}
	}


	
	/*



* Plot the gap in predicted error
use ./results/synth/synth_0728.dta, clear
keep _Y_treated _Y_synthetic _time
drop if _time==.
rename _time year
rename _Y_treated  treat
rename _Y_synthetic counterfact
gen gap48=treat-counterfact
sort year 
twoway (line gap48 year,lp(solid)lw(vthin)lcolor(black)), yline(0, lpattern(shortdash) lcolor(black)) xline(1993, lpattern(shortdash) lcolor(black)) xtitle("",si(medsmall)) xlabel(#10) ytitle("Gap in Lmean prediction error", size(medsmall)) legend(off)
save ./results/synth/synth_bmprate_s1.dta, replace


* Inference 1 placebo test
#delimit;
set more off;
use town_final_MK, replace;


local statelist  1 2 4 5 6 8 9 10 11 12 13 15 16 17 18 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 45 46 47 48 49 51 53 55;

foreach i of local statelist {;

synth 	bmprison 
		bmprison(1990) bmprison(1992) bmprison(1991) bmprison(1988)
		alcohol(1990) aidscapita(1990) aidscapita(1991) 
		income ur poverty black(1990) black(1991) black(1992) 
		perc1519(1990)
		,		
			trunit(`i') trperiod(1993) unitnames(state) 
			mspeperiod(1985(1)1993) resultsperiod(1985(1)2000)
			keep(../data/synth/synth_bmprate_`i'.dta) replace;
			matrix state`i' = e(RMSPE); /* check the V matrix*/
			};


 foreach i of local statelist {;
 matrix rownames state`i'=`i';
 matlist state`i', names(rows);
 };


 #delimit cr
local statelist  1 2 4 5 6 8 9 10 11 12 13 15 16 17 18 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 45 46 47 48 49 51 53 55

 foreach i of local statelist {
 	use ./results/synth/synth_bmprate_`i' ,clear
 	keep _Y_treated _Y_synthetic _time
 	drop if _time==.
	rename _time year
 	rename _Y_treated  treat`i'
 	rename _Y_synthetic counterfact`i'
 	gen gap`i'=treat`i'-counterfact`i'
 	sort year 
 	save ./results/synth/synth_gap_bmprate`i', replace
}

use ./results/synth/synth_gap_bmprate48.dta, clear
sort year
save ./results/synth/placebo_bmprate48.dta, replace

foreach i of local statelist {
		
		merge year using ./results/synth/synth_gap_bmprate`i'
		drop _merge
		sort year
		
	save ./results/synth/placebo_bmprate.dta, replace
}






** Inference 2: Estimate the pre- and post-RMSPE and calculate the ratio of the
*  post-pre RMSPE	
set more off
local statelist  1 2 4 5 6 8 9 10 11 12 13 15 16 17 18 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 45 46 47 48 49 51 53 55

foreach i of local statelist {
	use ./results/synth/synth_gap_bmprate`i', clear
	
	gen gap3=gap`i'*gap`i'
	egen postmean=mean(gap3) if year>1993
	egen premean=mean(gap3) if year<=1993
	gen rmspe=sqrt(premean) if year<=1993
	replace rmspe=sqrt(postmean) if year>1993
	gen ratio=rmspe/rmspe[_n-1] if year==1994
	gen rmspe_post=sqrt(postmean) if year>1993
	gen rmspe_pre=rmspe[_n-1] if year==1994
	
	mkmat rmspe_pre rmspe_post ratio if year==1994, matrix (state`i')
								}

* show post/pre-expansion RMSPE ratio for all states, generate histogram
foreach i of local statelist {
	matrix rownames state`i'=`i'
	matlist state`i', names(rows)
								}

	mat state=state1\state2\state4\state5\state6\state8\state9\state10\state11\state12\state13\state15\state16\state17\state18\state20\state21\state22\state23\state24\state25\state26\state27\state28\state29\state30\state31\state32\state33\state34\state35\state36\state37\state38\state39\state40\state41\state42\state45\state46\state47\state48\state49\state51\state53\state55
	mat2txt, matrix(state) saving(../inference/rmspe_bmprate.txt) replace
	insheet using ./results/synth/rmspe_bmprate.txt, clear
	ren v1 state
	drop v5
	gsort -ratio
	gen rank=_n
	gen p=rank/46
	
	export excel using ./results/synth/rmspe_bmprate, firstrow(variables) replace

	import excel ../inference/rmspe_bmprate.xls, sheet("Sheet1") firstrow clear
	histogram ratio, bin(20) frequency fcolor(gs13) lcolor(black) ylabel(0(2)6) xtitle(Post/pre RMSPE ratio) xlabel(0(1)5)

* Show the post/pre RMSPE ratio for all states, generate the histogram.
list rank p if state==48


* Inference 3: all the placeboes on the same picture
use ./results/synth/placebo_bmprate.dta, replace

* Picture of the full sample, including outlier RSMPE
#delimit;	

twoway 
(line gap1 year ,lp(solid)lw(vthin)) 
(line gap2 year ,lp(solid)lw(vthin)) 
(line gap4 year ,lp(solid)lw(vthin)) 
(line gap5 year ,lp(solid)lw(vthin))
(line gap6 year ,lp(solid)lw(vthin)) 
(line gap8 year ,lp(solid)lw(vthin)) 
(line gap9 year ,lp(solid)lw(vthin)) 
(line gap10 year ,lp(solid)lw(vthin)) 
(line gap11 year ,lp(solid)lw(vthin)) 
(line gap12 year ,lp(solid)lw(vthin)) 
(line gap13 year ,lp(solid)lw(vthin)) 
(line gap15 year ,lp(solid)lw(vthin)) 
(line gap16 year ,lp(solid)lw(vthin)) 
(line gap17 year ,lp(solid)lw(vthin))
(line gap18 year ,lp(solid)lw(vthin)) 
(line gap20 year ,lp(solid)lw(vthin)) 
(line gap21 year ,lp(solid)lw(vthin)) 
(line gap22 year ,lp(solid)lw(vthin)) 
(line gap23 year ,lp(solid)lw(vthin)) 
(line gap24 year ,lp(solid)lw(vthin)) 
(line gap25 year ,lp(solid)lw(vthin)) 
(line gap26 year ,lp(solid)lw(vthin))
(line gap27 year ,lp(solid)lw(vthin))
(line gap28 year ,lp(solid)lw(vthin)) 
(line gap29 year ,lp(solid)lw(vthin)) 
(line gap30 year ,lp(solid)lw(vthin)) 
(line gap31 year ,lp(solid)lw(vthin)) 
(line gap32 year ,lp(solid)lw(vthin)) 
(line gap33 year ,lp(solid)lw(vthin)) 
(line gap34 year ,lp(solid)lw(vthin))
(line gap35 year ,lp(solid)lw(vthin))
(line gap36 year ,lp(solid)lw(vthin))
(line gap37 year ,lp(solid)lw(vthin)) 
(line gap38 year ,lp(solid)lw(vthin)) 
(line gap39 year ,lp(solid)lw(vthin))
(line gap40 year ,lp(solid)lw(vthin)) 
(line gap41 year ,lp(solid)lw(vthin)) 
(line gap42 year ,lp(solid)lw(vthin)) 
(line gap45 year ,lp(solid)lw(vthin)) 
(line gap46 year ,lp(solid)lw(vthin)) 
(line gap47 year ,lp(solid)lw(vthin))
(line gap49 year ,lp(solid)lw(vthin)) 
(line gap51 year ,lp(solid)lw(vthin)) 
(line gap53 year ,lp(solid)lw(vthin)) 
(line gap55 year ,lp(solid)lw(vthin)) 
(line gap48 year ,lp(solid)lw(thick)lcolor(black)), /*treatment unit, Texas*/
yline(0, lpattern(shortdash) lcolor(black)) xline(1993, lpattern(shortdash) lcolor(black))
xtitle("",si(small)) xlabel(#10) ytitle("Gap in black male prisoners per capita prediction error", size(small))
	legend(off);

#delimit cr

graph save Graph ./results/synth/synth_placebo_bmprate.gph, replace

* Drop the outliers (RMSPE is 5 times more than Texas: drops 11, 28, 32, 33, and 41)
* Picture of the full sample, including outlier RSMPE
#delimit;	

twoway 
(line gap1 year ,lp(solid)lw(vthin)) 
(line gap2 year ,lp(solid)lw(vthin)) 
(line gap4 year ,lp(solid)lw(vthin)) 
(line gap5 year ,lp(solid)lw(vthin))
(line gap6 year ,lp(solid)lw(vthin)) 
(line gap8 year ,lp(solid)lw(vthin)) 
(line gap9 year ,lp(solid)lw(vthin)) 
(line gap10 year ,lp(solid)lw(vthin)) 
(line gap12 year ,lp(solid)lw(vthin)) 
(line gap13 year ,lp(solid)lw(vthin)) 
(line gap15 year ,lp(solid)lw(vthin)) 
(line gap16 year ,lp(solid)lw(vthin)) 
(line gap17 year ,lp(solid)lw(vthin))
(line gap18 year ,lp(solid)lw(vthin)) 
(line gap20 year ,lp(solid)lw(vthin)) 
(line gap21 year ,lp(solid)lw(vthin)) 
(line gap22 year ,lp(solid)lw(vthin)) 
(line gap23 year ,lp(solid)lw(vthin)) 
(line gap24 year ,lp(solid)lw(vthin)) 
(line gap25 year ,lp(solid)lw(vthin)) 
(line gap26 year ,lp(solid)lw(vthin))
(line gap27 year ,lp(solid)lw(vthin))
(line gap29 year ,lp(solid)lw(vthin)) 
(line gap30 year ,lp(solid)lw(vthin)) 
(line gap31 year ,lp(solid)lw(vthin)) 
(line gap34 year ,lp(solid)lw(vthin))
(line gap35 year ,lp(solid)lw(vthin))
(line gap36 year ,lp(solid)lw(vthin))
(line gap37 year ,lp(solid)lw(vthin)) 
(line gap38 year ,lp(solid)lw(vthin)) 
(line gap39 year ,lp(solid)lw(vthin))
(line gap40 year ,lp(solid)lw(vthin)) 
(line gap42 year ,lp(solid)lw(vthin)) 
(line gap45 year ,lp(solid)lw(vthin)) 
(line gap46 year ,lp(solid)lw(vthin)) 
(line gap47 year ,lp(solid)lw(vthin))
(line gap49 year ,lp(solid)lw(vthin)) 
(line gap51 year ,lp(solid)lw(vthin)) 
(line gap53 year ,lp(solid)lw(vthin)) 
(line gap55 year ,lp(solid)lw(vthin)) 
(line gap48 year ,lp(solid)lw(thick)lcolor(black)), /*treatment unit, Texas*/
yline(0, lpattern(shortdash) lcolor(black)) xline(1993, lpattern(shortdash) lcolor(black))
xtitle("",si(small)) xlabel(#10) ytitle("Gap in black male prisoners per capita prediction error", size(small))
	legend(off);

#delimit cr

graph save Graph ./results/synth/synth_placebo_bmprate2.gph, replace



* Just compare Illinois with Texas

#delimit;	

twoway 
(line gap17 year ,lp(solid)lw(vthin))
(line gap48 year ,lp(solid)lw(thick)lcolor(black)), /*treatment unit, Texas*/
yline(0, lpattern(shortdash) lcolor(black)) xline(1993, lpattern(shortdash) lcolor(black))
xtitle("",si(small)) xlabel(#10) ytitle("Gap in black male prisoners per capita prediction error", size(small))
	legend(off);

#delimit cr
capture log close
exit

*/
