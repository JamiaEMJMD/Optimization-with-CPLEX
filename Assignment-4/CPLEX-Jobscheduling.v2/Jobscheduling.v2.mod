

/*********************************************
 * OPL 22.1.0.0 Model
  * Author: Jamia Begum
  *    NIU: 1676891
 * Creation Date: 8 Jan 2023 at 01:02:53
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
   key string  name;
   	   int     duration;
   	   string  requirement;
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
// The activities which must precede an activity 
{ComputerActivityMatch} precedences[a in allActivities] = { b | b in allActivities : 
                                 a.computerType == b.computerType &&
                                 a.computer == b.computer && 
                                 b.activity.name in a.activity.precedences };

/********************************************************
  * Resource data consists of:
  *  - ResourceType
  *  - Number of available resorces of this type
  *******************************************************/                                 
tuple ResourceData {
	key string resourceType;
	int available;
}

// for describing each resource (machine)
tuple ResourceUnit{
	string resourceType;
	int unit;
}

/*************************************
 * Reads the defined resource units 
 * for each resource type
 *************************************/
{ResourceData} resources = ...;

{ResourceUnit} availableResources = {<r.resourceType, i> | r in resources, i in 1..r.available};

/**********************************************
 * Represent the pairs activity<->resouce unit
 **********************************************/
tuple JobAllocation {
	 ComputerActivityMatch job;
 	 int machineId;
}

/*********************************************
 * Define the domain for the different
 * choices when assigning a job to a machine
 *********************************************/
{JobAllocation} jobAllocations = {<job, unit> | 
								   job in allActivities, r in resources, unit in 1..r.available :
								    job.activity.requirement == r.resourceType};
                                 
dvar interval activity[a in allActivities] size a.activity.duration;
dvar interval jobAllocation[j in jobAllocations]optional size j.job.activity.duration ; // complete the dvar declaration accordingly
dvar sequence resource[r in availableResources] in all(j in jobAllocations:
 j.job.activity.requirement == r.resourceType && j.machineId == r.unit)jobAllocation[j]; // complete the dvar declaration accordingly
   

// Constraints labels
constraint Precedence[allActivities,allActivities];

execute {
		cp.param.FailLimit = 100000;
}

dexpr int makespan = max(a in allActivities) endOf(activity[a]); 
//the completion time of the last job
// Complete makespan expression;

minimize makespan;
subject to {
  // Remove symmetry
  //avoiding symmetric solutions
       forall(a1,a2 in allActivities:(a1.activity == a2.activity && 
	a1.computerType == a2.computerType && a1.computer < a2.computer) )
	
     endBeforeStart(activity[a1], activity[a2]);//end(a1)+z <= start(a2)
     
  // Each activity is performed only once  
  forall(a in allActivities)
      //using Alternative constraint for allocating job to activity
      //then one activity is performed exactly once
  alternative(activity[a], all(j in jobAllocations:j.job.activity == a.activity &&
 j.job.computerType ==  a.computerType &&
              j.job.computer == a.computer) jobAllocation[j]);
  
                                 
  // Resource Requirements
  forall(r in availableResources)
    //no overlapping in the use of each resource
	  noOverlap(resource[r]); 
    
  // Precedences
   forall( a in allActivities)
    forall( b in precedences[a])
      //b is the precedence of a, after b finishes a starts
      Precedence[a,b]: endBeforeStart(activity[b], activity[a]);
  
};

 