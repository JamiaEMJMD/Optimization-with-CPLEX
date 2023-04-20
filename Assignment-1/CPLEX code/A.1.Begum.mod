/*********************************************
 * OPL 22.1.0.0 Model
 * Author: jamia
 * Creation Date: 16 Nov 2022 at 16:53:36
 *********************************************/
// --------------------------------------------------------------------------
// Licensed Materials - Property of IBM
//
// 5725-A06 5725-A29 5724-Y48 5724-Y49 5724-Y54 5724-Y55
// Copyright IBM Corporation 1998, 2022. All Rights Reserved.
//
// Note to U.S. Government Users Restricted Rights:
// Use, duplication or disclosure restricted by GSA ADP Schedule
// Contract with IBM Corp.
// --------------------------------------------------------------------------


//constant variables
int   NbMetals = ...;
int   NbRaw = ...;
int   NbScrap = ...;
int   NbIngo = ...;


//data structures to define data storage for variables
range Metals = 1..NbMetals; //range of integers from 1 to number of metals
range Raws = 1..NbRaw;
range Scraps = 1..NbScrap;
range Ingos = 1..NbIngo;

//cost variables
float CostMetal[Metals] = ...;//array to store metal´s cost indexed over all the metal types
float CostRaw[Raws] = ...;
float CostScrap[Scraps] = ...;
float CostIngo[Ingos] = ...;

//array for production constraints
float Low[Metals] = ...;
float Up[Metals] = ...;

//array for source constraints
float PercRaw[Metals][Raws] = ...;
float PercScrap[Metals][Scraps] = ...;
float PercIngo[Metals][Ingos] = ...;

//total  production constraint
int Alloy  = ...;

//define dvar='decision variable'
dvar float+    p[Metals]; //p takes positive float values
dvar float+    r[Raws];
dvar float+    s[Scraps];
dvar int+      i[Ingos]; //integer quantity of ignot
dvar float    m[j in Metals] in Low[j] * Alloy .. Up[j] * Alloy;//specifing the range for m

//model the problem
minimize 
  sum(j in Metals) CostMetal[j] * p[j] +
  sum(j in Raws)   CostRaw[j]   * r[j] +
  sum(j in Scraps) CostScrap[j] * s[j] +
  sum(j in Ingos)  CostIngo[j]  * i[j];
subject to {
  forall( j in Metals )
    ct1: //source constraint
      m[j] == 
      p[j] + 
      sum( k in Raws )   PercRaw[j][k] * r[k] +
      sum( k in Scraps ) PercScrap[j][k] * s[k] +
      sum( k in Ingos )  PercIngo[j][k] * i[k];
    ct2:  //total production constraint
      sum( j in Metals ) m[j] == Alloy;
}









 