# project506
 ## introduction and overview  3-5 paragraphs
 what your topic is; information; sources; <br />
 description of the data used <br />
 scope, language <br />
 reason for unsimilar results <br />
 
 Topic:
 (Divisive) Hierachical Clustering
 Sources:
 
#introduction to clustering analysis
The hierarchical analysis 
Divisive hierachical algorithms are built top-down: starting with the whole sample in a unique
cluster they split this cluster into two subclusters which are, in turn, divided into subclusters
and so on. At each step the two new clusters make up a so-called bipartition of the former. It
is well known (Edwards and Cavalli-Sforza 1965) that there are 2n - 1 – 1 ways of splitting a set
of n objects into two subsets. 

$$
||a-b||_2 = \sqrt{\sum_i (a_i-b_i)^2}
$$

#dataet used here 
(source, variables inside, data structure, goal)
The dataset here is a sample of the transactions made in a retail store. The store wants to know better the customer purchase behaviour against different products. 

Dataset of 550 000 observations about the black Friday in a retail store, it contains different kinds of variables either numerical or categorical. 
User_ID: User ID
Product_ID: Product ID
Gender: Sex of User
Age: Age in bins
Occupation: Occupation
City_Category: Category of the City: A,B,C
Stay_In_Current_City_Years: Number of years stay in current city
Marital_Status: Marital Status
Product_Category_1: Product Category
Product_Category_2: Product may belongs to other category also
Product_Category_3: Product may belongs to other category also
Purchase: Purchase amount in dollars

Goal:
By saying predict customer preference, we expect to find informative characteristics of each group after clustering.
we plan to use a few of the attributes in the data only for segmentation and the remaining only to profile the clusters. These profiling attributes (e.g. demographic and behavioral data) would help us better understand patterns of different customer groups. Meantime, we expect to check robustness of our hierarchical clustering models by comparing similarity between these profiling variables.

#running divisive clytering analysis in STATA\
Similar to R and Python, we need to first import the dataset into STATA. We use the "import delimited" command.

Considered too many missing values 
