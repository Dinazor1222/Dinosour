//max channel is 1024. Only go lower from here, because byond tends to pick the first availiable channel to play sounds on
#define CHANNEL_LOBBYMUSIC 1024
#define CHANNEL_ADMIN 1023
#define CHANNEL_VOX 1022
#define CHANNEL_JUKEBOX 1021
#define CHANNEL_JUSTICAR_ARK 1020
#define CHANNEL_HEARTBEAT 1019 //sound channel for heartbeats
#define CHANNEL_AMBIENCE 1018
#define CHANNEL_BUZZ 1017
#define CHANNEL_BICYCLE 1016

//THIS SHOULD ALWAYS BE THE LOWEST ONE!
//KEEP IT UPDATED

#define CHANNEL_HIGHEST_AVAILABLE 1015


#define SOUND_MINIMUM_PRESSURE 10
#define FALLOFF_SOUNDS 0.5


//Ambience types

#define GENERIC 1
#define HOLY 2
#define HIGH-SEC 3
#define RUINS 4
#define ENGINEERING 5
#define MINING 6
#define MEDICAL 7
#define SPOOKY 8
#define SPACE 9
#define MAINTENACE 10
#define AWAY_MISSION 11
