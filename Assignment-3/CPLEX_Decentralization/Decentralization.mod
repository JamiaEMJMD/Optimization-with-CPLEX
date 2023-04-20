/*********************************************
 * OPL 22.1.0.0 Model
 * Author: Jamia Begum
 *    NIU: 1676891
 * Creation Date: 17 Dec 2022 at 21:19:30
 *********************************************/
 
{string} Cities = ...; 
{string} Depts = ...; 
 
float Benefit[Depts][Cities]=...; //Benefits to be derived from each relocation
float CostComm[Cities][Cities]=...; //matrix representing the unit communication cost between cities
float Comm[Depts][Depts]=...; //matrix representing the communication quantity between departments
 
  
int LimDeptsLoc = ...;  
 
// Decision Variables
//Binary Variables
dvar int IsIn[Depts][Cities]in 0..1;  //1 if department i in{A, B, C, D, E} is located 
                                     //in city j in {London, Bristol, Brighton}
                                     // 0 otherwise

dvar int Link[Depts][Cities][Depts][Cities] in 0..1;


// Generic formulation of the objective function terms
dexpr float Benef = sum(j in Cities)sum(i in Depts) Benefit[i][j]*IsIn[i][j] ; // formulate here Benefit expression
dexpr float Cost = sum(ordered i, j in Depts) 
                 sum( k, l in Cities) Comm[i][j] * CostComm[k][l] * Link[i][k][j][l]; // formulate here Cost expression
                   
maximize  Benef- Cost;

subject to{
  //every department must be located at one single city
  forall(i in Depts)
    sum(j in Cities) IsIn[i][j]==1; 
    
    //None of these cities can be the location for 
    //more than three of the departments
  forall(i in Cities)
     sum(j in Depts) IsIn[j][i]<=LimDeptsLoc;
        
        forall(ordered i, j in Depts)
      forall(k, l in Cities)
        {
//if department i is located in city k and department j is located in city l then variable Link == 1
             (IsIn[i][k]==1) &&  (IsIn[j][l]==1) => Link[i][k][j][l]==1;
// if variable Link == 1 then department i is located in city k and department j is located in city l
             Link[i][k][j][l]==1 =>  (IsIn[i][k]==1 ) &&  (IsIn[j][l]==1) ;
             
         }             
             
            
}     

execute DISPLAY { writeln("Maximum profit = " ,
 cplex.getObjValue(), " Cost = " , Cost, " Benefit = ", Benef );
for(var d in Depts) 
  for(var c in Cities) 
    if(IsIn[d][c] == 1) writeln("Department ", d, " is located in ", c);
for(var d1 in Depts) 
  for(var d2 in Depts) 
    for(var c1 in Cities) 
       for(var c2 in Cities)
          if(Link[d1][c1][d2][c2] == 1) 
             writeln("Dep. ", d1, " located in ", c1, 
             " links with Dep. ", d2, " located in ", c2, 
             " at communication cost ", CostComm[c1][c2] );
}       
    
