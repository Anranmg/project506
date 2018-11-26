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

//cluter data with 5 clusters




/*****report clustering result *****/
//profile with demographic features
