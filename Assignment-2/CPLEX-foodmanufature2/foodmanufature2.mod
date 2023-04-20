/*********************************************
 * OPL 22.1.0.0 Model
 * Author: Jamia Begum
 *    NIU:1676891
 * Creation Date: 29 Nov 2022 at 19:43:29
 *********************************************/
  // raw oil elemement declaration
{string} VegRaw = ...; 
{string} NonVegRaw = ...; 
{string} Raw = VegRaw union NonVegRaw;


// final month of planning horizon
int NbMonths   = ...;
// range representing the planning horizon
range Months = 1..NbMonths;


// Matrix respresenting the buying cost 
// for each month (rows) and each raw material (column)
float CostRaw[Raw][Months] = ...;

// other constant attributes
int ProfitProd = ...;
int CostStore = ...;
int MaxVeg = ...;
int MaxOil = ...;
int InitialStock = ...;
int FinalStock = ...;
int MaxStore = ...;
int MinUse = ... ;

// hardness index of raw oils
float HardRaw[Raw] = ...;
float MinHard = ...;
float MaxHard = ...;

// Decision Variables
dvar float+ Produce[Months]; // production amount
dvar float+ Use[Months][Raw]; // used raw oils
dvar float+ Buy[Months][Raw]; // row oil procurement
dvar float Store[0..NbMonths][Raw] in 0..1000; // storing policy


 // Generic formulation of the objective function terms
dexpr float Profit = sum(j in Months) Produce[j] * ProfitProd; // formulate here profit expression
dexpr float Cost = sum(j in Months) sum(k in Raw) Buy[j][k]*CostRaw[k][j]+ 
                   sum(j in Months)sum(k in Raw) Store[j][k]*CostStore; // formulate here supply ad store cost expression
                   
maximize Profit - Cost;
subject to {
  
	// initial and final stock constraints 
   	  forall(j in Raw)
   	    ct1:
   	    Store[0][j]==500;
   	   forall(j in Raw)
   	     ct2: 
   	  Store[NbMonths][j]==500;
  	// vegetable production capacity constraint
  	forall(j in Months)
       	ct3:
       	sum(k in VegRaw) Use[j][k]<= MaxVeg;
       	
	// non vegetable production capacity constraint 
	forall(j in Months)              
       	ct4:
       	sum(k in NonVegRaw) Use[j][k]<= MaxOil;
       	
	// quality estipulation constraint
       	forall(j in Months)
       	  ct5:
       	  sum(k in Raw) Use[j][k]*HardRaw[k]>=  MinHard*Produce[j];
       	 forall(j in Months)
       	   ct6:
       	   sum(k in Raw) Use[j][k]*HardRaw[k] <=  MaxHard*Produce[j];
       	    
       	  
	// Material balance Constraint (all what is used is mixed in the product)
        forall(j in Months)
          ct7:
          sum(k in Raw) Use[j][k] == Produce[j];
            
	// Material balance Constraint  (relationship Stock-Supply-Use)
	     forall(j in Months,k in Raw)
          ct8:
           Store[j-1][k]+ Buy[j][k] == Use[j][k]+Store[j][k];  
         
           
  //The food may never be made up of more than three oils in any month
       forall(j in Months)
       	  ct9:
       	  sum(k in Raw) (Use[j][k] >= MinUse) <=3;
       	        
    //oil use constraints (either use 0 unit or more than 20)       
            forall(j in Months,k in Raw)
          ct10:
           (Use[j][k]==0) || (Use[j][k]) >= MinUse;
           
 //If either of VEG 1 or VEG 2 are used in a month then OIL 3 must also be used
        forall(j in Months)
          ct11:
(Use [j]["Veg1"]>=MinUse) || (Use[j]["Veg2"] >= MinUse) => Use[j]["Oil3"] >= MinUse ;   
           
         }



 