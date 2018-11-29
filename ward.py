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
#import os
#cwd = os.getcwd()

# Data Cleaning 
bf = pd.read_csv("BlackFriday.csv")

########################################################################################################

bf_purchase = bf.groupby(['User_ID','Age','Occupation'], as_index=False).sum()
col_list = ['User_ID', 'Purchase','Age','Occupation']
bf_purchase = bf_purchase[col_list]
mapping = {'0-17': 1, '18-25': 2, '26-35': 3, '36-45': 4, '46-50':5, '51-55':6, '55+': 7}
bf_purchase = bf_purchase.applymap(lambda s: mapping.get(s) if s in mapping else s)

data = bf_purchase.values  

plt.figure(figsize=(10, 7))  
plt.title("Customer Dendograms")  
dend = shc.dendrogram(shc.linkage(data, method='ward')) #dend of clustering by purchase sum

cluster = AgglomerativeClustering(n_clusters=5, affinity='euclidean', linkage='ward')  
cluster.fit_predict(data)  #print clusters

plt.figure(figsize=(10, 7))  
plt.scatter(data[:,3], data[:,1], c=cluster.labels_, cmap='rainbow') #scatter plot of clusters

#The scatter plot does not show clear clusters.

########################################################################################################

bf_Age = bf[['Age', 'Purchase']]
bf_Age_p = bf_Age.groupby(['Age'], as_index=False).sum()

mapping = {'0-17': 1, '18-25': 2, '26-35': 3, '36-45': 4, '46-50':5, '51-55':6, '55+': 7}
bf_Age = bf_Age.applymap(lambda s: mapping.get(s) if s in mapping else s)
bf_Age_p = bf_Age_p.applymap(lambda s: mapping.get(s) if s in mapping else s)
age_data = bf_Age_p.values

plt.figure(figsize=(10, 7))  
plt.title("Customer Dendograms")  
dend = shc.dendrogram(shc.linkage(age_data, method='ward')) #dend of clustering by Age

cluster = AgglomerativeClustering(n_clusters=5, affinity='euclidean', linkage='ward')  
cluster.fit_predict(age_data)  #print clusters

plt.figure(figsize=(10, 7))  
plt.scatter(age_data[:,0], age_data[:,1], c=cluster.labels_, cmap='rainbow') #scatter plot of clusters

########################################################################################################

bf_Ocup = bf[['Occupation', 'Purchase']]
bf_Ocup_p = bf_Ocup.groupby(['Occupation'], as_index=False).sum()
Ocup_data = bf_Ocup_p.values

plt.figure(figsize=(10, 7))  
plt.title("Customer Dendograms")  
dend = shc.dendrogram(shc.linkage(Ocup_data, method='ward')) #dend of clustering by Occupation

cluster = AgglomerativeClustering(n_clusters=5, affinity='euclidean', linkage='ward')  
cluster.fit_predict(Ocup_data)  #print clusters

plt.figure(figsize=(10, 7))  
plt.scatter(Ocup_data[:,0], Ocup_data[:,1], c=cluster.labels_, cmap='rainbow') #scatter plot of clusters

########################################################################################################
#Using percentage

bf_sum = bf.groupby(['User_ID','Product_Category_1'], as_index=False).sum()
bf_sum = bf_sum[['User_ID','Purchase','Product_Category_1']]
pivoted = bf_sum.pivot(index='User_ID', columns='Product_Category_1', values='Purchase')
bf_p_narm = pivoted.fillna(0)
df_dismat = bf_p_narm.assign(purchasesum = bf_p_narm.apply(np.sum, axis=1))
for column in df_dismat:
    df_perc_dismat = df_dismat
    df_perc_dismat[column] = df_dismat[column]/df_dismat['purchasesum']
df_perc_dismat_test1 = df_perc_dismat.iloc[0:100,0:18]

plt.figure(figsize=(10, 7))  
plt.title("Customer Dendograms")  
dend = shc.dendrogram(shc.linkage(df_perc_dismat_test1, method='ward'))

sum_data = df_perc_dismat_test1.values
sum_data_whole = df_perc_dismat.values
cluster = AgglomerativeClustering(n_clusters=5, affinity='euclidean', linkage='ward')  
cluster.fit_predict(sum_data)  #print clusters
cluster.fit_predict(sum_data_whole)  #print clusters

plt.figure(figsize=(10, 7))  
plt.scatter(sum_data[:,0], sum_data[:,1], c=cluster.labels_, cmap='rainbow') #scatter plot of clusters
plt.scatter(sum_data_whole[:,0], sum_data_whole[:,1], c=cluster.labels_, cmap='rainbow') 

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
