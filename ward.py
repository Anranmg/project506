# -*- coding: utf-8 -*-
"""
Created on Mon Nov 26 22:05:09 2018

@author: Yuxuan Hu
"""

import numpy as np
import pandas as pd
#import os
#cwd = os.getcwd()

# data cleaning

bf = pd.read_csv("BlackFriday.csv")[['User_ID', 'Product_Category_1', 'Purchase']]
        
bf_sum = bf.groupby(['User_ID','Product_Category_1'], as_index=False).sum()

pivoted = bf_sum.pivot(index='User_ID', columns='Product_Category_1', values='Purchase')

bf_p_narm = pivoted.fillna(0)

df_dismat = bf_p_narm.assign(purchasesum = bf_p_narm.apply(np.sum, axis=1))

for column in df_dismat:
    df_perc_dismat = df_dismat
    df_perc_dismat[column] = df_dismat[column]/df_dismat['purchasesum']
    
df_perc_dismat = df_perc_dismat.drop(columns = ['purchasesum'])

# ward clustering

import scipy.cluster.hierarchy as shc
import matplotlib.pyplot as plt  

plt.figure(figsize=(10, 7))  
plt.title("Customer Dendograms")  
dend = shc.dendrogram(shc.linkage(df_perc_dismat, method='ward'))  