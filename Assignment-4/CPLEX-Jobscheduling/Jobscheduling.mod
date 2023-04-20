/*********************************************
 * OPL 22.1.0.0 Model
 * Author: Jamia Begum
  *    NIU: 1676891
 * Creation Date: 7 Jan 2023 at 21:32:36
 *********************************************/

 using CP;

{string} ComputerTypes = ...;
{string} ActivityTypes = ...;
{string} ResourceTypes = ...;

// Production work orders
int requiredQuantities[ComputerTypes] = ...;


/*************************************************
 * An activity consists of 
 *   - an activity type, 
 *   - a duration, 
 *   - a unary resource requirement, and 
 *   - a list of precedences.
 *************************************************/
tuple ActivityData {
   key string  activity;
   	   int     duration;
   	   string  requirement; //assigned resoruce
      {string} precedences;
};




{ActivityData} activities[ComputerTypes] = ...;

/********************************************************
 * Each particular activity for each computer consist of:
 *   - a defined activity 
 *   - for a computer type
 *   - for each computer to be manufatured
 ********************************************************/
tuple ComputerActivityMatch {
   ActivityData activity;
   string       computerType;
   int          computer;            
};
// All activities that must get scheduled
{ComputerActivityMatch} allActivities = {<a,c,j> | c in ComputerTypes,
					 a in activities[c],
					 j in 1..requiredQuantities[c]};
// The activities which must precede activity a
{ComputerActivityMatch} precedences[a in allActivities] = { b | b in allActivities : 
                                 a.computerType == b.computerType &&
                                 a.computer == b.computer && 
                                 b.activity.activity in a.activity.precedences };
//decision variables                                 
dvar interval activity[a in allActivities] size a.activity.duration;

dvar sequence resource[r in ResourceTypes] in 
   all(a in allActivities: a.activity.requirement==r) activity[a];

// Constraints labels
constraint Precedence[allActivities,allActivities];

execute {
		cp.param.FailLimit = 1000;
}

dexpr int makespan =max(a in allActivities) endOf(activity[a]); 
//the completion time of the last job


minimize makespan;
subject to {
  // Remove symmetries 
forall(a1,a2 in allActivities:(a1.activity == a2.activity && 
	a1.computerType == a2.computerType && a1.computer < a2.computer) )
	
     endBeforeStart(activity[a1], activity[a2]);//end(a1)+z <= start(a2)
     
  // Resource Requirements
  forall(r in ResourceTypes)
    //no overlapping in the use of each resource
	  noOverlap(resource[r]); 
	   
	   
  // Precedences
  //b is the precedence of a, after b finishes a starts
  forall( a in allActivities)
    forall( b in precedences[a])
      Precedence[a,b]: endBeforeStart(activity[b], activity[a]);

};

 

