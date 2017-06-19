

//Curse you calenders...
/proc/IsLeapYear(y)
	return ((y) % 4 == 0 && ((y) % 100 != 0 || (y) % 400 == 0))


////////////////////////
// CHRISTIAN HOLIDAYS //
////////////////////////

//Y, eg: 2017, 2018, 2019, in num form (not string)
//etc. Between 1583 and 4099
//Adapted from a free algorithm written in BASIC (https://www.assa.org.au/edm#Computer)
/proc/EasterDate(y)
	var/FirstDig, Remain19, temp	//Intermediate Results
	var/tA, tB, tC, tD, tE			//Table A-E results
	var/d, m						//Day and Month returned

	FirstDig = Floor((y / 100))
	Remain19 = y % 19

	temp = (Floor((FirstDig - 15) / 2)) + 202 - 11 * Remain19

	switch(FirstDig)
		if(21,24,25,27,28,29,30,31,32,34,35,38)
			temp -= 1
		if(33,36,37,39,40)
			temp -= 2
	temp %= 30

	tA = temp + 21
	if(temp == 29)
		tA -= 1
	if(temp == 28 && (Remain19 > 10))
		tA -= 1
	tB = (tA - 19) % 7

	tC = (40 - FirstDig) % 4
	if(tC == 3)
		tC += 1
	if(tC > 1)
		tC += 1
	temp = y % 100
	tD = (temp + Floor((temp / 4))) % 7

	tE = ((20 - tB - tC - tD) % 7) + 1
	d = tA + tE
	if(d > 31)
		d -= 31
		m = 4
	else
		m = 3
	return list("day" = d, "month" = m)


/proc/MotheringSundayDate(y)
	var/list/easterResults = EasterDate(y) //But first, when's easter?
	var/day = easterResults["day"]
	var/month = easterResults["month"]

	var/timeMachine = 21 //21 days (3 weeks) in the paaaaast~

	if(month == APRIL)
		if(timeMachine >= day) //>= as the 0th of April is just the 31st of March
			var/toRemove = timeMachine - day
			day = 31
			month--
			day -= toRemove
		else
			day -= timeMachine
	else //Earliest Mothering Sunday is the 22nd of march, which becomes the 1st of March, no fudge needed!
		day -= timeMachine

	return list("day" = day, "month" = month)


/proc/AshWednesdayDate(y)
	var/list/easterResults = EasterDate(y) //But first, when's easter?
	var/day = easterResults["day"]
	var/month = easterResults["month"]

	var/timeMachine = 46 //46 days (6 weeks + 4 days) in the paaaaast~
	var/leap = IsLeapYear(y) //TAIMA RIIPU

	if(month == 4)
		var/toRemove = timeMachine - day
		day = 31
		month--
		if(toRemove >= 31)
			toRemove -= day
			day = leap ? 29 : 28
			month--
			day -= toRemove
		else
			day -= toRemove
	else
		var/toRemove = timeMachine - day
		day = leap ? 29 : 28
		month--
		day -= toRemove

	return list("day" = day, "month" = month)


/proc/ShroveTuesdayDate(y)
	var/list/easterResults = AshWednesdayDate(y) //But first, when's ash wednesday?
	var/day = easterResults["day"]
	var/month = easterResults["month"]
	var/leap = IsLeapYear(y)

	if(1 == day)
		if(month == 4)
			day = 31
			month--
		else
			day = leap ? 29 : 28
			month--
	else
		day -= 1

	return list("day" = day, "month" = month)


/proc/GoodFridayDate(y)
	var/list/easterResults = EasterDate(y) //But first, when's easter?
	var/day = easterResults["day"]
	var/month = easterResults["month"]
	var/leap = IsLeapYear(y)

	if(2 >= day)
		if(month == 4)
			var/toRemove = 2 - day
			day = 31 - toRemove
			month--
		else
			var/toRemove = 2 - day
			day = leap ? 29 : 28
			day -= toRemove
			month--
	else
		day -= 2

	return list("day" = day, "month" = month)

////////////////////////////
// END CHRISTIAN HOLIDAYS //
////////////////////////////