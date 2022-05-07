*********Islands, Urban districts and Gangwon Province are already excluded
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
eststo:reg dist_ktx `x',vce(cluster sigungu_cd)
eststo:reg dist_ktx `x' Lcell_num,vce(cluster sigungu_cd)
eststo:reg dist_ktx `x' Lcell_num town_eup,vce(cluster sigungu_cd)			//(3)
test `x'
eststo:reg dist_ktx `x' Lcell_num town_eup if big_city==0,vce(cluster sigungu_cd)  //(4)
test `x'
esttab using `x'_2.tex,replace ///
nomtitles mgroups("Distance to KTX", pattern(1 0 0 0) ///
span prefix(\multicolumn{@span}{c}{) suffix(})) ///
se(3) ar2 star nocon ///
label title(IV`i': `j')
}

/*F-statistics of IV in specification (3)&(4)
distance: 208.05 154.61
elevation: 15.95 12.99
ruggedness: 5.20 3.56
slope: 5.38 3.73*/

eststo clear

**II. IV Regression (assuming that each instrument is valid)
local IVLIST dist_direct elev_med rugged_med slope_med
local titlelist Distance Elevation Ruggedness Slope
local num: word count `IVLIST'
forvalues n=1/`num'{
local x: word `n' of `IVLIST'
local y: word `n' of `titlelist'

eststo clear
eststo: ivregress 2sls Lmean Lcell_num (dist_ktx=`x'),vce(cluster sigungu_cd)
eststo: ivregress 2sls Lmean Lcell_num (dist_ktx=`x') if big_city==0,vce(cluster sigungu_cd)
esttab using ./two_stage_`x'_2.tex, replace ///
nomtitles mgroups("Light Mean", pattern(1 0) ///
span prefix(\multicolumn{@span}{c}{) suffix(})) ///
se(3) label title(Two-Stage Results using `y')
}

eststo clear

//Additional Checks

**III. Exogeneity Checks by the over-identification tests (2IV's are required)
local ivlist elev_med rugged_med slope_med
foreach i of local ivlist{
ivregress 2sls Lmean Lcell_num (dist_ktx=dist_direct `i'),vce(cluster sigungu_cd)
predict e, resid
reg e dist_direct `i' Lcell_num, vce(cluster sigungu_cd)
test dist_direct `i'
dis "J-stat2="r(df)*r(F) 
drop e

ivregress 2sls Lmean Lcell_num (dist_ktx=dist_direct `i') if big_city==0,vce(cluster sigungu_cd)
predict e, resid
reg e dist_direct `i' Lcell_num, vce(cluster sigungu_cd)
test dist_direct `i'
dis "J-stat2="r(df)*r(F) 
drop e
}

/*                               
								   J-statistics
dist_direct & elev_med			44.72053   45.283554
dist_direct & rugged_med		44.30758   44.208832
dist_direct * slope_med			45.45655   45.373782
Excluding big_cities			   X		   O

all overidentifying tests indicate that at least one instrument of each combination is endogeneous,
but we cannot tell which is endogenous or not.
*/

**IV. Exogeneity checks by regressing on residuals.
gen post2004=(year>2004)
gen dist_post=post2004*dist_ktx
reg Lmean dist_ktx, absorb(sigungu_cd) vce(cluster sigungu_cd)
predict e,resid

local IVLIST dist_direct elev_med rugged_med slope_med
foreach x of local IVLIST{
reg e Lcell_num town_eup `x' post2004 dist_post,vce(cluster sigungu_cd)
test `x'
reg e Lcell_num town_eup `x' post2004 dist_post if big_city==0,vce(cluster sigungu_cd)
test `x'
}

/*             F-Statistics
dist_direct		27.42  24.13
elev_med		17.92  30.45
rugged_med		25.30  33.29
slope_med		25.05  34.06










