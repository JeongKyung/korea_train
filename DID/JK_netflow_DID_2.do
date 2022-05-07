*********************************************************************************
************JK_netflow_DID_2.do (동까지 포함한 sample)*******************************
************Date:2021/02/20, last edited by Jeongkyung Won***********************
*********************************************************************************

cd "C:\Users\user\Dropbox\내 PC (LAPTOP-ODROTJ7E)\Desktop\Dropbox\korea_ktx\JK\data\인구이동통계" 
use ./netflow/netflow_all_dist_merged_v2.dta,clear
merge m:1 station using ktx_id2, nogen

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

*************DID Graphs*************
**** 1. Whole sample
**1)opening
cd "C:\Users\user\Dropbox\RA\migration\net"
br if name_town==""
replace name_town=name_cnty if name_town==""&name_prov=="세종특별자치시"
drop if name_prov=="서울특별시"|name_prov=="제주도"|name_prov=="제주특별자치도"

#delimit ;
twoway (scatter net_inflow dist_ktx if yearopn==-4, mcolor(black) msize(small) msymbol(circle) mlabel(name_town)) 
(scatter net_inflow dist_ktx if yearopn==0, mcolor(red) msize(small) msymbol(circle) mlabel(name_town))
(scatter net_inflow dist_ktx if yearopn==2, mcolor(orange) msize(small) msymbol(circle) mlabel(name_town)) 
(scatter net_inflow dist_ktx if yearopn==4, mcolor(mint) msize(small) msymbol(circle) mlabel(name_town)) 
(scatter net_inflow dist_ktx if yearopn==8, mcolor(blue) msize(small) msymbol(circle) mlabel(name_town)) 
(lfit net_inflow dist_ktx if yearopn==-4, lcolor(black) lwidth(medthick))
(lfit net_inflow dist_ktx if yearopn==0, lcolor(red) lwidth(medthick)) 
(lfit net_inflow dist_ktx if yearopn==2, lcolor(orange) lwidth(medthick)) 
(lfit net_inflow dist_ktx if yearopn==4, lcolor(mint) lwidth(medthick)) 
(lfit net_inflow dist_ktx if yearopn==8, lcolor(blue) lwidth(medthick)) if dist_ktx<=60, 
title("Net-Migration of townships across t1(opening)") ytitle("net-inflow") graphregion(color(white))
legend(order(1 "t1=-4" 2 "t1=0" 3 "t1=2" 4 "t1=4" 5 "t1=8"));
#delimit cr
graph save net_opening_2_label.gph,replace
graph export net_opening_2_label.pdf,replace


**2)announcement
#delimit ;
twoway (scatter net_inflow dist_ktx if yearann==-4, mcolor(black) msize(small) msymbol(circle) mlabel(name_town)) 
(scatter net_inflow dist_ktx if yearann==0, mcolor(red) msize(small) msymbol(circle) mlabel(name_town))
(scatter net_inflow dist_ktx if yearann==2, mcolor(orange) msize(small) msymbol(circle) mlabel(name_town)) 
(scatter net_inflow dist_ktx if yearann==4, mcolor(mint) msize(small) msymbol(circle) mlabel(name_town)) 
(scatter net_inflow dist_ktx if yearann==8, mcolor(blue) msize(small) msymbol(circle) mlabel(name_town)) 
(qfit net_inflow dist_ktx if yearann==-4, lcolor(black) lwidth(medthick)) 
(qfit net_inflow dist_ktx if yearann==0, lcolor(red) lwidth(medthick)) 
(qfit net_inflow dist_ktx if yearann==2, lcolor(orange) lwidth(medthick)) 
(qfit net_inflow dist_ktx if yearann==4, lcolor(mint) lwidth(medthick)) 
(qfit net_inflow dist_ktx if yearann==8, lcolor(blue) lwidth(medthick)) if dist_ktx<=80, 
title("Net-Migration of townships across t2(announcement)") ytitle("net-inflow") graphregion(color(white))
legend(order(1 "t2=-4" 2 "t2=0" 3 "t2=2" 4 "t2=4" 5 "t2=8"));
#delimit cr
graph save net_announcement_2_label.gph,replace
graph export net_announcement_2_label.pdf,replace

**** 2. By station
ren yearopn t1
ren yearann t2

local station osong gwangmyeong cheonan_asan gimcheon-gumi singyungjoo woolsan 
local time t1 t2

foreach x of local station{
	foreach t of local time{
		#delimit;
		twoway (scatter net_inflow dist_ktx if `t'==-4, mcolor(black) msize(small) msymbol(circle) mlabel(name_town)) 
		(scatter net_inflow dist_ktx if `t'==0, mcolor(red) msize(small) msymbol(circle) mlabel(name_town))
		(scatter net_inflow dist_ktx if `t'==2, mcolor(orange) msize(small) msymbol(circle) mlabel(name_town)) 
		(scatter net_inflow dist_ktx if `t'==4, mcolor(mint) msize(small) msymbol(circle) mlabel(name_town)) 
		(scatter net_inflow dist_ktx if `t'==8, mcolor(blue) msize(small) msymbol(circle) mlabel(name_town)) 
		(lfit net_inflow dist_ktx if `t'==-4, lcolor(black) lwidth(medthick)) 
		(lfit net_inflow dist_ktx if `t'==0, lcolor(red) lwidth(medthick)) 
		(lfit net_inflow dist_ktx if `t'==2, lcolor(orange) lwidth(medthick)) 
		(lfit net_inflow dist_ktx if `t'==4, lcolor(mint) lwidth(medthick)) 
		(lfit net_inflow dist_ktx if `t'==8, lcolor(blue) lwidth(medthick)) if dist_ktx<=60& station=="`x'", 
		title("Net-Migration of townships near `x' station across `t'") ytitle("net-inflow") graphregion(color(white))
		legend(order(1 "`t'=-4" 2 "`t'=0" 3 "`t'=2" 4 "`t'=4" 5 "`t'=8"));

		#delimit cr
		graph save net_opening_`x'_`t'_2_with_label.gph,replace
		graph export net_opening_`x'_`t'_2_with_label.pdf,replace
		}
	}

	
	
	
	
