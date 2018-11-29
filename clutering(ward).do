/*****data clearing *****/
//import dataset
import delimited "https://raw.githubusercontent.com/Anranmg/project506/master/BlackFriday.csv"

//keep variables that later would be used
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
size:5891*25
gender: female: 28%; male:72%
age: 35% are between 26 and 35; 20% between 36 and 45
*/
summarize all_purchase*
//convert string variable to the numerical
describe
encode gender, gen(sex)
encode age, gen(nage)
encode city_category, gen(city)
encode stay_in_current_city_years, gen(stay_years)
drop gender age city_category stay_in_current_city_years


/*****clustering analysis*****/
//initial: split sample into 2 parts: training(80%) 4713 obs, testing(20%) 1178 obs
//final: no longer split the dataset

/*measure: correlation 
down-top clustering: cluster 
linkage: ward
*/
cluster wardslinkage all_purchase*, measure(correlation) name(ward)
//basic info for the clustering method
cluster list ward
//draw dendrogram
cluster dendrogram ward, xlabel(, angle(90) labsize(*.75)) cutnumber(20) title(Ward-linkage clustering)
graph export project0.png, replace

//Calinski–Harabasz;  The highest Calinski–Harabasz pseudo-´ F value 
//how many cluster to choose
cluster stop ward
 
//choose k=2
cluster generate group=group(2)
table group


//list clutering result for first ten obs
list user_id group in 1/10



/******assess clustering ******/
//visualiza pairwise distance
matrix dissimilarity di = all_purchase*, correlation
//sil
silhouette group, dist(di) id(user_id) lwidth(1 1 1) title("silhouette coefficient")


/*******report clustering result *********/
//average value for each group (table & figure)
save project_result

//population mean
//add one obs
local new = _N + 1
set obs `new'
//population average
foreach var of varlist all_purchase1-all_purchase18 marital_status sex stay_years nage{
   qui su `var',mean
   replace `var'=`r(mean)' in 5892
}
replace group=0 in 5892
//table with numeric values for 2 clusters
collapse (mean) all_purchase* marital_status sex stay_years nage, by(group)
list

//profile with features with graph
//difference between clusters in customer preference 
drop marital_status sex stay_years nage
reshape long all_purchase, i(group) j(type)
tw (connected all_purchase type if group==0) || (connected all_purchase type if group==1) /*
*/|| (connected all_purchase type if group==2) , legend(lab(1 "population") lab(2 "group 1") lab(3 "group 2")) title("proportion of purchase within 4 clusters")
graph export project2.png, replace


/***** profile with demographic features with graph ******/
use project_result,clear
//marital status; gender
graph bar marital_status sex, over(group) title("average marital status and gender within segement")/*
*/legend(lab(1 "marital status") lab(2 "gender")) note("gender: 1 female, 2 male; marital: 0 unmarried, 1 mariied")
graph export project3.png, replace

//proportion of occupation
bys group occupation: gen prop=_N
bys group: gen num=_N
replace prop= prop/num
bys occupation: gen prop_al=_N
gen num_al=_N
replace prop_al= prop_al/num_al
tw (connected prop_al occupation, msymbol(D)) || (connected prop occupation if group==1) || (connected prop occupation if group==2), /*
*/legend(lab(1 "population") lab(2 "group 1") lab(3 "group 2")) title(" Occupation Proportion between Clusters")
graph export project4.png, replace

//age; city; stay_years
gen frequency = 1
graph bar (sum) frequency, over(group) over(nage) asyvars title("Distribution of Age between Clusters") ytitle("Counts")
graph bar (sum) frequency, over(group) over(city) asyvars title("Distribution of City between Clusters") ytitle("Counts")
graph bar (sum) frequency, over(group) over(stay_years) asyvars title("Distribution of Living Years between Clusters") ytitle("Counts")

