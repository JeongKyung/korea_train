*************************************************************************************************
************Calculating Net-migration for each townships in which KTX stations are located*******
************Date:2020/01/23,last edited by Jeongkyung Won ***************************************
*************************************************************************************************

cd "C:\Users\user\Dropbox\내 PC (LAPTOP-ODROTJ7E)\Desktop\Dropbox\korea_ktx\JK\data\인구이동통계"
use ./inflow/inflow_balanced.dta, clear
keep if in_emd_3==41210650|in_emd_3==44200320|in_emd_3==43710400|in_emd_3==47150390|in_emd_3==47130256|in_emd_3==31710360
drop within_* from_* in_sido in_sig in_emd in_emd_2
ren in_emd_3 out_emd_3
merge m:m out_emd_3 year using ./outflow/outflow_balanced.dta
drop if _merge==2
drop within_* to_* out_sido out_sig out_emd out_emd_2
drop count
ren out_emd_3 emd
gen net_move=total_inflow-total_outflow
save netflow.dta,replace
sort emd year



label variable total_inflow "In-migration"
label variable total_outflow "Out-migration"
label variable net_move "Net-migration"

label define cd1 41210650"Gwangmyeong" 44200320"Cheonan Asan" 43710400"Osong" 47150390"Gimcheon Gumi" 47130256"Singyungjoo" 31710360"Woolsan"
label value emd cd1

local codelist 41210650 44200320 43710400 47150390 47130256 31710360
local station Gwangmyeong Cheonan-Asan Osong Gimcheon-Gumi Singyungjoo Woolsan

forvalues n=1/6{
	local i: word `n' of `codelist'
	local j: word `n' of `station'

	twoway (tsline total_inflow, recast(connected) msize(small)) ///
	(tsline total_outflow, recast(connected) msize(small)) ///
	(tsline net_move, recast(connected) msize(small)) if emd==`i', title("`j'")
	graph save 
	}
