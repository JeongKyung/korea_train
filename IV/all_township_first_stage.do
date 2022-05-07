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
eststo:reg dist_ktx `x',r
eststo:reg dist_ktx `x' Lcell_num,r
eststo:reg dist_ktx `x' Lcell_num town_eup,r			//(3)
test `x'
eststo:reg dist_ktx `x' Lcell_num town_eup if big_city==0,r  //(4)
test `x'
esttab using `x'.tex,replace ///
nomtitles mgroups("Distance to KTX", pattern(1 0 0 0) ///
span prefix(\multicolumn{@span}{c}{) suffix(})) ///
se(3) ar2 star nocon ///
label title(IV`i': `j')
}

/*F-statistics of IV in specification (3)&(4)
distance: 23652.34 17885.58
elevation: 1216.89 989.79
ruggedness: 359.68 243.93
slope: 362.46 247.78 */

eststo clear

**II. IV Regression (assuming that each instrument is valid)
local IVLIST dist_direct elev_med rugged_med slope_med
local titlelist Distance Elevation Ruggedness Slope
local num: word count `IVLIST'
forvalues n=1/`num'{
local x: word `n' of `IVLIST'
local y: word `n' of `titlelist'

eststo clear
eststo: ivregress 2sls Lmean Lcell_num (dist_ktx=`x'),vce(r)
eststo: ivregress 2sls Lmean Lcell_num (dist_ktx=`x') if big_city==0,vce(r)
esttab using ./two_stage_`x'.tex, replace ///
nomtitles mgroups("Light Mean", pattern(1 0) ///
span prefix(\multicolumn{@span}{c}{) suffix(})) ///
se(3) label title(Two-Stage Results using `y')
}

eststo clear

**III. Exogeneity Checks by the over-identification tests (2IV's are required)
local ivlist elev_med rugged_med slope_med
foreach i of local ivlist{
ivregress 2sls Lmean Lcell_num (dist_ktx=dist_direct `i'),vce(r)
predict e, resid
reg e dist_direct `i' Lcell_num
test dist_direct `i'
dis "J-stat2="r(df)*r(F) 
drop e

ivregress 2sls Lmean Lcell_num (dist_ktx=dist_direct `i') if big_city==0,vce(r)
predict e, resid
reg e dist_direct `i' Lcell_num
test dist_direct `i'
dis "J-stat2="r(df)*r(F) 
drop e
}

/*                               
								   F-statistics
dist_direct & elev_med			663.69		664.97
dist_direct & rugged_med		675.67	 	675.54
dist_direct * slope_med			683.45 		683.34
Excluding big_cities			   X		   O

all overidentifying tests indicate that at least one instrument of each combination is endogeneous,
but we cannot tell which is endogenous or not.
*/




