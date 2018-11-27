//program drop diana
program diana
    //import parameter
	gen mn=0
	gen mn_2=0
	gen diff=0
    //average distance within goup
   local n=_N
   forval i=1/`n'{
     forval j=1/`n'{
      if  (`i' == `j') { 
	  qui su dist_`j' if group==`1'     //first group
	  replace mn=`r(sum)'/(`r(N)'-`2'+`1') in `i'
		}
   }
}
   //initiare the splinter group
   qui su mn if group==`1'
   replace group=`2' if mn==float(`r(max)')
   
local d=1
while (`d'>0){
   //average disimilarity to remaining objects
local n=_N
forval i=1/`n'{
   forval j=1/`n'{
    if  (`i' == `j') { 
	qui su dist_`j' if group!=`2' //second group
	replace mn=`r(sum)'/(`r(N)'-1) in `i'
	 }
   }
}
   //average disimilarity to splinter
   local n=_N
   forval i=1/`n'{
      forval j=1/`n'{
      if  (`i' == `j') { 
	  qui su dist_`j' if group==`2'
	  replace mn_2=`r(sum)'/(`r(N)') in `i'
	 }
   }
}
   //compare with two distance and remove the next object
   replace diff=mn-mn_2
   qui su diff if group==`1'
   local d=`r(max)'
   replace group=`2' if (diff==float(`d')) & (`d'>0)
}     
  //drop intermediate variable
 drop mn mn_2 diff
end

/*
alogrithm explanation: 
measure: euclidean distance
average linkage
2 cluster case:
1st: matrix of dissimilarities
2nd: calculate average disimilarity to the other objects
3rd:  compared average disimilarity to remaining objects with distance to splinter
4th: repeat until maximized difference become negative
5th: split data into 2 groups
*/
