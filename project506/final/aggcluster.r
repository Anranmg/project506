library(cluster)
library(fpc)
library(ggplot2)
library(tidyr)
library(dplyr)
library(data.table)
library(psych)
library(cowplot)
# We need to load data into R by using read.csv since it's in csv format.
## set working directory---------------
#setwd("~/Desktop/group_proj")

# import data-----------------------------
data=read.csv("https://raw.githubusercontent.com/Anranmg/project506/master/project506/final/BlackFriday.csv",header=TRUE, sep=',')

# Because product category2 and category3 are products belong to other catagory, it recalculate same product, we drop these two category.
# By manipulating data, we get a new dataset with user_id and 18 category1 ratios for each user.
# segementation attributes: ratio_in_cate1-ratio_in_cate18
# profiling attributes: Occupation,Age,Gender
data = data%>%
  select(User_ID,Occupation,Age,Gender,Product_Category_1,Purchase)%>%
  group_by(User_ID)%>%
  mutate(total=sum(Purchase))%>%
  group_by(User_ID,Product_Category_1,Occupation,Age,Gender)%>%
  summarise(Purchase = sum(Purchase), total = mean(total))%>%
  mutate(Purchase=Purchase/total)%>%
  spread(Product_Category_1,Purchase)%>%
  replace(.,is.na(.),0)%>%
  select(-total)
names(data)[5:22]=paste0("ratio_in_cate",1:18,sep="")

# Simple summary statistics of our dataset
psych::describe(data[,2:22])%>%
  select(vars, n, mean, sd, median, min, max, range)

# check structure and list first 5 obs
head(data,5)

# segementation attributes: ratio_in_cate1-ratio_in_cate18
# since all segementation variables are on a similar scale, 
# we skip the feature scaling step

# reason to choose ratio in cates as segementaion variables----------------
# use euclidean distance measure to calculate pairwise distance
data1=data[5:22]
m=dist(data1)%>%
  as.matrix()
# list pairwise distance between first 5 consumers
m[1:5,1:5]
# selected histogram of ratio_in_cate1 and ratio_in_cate5
# we could find 'mountains and valleys' patterns in these two graphs, 
# indicating being potential segements for later analysis. 
plot1=ggplot(data,aes(x=ratio_in_cate1))+
  geom_histogram(col="black",fill="white")+
  xlab("histogram of ratio_in_cate1")+
  ylab("frequency")
plot2=ggplot(data,aes(x=ratio_in_cate5))+
  geom_histogram(col="black",fill="white")+
  xlab("histogram of ratio_in_cate5")+
  ylab("frequency")
cowplot::plot_grid(plot1,plot2)


#clustering analysis----------------------------
# Using hierarchical clustering method, and get the dendrogram.
# agglomeration method
# linkage: ward
# And we use euclidean method to calculate distance.
sol = hclust(dist(data1), method = "ward.D")
plot(sol,cex = 0.3,hang = - 10, main = "Ward-linkage Cluster Dendrogram")
rect.hclust(sol, k=20, border="red")

# Select number of clusters based on ch index--------------------------
#And we use clusters=2
stat=data.frame(no.=c(2:15))
fun=function(k){
  cluster_id = cutree(as.hclust(sol), k)
  return(calinhara(data1,cluster_id))
}
stat$calinhara=sapply(stat$no.,fun)
stat

#clustering result
cluster_id = cutree(as.hclust(sol), k = 2)
# Check the number of each cluster
table(cluster_id)
data_cluster = data.frame(cluster_id)
tmp=cbind(cluster_id=data_cluster$cluster_id,data)
# clustering result in first 5 obs
tmp[1:10,c(2,1)]

# Profile and interpret the segments----------------------------------
# average values of purchase ratio in two clusters
tb=as.data.table(tmp)
av=data.frame(cluster_id=0)%>%
  cbind(as.data.frame(tb[,lapply(.SD,mean),.SDcols=ratio_in_cate1:ratio_in_cate18]))%>%
  bind_rows(as.data.frame(tb[,lapply(.SD,mean),by=cluster_id,.SDcols=ratio_in_cate1:ratio_in_cate18]))%>%
  gather(key=type,value=measurement,-cluster_id)%>%
  mutate(cluster_id=factor(cluster_id),category=rep(1:18,each=3))

#table of average values within clusters
tb1=av%>%
  spread(key=cluster_id,val=measurement)
names(tb1)[3:5]=c("population","group1","group2")

#line plot of average values within clusters
av%>%
  ggplot(aes(x=category,y=measurement,group=cluster_id))+
  geom_line(aes(color=cluster_id))+
  geom_point(aes(color=cluster_id))+
  labs(title="Plot of Purchase Proportion",y="mean of cluster")+
  scale_color_manual(labels=c("Population","Group 1","Group 2"),
                     values=c("#999999", "#E69F00", "#56B4E9"))

# line plot of occupation
ocp=tmp%>%
  group_by(cluster_id)%>%
  mutate(n=1/n())%>%
  group_by(cluster_id,Occupation)%>%
  summarise(pct=sum(n))%>%
  bind_rows(tmp%>%
              mutate(n=1/n())%>%
              group_by(Occupation)%>%
              summarise(pct=sum(n))%>%
              mutate(cluster_id=0))
ocp$cluster_id=factor(ocp$cluster_id)

ocp%>%
  ggplot(aes(x=Occupation,pct,group=cluster_id))+
  geom_line(alpha=.5, aes(color=cluster_id))+
  geom_point(alpha=.5, aes(color=cluster_id))+
  labs(title="Plot of Occupation Proportion",y="mean of cluster")+
  scale_color_manual(labels=c("Population","Group 1","Group 2"),
                     values=c("#999999", "#E69F00", "#56B4E9"))
# The plot shows that group 2 in occupation
# distribution plot of age
tmp$cluster_id=factor(tmp$cluster_id)
ggplot(tmp,aes(x=Age,fill=cluster_id))+
  geom_histogram(alpha=.5, position="dodge",stat="count")+
  scale_color_discrete(labels=c("Group 1","Group 2"))+
  labs(title="Plot of Age Distribution")

