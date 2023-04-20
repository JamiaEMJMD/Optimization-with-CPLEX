/*********************************************
 * OPL 22.1.0.0 Model
 * Author: Jamia Begum
 *    NIU: 1676891
 * Creation Date: 18 Dec 2022 at 01:34:00
 *********************************************/

 {string} Products =...; //products to be manufactured
 int T=...;
 {string}Resources=...;
 range TimePeriod= 1..T;//a vector
 
 float Avail[Resources][TimePeriod]=...; //availability of resources over the periods
 float ResourceReq[Products][Resources]=...; //resource requirements are per production unit
 float Demand[Products][TimePeriod]=...; //matrix to represent demands over the periods
 
 float Inv0[Products]=...; //initial inventory
 float Backorder0[Products]=...; //initial backorder
 float EndInv[Products]=...; //Ending inventory
 float EndBlg[Products]=...; //Ending backorder
 
float Prodcost[Products][TimePeriod]=...;//Production costs (€/ton)
float Backlogcost[Products][TimePeriod]=...;//Backlog costs (€/ton)
float Invcost[Products][TimePeriod]=...;//Inventory costs (€/ton)

// Decision Variables
dvar float+ Make[Products][TimePeriod]; //what to make of product p during the period T
dvar float+ Inv[Products][0..T];  //what to store of product p during the period T
dvar float+ Backorder[Products][0..T];//what to accept as backorder of product P during the period T

// objective function 
dexpr float Cost = sum(i in Products)sum(j in TimePeriod)Prodcost[i][j]* Make[i][j]+
                   sum(i in Products)sum(j in TimePeriod)Backlogcost[i][j]*Backorder[i][j]+
                   sum(i in Products)sum(j in TimePeriod)Invcost[i][j]*Inv[i][j];

minimize Cost;

subject to{
  
  //initial and final inventory
  forall(i in Products){
    Inv[i][0]==Inv0[i];
    Inv[i][T]==EndInv[i];
  }   
  
  //initial and final Backorder
   forall(i in Products){
    Backorder[i][0]==Backorder0[i];
    Backorder[i][T]<=EndBlg[i];
  }  
  
  //the balance equation between two consecutive periods
   forall(i in Products,j in TimePeriod)
     Inv[i][j-1]-Backorder[i][j-1]+Make[i][j]==Inv[i][j]-Backorder[i][j]+Demand[i][j];
       
  //balance equation between required and available resources 
  forall(i in Resources, j in TimePeriod) 
      sum(p in Products)(Make[p][j]*ResourceReq[p][i]) <= Avail[i][j]; 
      
   }                   


execute DISPLAY { writeln("Minimum cost = " , cplex.getObjValue());
writeln("Initial inventories and backorders:"); 
for(var p in Products)
 { writeln(" Product ",p,": <Inventory: ",Inv[p][0],", Backorder: ", Backorder[p][0],">");}
 
writeln();
writeln("Production Scheduling:");
 for(var t in TimePeriod) { 
  writeln(" Period ", t); 
  writeln(" -------- ");
    for(p in Products) {
       writeln(" Product ",p,": <Inventory: ",Inv[p][t],
        ", Backorder: ", Backorder[p][t], ", Make: ", Make[p][t],">");
                        }
                                }
writeln(); 
writeln("Final inventories and backorders:"); 
for(p in Products) {
   writeln(" Product ",p,": <Inventory: ",Inv[p][T], ", Backorder: ", Backorder[p][T],">");
} 
  }
  