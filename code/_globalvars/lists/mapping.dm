#define Z_NORTH 1
#define Z_EAST 2
#define Z_SOUTH 3
#define Z_WEST 4

var/list/cardinal = list( NORTH, SOUTH, EAST, WEST )
var/list/alldirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)


//This list contains the z-level numbers which can be accessed via space travel and the percentile chances to get there.
//(Exceptions: extended, sandbox and nuke) -Errorage
//Was list("3" = 30, "4" = 70).
//Spacing should be a reliable method of getting rid of a body -- Urist.
//Go away Urist, I'm restoring this to the longer list. ~Errorage
var/list/accessible_z_levels = list(1,3,4,5) //levels accessible through map edge transitions and falling off a shuttle in transit

var/list/landmarks_list = list()				//list of all landmarks created
var/list/start_landmarks_list = list()			//list of all spawn points created

var/list/monkeystart = list()
var/list/wizardstart = list()
var/list/newplayer_start = list()
var/list/latejoin = list()
var/list/prisonwarp = list()	//prisoners go to these
var/list/holdingfacility = list()	//captured people go here
var/list/xeno_spawn = list()//Aliens spawn at these.
var/list/tdome1 = list()
var/list/tdome2 = list()
var/list/tdomeobserve = list()
var/list/tdomeadmin = list()
var/list/prisonsecuritywarp = list()	//prison security goes to these
var/list/prisonwarped = list()	//list of players already warped
var/list/blobstart = list()
var/list/secequipment = list()
var/list/deathsquadspawn = list()
var/list/emergencyresponseteamspawn = list()

	//away missions
var/list/awaydestinations = list()	//a list of landmarks that the warpgate can take you to

	//used by jump-to-area etc. Updated by area/updateName()
var/list/sortedAreas = list()
