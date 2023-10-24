/datum/component/glitch
	/// Ref of the spawning forge
	var/datum/weakref/forge_ref

/datum/component/glitch/Initialize(obj/machinery/quantum_server/server, obj/machinery/byteforge/forge)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	forge_ref = WEAKREF(forge)
	forge.setup_particles(angry = TRUE)

	var/mob/living/owner = parent
	server.spawned_threat_refs.Remove(WEAKREF(owner))

	owner.faction.Cut()
	owner.faction += list(ROLE_GLITCH)

	var/current_max = owner.maxHealth + ROUND_UP(server.threat * 0.2)
	owner.maxHealth = clamp(current_max, 200, 500)
	owner.fully_heal()

	owner.AddElement(/datum/element/digital_aura)

/datum/component/glitch/RegisterWithParent()
	RegisterSignals(parent, list(COMSIG_LIVING_STATUS_UNCONSCIOUS, COMSIG_LIVING_DEATH), PROC_REF(on_death))

/datum/component/glitch/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/// Sakujo
/datum/component/glitch/proc/dust_mob()
	if(QDELETED(parent))
		return

	var/mob/living/owner = parent

	owner.dust()

	var/obj/machinery/byteforge/forge = forge_ref.resolve()
	forge?.setup_particles()

/// We don't want digital entities just lingering around as corpses.
/datum/component/glitch/proc/on_death()
	SIGNAL_HANDLER

	if(QDELETED(parent))
		return

	var/mob/living/owner = parent
	to_chat(owner, span_userdanger("You feel a strange sensation..."))

	addtimer(CALLBACK(src, PROC_REF(dust_mob)), 2 SECONDS, TIMER_UNIQUE|TIMER_DELETE_ME|TIMER_STOPPABLE)
