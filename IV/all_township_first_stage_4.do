*********Islands, Urban districts and Gangwon Province are already excluded*******
cd "C:\Users\user\Dropbox\내 PC (LAPTOP-ODROTJ7E)\Desktop\Dropbox\korea_ktx\JK\data\first_stage"
use "C:\Users\user\Dropbox\내 PC (LAPTOP-ODROTJ7E)\Desktop\Dropbox\korea_ktx\JK\data\first_stage\all_em",clear
sort em_cd year
tsset em_cd year

pwcorr dist_ktx dist_direct elev_med slope_med rugged_med Lcell_num town_eup //pairwise correlation between x, IVs and other variables.

**I. Tabulating the first-stage results of potential IVs
local IVLIST dist_direct elev_med rugged_med slope_med
local numlist 1 2 3 4
local titlelist Distance Elevation Ruggedness Slope

local num: word count `IVLIST'
forvalues n= 1/`num'{
local x: word `n' of `IVLIST'
local i: word `n' of `numlist'
local j: word `n' of `titlelist'

eststo clear
eststo:reg dist_ktx `x',vce(cluster sigungu_cd) //(1)
estadd local FE ""
eststo:reg dist_ktx `x' Lcell_num town_eup,vce(cluster sigungu_cd) //(2)
estadd local FE ""
eststo:areg dist_ktx `x' Lcell_num town_eup, absorb(sigungu_cd) vce(cluster sigungu_cd) //(3)
estadd local FE "X"
test `x'
eststo:areg dist_ktx `x' Lcell_num town_eup if ktx_near1==1,absorb(sigungu_cd) vce(cluster sigungu_cd) //(4)
estadd local FE "X"
test `x' 
eststo:areg dist_ktx `x' Lcell_num town_eup if ktx_near2==1,absorb(sigungu_cd) vce(cluster sigungu_cd) //(5)
estadd local FE "X"
test `x' 

esttab using `x'_3.tex,replace ///
nomtitles mgroups("Distance to KTX", pattern(1 0 0 0 0) ///
span prefix(\multicolumn{@span}{c}{) suffix(})) ///
lines se(3) ar2 star nocon ///
label title(IV`i': `j') scalars("FE County Fixed Effects")
}

/*F-statistics of IV in specification (3),(4),(5)
distance: 83.37 0.62 2.81
elevation: 3.42 1.26 0.37
ruggedness: 1.94 0.99 0.00
slope: 2.00 0.89 0.00 */

eststo clear


**II. Simple Endogeneity checks using estat endog
tab sigungu_cd,gen(county)

local IVLIST dist_direct elev_med rugged_med slope_med

foreach x of local IVLIST{
quietly ivregress 2sls Lmean Lcell_num town_eup (dist_ktx=`x'),vce(cluster sigungu_cd)
asdoc estat endog
quietly ivregress 2sls Lmean Lcell_num town_eup post2004 dist_post (dist_ktx=`x'),vce(cluster sigungu_cd) 
asdoc estat endog
quietly ivregress 2sls Lmean Lcell_num town_eup post2004 dist_post county* (dist_ktx=`x'),vce(cluster sigungu_cd)
asdoc estat endog
quietly ivregress 2sls Lmean Lcell_num town_eup post2004 dist_post county* (dist_ktx=`x') if big_city==0,vce(cluster sigungu_cd)
asdoc estat endog
quietly ivregress 2sls Lmean Lcell_num town_eup post2004 dist_post county* (dist_ktx=`x') if ktx_near==1,vce(cluster sigungu_cd) 
asdoc estat endog
}


**III.IV Regression (assumes that each instrument is valid)
local IVLIST dist_direct elev_med rugged_med slope_med
local titlelist Distance Elevation Ruggedness Slope
local num: word count `IVLIST'
forvalues n=1/`num'{
local x: word `n' of `IVLIST'
local y: word `n' of `titlelist'

quietly regress Lmean Lcell_num town_eup `x'
predict xhat, xb
gen xhat_post=xhat*post2004
label variable xhat "Distance to KTX(Inst'ed)"
label variable xhat_post "Distance to KTX(Inst'ed)*post2004"

eststo:reg Lmean xhat Lcell_num town_eup, vce(cluster sigungu_cd)
estadd local FE ""
eststo:reg Lmean xhat Lcell_num town_eup post2004 xhat_post, vce(cluster sigungu_cd)
estadd local FE ""
eststo: areg Lmean xhat Lcell_num town_eup post2004 xhat_post, absorb(sigungu_cd) vce(cluster sigungu_cd)
estadd local FE "X"
eststo: areg Lmean xhat Lcell_num town_eup post2004 xhat_post if big_city==0, absorb(sigungu_cd) vce(cluster sigungu_cd)
estadd local FE "X"

esttab using ./two_stage_`x'_4.tex, replace ///
nomtitles mgroups("Light Mean", pattern(1 0 0 0) ///
span prefix(\multicolumn{@span}{c}{) suffix(})) ///
keep(xhat Lcell_num town_eup post2004 xhat_post) ///
se(3) nocon label title(Two-Stage Results using `y' as the instrument) ///
scalars("FE County Fixed Effects")

eststo clear
drop xhat xhat_post
}



