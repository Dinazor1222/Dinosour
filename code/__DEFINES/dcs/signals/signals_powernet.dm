// powernet related signals

/// Machine hardwired to powernet: (machine, new_powernet)
#define COMSIG_POWERNET_CABLE_ATTACHED "powernet_cable_attached"
/// Machine removed hardwiring from powernet: (machine, old_powernet)
#define COMSIG_POWERNET_CABLE_DETACHED "powernet_cable_detached"
/// Is there anything that can take a refund from speculatively provided power?
/// Typically SMES units with high power output. Looks at and adjusts netexcess on the attached powernet.
///from /datum/powernet/proc/reset: (powernet)
#define COMSIG_POWERNET_DO_REFUND "powernet_do_refund"
