:- dynamic node/3.
:- dynamic closed/1.
:- dynamic state/4.
:-consult(counter).
:-consult(eightPuzzle).
:-consult(queues).
		
breadthFirstSearch(InitialState, Solution, Statistics):-	
	retractall(closed(_)),
	initialiseCounter(_, generated), 
	initialiseCounter(_, duplicated), 	
	initialiseCounter(_, expanded), 
    make_queue(QueueOpenlist),
	join_queue(node(InitialState,[],0), QueueOpenlist, NewQueueOpenlist),
	expandNodes(NewQueueOpenlist,node(GoalState,GoalParent,GoalGvalue)),
	solutionAndStat(node(GoalState,GoalParent,GoalGvalue),Solution,Statistics).

solutionAndStat([],[],[]).	
solutionAndStat(node(State,PNode,Gvalue),Solution,Statistics):-
    solutionAndStat(PNode,Psolution,PStatistics),
	append(Psolution,[State],Solution),
	getValueCounter(Gvalue, generated,  CountG),
	getValueCounter(Gvalue, duplicated, CountD),
	getValueCounter(Gvalue, expanded, CountE),
	assert(state(Gvalue,CountG,CountD,CountE)),
	append(PStatistics,[state(Gvalue,CountG,CountD,CountE)],Statistics).

expandNodes(QOpenList,GoalNode):-
    /* get the first node from openlist */
    serve_queue(QOpenList, node(State,Parent,Gvalue), QOpenListRest),	
	assert(closed(State)),	
	incrementCounter(Gvalue, expanded),
	/* goal test*/
	(not(goal8(State))->
     (/* not goal, expand to generate new nodes*/
	  succ8(State, Successors),		
      addToOpen(Successors,node(State,Parent,Gvalue),Gvalue,QOpenListRest,QOpenListAdded),
      expandNodes(QOpenListAdded,GoalNode));
	 (/*find goal, return GoalNode*/
	  (GoalNode = node(State,Parent,Gvalue)))
	).	
	
addToOpen([],_,_,QOpenlist,QOpenlist).	
addToOpen([(Cost,HeadState)|Tail],ParentNode,Gvalue,QOpenlist,QNewOpenList):-
        NewGvalue is Gvalue+Cost,
		incrementCounter(NewGvalue, generated),
        (not(closed(HeadState))->
	     ( assert(node(HeadState,ParentNode,NewGvalue)),
	       join_queue(node(HeadState,ParentNode,NewGvalue),QOpenlist,QNewOpenList_temp),
		   addToOpen(Tail,ParentNode,Gvalue,QNewOpenList_temp,QNewOpenList));			 
	     ( incrementCounter(NewGvalue, duplicated),
		   addToOpen(Tail,ParentNode,Gvalue,QOpenlist,QNewOpenList))).
	   	