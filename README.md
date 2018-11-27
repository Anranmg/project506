# Project506
 ## Introduction and overview  3-5 paragraphs
 what your topic is; information; sources; <br />
 description of the data used <br />
 scope, language <br />
 reason for unsimilar results <br />
 ## Topic:
 (Divisive) Hierachical Clustering
# Introduction to clustering analysis
[The hierarchical analysis][https://en.wikipedia.org/wiki/Hierarchical_clustering#Divisive_clustering] 

Divisive hierachical algorithms are built top-down: starting with the whole sample in a unique
cluster they split this cluster into two subclusters which are, in turn, divided into subclusters
and so on. At each step the two new clusters make up a so-called bipartition of the former. It
is well known (Edwards and Cavalli-Sforza 1965) that there are 2n - 1 – 1 ways of splitting a set
of n objects into two subsets. 

[Euclidean distance][https://en.wikipedia.org/wiki/Euclidean_distance]

$$
||a-b||_2 = \sqrt{\sum_i (a_i-b_i)^2}
$$

# Dataset used here 
(source, variables inside, data structure, goal)
## Source:
[Black Friday, Kaggle Reference][https://www.kaggle.com/mehdidag/black-friday]

The dataset here is a sample of the transactions made in a retail store. The store wants to know better the customer purchase behaviour against different products. 

Dataset of 550 000 observations about the black Friday in a retail store, it contains different kinds of variables either numerical or categorical. 

## Variables inside:
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

## Goal:
By saying predict customer preference, we expect to find informative characteristics of each group after clustering.
we plan to use a few of the attributes in the data only for segmentation and the remaining only to profile the clusters. These profiling attributes (e.g. demographic and behavioral data) would help us better understand patterns of different customer groups. Meantime, we expect to check robustness of our hierarchical clustering models by comparing similarity between these profiling variables.

# Running divisive clustering analysis in STATA
Similar to R and Python, we need to first import the dataset into STATA. We use the "import delimited" command. <br />
**import delim....

We only use information in "product_category_1" for clustering analysi considered too many missing values 
in another two categories. In our clustering model, we use customer preference, defined as proporation of expense in 
each product category, to help identify market segments and use some of the remaining geo-demographic attribututes to profile the clusters. Therefore, we later reshaped the dataset to the wide format and obtain 18 different variables.  <br />

To gain a overview of our consumer's shopping preference, we use summarize: <br />
**summarize all_purchase* 

Since our goal is to group customer based on how similiar taste they have for shopping, we use Euclidean distance measure as 
well as average linkage method. With list command, the distance betweem the first ten consumers, using their shopping behaviors, are: <br />
**list dist* in 1/10

Later, to provide a first understanding of the dataset, we draw a histogram graph of all pairwise distance for 
eucliean distance. The "mountain an valleys" patterns in the graph indicates there indeed multiple fragments in the dataset. <br />
**tw hist

Unlike R, there is no relevant command to compute divisive hierarchical clustering analysis. We thus write our own programming
command "Diana" with reference to Kaufman, L. and Pousseeuw, P.J. (1999). The alogrithm is fully describe in Chapter 6. Even
though it has reduced the computation cost quite a lot, it still takes much time for the loop compared with agglomerative hierarchical clustering method. For simplicity, we at first look at the 4-segments solution and the segmentation result is shown as following
for the first 10 consumers in the dataset. <br />
**list group in 1/10

We  <br />

# Running divisive clustering analysis in Python
First, we need to clean and reshape the huge dataset, keeping informative columns ('User_ID', 'Product_Category_1' and 'Purchase' in our case) and converting to a wide readable table. Using pandas package in Python, we follow the similar ideas as using dyplr in R. First of all, calculating the individual purchasing percentage under each category over years. Then, reshaping the long table to a wide form with customers' ID as the row names, and the categorical index of products as the column names. <br />

Since there is no built-in Python package or method for divisive clustering. We write several functions based on the principle of algorithm. The first step is to construct a dissimilarity matrix, which is symmerical. <br /> 

However, so far, the dissimilarity matrix is 5891 by 5891, which is still too big for clustering. We also noticed extreme data points have huge effect to the outcome. More adjustments (e.g. introducing criterions) will be implemented in the furture steps. <br />



# reference 
Finding groups in data: An introduction to cluster analysis
