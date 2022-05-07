****역 소재 역 주변 읍면동 dummy만들기(강외면,남면,건천읍,삼남면)
cd "C:\Users\user\Dropbox\RA\net" 
use netflow_balanced_1.dta,clear

label define cd1 43710400"Gangwae-myeon" 44730310"Dong-myeon" 44730250"Jochiwon-eup" 43710410"Oksan-myeon" 43710390"Gangnae-myeon" 44730360"Jeondong-myeon" ///
47150320"Nam-myeon" 47150390"Gamcheon-myeon" 47150310"Nongso-myeon" 47150340"Gaeryong-myeon" 47150565"Yanggeum-dong" 47150640"Yulgok-dong" 47130256"Guncheon-eup" ///
47130590"Seondo-dong" 47130360"Hyungok-myeon" 47130340"Sannae-myeon" 47130570"Hwangnam-dong" 47130350"Seo-myeon" 31710360"Dudong-myeon" 47130330"Naenam-myeon" ///
31710259"Beomseo-eup" 31710253"Eunyang-eup" 31710400"Samdong-myeon" 31710380"Sangbook-myeon" 31710390"Sangnam-myeon" 31710370"Duseo-meyon" 47150610"Jijwa-dong" 47150575"Daesin-dong" 47170620"Pyungwha-dong" 47150250"Apo-eup" ///
41210650"Soha2-dong" 41210640"Soha1-dong" 41210631"Haahn1-dong" 41171600"Seoksu2-dong" 41171610"Seoksu3-dong" 41171630"Bakdal-dong" 47150610"Jijwha-dong"

label value emd_3 cd1

gen near_gwangmyeong=(emd_3==41210650|emd_3==41210640|emd_3==41210631|emd_3==41171600|emd_3==41171610|emd_3==41171630)
gen near_osong=(emd_3==43710390|emd_3==43710400|emd_3==43710410|emd_3==44730250|emd_3==44730310|emd_3==44730360)
gen near_gimcheon_gumi=(emd_3==47150565|emd_3==47150390|emd_3==47150310|emd_3==47150320|emd_3==47150340|emd_3==47150640|emd_3==47150610)
gen near_singyungjoo=(emd_3==47130256|emd_3==47130590|emd_3==47130360|emd_3==47130340|emd_3==47130330|emd_3==47130350|emd_3==47130570) 
gen near_woolsan=(emd_3==31710360|emd_3==31710390|emd_3==31710259|emd_3==31710253|emd_3==31710400|emd_3==31710380|emd_3==31710370)
gen year2=year-2000

save netflow_balanced_1.dta,replace

cd "C:\Users\user\Dropbox\RA\net\xtline"

local station gwangmyeong osong gimcheon_gumi singyungjoo woolsan
local yearlist 4 10 10 10 10
local num: word count `station'

forvalues n= 1/`num'{
	local i: word `n' of `station'
	local j: word `n' of `yearlist'

	xtline net_flow if near_`i'==1, t(year2) i(emd_3) tlabel(#18) overlay xline(`j',lcolor(black)) ///
	title("Net-inflow of townships near `i' station") ytitle("net-inflow") graphregion(color(white)) 
	graph save near_`i'_netflow.gph,replace
	graph export near_`i'_netflow.pdf,replace
	}
			
**netflow_gimcheon_v2.pdf (농소면+남면+율곡동, 농소면 code로 통일)
use netflow_balanced_1.dta,clear
cd "C:\Users\user\Dropbox\RA\net\xtline"

replace emd_3=47150310 if emd_3==47150320|emd_3==47150640
sort emd_3 year
by emd_3 year: replace net_flow=sum(net_flow)
by emd_3 year: gen count2=_n
by emd_3 year: keep if count2==_N

gen year2=year-2000

xtline net_flow if near_gimcheon_gumi==1, t(year2) i(emd_3) tlabel(#18) overlay xline(10,lcolor(black)) ///
	title("Net-inflow of townships near gimcheon_gumi station") ytitle("net-inflow") graphregion(color(white)) 
	graph save near_gimcheon_gumi_netflow_2.gph,replace
	graph export near_gimcheon_gumi_netflow_2.pdf,replac

**


