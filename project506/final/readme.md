***THIS IS THE FINAL VERSION FOR GROUP PROJECT.***



## Agglomertive Hierarchical Clustering using Ward Linkage

Group 10 (Yuxuan Hu,Ke Li and Anran Meng)



### Agglomerative Hierarchical Clustering
As indicated by the term ***hierarchical***, the method seeks to build clusters based on hierarchy. Generally, there are two types of clustering strategies: ***Agglomerative*** and ***Divisive***. Here, we mainly focus on the agglomerative approach, which can be easily pictured as a ‘bottom-up’ algorithm.

> Observations are treated separately as singleton clusters. Then, compute the Euclidean distance of each pair and successively merge the most similar clusters. Repeated the previous step until the final optimal clusters are formed. 



### Ward Linkage Method
There are four methods for combining clusters in ***agglomerative approach***. The one we choose to use is called ***Ward’s Method***. Unlike the others. Instead of measuring the distance directly, it analyzes the variance of clusters. Ward’s is said to be the most suitable method for quantitative variables. 

[Ward's method](https://www.stat.cmu.edu/~cshalizi/350/lectures/08/lecture-08.pdf)
 says that the distance between two clusters, A and B, is how
much the sum of squares will increase when we merge them:
$$
\Delta(A,B) = \sum_{i\in A \bigcup B} ||\overrightarrow{x_i} - \overrightarrow{m}_{A \bigcup B}||^2 - \sum_{i \in A}||\overrightarrow{x_i} - \overrightarrow{m}_A||^2 -\sum_{i \in B}||\overrightarrow{x_i}- \overrightarrow{m}_B||^2 
= \frac{n_An_B}{n_A+n_B} ||\overrightarrow{m}_A- \overrightarrow{m}_B||^2
$$ 

where $\overrightarrow{m}_j$is the center of cluster j, and $n_j$ is the number of points in it. $\Delta$ is called the merging cost of combining the clusters A and B.
With hierarchical clustering, the sum of squares starts out at zero (because every point is in its own cluster) and then grows as we merge clusters. Ward’s method keeps this growth as small as possible.


The [Euclidean distance](https://en.wikipedia.org/wiki/Euclidean_distance) is the "ordinary" straight-line distance between two points in Euclidean space.

$$
d(p,q) = d(q,p) = \sqrt{(q_1 -p_1)^2 + (q_2 - p_2)^2 + \cdots + (q_n -p_n)^2} = \sqrt{\sum_{i=1} (q_i-p_i)^2}
$$

![](https://github.com/Anranmg/project506/blob/master/project506/final/ward_def.png?raw=true)

### Calinski and Harabasz Index
***Calinski and Harabasz Index (CH Index)*** is often used for choosing the optimal number of clusters. 
This criterion combines the within and between cluster variance to evalute the quality of segmentation. 
The formula of ***CH Index*** defined as:
$$CH(K)=\frac{B(K)/(K-1)}{W(K)/(n-K)}$$
where ***W*** denotes within-cluster variation, ***B*** denotes between-cluster variation. 

To obtain a small within-cluster variation and large within-cluster variation simultaneously, we would pick the value of K with the largest CH score as the stopping point. Even though in practice, there is
limitation in CH index, for simplicity, we use CH Index as our main cluster stopping rule in this project.  


### Dataset: [Black Friday](https://www.kaggle.com/mehdidag/black-friday/ 'Black Friday')

In this tutorial, we choose the dataset on Black Friday with 6 variables. Dataset of 550 000 observations about the black Friday in a retail store, it contains different kinds of variables either numerical or categorical. It also contains missing values. 

The description of the variables we use can be found below. 


Variable  | Desciption| Range/Unit
----------- |----------- |----------- 
User_ID| User ID | 1000001-1006040 
Gender| Gender | F(female), M(male)  
Age| Age in bins | 0-17;18-25;26-35;36-45;46-50;51-55;55+
Occupation | Occupation | 0-20
Product_Category_1 | Product Category | 0-18
Purchase | Purchase amount| in dollars



```{r,echo=FALSE,message=FALSE, warning=FALSE, paged.print=FALSE}
# library(cluster)
# library(fpc)
# library(ggplot2)
# library(tidyr)
# library(dplyr)
# library(data.table)
source('./aggcluster.r')
```

In our later analysis, we use purchase portion in product category as segmentation attributes. After some transformation, the simple summary statistics of our dataset is shown as following:

```{r summarize data,eval=TRUE, echo=FALSE}
psych::describe(data[,2:22])%>%
  select(vars, n, mean, sd, median, min, max, range)
```


To test whether the method is fit for this data, we plot histgram on 18 segmentation features. And two selected histogram of ratio_in_cate1 and ratio_in_cate5 are shown as belows:

```{r echo=FALSE, message=FALSE, warning=FALSE, paged.print=FALSE}
plot1=ggplot(data,aes(x=ratio_in_cate1))+
  geom_histogram(col="black",fill="white")+
  xlab("histogram of ratio_in_cate1")+
  ylab("frequency")
plot2=ggplot(data,aes(x=ratio_in_cate5))+
  geom_histogram(col="black",fill="white")+
  xlab("histogram of ratio_in_cate5")+
  ylab("frequency")
cowplot::plot_grid(plot1,plot2)
```

These two histograms show that customer have different preference on different category products.\
We could find 'mountains and valleys' patterns in these two graphs, indicating being potential segements for later analysis. 



### R

Load all the libraries we need for our analysis:
```{r}
library(cluster)
library(fpc)
library(ggplot2)
library(tidyr)
library(dplyr)
library(data.table)
```

#### Data Preparation

We need to load data into R by using read.csv since it's in csv format.

```{r load data, message=FALSE, warning=FALSE, paged.print=FALSE}
dt=read.csv("https://raw.githubusercontent.com/Anranmg/project506/master/project506/final/BlackFriday.csv",header=TRUE, sep=',')
```

Product_category 2 and product_category 3 are products belong to other catagories, it recalculate same product, thus, we drop these two product_categories. By manipulating data, we get a new dataset with user_id, occupation, age, gender and ratio in 18 categories for each user.

`head` command allow us to check structure:

```{r list data,eval=TRUE}
head(data,1)
```

Choosing ratio in categories as segementaion variables, and using euclidean distance measure to calculate pairwise distance. Then we show pairwise distance between first 5 consumers:
```{r echo=F, message=FALSE, warning=FALSE}
m[1:5,1:5]
```


#### Clustering Analysis

Using hierarchical clustering method, and get the dendrogram.\
Method: Agglomeration method \
Linkage: ward \
Use euclidean method to calculate distance.

```{r echo=TRUE, message=FALSE, warning=FALSE, paged.print=FALSE}
plot(sol,cex = 0.3,hang = - 10, main = "Ward-linkage Cluster Dendrogram")
rect.hclust(sol, k=20, border="red")
```

Select number of clusters based on CH index. When clusters number is 2, calinhara has max value. Thus, choose 2 be the number of clusters with `cutree` command.
```{r, echo=F, message=FALSE, warning=FALSE, paged.print=T}
stat
```
```{r echo=TRUE, message=FALSE, warning=FALSE, paged.print=FALSE}
cluster_id = cutree(as.hclust(sol), k = 2)
```

Check the number of each cluster
```{r echo=F, message=FALSE, warning=FALSE}
table(cluster_id)
```

Clustering result in first 10 obs:
```{r echo=F, message=FALSE, warning=FALSE,paged.print=FALSE}
knitr::kable(tmp[1:10,c(2,1)])
```

#### Analysis on Demographic Features
The plot shows average purchase proportion for each group and mean ourchase proportion for whole population. 

* From plot of Purchase Proportion and plot of Occupation Proportion, we can see group 2 have more people with occupation 2 and 20 than group 1, while group 2 has obvious purchase preference on product category 5 and 8. Thus, we can infer that people with occupation 2 and 20 may prefer buying product category 5 and 8 


* Group 1 has more people with occupation 13 and 17, while group 1 has large purchase ratio on product category 1, we can also speculate that people with occupation 13 and 17 have ralatively purchase preference on product category 1.

```{r ,echo=F, message=FALSE, warning=FALSE, paged.print=T}
#table of average values within clusters
tb1
```

```{r echo=F, message=FALSE, warning=FALSE, paged.print=FALSE}
#line plot of average values within clusters
av%>%
  ggplot(aes(x=category,y=measurement,group=cluster_id))+
  geom_line(aes(color=cluster_id))+
  geom_point(aes(color=cluster_id))+
  labs(title="Plot of Purchase Proportion",y="mean of cluster")+
  scale_color_manual(labels=c("Population","Group 1","Group 2"),
                     values=c("#999999", "#E69F00", "#56B4E9"))
```
```{r echo=F, message=FALSE, warning=FALSE, paged.print=FALSE}
# line plot of occupation
ocp%>%
  ggplot(aes(x=Occupation,pct,group=cluster_id))+
  geom_line(alpha=.5, aes(color=cluster_id))+
  geom_point(alpha=.5, aes(color=cluster_id))+
  labs(title="Plot of Occupation Proportion",y="mean of cluster")+
  scale_color_manual(labels=c("Population","Group 1","Group 2"),
                     values=c("#999999", "#E69F00", "#56B4E9"))
```

According to the plot, we can see that the age is similar distributed in each group.
```{r echo=F, message=FALSE, warning=FALSE, paged.print=FALSE}
ggplot(tmp,aes(x=Age,fill=cluster_id))+
  geom_histogram(alpha=.5, position="dodge",stat="count")+
  scale_color_discrete(labels=c("Group 1","Group 2"))+
  labs(title="Plot of Age Distribution")
```




### Stata

#### Data Prepartion

Similar to R and Python, we need to first import the dataset into STATA. We use the `import delimited` command. 

```{r load data2, eval=FALSE}
import delimited "https://raw.githubusercontent.com/Anranmg/project506/master/BlackFriday.csv"
```

We only use information in "product_category_1" for clustering analysis considered too many missing values in another two categories. In our clustering model, we use customer preference, defined as relative expense in each product category, to help identify market segments. Meanwhile, we use some of the remaining geo-demographic attribututes to profile the clusters. Therefore, we later reshaped the dataset to the wide format and obtain 18 different variables.
```{r reshape data2, eval=FALSE}
reshape wide all_purchase, i(user_id) j(product_category_1)
```

To gain a overview of our consumer's shopping preference, we use `summarize` command. And use `encode`
command to convert string to numerical variables. As all our segmentation attributes are on the similar
scale (0 to 1), we skip the feature scaling step. 

```{r view head of data2, eval=FALSE}
encode gender, gen(sex)
encode age, gen(nage)
encode city_category, gen(city)
encode stay_in_current_city_years, gen(stay_years)
summarize all_purchase*

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
all_purch~e1 |      5,891    .3574884    .2054086          0          1
all_purch~e2 |      5,891    .0487926    .0535967          0   .5145295
all_purch~e3 |      5,891    .0432541    .0679692          0   .7986262
all_purch~e4 |      5,891    .0054967    .0099025          0   .1729248
all_purch~e5 |      5,891    .1935776    .1421216          0          1
-------------+---------------------------------------------------------
all_purch~e6 |      5,891     .064011    .0748471          0   .7285641
all_purch~e7 |      5,891    .0112639    .0371069          0   .8893259
all_purch~e8 |      5,891    .1760551    .1295851          0   .9368429
all_purcha~9 |      5,891    .0010103    .0059569          0   .2057311
all_purch~10 |      5,891    .0214523    .0480529          0   .6188408
-------------+---------------------------------------------------------
all_purch~11 |      5,891    .0218461    .0511153          0   .7596826
all_purch~12 |      5,891    .0012126    .0045447          0   .1463652
all_purch~13 |      5,891    .0007597    .0019349          0   .0402441
all_purch~14 |      5,891    .0037908    .0142612          0   .3009311
all_purch~15 |      5,891    .0167197    .0337391          0   .7496737
-------------+---------------------------------------------------------
all_purch~16 |      5,891    .0305506    .0474592          0     .44275
all_purch~17 |      5,891    .0010501    .0060297          0   .1240658
all_purch~18 |      5,891    .0016683    .0078574          0   .3889048

```


#### Clustering Analysis
Since our goal is to group customer based on how similiar taste they have for shopping, we use euclidean distance measure as well as ward linkage method. `dendrogram` command allows us to visualize the 
clustering results (shown in Figure1). 

```{r clustering data2, eval=FALSE}
cluster wardslinkage all_purchase*, measure(Euclidean) name(ward)
cluster list ward

ward  (type: hierarchical,  method: wards,  dissimilarity: L2)
      vars: ward_id (id variable)
            ward_ord (order variable)
            ward_hgt (height variable)
     other: cmd: cluster wardslinkage all_purchase*, measure(Euclidean) name(ward)
            varlist: all_purchase1 all_purchase2 all_purchase3 all_purchase4
                 all_purchase5 all_purchase6 all_purchase7 all_purchase8
                 all_purchase9 all_purchase10 all_purchase11 all_purchase12
                 all_purchase13 all_purchase14 all_purchase15 all_purchase16
                 all_purchase17 all_purchase18
            range: 0 .

cluster dendrogram ward, xlabel(, angle(90) labsize(*.75)) cutnumber(20) title(Ward-linkage clustering)
```
![](https://github.com/Anranmg/project506/blob/master/project506/final/project1.png?raw=true)


For simplicity, we use the Calinski Harabasz method to choose no. of clusters. Based on that, we finally use 2-segments solution and the segmentation result is shown as following. 

```{r stopingrule data2, eval=FALSE}
cluster stop ward

+---------------------------+
|             |  Calinski/  |
|  Number of  |  Harabasz   |
|  clusters   |  pseudo-F   |
|-------------+-------------|
|      2      |   2640.99   |
|      3      |   1920.50   |
|      4      |   1910.16   |
|      5      |   1737.10   |
|      6      |   1569.27   |
|      7      |   1409.96   |
|      8      |   1315.29   |
|      9      |   1243.72   |
|     10      |   1201.23   |
|     11      |   1160.03   |
|     12      |   1117.24   |
|     13      |   1068.26   |
|     14      |   1009.08   |
|     15      |    982.52   |
+---------------------------+


```

We use `list` command to show the clustering result of our first ten consumers.
```{r result data2, eval=FALSE}
list user_id group in 1/10

     +-----------------+
     | user_id   group |
     |-----------------|
  1. | 1000001       1 |
  2. | 1000002       1 |
  3. | 1000003       1 |
  4. | 1000004       1 |
  5. | 1000005       2 |
     |-----------------|
  6. | 1000006       1 |
  7. | 1000007       1 |
  8. | 1000008       2 |
  9. | 1000009       2 |
 10. | 1000010       2 |
     +-----------------+

```
We also plot a line chart to compare difference between groups: 

* it is apparent that compared with ***two groups***, customers in group one spend much more in ***category 1*** while
they are less likely attracted by products in ***category 5 and 8***. 

* Also, we can find people clustered in ***group two*** have some relatively preference on  ***category 5 and 8***.

* Based on these results, the company
could set tailored promotion strategy on different groups of people. 


![](https://github.com/Anranmg/project506/blob/master/project506/final/project2.png?raw=true)


#### Analysis on Demographic Features
Combined demographic features, we use the following plots to help detect divergence among these two clusters: 

* No big difference in age or residence structure among these two groups

* However, if we look at the percent of occupation, there are some interesting findings:

    + for example, for people with ***job 2***, they are more likely to be gathered in ***group two***. In other words, they would be more likely to be attracted by products in ***category 5 and 8***. Thus, the company could make customerized ads for these workers. 

    + Similar conclusion can also applied to ***job 20***.

![](https://github.com/Anranmg/project506/blob/master/project506/final/project4.png?raw=true)
![](https://github.com/Anranmg/project506/blob/master/project506/final/project5.png?raw=true)



### Python

Import all the packages needed for hierarchical agglomerative clustering and Ward's linkage:

```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt  
import scipy.cluster.hierarchy as shc
from sklearn.cluster import AgglomerativeClustering
from sklearn import metrics
import seaborn as sns
```
Download the online data directly and read as .csv file:

```python
bf = pd.read_csv("https://raw.githubusercontent.com/Anranmg/project506/master/project506/final/BlackFriday.csv")
```

#### Data Preparation


Before start, we need to clean and reshape the data to a preferred format. For example, "product_category_2" and "product_category_3" need to be removed for not providing enough analyzable information. We calculated the individual total expenditures of 18 product categories and then standardized to a measure of percentage. Finally, we reshaped the table from long to wide for the convenience of calculation.

Following is the data manipulation code and an overview of the reshaped data: 


```python
bf_sum = bf.groupby(['User_ID','Product_Category_1'], as_index=False).sum()
bf_sum = bf_sum[['User_ID','Purchase','Product_Category_1']]
pivoted = bf_sum.pivot(index='User_ID', columns='Product_Category_1', values='Purchase')
bf_p_narm = pivoted.fillna(0)
df_dismat = bf_p_narm.assign(purchasesum = bf_p_narm.apply(np.sum, axis=1))
for column in df_dismat:
    df_perc_dismat = df_dismat
    df_perc_dismat[column] = df_dismat[column]/df_dismat['purchasesum']   
df_perc_dismat = df_perc_dismat.drop(['purchasesum'],axis=1)
df_perc_dismat.iloc[0:10,0:5]
```

    Product_Category_1         1         2         3         4         5
    User_ID                                                             
    1000001             0.184730  0.038509  0.359418  0.016829  0.047226
    1000002             0.510480  0.019584  0.000000  0.000000  0.099327
    1000003             0.669071  0.085044  0.031923  0.000000  0.185654
    1000004             1.000000  0.000000  0.000000  0.000000  0.000000
    1000005             0.236785  0.031829  0.013217  0.009435  0.141807
    1000006             0.327155  0.094866  0.156316  0.033132  0.200092
    1000007             0.938603  0.000000  0.000000  0.000000  0.029911
    1000008             0.436071  0.020013  0.016653  0.000000  0.057605
    1000009             0.251823  0.000000  0.090828  0.000000  0.086095
    1000010             0.322341  0.118658  0.086327  0.008085  0.270491   




#### Clustering Analysis

Plot the Customer Dendograms to visualize the results:

```python
data = df_perc_dismat.values  
plt.figure(figsize=(10, 7))  
plt.title("Customer Dendograms")  
dend = shc.dendrogram(shc.linkage(data, method='ward')) 
```

![](https://github.com/Anranmg/project506/blob/master/project506/final/py_dend1.png?raw=true){width=60%}

Choose the number of clusters between 2 and 15 and print with the associated Calinski-Harabaz Index. Then, we check through the line chart to visualize the difference of clusters when setting the number of clusters to 2.

```python
for k in range(2,15):
    cluster = AgglomerativeClustering(n_clusters=k, affinity='euclidean', linkage='ward')
    cluster.fit_predict(data)  #print clusters
    print (k, metrics.calinski_harabaz_score(data,cluster.labels_))
```



      Clusters    Calinski-Harabaz Index
        2             2430.54743198
        3             2069.67755838
        4             1995.90988942
        5             1731.82812779
        6             1562.46158999
        7             1435.16182401
        8             1345.25671186
        9             1279.30670412
        10            1223.71316752
        11            1184.40091503
        12            1133.39691105
        13            1080.13084484
        14            1035.6524882




```python
cluster = AgglomerativeClustering(n_clusters=2, affinity='euclidean', linkage='ward')
cluster.fit_predict(data)

```


![](https://github.com/Anranmg/project506/blob/master/project506/final/py_2.png?raw=true){width=60%}






Apparently, customers within the clutser #1 highly prefer purchasing product of category #1 than the other 17 kinds. Product of category #5 and #8 are slightly more preferred by customers within cluster #0. Product category ranged from #9 to #18 are not as popular. 


#### Analysis on Demographic Features


For furthur research, we took a look at 'occupation' and 'age', two pre-excluded variables that actually can affect the purchasing preference. 

First, we observed that 'age' has brought minimal effect to the clustering decision. Density functions follow the similar trend, without worth-noticing patterns or obvious information towards purchasing preference.





![](https://github.com/Anranmg/project506/blob/master/project506/final/py_age.png?raw=true){width=60%}




However, the result of 'occupation' is worth exploring. It shows the maximum purchasing percentage of cluster #0 was denoted by customers with occupation #4; The maximum purchasing percentage of cluster #1 was denoted by customers with occupation #0. The density functions' trends vary a lot. Therefore, 'occupation' can be assumed as a significance variable for customer preference prediction model.   






![](https://github.com/Anranmg/project506/blob/master/project506/final/py_occp.png?raw=true){width=60%}


## Things to Consider
There is some potential risk in our analysis. For example, it might be to early to draw the conclusion on occupation as some other features have strong impact on consumer's shopping preference. Additionally, for time limited, we skip the robustness check step. It could hurt the validness of our clustering results. 

## References
1. [*A Dendrite Method for Cluster Analysis*](https://www.tandfonline.com/doi/pdf/10.1080/03610927408827101)

2. [*Euclidean Distance*](https://en.wikipedia.org/wiki/Euclidean_distance)

3. [*Ward's Method*](https://www.stat.cmu.edu/~cshalizi/350/lectures/08/lecture-08.pdf)

4. [*Hierarchical agglomerative clustering*](https://nlp.stanford.edu/IR-book/html/htmledition/hierarchical-agglomerative-clustering-1.html)
 
5. [*Divisive clustering*](https://en.wikipedia.org/wiki/Hierarchical_clustering#Divisive_clustering)

## Link to Github
All the materials can be found in our [Github](https://github.com/Anranmg/project506/tree/master/final).
