/*
	Used with the various stat variables (mob, machines)
*/

//mob/var/stat things
#define CONSCIOUS	0
#define UNCONSCIOUS	1
#define DEAD		2

// bitflags for machine stat variable
#define BROKEN		1
#define NOPOWER		2
#define POWEROFF	4		// tbd
#define MAINT		8			// under maintaince
#define EMPED		16		// temporary broken by EMP pulse

//shuttle mode defines
#define SHUTTLE_IDLE 0
#define SHUTTLE_RECALL 1
#define SHUTTLE_CALL 2
#define SHUTTLE_DOCKED 3
#define SHUTTLE_ESCAPE 4
#define SHUTTLE_ENDGAME 5