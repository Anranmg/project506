# project506
 ## introduction and overview  3-5 paragraphs
 what your topic is; information; sources; <br />
 description of the data used <br />
 scope, language <br />
 reason for unsimilar results <br />
 
# introduction to clustering analysis
The hierarchical analysis 

# dataet used here 
(source, variables inside, data structure, goal)

# running divisive clytering analysis in STATA
Similar to R and Python, we need to first import the dataset into STATA. We use the "import delimited" command.
**import delim....

We only use information in "product_category_1" for clustering analysi considered too many missing values 
in another two categories. In our clustering model, we use customer preference, defined as proporation of expense in 
each product category, to help identify market segments and use some of the remaining geo-demographic attribututes to profile the clusters. Therefore, we later reshaped the dataset to the wide format and obtain 18 different variables. 

To gain a overview of our consumer's shopping preference, we use summarize:
**summarize all_purchase* 

Since our goal is to group customer based on how similiar taste they have for shopping, we use Euclidean distance measure as 
well as average linkage method. With list command, the distance betweem the first ten consumers, using their shopping behaviors, are:
**list dist* in 1/10

Later, to provide a first understanding of the dataset, we draw a histogram graph of all pairwise distance for 
eucliean distance. The "mountain an valleys" patterns in the graph indicates there indeed multiple fragments in the dataset.
**tw hist

Unlike R, there is no relevant command to compute divisive hierarchical clustering analysis. We thus write our own programming
command "Diana" with reference to Kaufman, L. and Pousseeuw, P.J. (1999). The alogrithm is fully describe in Chapter 6. Even
though it has reduced the computation cost quite a lot, it still takes much time for the loop compared with agglomerative hierarchical clustering method. For simplicity, we at first look at the 4-segments solution and the segmentation result is shown as following
for the first 10 consumers in the dataset.
**list group in 1/10

We 


# reference 
Finding groups in data: An introduction to cluster analysis
