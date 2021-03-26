// Implementations
/// Declares that a typepath implements some interfaces.
#define IMPLEMENTS_INTERFACE(typepath, interfaces...) \
/datum/controller/subsystem/interfaces/aggregate_implementations() { \
	. = ..(); \
	for(var/interface in list(##interfaces)) { \
		.[interface][##typepath] = TRUE; \
	} \
}

/// The name of the var used to store a list of the procs on an interface. Very long so it doesn't collide with user-defined variables.
#define INTERFACE_PROC_CACHE_NAME ____procs_that_this_interface_declares_in_a_long_complicated_var_name_so_it_wont_collide_with_user_defined_vars_____________________wheeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeaeaeeasdaedasdadfsfsdfadadadfashdfkjdsahfskjdfhakshfdsdasdasdasdasgdasdejfslfhlskjfhwilfsakjdfskefsdfkjsskjdfkahdkjhkfhaedasfesdawdadsdawdasdawdasdawdasdasdawdawdadLorem_ipsum_dolor_sit_amet_consectetur_adipiscing_elit_Vestibulum_ultrices_tobeornottobethatisthequestionwhethertisnoblerinthemindtosuffertheslingsandarrowsofoutrageousfortuneortotakearmsagainstaseaoftroublesandbyopposingendthemtodietosleepnomoreandbyasleeptosayweendtheheartacheandthethousandnaturalshocksthatfleshisheirtotisaconsummationdevoutlytobewishdtodietosleeptosleepperchancetodreamaytherestherubforinthatsleepofdeathwhatdreamsmaycomewhenwehaveshuffledoffthismortalcoilmustgiveuspausetherestherespectthatmakescalamityofsolonglifeforwhowouldbearthewhipsandscornsoftimethoppressorswrongtheproudmanscontumelythepangsofdisprizdlovethelawswowyouareactuallyreadingthisgoodforyoudelaytheinsolenceofofficeandthespurnsthatpatientmeritofthunworthytakeswhenhehimselfmighthisquietusmakewithabarebodkinwhowouldfardelsbeartogruntandsweatunderawearylifebutthatthedreadofsomethingafterdeaththeundiscoveredcountryfromwhosebournnotravellerreturnspuzzlesthewillandmakesusratherbearthoseillswehavethanflytoothersthatweknownotofthusconsciencedothmakecowardsofusallandthusthenativehueofresolutionissickliedoerwiththepalecastofthoughtandenterprisesofgreatpithandmomentwiththisregardtheircurrentsturnawryandlosethenameofaction________________________________________________________________________________________________________________________________________________________________________
/// The above, but as a string so it can be checked against var names.
#define INTERFACE_PROC_CACHE_NAME_STRING #INTERFACE_PROC_CACHE_NAME
/// Defines a proc for an interface.
#define DEF_INTERFACE_PROC(interface, procname, arguments) \
##interface/proc/##procname(##arguments) \
##interface/____aggregate_procs() { \
	. = ..(); \
	.[##procname] = TRUE; \
}
