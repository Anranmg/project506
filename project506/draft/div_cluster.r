# Load all the libraries we need for our analysis:
library(sqldf)
library(cluster)
library(ggplot2)
library(tidyr)
library(dplyr)

# We need to load data into R by using read.csv since it’s in csv format.
#setwd("./Desktop")
data=read.csv("./BlackFriday.csv",header=TRUE, sep=',')

# Because product category2 and category3 are products belong to other catagory, it recalculate same product, we drop these two category.
# By manipulating data, we get a new dataset with user_id and 18 category1 ratios for each user.
data=data %>%
  select(-Product_ID,-Product_Category_2,-Product_Category_3)%>%
  group_by(User_ID)%>%
  mutate(total=sum(Purchase))%>%
  group_by(User_ID,Product_Category_1)%>%
  summarise(Purchase=sum(Purchase),total=mean(total))%>%
  mutate(Purchase=Purchase/total)%>%
  spread(Product_Category_1,Purchase)%>%
  replace(.,is.na(.),0)%>%
  select(-total)

# Since the dataset is so large, it will takes more than 10 mins to run, we choose first 100 data to just show one result.
data = head(data, n = 100)

# Check the data structure.
str(data)

# Standardization data
data2 = data[2:19]
data1 = scale(data[2:19])

# Using diana cluster to cluster, and get the dendrogram of diana.
# And we use euclidean method to calculate distance.
sol = diana(data2, metric = "euclidean", stand = TRUE)
pltree(sol, cex = 0.3, hang = -1)

# Just for test, we choose k=4 to cluster data into 4 groups.
cluster_id = cutree(as.hclust(sol), k = 4)

# Check the number of each cluster
table(cluster_id)
data_cluster = data.frame(cluster_id)
tmp=cbind(cluster_id=data_cluster$cluster_id,data)
data_all=sqldf('select a.*,b.cluster_id from data as a left join tmp as b on a.User_ID=b.User_ID')

# Select cluster number to generate barplot of category ratio in cluster 1. 
cluster_data=sqldf('select a.* from data_all as a where a.cluster_id = 1')

# Summary cluster data.
summary(cluster_data)

plot_data = colMeans(cluster_data)
barplot(plot_data[2:19])

# Select cluster number to generate barplot of category ratio in cluster 2. 
cluster_data=sqldf('select a.* from data_all as a where a.cluster_id = 2')
plot_data = colMeans(cluster_data)
barplot(plot_data[2:19])

# Select cluster number to generate barplot of category ratio in cluster 3. 
cluster_data=sqldf('select a.* from data_all as a where a.cluster_id = 3')
plot_data = colMeans(cluster_data)
barplot(plot_data[2:19])

# Select cluster number to generate barplot of category ratio in cluster 4. 
cluster_data=sqldf('select a.* from data_all as a where a.cluster_id = 4')
plot_data = colMeans(cluster_data)
barplot(plot_data[2:19])

