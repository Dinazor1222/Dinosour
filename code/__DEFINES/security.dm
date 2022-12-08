#define DETSCAN_CATEGORY_FINGERS "Prints"
#define DETSCAN_CATEGORY_BLOOD "Blood"
#define DETSCAN_CATEGORY_FIBER "Fibers"
#define DETSCAN_CATEGORY_DRINK "Reagents"
#define DETSCAN_CATEGORY_ACCESS "ID Access"

// custom categories section
#define DETSCAN_CATEGORY_NOTES "Additional Notes"
#define DETSCAN_CATEGORY_ILLEGAL "Illegal Tech"
#define DETSCAN_CATEGORY_SYNDIE "Syndicate Tech"
#define DETSCAN_CATEGORY_HOLY "Holy Data"
#define DETSCAN_CATEGORY_SETTINGS "Active Settings"

/// defines the order categories are displayed, with the standard ones first, then misc, then finally the closing remarks.
#define DETSCAN_DEFAULT_ORDER list(\
	DETSCAN_CATEGORY_FINGERS, \
	DETSCAN_CATEGORY_BLOOD, \
	DETSCAN_CATEGORY_FIBER, \
	DETSCAN_CATEGORY_DRINK, \
	DETSCAN_CATEGORY_ACCESS, \
	DETSCAN_CATEGORY_SETTINGS, \
	DETSCAN_CATEGORY_HOLY, \
	DETSCAN_CATEGORY_ILLEGAL, \
	DETSCAN_CATEGORY_SYNDIE, \
	DETSCAN_CATEGORY_NOTES, \
)

/// the order departments show up in for the id scan (its sorted by red to blue on the color wheel)
#define DETSCAN_ACCESS_ORDER(...) list(\
	REGION_SECURITY, \
	REGION_ENGINEERING, \
	REGION_SUPPLY, \
	REGION_GENERAL, \
	REGION_MEDBAY, \
	REGION_COMMAND, \
	REGION_RESEARCH, \
	REGION_CENTCOM, \
)

/// if any categories list has this entry, it will be hidden
#define DETSCAN_BLOCK "DETSCAN_BLOCK"
