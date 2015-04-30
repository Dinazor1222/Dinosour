var/list/potentialRandomZlevels = list()
var/away_loaded = 0

/proc/createRandomZlevel()
	if(away_loaded)
		return

	world << "<span class='boldannounce'>Searching for away missions...</span>"
	var/list/Lines = file2list("_maps/RandomZLevels/fileList.txt")
	if(!Lines.len)	return
	for (var/t in Lines)
		if (!t)
			continue

		t = trim(t)
		if (length(t) == 0)
			continue
		else if (copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
	//	var/value = null

		if (pos)
			name = lowertext(copytext(t, 1, pos))
		//	value = copytext(t, pos + 1)
		else
			name = lowertext(t)

		if (!name)
			continue

		potentialRandomZlevels.Add(t)


	if(potentialRandomZlevels.len)
		if(!config.roundstart_awaymissions)
			return

		var/map = pick(potentialRandomZlevels)
		loadAwayMission(map)

	else
		world << "<span class='boldannounce'>No away missions found.</span>"

/proc/loadAwayMission(map, silent = 0)
	if(!silent)
		world << "<span class='boldannounce'>Loading away mission...</span>"

	var/file = file(map)
	if(isfile(file))
		maploader.load_map(file)
		world.log << "away mission loaded: [map]"
		away_loaded = 1

	for(var/obj/effect/landmark/L in landmarks_list)
		if (L.name != "awaystart")
			continue
		awaydestinations.Add(L)

	if(!silent)
		world << "<span class='boldannounce'>Away mission loaded.</span>"
