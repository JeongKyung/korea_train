*********************************************************************************
************JK_netflow_DID_3.do (동까지 포함한 sample + 5년 단위로 netinflow 합쳐주기****
************Date:2021/02/20, last edited by Jeongkyung Won***********************
*********************************************************************************

**** Prepare Data ****

cd "C:\Users\user\Dropbox\내 PC (LAPTOP-ODROTJ7E)\Desktop\Dropbox\korea_ktx\JK\data\인구이동통계" 
use ./netflow/netflow_all_dist_merged_v3.dta,clear
merge m:1 station using ktx_id2, nogen

/* Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                            67,352  
    ----------------------------------------- */

* gen year var
gen yearopn = year-opening
gen yearann = year-announcement

sort id_town_h yearopn

**A:2004년에 개통한 ktx역 주변 읍면동(t=-3~15) vs B:2010년에 개통한 ktx역 주변 읍면동(t=-9~9)
**A는 t=-3vs+2만 가능, B는 t=-9vs+8도 가능; 우선 A,B 구분하지 않고 -3,+2 먼저 

**3년씩 *flow 값 합쳐주기 (t: -9~+15)
gen t=. 
label variable t "years from opening"
order name_* id_town_h id_town_h_2 year t yearopn yearann *flow station dist_ktx

local numlist0 -9 -6 -3 2 5 8 11 14
local numlist1 -9 -6 -3 0 3 6 9 12
local numlist2 -6 -3 0 3 6 9 12 15 

local num: word count `numlist0'

forvalues n=1/`num'{
	local i: word `n' of `numlist0'
	local j: word `n' of `numlist1'
	local k: word `n' of `numlist2'

	replace t=`i' if yearopn>=`j'& yearopn<`k'
	}
replace t=15 if yearopn==15
	
foreach x in "inflow" "outflow" "net_inflow"{
	bysort id_town_h t: egen `x'_sum=sum(`x') 
	}
order *_sum,after(t)

bysort id_town_h t: gen rank=_n
order rank, after(t)
bysort id_town_h t: keep if rank==_N 
keep name_* id_town* t *_sum dist_ktx station opening

***********************************************************************************************

****DID Graphs

*1. Whole sample

cd "C:\Users\user\Dropbox\RA\migration\net"

drop if name_prov=="서울특별시"| name_prov=="경기도"| name_prov=="강원도"

ren *_sum *

*name_town이 겹치는 곳(남면) address해주기 
local codelist 3611031000 4476038000 4482532000 4613034000 4671033000 4679041000 4688032000 4715032000 4884035000
local namelist 연기군남면 부여군남면 태안군남면 여수시남면 담양군남면 화순군남면 장성군남면 김천시남면 남해군남면
local num:word count `codelist'
forvalues n=1/`num'{
	local i:word `n' of `codelist'
	local j:word `n' of `namelist'
	
	replace name_town="`j'" if id_town_h=="`i'"
	}


*-3vs+2
#delimit ;
twoway (scatter net_inflow dist_ktx if t==-3, mcolor(red) msize(small) msymbol(circle) mlabel(name_town))
(scatter net_inflow dist_ktx if t==2, mcolor(blue) msize(small) msymbol(circle) mlabel(name_town)) 
(lfit net_inflow dist_ktx if t==-3, lcolor(red) lwidth(medthick)) 
(lfit net_inflow dist_ktx if t==2, lcolor(blue) lwidth(medthick)) if dist_ktx<=20& opening==2010, /*opening==2010 넣어서도 한 번*/
title("Net-inflow of townships across t(opening)") ytitle("Net-inflow") graphregion(color(white))
legend(order(1 "t=-3~-1" 2 "t=0~2"));
#delimit cr
graph save net_opening_3_label.gph,replace
graph export net_opening_3_label.pdf,replace

*-9vs+8
#delimit ;
twoway (scatter net_inflow dist_ktx if t==-9, mcolor(red) msize(small) msymbol(circle) mlabel(name_town))
(scatter net_inflow dist_ktx if t==8, mcolor(blue) msize(small) msymbol(circle) mlabel(name_town)) 
(lfit net_inflow dist_ktx if t==-9, lcolor(red) lwidth(medthick)) 
(lfit net_inflow dist_ktx if t==8, lcolor(blue) lwidth(medthick)) if dist_ktx<=20& opening==2010, 
title("Net-inflow of townships across t(opening)") ytitle("Net-inflow") graphregion(color(white))
legend(order(1 "t=-9~-1" 2 "t=0~8"));
#delimit cr
graph save net_opening_3_label_long.gph,replace
graph export net_opening_3_label_long.pdf,replace


**** 2. By station

*-3 vs +2 
local station osong cheonan_asan gimcheon-gumi singyungjoo woolsan changwon-joongang 

foreach x of local station{

		#delimit;
		twoway (scatter net_inflow dist_ktx if t==-3, mcolor(red) msize(small) msymbol(circle) mlabel(name_town)) 
		(scatter net_inflow dist_ktx if t==2, mcolor(blue) msize(small) msymbol(circle) mlabel(name_town))
		(lfit net_inflow dist_ktx if t==-3, lcolor(red) lwidth(medthick)) 
		(lfit net_inflow dist_ktx if t==2, lcolor(blue) lwidth(medthick)) if dist_ktx<=20& station=="`x'", 
		title("Net-inflow of townships near `x' station across t") ytitle("net-inflow") graphregion(color(white))
		legend(order(1 "t=-3~-1" 2 "t=0~2"));

		#delimit cr
		graph save net_opening_`x'_3_with_label.gph,replace
		graph export net_opening_`x'_3_with_label.pdf,replace
		}

*-9 vs +8
local station osong gimcheon-gumi singyungjoo woolsan changwon-joongang 

foreach x of local station{

		#delimit;
		twoway (scatter net_inflow dist_ktx if t==-9, mcolor(red) msize(small) msymbol(circle) mlabel(name_town)) 
		(scatter net_inflow dist_ktx if t==8, mcolor(blue) msize(small) msymbol(circle) mlabel(name_town))
		(lfit net_inflow dist_ktx if t==-9, lcolor(red) lwidth(medthick)) 
		(lfit net_inflow dist_ktx if t==8, lcolor(blue) lwidth(medthick)) if dist_ktx<=20& station=="`x'", 
		title("Net-inflow of townships near `x' station across t") ytitle("net-inflow") graphregion(color(white))
		legend(order(1 "t=-9~-1" 2 "t=0~8"));

		#delimit cr
		graph save net_opening_`x'_3_with_label_long.gph,replace
		graph export net_opening_`x'_3_with_label_long.pdf,replace
		}







 

