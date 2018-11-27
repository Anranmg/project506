# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
import numpy as np
import pandas as pd
#import os
#cwd = os.getcwd()

bf = pd.read_csv("BlackFriday.csv")[['User_ID', 'Product_Category_1', 'Purchase']]
        
bf_sum = bf.groupby(['User_ID','Product_Category_1'], as_index=False).sum()

pivoted = bf_sum.pivot(index='User_ID', columns='Product_Category_1', values='Purchase')

bf_p_narm = pivoted.fillna(0)

df_dismat = bf_p_narm.assign(purchasesum = bf_p_narm.apply(np.sum, axis=1))

for column in df_dismat:
    df_perc_dismat = df_dismat
    df_perc_dismat[column] = df_dismat[column]/df_dismat['purchasesum']
    
df_perc_dismat = df_perc_dismat.drop(columns = ['purchasesum'])

df_perc_dismat_test = df_perc_dismat.head(100)
 
#####################################################################################

num_clusters = 0

#from skbio.core.distance import DistanceMatrix
#dm = DistanceMatrix(df_perc_dismat_test)
##################################Package not available###############################

###################################Another attempt##################################

#dismat = df_perc_dismat_test
#
#for column in df_perc_dismat_test:
#    dismat.append(df_perc_dismat_test[column])

###################################Another attempt##################################

#dismat = (pd.read_csv("project_v1.csv")
#    .drop(dismat.columns[0:27], axis=1)
#    )
#all_elements = df_perc_dismat.index
#dissimilarity_matrix = pd.DataFrame(dismat,index=all_elements, columns=all_elements)
#

###################################algorithm functions################################


#def avg_dissim_within_group_element(ele, element_list):
#    max_diameter = -np.inf
#    sum_dissm = 0
#    for i in element_list:
#        sum_dissm += dissimilarity_matrix[ele][i]   
#        if( dissimilarity_matrix[ele][i]  > max_diameter):
#            max_diameter = dissimilarity_matrix[ele][i]
#    if(len(element_list)>1):
#        avg = sum_dissm/(len(element_list)-1)
#    else: 
#        avg = 0
#    return avg
#
#def avg_dissim_across_group_element(ele, main_list, splinter_list):
#    if len(splinter_list) == 0:
#        return 0
#    sum_dissm = 0
#    for j in splinter_list:
#        sum_dissm = sum_dissm + dissimilarity_matrix[ele][j]
#    avg = sum_dissm/(len(splinter_list))
#    return avg
#    
#    
#def splinter(main_list, splinter_group):
#    most_dissm_object_value = -np.inf
#    most_dissm_object_index = None
#    for ele in main_list:
#        x = avg_dissim_within_group_element(ele, main_list)
#        y = avg_dissim_across_group_element(ele, main_list, splinter_group)
#        diff= x -y
#        if diff > most_dissm_object_value:
#            most_dissm_object_value = diff
#            most_dissm_object_index = ele
#    if(most_dissm_object_value>0):
#        return  (most_dissm_object_index, 1)
#    else:
#        return (-1, -1)
#    
#def split(element_list):
#    main_list = element_list
#    splinter_group = []    
#    (most_dissm_object_index,flag) = splinter(main_list, splinter_group)
#    while(flag > 0):
#        main_list.remove(most_dissm_object_index)
#        splinter_group.append(most_dissm_object_index)
#        (most_dissm_object_index,flag) = splinter(element_list, splinter_group)
#    
#    return (main_list, splinter_group)
#
#def max_diameter(cluster_list):
#    max_diameter_cluster_index = None
#    max_diameter_cluster_value = -np.inf
#    index = 0
#    for element_list in cluster_list:
#        for i in element_list:
#            for j in element_list:
#                if dissimilarity_matrix[i][j]  > max_diameter_cluster_value:
#                    max_diameter_cluster_value = dissimilarity_matrix[i][j]
#                    max_diameter_cluster_index = index
#        
#        index +=1
#    
#    if(max_diameter_cluster_value <= 0):
#        return -1
#    
#    return max_diameter_cluster_index
#    
#
#current_clusters = ([all_elements])
#level = 1
#index = 0
#while(index!=-1):
#    print(level, current_clusters)
#    (a_clstr, b_clstr) = split(current_clusters[index])
#    del current_clusters[index]
#    current_clusters.append(a_clstr)
#    current_clusters.append(b_clstr)
#    index = max_diameter(current_clusters)
#    level +=1
#
#
#print(level, current_clusters)


###################################### use another method ######################################
################################### Ward ##################################


import scipy.cluster.hierarchy as shc
import matplotlib.pyplot as plt  

plt.figure(figsize=(10, 7))  
plt.title("Customer Dendograms")  
dend = shc.dendrogram(shc.linkage(df_perc_dismat, method='ward'))  
