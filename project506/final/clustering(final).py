# -*- coding: utf-8 -*-
"""
Created on Tue Nov 27 20:17:34 2018

@author: Yuxuan Hu
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt  
import scipy.cluster.hierarchy as shc
from sklearn.cluster import AgglomerativeClustering
from sklearn import metrics
import seaborn as sns
#import os
#cwd = os.getcwd()

# Data Cleaning 
bf = pd.read_csv("https://raw.githubusercontent.com/Anranmg/project506/master/BlackFriday.csv")

########################################################################################################
#Using percentage
#Using the whole data set(scatter plot)

bf_sum = bf.groupby(['User_ID','Product_Category_1'], as_index=False).sum()
bf_sum = bf_sum[['User_ID','Purchase','Product_Category_1']]
pivoted = bf_sum.pivot(index='User_ID', columns='Product_Category_1', values='Purchase')
bf_p_narm = pivoted.fillna(0)
df_dismat = bf_p_narm.assign(purchasesum = bf_p_narm.apply(np.sum, axis=1))
for column in df_dismat:
    df_perc_dismat = df_dismat
    df_perc_dismat[column] = df_dismat[column]/df_dismat['purchasesum']   
df_perc_dismat = df_perc_dismat.drop(['purchasesum'],axis=1)
data = df_perc_dismat.values  


plt.figure(figsize=(10, 7))  
plt.title("Customer Dendograms")  
dend = shc.dendrogram(shc.linkage(data, method='ward')) #dend of clustering by purchase sum

########################################################################################################
#choose no. of clusters between 2 and 15 with Calinski-Harabaz Index 
for k in range(2,15):
    cluster = AgglomerativeClustering(n_clusters=k, affinity='euclidean', linkage='ward')
    cluster.fit_predict(data)  #print clusters
    print (k, metrics.calinski_harabaz_score(data,cluster.labels_))

#no. of cluster=2
cluster = AgglomerativeClustering(n_clusters=2, affinity='euclidean', linkage='ward')
cluster.fit_predict(data)  #print clusters


plt.figure(figsize=(10, 7))  
plt.scatter(data[:,0], data[:,1], c=cluster.labels_, cmap='rainbow') #scatter plot of clusters
plt.xlabel('expense proportion in product category1')
plt.ylabel('expense proportion in product category2')
plt.title('scatter plot of expense between clusters')



########################################################################################################
#Analysis on clusters 

bf_result = bf[['User_ID','Age','Occupation']]
bf_result = bf_result.groupby(['User_ID','Age'], as_index=False).mean()
mapping = {'0-17': 1, '18-25': 2, '26-35': 3, '36-45': 4, '46-50':5, '51-55':6, '55+': 7}
bf_result = bf_result.applymap(lambda s: mapping.get(s) if s in mapping else s)
bf_result['Group']=cluster.fit_predict(data)
bf_result['Percent']=1

#Analysis on clusters by occupation
bf_Ocup = bf_result.groupby(['Group','Occupation']).agg({'Percent': 'sum'})
bf_Ocup=bf_Ocup.groupby(level=['Group']).apply(lambda x: 100 * x / float(x.sum())).reset_index()
sns.pairplot(x_vars=["Occupation"], y_vars=["Percent"], data=bf_Ocup, hue='Group', size=5)

fig, ax = plt.subplots(figsize=(8,6))
for label, df in bf_result.groupby('Group'):
    df.Occupation.plot(kind="kde", ax=ax, label=label)
plt.legend()

#Analysis on clusters by Age distribution
bf_Age = bf_result.groupby(['Group','Age']).agg({'Percent': 'sum'})
bf_Age=bf_Age.groupby(level=['Group']).apply(lambda x: 100 * x / float(x.sum())).reset_index()
sns.pairplot(x_vars=["Age"], y_vars=["Percent"], data=bf_Age, hue='Group', size=5)

fig, ax = plt.subplots(figsize=(8,6))
for label, df in bf_result.groupby('Group'):
    df.Age.plot(kind="kde", ax=ax, label=label)
plt.legend()



#########################################################################################################

ward = AgglomerativeClustering(n_clusters=6, linkage='ward').fit(df_perc_dismat)
ward.fit(df_perc_dismat)
print(ward.labels_) 

#convert dataframe to matrix
conv_arr= df_perc_dismat.values

#split matrix into 3 columns each into 1d array
arr = []
for i in range(0,18):
    arr.append(conv_arr[i,:])    

plt.scatter(conv_arr[:,0], conv_arr[:,1], c=ward.labels_, cmap='rainbow')  

#########################################################################################################
#truncated dendrogram

from scipy.cluster.hierarchy import dendrogram, linkage

# Dendrogram Truncation
# generate the linkage matrix
Z = linkage(df_perc_dismat, 'ward')
#with more details
plt.title('Hierarchical Clustering Dendrogram (truncated)')
plt.xlabel('sample index or (cluster size)')
plt.ylabel('distance')
dendrogram(
    Z,
    truncate_mode='lastp',  # show only the last p merged clusters
    p=12,  # show only the last p merged clusters
    leaf_rotation=90.,
    leaf_font_size=12.,
    show_contracted=True,  # to get a distribution impression in truncated branches
)
plt.show()