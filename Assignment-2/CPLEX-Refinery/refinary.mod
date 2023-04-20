/*********************************************
 * OPL 22.1.0.0 Model
 * Author: Jamia Begum
 *   NIU:1676891
 * Creation Date: 29 Nov 2022 at 22:28:58
 *********************************************/

 
 {string} Crude = ...;
{string} Naptha = ...;
{string} Resid = ...;
{string} Oil = ...;
{string} ReformProd = ...;
{string} CrackProd = ...;
{string} Petrol = ...; 
{string} Fuel = ...;
{string} Lube = ...;

float DistillNaptha[Crude][Naptha] = ...;
float DistillOil[Crude][Oil] = ...;
float DistillResid[Crude][Resid] = ...;

float ResidProcess[Resid][Lube] = ...;
float ReformProcess[Naptha][ReformProd] = ...;
float CrackProcess[Oil][CrackProd] = ...;

float VaporOil[Oil] = ...;
float VaporResid[Resid] = ...;
float VaporCrkOil = ...;
float LimVaporJF = ...;

float LimCrude[Crude] = ...;
float LimDistill = ...;
float LimReform = ...;
float LimCrack = ...;
float LoLube[Lube] = ...;
float UpLube[Lube] = ...;

float OctaneNaptha[Naptha] = ...;
float OctaneReform[ReformProd] = ...;
float OctaneCG = ...;
float ReqOctane[Petrol] = ...;
float ReqRatioPetrol = ...;

float ReqOilFO[Oil] = ...;
float ReqCrkFO = ...;
float ReqResidFO[Resid] = ...;

float ProfitPetrol[Petrol] = ...;
float ProfitFuel[Fuel] = ...;
float ProfitLube[Lube] = ...;


/* What to produce and use dvars */

// Fuels (JF jet fuel/FO fuel oil)
dvar float+ Fpf[Fuel];
// Petrols (PMF premium motor fuel/RMF regular motor fuel)
dvar float+ Fpp[Petrol];
// LBO lube-oil
dvar float+ Fpl[l in Lube] in LoLube[l]..UpLube[l];
// Crude oil to use
dvar float+ Cr[c in Crude] in 0..LimCrude[c];
// Naphthas from distillation
dvar float+ Nap[Naptha];
// Naphthas for reforming
dvar float+ Napref[Naptha];
// Naphthas for blending
dvar float+ Napb[Naptha][Petrol];
// Reforming products for blending petrol
dvar float+ Refb[ReformProd][Petrol];
// Reform products
dvar float+ Ref[ReformProd];
// Oils from distillation
dvar float+ OilVar[Oil];
// Distilled oils for cracking
dvar float+ Oilcrk[Oil];
// Distilled oils for blending
dvar float+ Oilb[Oil][Fuel];
// Cracked products
dvar float+ Crk[CrackProd];
// Cracked gasoline for blending petrol
dvar float+ Crkg[Petrol];
// Cracked oild for blending
dvar float+ Crko[Fuel];
// Residuum from distillation
dvar float+ ResidVar[Resid];
// Residuum used for lube-oil
dvar float+ Residl[Resid];
// Residuum used for blending
dvar float+ Residbf[Resid][Fuel];

// Objective
dexpr float TotalProfitPetrol = sum(p in Petrol) ProfitPetrol[p]*Fpp[p];
dexpr float TotalProfitFuel = sum(f in Fuel) ProfitFuel[f]*Fpf[f];
dexpr float TotalProfitLube = sum(l in Lube) ProfitLube[l]*Fpl[l];

maximize TotalProfitPetrol + TotalProfitFuel + TotalProfitLube;

/* this is equivalent to

maximize sum(p in Petrol) ProfitPetrol[p]*Fpp[p] +
         sum(f in Fuel) ProfitFuel[f]*Fpf[f] +
         sum(l in Lube) ProfitLube[l]*Fpl[l];
*/


subject to {
  // Distillation capacity
  // Cr["CRA"] + Cr["CRB"] <= LimDistill;
  sum(c in Crude) Cr[c] <= LimDistill;

  // Reforming capacity
  // Napref["LN"] + Napref["MN"] + Napref["HN"] <= LimReform;
  sum(n in Naptha) Napref[n] <= LimReform;
  
  // Cracking capacity
  sum(o in Oil) Oilcrk[o] <= LimCrack;

  // Distillation products
  forall(n in Naptha)
    sum(c in Crude) Cr[c]*DistillNaptha[c][n] == Nap[n];
  forall(o in Oil)
    sum(c in Crude) Cr[c]*DistillOil[c][o] == OilVar[o];
  forall(r in Resid)
    sum(c in Crude) Cr[c]*DistillResid[c][r]== ResidVar[r];
 

  // Reformer products
forall(r in ReformProd)
  sum(n in Naptha) Napref[n]*ReformProcess[n][r]== Ref[r];
   
   
  // Cracking products
forall(c in CrackProd)
  sum(o in Oil) Oilcrk[o]*CrackProcess[o][c]== Crk[c];


  // Balance constraints on Napthas
forall(n in Naptha)
    Napref[n]+ sum(p in Petrol)Napb[n][p]==Nap[n];

  // Balance constraints on Oils
forall(o in Oil)
  Oilcrk[o] + sum(f in Fuel)Oilb[o][f]== OilVar[o];

  // Balance constraints on Residuums
forall(r in Resid) 
   Residl[r] + sum(f in Fuel)Residbf[r][f]== ResidVar[r];


  // Balance constraint on Reformed products
forall(r in ReformProd)
   sum(p in Petrol)Refb[r][p] == Ref[r];
   // Balance constraint on crack products
   sum(p in Petrol)Crkg[p]==Crk["CG"];
   sum(f in Fuel)Crko[f]== Crk["CO"];

  // Balance constraints on Petrols
 forall(p in Petrol)
sum(n in Naptha)Napb[n][p]+  sum(r in ReformProd)Refb[r][p]+ Crkg[p] == Fpp[p];

  // Balance constraint on Fuels
   forall(f in Fuel)
sum(o in Oil)Oilb[o][f]+sum(r in Resid)Residbf[r][f]+Crko[f]== Fpf[f];

//Balance constraints for lube
forall(l in Lube)
  sum (r in Resid) Residl[r]*ResidProcess[r][l]== Fpl[l];
   
  // Fixed proportions required for Fuel Oil
  forall(o in Oil)
Oilb[o]["FO"]==ReqOilFO[o]*Fpf["FO"];
 Crko["FO"] == ReqCrkFO*Fpf["FO"];
 forall(r in Resid)
 Residbf[r]["FO"]==ReqResidFO[r]*Fpf["FO"];
 
  // Required ratio between petrols
  Fpp["PMF"]>=ReqRatioPetrol*Fpp["RMF"];
   
  // Qualities  Octane
forall(p in Petrol)
sum(n in Naptha) OctaneNaptha[n]*Napb[n][p]+
sum(r in ReformProd) OctaneReform[r]*Refb[r][p]+
OctaneCG*Crkg[p]>= ReqOctane[p]*Fpp[p];


  // Vapor Pressure constraint on Jet Fuel
sum(o in Oil) VaporOil[o]*Oilb[o]["JF"] + 
sum(r in Resid) VaporResid[r]*Residbf[r]["JF"] + 
VaporCrkOil*Crko["JF"] <= LimVaporJF*Fpf["JF"];

      
}
 