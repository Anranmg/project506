# install packages
library(sqldf)

# read file
data=read.csv("~/Desktop/BlackFriday.csv",header=T)

library(dplyr)

#manipulate data
data$Gender=as.numeric(factor(data$Gender))
data$Age=as.numeric(factor(data$Age))
data$City_Category =as.numeric(factor(data$City_Category ))
data$Stay_In_Current_City_Years=as.numeric(factor(data$Stay_In_Current_City_Years))


#group data
group_data=group_by(data,User_ID,
                    Gender,Age,Occupation,City_Category,
                    Stay_In_Current_City_Years,Marital_Status)

data_sql=summarise(group_data,sum(Purchase))


#check data structure 
str(data_sql)

#standardization data
data1=scale(data_sql[2:8])


library(cluster)

#diana cluster
h2=diana(head(data1,10000), stand = TRUE)

#plot
plot(h2)
#choose k=4,cluster
cluster_id = cutree(as.hclust(h2), k = 4)

#check the number of each cluster
table(cluster_id)


#transfer data to datafrme
data_cluster=data.frame(cluster_id)

tmp=cbind(data_cluster,data_sql)
tmp

data_all=sqldf('select a.*,b.cluster_id from data as a left join tmp as b on a.User_ID=b.User_ID')



# base on each cluster purchase on Product_Category_1
Product_Category_1_count=sqldf('select cluster_id,Product_Category_1,count(*) as count 
                               from data_all group by cluster_id,Product_Category_1 ')

Product_Category_1_count$cluster_id = factor(Product_Category_1_count$cluster_id)
Product_Category_1_count$Product_Category_1 = factor(Product_Category_1_count$Product_Category_1)


library(ggplot2)
# plot
ggplot(Product_Category_1_count, aes(x = cluster_id, y = count, fill = Product_Category_1)) +
  geom_bar(stat="identity",aes(fill=Product_Category_1))
