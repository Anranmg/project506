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
                        replace dist_`j'=sqrt(`d') in `i'  // change added
                        }
                }
        }
//visualiza pairwise distance
list dist_1-dist_5 in 1/5
save projectv1, replace

keep dist* user_id
reshape long dist_,i(user_id) j(j)
rename dist_ distance
hist distance, freq title("histogram of pairwise distances") 
graph export project1.png, replace
		
		
//divisve hierarchical clustering
//considered computation cost, only select first 100 observations
drop dist_101-dist_5891
drop if _n>100		
//calculate average distance to find splinter
gen group=1
diana 1 2  // split group 1 into 2 clusters
diana 1 3
diana 1 4

//cluter data with 4 clusters
list group in 1/10
export delimited using "./project_result.csv", replace

/*****report clustering result *****/
//average value for each group (table & figure)
drop dist_*
save project_result,replace
//population mean
//add one obs
local new = _N + 1
set obs `new'
//population average
foreach var of varlist all_purchase1-all_purchase18 marital_status occupation{
   qui su `var',mean
   replace `var'=`r(mean)' in 101
}
replace group=0 in 101
//table for 4 clusters
collapse (mean) all_purchase* marital_status occupation, by(group)

drop marital_status occupation
reshape long all_purchase, i(group) j(type)
//profile with demographic features with graph 
tw (connected all_purchase type if group==0) || (connected all_purchase type if group==1) /*
*/|| (connected all_purchase type if group==2) || (connected all_purchase type if group==3) /*
*/|| (connected all_purchase type if group==4), legend(lab(1 "population") lab(2 "group 1") lab(3 "group 2") lab(4 "group 3") lab(5 "group 4")) title("proportion of purchase within 4 clusters")
graph export project2.png, replace


use project_result,clear
//change string to numeric
rename gender str_gender
gen gender=1 if str_gender=="M"
replace gender=0 if gender==.
//profile with demographic features with graph 
graph bar marital_status gender, over(group) title("average marital status and gender within segement")/*
*/legend(lab(1 "marital status") lab(2 "gender")) note("gender: 0 female, 1 male; marital: 0 unmarried, 1 mariied")

bys group occupation: gen prop=_N
bys group: gen num=_N
replace prop= prop/num
tw (connected prop occupation if group==1) || (connected prop occupation if group==2) || (connected prop occupation if group==3) /*
*/|| (connected prop occupation if group==4), legend(lab(1 "group 1") lab(2 "group 2") lab(3 "group 3") lab(4 "group 4")) title("proportion of occupation within 4 clusters")
graph export project3.png, replace
