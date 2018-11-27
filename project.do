/*****data clearing *****/
//import dataset
import delimited "/Users/meng/Downloads/BlackFriday.csv"

//keep variables that later would be use
drop product_category_2 product_category_3 product_id

//compute product preference for each customer, defined as total purchase for each category
//sum purchase within same category for each customer
bys user_id product_category_1:egen all_purchase=sum(purchase)
//delete redundent data for each customer
bys user_id product_category_1: drop if _n<_N
drop purchase
//reshape dataset from long to wide
reshape wide all_purchase, i(user_id) j(product_category_1)
//replace na with 0 for expense on each category  
forvalue i=1/18{
  replace all_purchase`i'=0 if all_purchase`i'==.
}

//summary statistics of final dataset
/*
no. of observations: 5891
gender: female: 28%; male:72%
age: 35% are between 26 and 35; 20% between 36 and 45
*/
summarize all_purchase*
tab gender 
tab age
//convert string variable to the numerical


/*****clustering analysis*****/
//split sample into 3 parts: training(60%), validation(20%) and test(20%)
set seed 92122
//measure: correlation 
//divisive: top-down //down-top clustering: cluster averagelinkage all_purchase*, measure(corr)

//compute disimilarity matrix
gen total=sum(all_purchase1+all_purchase2+all_purchase3+ all_purchase4+ all_purchase5+ all_purchase6+ all_purchase7+ all_purchase8+ all_purchase9+ all_purchase10+ all_purchase11+ all_purchase12+ all_purchase13+ all_purchase14+ all_purchase15+ all_purchase16+ all_purchase17 +all_purchase18)
forvalue i=1/18{
  replace all_purchase`i'=all_purchase`i'/total
}

//pairwise distance
local n = _N
forval i=1/`n'{
   gen dist_`i'=0
}

local n = _N
forval i = 1/`n' {
    forval j = 1/`n' {
          if  (`i' != `j') { 
		  local d=(all_purchase1[`i'] - all_purchase1[`j'])^2+/*
						*/(all_purchase2[`i'] - all_purchase2[`j'])^2+/*
						*/(all_purchase3[`i'] - all_purchase3[`j'])^2+/*
						*/(all_purchase4[`i'] - all_purchase4[`j'])^2+/*
						*/(all_purchase5[`i'] - all_purchase5[`j'])^2+/*
						*/(all_purchase6[`i'] - all_purchase6[`j'])^2+/*
						*/(all_purchase7[`i'] - all_purchase7[`j'])^2+/*
						*/(all_purchase8[`i'] - all_purchase8[`j'])^2+/*
						*/(all_purchase9[`i'] - all_purchase9[`j'])^2+/*
						*/(all_purchase10[`i'] - all_purchase10[`j'])^2+/*
						*/(all_purchase11[`i'] - all_purchase11[`j'])^2+/*
						*/(all_purchase12[`i'] - all_purchase12[`j'])^2+/*
						*/(all_purchase13[`i'] - all_purchase13[`j'])^2+/*
						*/(all_purchase14[`i'] - all_purchase14[`j'])^2+/*
						*/(all_purchase15[`i'] - all_purchase15[`j'])^2+/*
						*/(all_purchase16[`i'] - all_purchase16[`j'])^2+/*
						*/(all_purchase17[`i'] - all_purchase17[`j'])^2+/*
						*/(all_purchase18[`i'] - all_purchase18[`j'])^2
                        replace dist_`j'=`d' in `i'
                        }
                }
        }
		
//divisve hierarchical clustering		
//calculate average distance to find splinter
gen group=1
diana 1 2  // split group 1 into 2 clusters
diana 1 3
diana 2 4

/* diana command
local n=_N
forval i=1/`n'{
   forval j=1/`n'{
    if  (`i' == `j') { 
	qui su dist_`j' if group==1
	replace mn=`r(sum)'/(`r(N)'-2) in `i'
	 }
   }
}
//initiare the splinter group
qui su mn
replace group=2 if mn>=`r(max)'

//average disimilarity to remaining objects
local n=_N
forval i=1/`n'{
   forval j=1/`n'{
    if  (`i' == `j') { 
	qui su dist_`j' if group!=2
	replace mn=`r(sum)'/(`r(N)'-1) in `i'
	 }
   }
}

//average disimilarity to splinter
local n=_N
forval i=1/`n'{
   forval j=1/`n'{
    if  (`i' == `j') { 
	qui su dist_`j' if group==2
	replace mn_2=`r(sum)'/(`r(N)') in `i'
	 }
   }
}
//compare with two distance and remove the next object
replace diff=mn-mn_2
qui su diff
local d=`r(max)'
replace group=2 if (diff>=`d') & (`d'>0)

//repeat until all diff<0
max(diff)>0
//loop command for subcluster; no. group 2*i
*/

//cluter data with 4 clusters




/*****report clustering result *****/
//average value for each group (table & figure)
by group: collapse (mean) all_purchase*
//profile with demographic features with graph 
