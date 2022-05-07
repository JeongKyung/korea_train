cd "C:\Users\user\Dropbox\RA\net" 
use inflow_all.dta,clear
ren in_emd out_emd
ren within_* from_same_*
merge m:m out_emd using outflow_all.dta
keep if _merge==3
drop out_sido out_sig in_sido in_sig
ren out_* *
ren within_* to_same_*
gen net_flow=total_inflow-total_outflow
order total_outflow total_inflow net_flow,before(_merge)
save netflow_all.dta,replace

sort emd year

use netflow_all.dta,clear

tostring emd, gen(emd_2)
drop emd 
ren emd_2 emd
gen emd_2=substr(emd,1,8) /*substring to apply label value*/
order emd_2,after(emd)
replace emd_2="43710400" if emd_2=="43710256"| emd_2=="43113250" /*역 주변 읍면동 행정동 코드 변화를 fixed boundary를 기준으로 통일시켜서 하나의 unit으로 matching*/
replace emd_2="44730310" if emd_2=="36110320"
replace emd_2="44730250" if emd_2=="36110250"
replace emd_2="43710410" if emd_2=="43113320"
replace emd_2="43710390" if emd_2=="43113310"
replace emd_2="44730360" if emd_2=="36110380"
replace emd_2="47170620" if emd_2=="47150515"|emd_2=="47150535"|emd_2=="47150536"|emd_2=="47150535"
replace emd_2="44200320" if emd_2=="44200253"

destring emd_2,gen(emd_3)

sort emd_3 year
bysort emd_3 year: gen count=_n /*하나의 동일한 지역경계인데 행정구역 변화로 특정년도에 복수의 행정구역으로 나눠서 전입신고가 집계 된 경우를 합쳐주기*/

local varlist total_inflow total_outflow net_flow from_gyungi from_gangwon from_chungbuk from_chungnam from_jeonbuk from_jeonnam from_gyungbook from_gyungnam from_jeju to_gyungi to_gangwon to_chungbuk to_chungnam to_jeonbuk to_jeonnam to_gyungbook to_gyungnam to_jeju
foreach v of local varlist{
	by emd_3 year: replace `v'=sum(`v')
	}
by emd_3 year: keep if count==_N
drop count
keep if count==19 /*balanced panel만들기 (원래 full로 기록된 읍면동 + 4개역 주변 읍면동)*/
save inflow_balanced.dta,replace
