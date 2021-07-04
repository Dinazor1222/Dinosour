/**
 * Adding this component to an Atom will have it automatically render an overlay.
 * The overlay can be specified in new as the first and only parameter; it defaults to "rust" if not included.
 */
/datum/component/rust
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Internal variable to store the rust overlay we are using to avoid regenerating it every overlay update call
	var/mutable_appearance/rust_overlay

/turf/closed/wall/rust/New()
	var/atom/wall_new = new /turf/closed/wall(src)
	wall_new._AddComponent(list(/datum/component/rust))

/turf/closed/wall/r_wall/rust/New()
	var/atom/wall_new = new /turf/closed/wall/r_wall(src)
	wall_new._AddComponent(list(/datum/component/rust))

/turf/open/floor/plating/rust/New()
	var/atom/wall_new = new /turf/open/floor/plating(src)
	wall_new._AddComponent(list(/datum/component/rust))

/datum/component/rust/Initialize(rust_iconstate = "rust")
	. = ..()
	if(!isatom(parent))
		stack_trace("Attempted to intialize a Rust Component for non-Atom [parent]")
		return COMPONENT_INCOMPATIBLE
	var/atom/parent_atom = parent
	if(!(rust_iconstate in icon_states(parent_atom.icon)))
		stack_trace("Attempted to intialize a Rust Component for [parent] with invalid rust iconstate '[rust_iconstate]'")
		return COMPONENT_INCOMPATIBLE

	rust_overlay = mutable_appearance(parent_atom.icon, rust_iconstate)

/datum/component/rust/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, .proc/apply_rust_overlay)
	RegisterSignal(parent, list(COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_WELDER), COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_RUSTSCRAPER)), .proc/secondary_tool_act)
	RegisterSignal(parent, COMSIG_PARENT_PREQDELETED, .proc/parent_del)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/handle_examine)

/datum/component/rust/UnregisterFromParent()
	UnregisterSignal(parent,\
		list(COMSIG_ATOM_UPDATE_OVERLAYS, COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_WELDER), COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_RUSTSCRAPER)), COMSIG_PARENT_PREQDELETED)

/datum/component/rust/proc/handle_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	examine_text += span_notice("The [source] is very rusty; you could probably <i>burn</i> or <i>scrape</i> it off.")

/datum/component/rust/proc/apply_rust_overlay(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER
	overlays |= rust_overlay

/datum/component/rust/proc/parent_del()
	SIGNAL_HANDLER
	qdel(src)

/datum/component/rust/Destroy()
	if(parent)
		var/atom/parent_atom = parent
		UnregisterFromParent()
		parent_atom.update_icon(UPDATE_OVERLAYS)
		rust_overlay = null
	return ..()

/// We call this from secondary_tool_act because we sleep with do_after
/datum/component/rust/proc/handle_tool_use(atom/source, mob/user, obj/item/item)
	switch(item.tool_behaviour)
		if(TOOL_WELDER)
			if(item.use(5))
				user.balloon_alert(user, "You start burning off the rust on [parent]...")
				if(!do_after(user, 5 SECONDS * item.toolspeed, parent))
					return
				to_chat(user, span_notice("You burn off the rust of [parent]."))
				qdel(src)
				return
		if(TOOL_RUSTSCRAPER)
			user.balloon_alert(user, "You start scraping off the rust on [parent]...")
			if(!do_after(user, 2 SECONDS * item.toolspeed, parent))
				return
			to_chat(user, span_notice("You scrape the rust off of [parent]."))
			qdel(src)
			return

/// Because do_after sleeps we register the signal here and defer via an async call
/datum/component/rust/proc/secondary_tool_act(atom/source, mob/user, obj/item/item)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/handle_tool_use, source, user, item)
	return COMPONENT_BLOCK_TOOL_ATTACK
