/obj/effect/vaultspawner
	var/maxX = 6
	var/maxY = 6
	var/minX = 2
	var/minY = 2

/obj/effect/vaultspawner/Initialize(mapload,lX = minX,uX = maxX,lY = minY,uY = maxY, spawn_type = null)
	. = ..()
	if(!spawn_type)
		spawn_type = pick("sandstone","rock","alien")

	var/lowBoundX = loc.x
	var/lowBoundY = loc.y

	var/hiBoundX = loc.x + rand(lX,uX)
	var/hiBoundY = loc.y + rand(lY,uY)

	var/z = loc.z

	for(var/i = lowBoundX,i<=hiBoundX,i++)
		for(var/j = lowBoundY,j<=hiBoundY,j++)
			var/turf/T = locate(i,j,z)
			if(i == lowBoundX || i == hiBoundX || j == lowBoundY || j == hiBoundY)
				T.PlaceOnTop(text2path("/turf/closed/wall/vault/[spawn_type]"))
			else
				T.PlaceOnTop(text2path("/turf/open/floor/vault/[spawn_type]"))

	return INITIALIZE_HINT_QDEL
