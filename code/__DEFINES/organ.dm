//Defines for organs.
//Subject to change. I do not know yet which defines I will need until Organs are fully finished. |- Ricotez
//Organ status
//0 = Organ is fine.
#define ORGAN_REMOVED	1	//Organ has safely been removed.
#define ORGAN_SPLINTED	2	//Organ has splinted. Not used right now. This would probably be using a crutch for legs or splinting for any limb
#define ORGAN_BROKEN	4	//Organ broke. Not used right now. If I were to implement this, it'd probably be something like a flat rate at enough brute damage
#define ORGAN_DESTROYED	8	//Organ was forcefully removed and the wound is open.
#define ORGAN_NOBLEED	16	//Organ was forcefully removed, but the wound is not bleeding right now.
//0 = Organ is a default organ.
#define ORGAN_ORGANIC	0 //Or you could just use 0.
#define ORGAN_ROBOTIC	1
#define ORGAN_ALIEN	2 //For future purposes.

#define MAX_BRAIN_IMPLANT	2
#define MAX_CHEST_IMPLANT	3

#define CAUTERIZED_DENOMINATOR 2	//The number which damage for NOBLEED organs is divided by (compared to DESTROYED), otherwise eswords are 2OP