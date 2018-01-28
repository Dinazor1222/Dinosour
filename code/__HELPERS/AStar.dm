/*
A Star pathfinding algorithm
Returns a list of tiles forming a path from A to B, taking dense objects as well as walls, and the orientation of
windows along the route into account.
Use:
your_list = AStar(start location, end location, moving atom, distance proc, max nodes, maximum node depth, minimum distance to target, adjacent proc, atom id, turfs to exclude, check only simulated)

Optional extras to add on (in order):
Distance proc : the distance used in every A* calculation (length of path and heuristic)
MaxNodes: The maximum number of nodes the returned path can be (0 = infinite)
Maxnodedepth: The maximum number of nodes to search (default: 30, 0 = infinite)
Mintargetdist: Minimum distance to the target before path returns, could be used to get
near a target, but not right to it - for an AI mob with a gun, for example.
Adjacent proc : returns the turfs to consider around the actually processed node
Simulated only : whether to consider unsimulated turfs or not (used by some Adjacent proc)

Also added 'exclude' turf to avoid travelling over; defaults to null

Actual Adjacent procs :

	/turf/proc/reachableAdjacentTurfs : returns reachable turfs in cardinal directions (uses simulated_only)

	/turf/proc/reachableAdjacentAtmosTurfs : returns turfs in cardinal directions reachable via atmos

*/

//////////////////////
//datum/PathNode object
//////////////////////

//A* nodes variables
/datum/PathNode
	var/turf/source //turf associated with the PathNode
	var/datum/PathNode/prevNode //link to the parent PathNode
	var/f		//A* Node weight (f = g + h)
	var/g		//A* movement cost variable
	var/h		//A* heuristic variable
	var/nt		//count the number of Nodes traversed
	var/bf		//bitflag for dir to expand.Some sufficiently advanced motherfuckery
	var/i		//id in turflist

/datum/PathNode/New(s,p,pg,ph,pnt,_bf,_i)
	source = s
	prevNode = p
	g = pg
	h = ph
	f = g + h*(1+SSpathfinder.tiew)
	nt = pnt
	bf = _bf
	i = _i

/datum/PathNode/proc/setp(p,pg,ph,pnt)
	prevNode = p
	g = pg
	h = ph
	f = g + h*(1+SSpathfinder.tiew)
	nt = pnt

/datum/PathNode/proc/calc_f()
	f = g + h

//////////////////////
//A* procs
//////////////////////

//the weighting function, used in the A* algorithm
/proc/PathWeightCompare(datum/PathNode/a, datum/PathNode/b)
	return a.f - b.f

//reversed so that the Heap is a MinHeap rather than a MaxHeap
/proc/HeapPathWeightCompare(datum/PathNode/a, datum/PathNode/b)
	return b.f - a.f

//wrapper that returns an empty list if A* failed to find a path
/proc/get_path_to(caller, end, dist, maxnodes, maxnodedepth = 30, mintargetdist, adjacent = /turf/proc/reachableTurftest, id=null, turf/exclude=null, simulated_only = 1)
	var/l = SSpathfinder.getfree()
	while(!l)
		stoplag(3)
		l = SSpathfinder.getfree()
	var/list/path = AStar(caller, end, dist, maxnodes, maxnodedepth, mintargetdist, adjacent,id, exclude, simulated_only)
	var/list/path1 = AStarold(caller, end, dist, maxnodes, maxnodedepth, mintargetdist, adjacent = /turf/proc/reachableAdjacentTurfs,id, exclude, simulated_only)
	SSpathfinder.found(l)
	if(!path)
		path = list()
	return path

//the actual algorithm
/proc/AStar(caller, var/turf/end, dist, maxnodes, maxnodedepth = 30, mintargetdist, adjacent = /turf/proc/reachableAdjacentTurfs, id=null, turf/exclude=null, simulated_only = 1)
	//sanitation
	var/turf/start = get_turf(caller)
	if((!start)||(start.z != end.z)||(start == end)) //no PF between z levels
		return 0
	if(maxnodes)
		//if start turf is farther than maxnodes from end turf, no need to do anything
		if(call(start, dist)(end) > maxnodes)
			return 0
		maxnodedepth = maxnodes //no need to consider path longer than maxnodes
	var/datum/Heap/open = new /datum/Heap(/proc/HeapPathWeightCompare) //the open list
	var/list/openc = new() //open list for node check
	var/list/path = null //the returned path, if any
	//initialization
	var/datum/PathNode/cur = new /datum/PathNode(start,null,0,call(start,dist)(end),0,15,1)//current processed turf
	var/datum/PathNode/CN
	var/datum/PathNode/last = cur
	var/f
	var/r
	var/turf/T
	var/ne
	open.Insert(cur)
	openc[start] = cur
	//then run the main loop
	while(!open.IsEmpty() && !path)
		//get the lower f node on the open list
		if(ne)
			last = openc[openc[openc.len]]//list search by key is still costly.Let's avoid it whenever it possible.So if no new open nodes, so be it.
		cur = open.Pop() //get the lower f turf in the open list
		if(openc.len>1)
			last.i = cur.i
			openc.Swap(cur.i,openc.len)
		openc.len -= 1//we need to serch only in open list.So let's keep turf list tidy
		ne = TRUE
		//if we only want to get near the target, check if we're close enough
		var/closeenough
		if(mintargetdist)
			closeenough = call(cur.source,dist)(end) <= mintargetdist
		//if too many steps, abandon that path
		if(maxnodedepth && (cur.nt > maxnodedepth))
			continue
		//found the target turf (or close enough), let's create the path to it
		if(cur.source == end || closeenough)
			path = new()
			path.Add(cur.source)
			while(cur.prevNode)
				cur = cur.prevNode
				path.Add(cur.source)
			break
		//get adjacents turfs using the adjacent proc, checking for access with id
		for(var/i = 0 to 3)
			f= 1<<i
			if(cur.bf & f)
				T = get_step(cur.source,f)
				if(T != exclude)
					CN = openc[T]  //current checking turf
					var/newg = cur.g + call(cur.source,dist)(T)
					r=15^((f & 85)<<1)|((f & 170)>>1) //fuck list calls. bit operations faster
					if(CN)
					//is already in open list, check if it's a better way from the current turf
						CN.bf &= r //we have no closed, so just cut off exceed dir
						if(newg < CN.g)
							if(call(cur.source,adjacent)(caller, T, id, simulated_only))
								CN.setp(cur,newg,CN.h,cur.nt+1)
								open.ReSort(CN)//reorder the changed element in the list
					else
					//is not already in open list, so add it
						if(call(cur.source,adjacent)(caller, T, id, simulated_only))
							CN = new(T,cur,newg,call(T,dist)(end),cur.nt+1,r,openc.len+1)
							open.Insert(CN)
							openc[T] = CN
							last = CN
							ne = FALSE
		cur.bf = 0
		CN = null
		CHECK_TICK
	//QDEL_LIST(checked)
	//checked = null
	//cleaning after us
	//reverse the path to get it from start to finish
	if(path)
		for(var/i = 1 to round(0.5*path.len))
			path.Swap(i,path.len-i+1)
	return path

//Returns adjacent turfs in cardinal directions that are reachable
//simulated_only controls whether only simulated turfs are considered or not

/turf/proc/reachableAdjacentTurfs(caller, ID, simulated_only)
	var/list/L = new()
	var/turf/T
	var/static/space_type_cache = typecacheof(/turf/open/space)

	for(var/k in 1 to GLOB.cardinals.len)
		T = get_step(src,GLOB.cardinals[k])
		if(!T || (simulated_only && space_type_cache[T.type]))
			continue
		if(!T.density && !LinkBlockedWithAccess(T,caller, ID))
			L.Add(T)
	return L
/*

/turf/proc/reachableAdjacentTurfs(caller, ID, simulated_only)
	var/list/L = new()
	var/turf/T

	for(var/k in 1 to GLOB.cardinals.len)
		T = get_step(src,GLOB.cardinals[k])
		if(reachableTurftest(caller, T, ID, simulated_only))
			L.Add(T)
	return L
*/
/turf/proc/reachableTurftest(caller, var/turf/T, ID, simulated_only)
	if(T && !T.density && !(simulated_only && SSpathfinder.space_type_cache[T.type]) && !LinkBlockedWithAccess(T,caller, ID))
		return TRUE

//Returns adjacent turfs in cardinal directions that are reachable via atmos
/turf/proc/reachableAdjacentAtmosTurfs()
	return atmos_adjacent_turfs

/turf/proc/LinkBlockedWithAccess(turf/T, caller, ID)
	var/adir = get_dir(src, T)
	var/rdir = get_dir(T, src)

	for(var/obj/structure/window/W in src)
		if(!W.CanAStarPass(ID, adir))
			return 1
	for(var/obj/machinery/door/window/W in src)
		if(!W.CanAStarPass(ID, adir))
			return 1
	for(var/obj/O in T)
		if(!O.CanAStarPass(ID, rdir, caller))
			return 1

	return 0

/proc/AStarold(caller, end, dist, maxnodes, maxnodedepth = 30, mintargetdist, adjacent = /turf/proc/reachableAdjacentTurfs, id=null, turf/exclude=null, simulated_only = 1)
	var/list/pnodelist = list()
	//sanitation
	var/start = get_turf(caller)
	if(!start)
		return 0
	if(maxnodes)
		//if start turf is farther than maxnodes from end turf, no need to do anything
		if(call(start, dist)(end) > maxnodes)
			return 0
		maxnodedepth = maxnodes //no need to consider path longer than maxnodes
	var/datum/Heap/open = new /datum/Heap(/proc/HeapPathWeightCompare) //the open list
	var/list/closed = new() //the closed list
	var/list/path = null //the returned path, if any
	var/datum/PathNode/cur //current processed turf
	//initialization
	open.Insert(new /datum/PathNode(start,null,0,call(start,dist)(end),0))
	//then run the main loop
	while(!open.IsEmpty() && !path)
		//get the lower f node on the open list
		cur = open.Pop() //get the lower f turf in the open list
		closed.Add(cur.source) //and tell we've processed it

		//if we only want to get near the target, check if we're close enough
		var/closeenough
		if(mintargetdist)
			closeenough = call(cur.source,dist)(end) <= mintargetdist

		//if too many steps, abandon that path
		if(maxnodedepth && (cur.nt > maxnodedepth))
			continue

		//found the target turf (or close enough), let's create the path to it
		if(cur.source == end || closeenough)
			path = new()
			path.Add(cur.source)
			while(cur.prevNode)
				cur = cur.prevNode
				path.Add(cur.source)

			break
		//get adjacents turfs using the adjacent proc, checking for access with id
		var/list/L = call(cur.source,adjacent)(caller,id, simulated_only)
		for(var/turf/T in L)
			if(T == exclude || (T in closed))
				continue
			var/newg = cur.g + call(cur.source,dist)(T)
			var/datum/PathNode/P = pnodelist[T]
			if(!P)
			 //is not already in open list, so add it
				var/datum/PathNode/newnode = new /datum/PathNode(T,cur,newg,call(T,dist)(end),cur.nt+1)
				open.Insert(newnode)
				pnodelist[T] = newnode
			else //is already in open list, check if it's a better way from the current turf
				if(newg < P.g)
					P.prevNode = cur
					P.g = (newg * L.len / 9)
					P.calc_f()
					P.nt = cur.nt + 1
					open.ReSort(P)//reorder the changed element in the list
		CHECK_TICK
	//cleaning after us
	pnodelist = null
	//reverse the path to get it from start to finish
	if(path)
		for(var/i = 1; i <= path.len/2; i++)
			path.Swap(i,path.len-i+1)

	return path