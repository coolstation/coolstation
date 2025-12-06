/**
 * copyright 2025 Inorien
 */

/*
	This is a sound_emitter. It is made of /sounds and var/atom/source
	These are passive data sources that hold information about which sound an atom is currently emitting.
	The sound_emitter is the primary means by which developers interact with the sound system. For example,
	  when writing an /obj/machine that needs to emit some sound (either one-off or looping ambient sounds),
	  the user need only call `play` or `deactivate`. The sound_emitter maintains an internal container of sounds
	  it can play which must be referenced with a key in `play`.
	They are registered with the sound_zone_manager (SZM) on construction and invoke events when
	  starting, updating or stopping a sound. These events are subscribed to by /mobs that enter range.
	  The subscription is driven by the SZM, which maintains a hashmap of sound_emitter locations.
*/

// Arguments:
//   /datum/sound_emitter/emitter: The emitter whose sound was SOUND_UPDATEd.
// Remember that SOUND_UPDATE will NOT start playing a sound!
// You must first send the sound WITHOUT SOUND_UPDATE for the client to start
//   hearing it if they couldn't before
// Also remember that sounds are DATUMS and hence REFERENCE TYPES so copy
//   in whatever you registered to the event!!!
#define SIGNAL_SOUND_UPDATED "sound_updated"

// Arguments:
//   /datum/sound_emitter/emitter: The emitter that started playing a sound
#define SIGNAL_SOUND_STARTED "sound_started"

// Arguments:
//   /datum/sound_emitter/emitter: The emitter that stopped playing a sound
#define SIGNAL_SOUND_STOPPED "sound_stopped"

// Arguments:
//   /sound/S: The sound that was pushed
//   /datum/sound_emitter/emitter: The emitter that played the sound
#define SIGNAL_SOUND_PUSHED "sound_pushed"


/atom/movable
	var/datum/sound_emitter/sound_emitter

/atom/movable/disposing()
	qdel(sound_emitter)
	return ..()

/atom/movable/proc/setup_sound()
	return

/mob
	var/last_sound_zone_hash = null
	// proxy for when the sound needs to be sent to some other mob, e.g. aiEye mob movement needs sounds sent to AI Core mob
	//  this is because the AI Eye client is null so we can't get to the SLC via the aiEye mob
	var/mob/sound_endpoint = null

/mob/New()
	. = ..()
	sound_endpoint = src

/mob/disposing()
	sound_endpoint = null
	. = ..()

/datum/sound_emitter
	var/atom/source = null
	var/list/sounds = list() // list of managed_sound
	var/datum/managed_sound/active_sound = null
	var/rangex
	var/rangey
	var/last_hash = null
	var/spaced = FALSE
	var/ignore_space = FALSE
	var/volume_channel = VOLUME_CHANNEL_GAME

	var/datum/sound_zone_manager/szm // not strictly necessary but its here for easy debugging in this early stage

// for static things (e.g. machines that must be bolted to work) pass is_static = TRUE
//  this causes the reserved channel to be taken from a shared pool, as static objects won't move close
//  to eachother and won't contend. There is no overlap between the shared and unique pools, so no contention
//  for example if someone carrying something noisy (mobile -> unique pool) walks close to something in the shared pool.
// !!! ^ The above is no longer in use ^ !!!
/datum/sound_emitter/New(atom/A)
	..()
	source = A
	rangex = SOUND_BUCKET_SIZE
	rangey = SOUND_BUCKET_SIZE
	sound_emitter_collection.add(src)
	if (sound_zone_manager)
		szm = sound_zone_manager
	sound_zone_manager.register_emitter(src)
	RegisterSignal(source, COMSIG_MOVABLE_MOVED, PROC_REF(on_source_moved))

/datum/sound_emitter/disposing()
	sound_emitter_collection.remove(src)
	sound_zone_manager.unregister_emitter(src)
	deactivate()
	if (sounds)
		sounds.Cut()
		sounds = null
	. = ..()

/*
		GENERAL USE INTERFACE - SETUP, PLAY/STOP CONTROL
*/

/datum/sound_emitter/proc/add(sound/s, key)
	if (!s || !istype(s, /sound))
		return
	if (key && (key in sounds))
		return
	s.atom = source
	s.transform = matrix(1, 0, 0, 0, 1, 0) //dont think theres a good reason for this to be anything else
	sounds[key] = new /datum/managed_sound(s)

/datum/sound_emitter/proc/play(key)
	var/datum/managed_sound/S = sounds[key]
	if (!S)
		CRASH("Sound emitter play called for key [key], but sound does not exist.")

	if (S.base_sound.repeat == 1)
		activate(key)
	else
		play_once(copy_sound(S.base_sound))

// halt sounds to clients, unregister from dynamic updates
/datum/sound_emitter/proc/deactivate()
	if(active_sound == null)
		return
	active_sound = null

	SEND_SIGNAL(src, SIGNAL_SOUND_STOPPED)

/datum/sound_emitter/proc/play_once(sound/S, interrupt = FALSE)
	S.atom = source
	S.repeat = 0 //no repeat - no need for channel reservation
	S.wait = 0
	if (interrupt)
		deactivate()
	// reduce volume if emitter is in low pressure
	update_env_effect()
	if (!S.volume)
		return

	SEND_SIGNAL(src, SIGNAL_SOUND_PUSHED, copy_sound(S))


/datum/sound_emitter/proc/update_active_sound_param(volume = null, frequency = null, falloff = null)
	if (active_sound == null)
		return
	// update active_sound overrides if given
	if (volume)
		active_sound.volume_override = volume
	if (frequency)
		active_sound.frequency_override = frequency
	if (falloff)
		active_sound.falloff_override = falloff

	update_env_effect()

	var/sound/S = active_sound.get()
	S.status |= SOUND_UPDATE
	SEND_SIGNAL(src, SIGNAL_SOUND_UPDATED)

/datum/sound_emitter/proc/update_source(atom/new_source)
	sound_emitter_collection.remove(src)
	sound_zone_manager.unregister_emitter(src)
	//old source should no longer fire move events
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)

	source = new_source
	for (var/key in sounds)
		var/datum/managed_sound/S = sounds[key]
		S.update_atom(new_source)
	update_active_sound_param()

	sound_emitter_collection.add(src)
	sound_zone_manager.register_emitter(src)
	//new source
	RegisterSignal(source, COMSIG_MOVABLE_MOVED, PROC_REF(on_source_moved))

/*
		SYSTEMS-FACING INTERFACE
*/

/datum/sound_emitter/proc/on_source_moved(atom/mover)
	if (mover != source)
		CRASH("Called on_source_moved while mover ([mover]) != source ([source])")
	var/turf/T = get_turf(source)
	if (!T)
		CRASH("Failed to get source turf")
	sound_zone_manager.update_emitter(src, T.x, T.y, T.z)

/datum/sound_emitter/proc/contains(turf/T)
	if (!T)
		return FALSE
	var/turf/S = get_turf(source)
	if (!S)
		CRASH("Failed to get source turf in contains")
	var/minX = S.x - rangex
	var/maxX = S.x + rangex
	var/minY = S.y - rangey
	var/maxY = S.y + rangey
	return (minX <= T.x && T.x <= maxX && minY <= T.y && T.y <= maxY)

/datum/sound_emitter/proc/contains_bugfix(datum/sound_listener_context/SLC, turf/T)
	var/turf/S = get_turf(source)
	if (!S)
		CRASH("Failed to get source turf in contains_bugfix")
	var/minX = S.x - SLC.rangex
	var/maxX = S.x + SLC.rangex
	var/minY = S.y - SLC.rangey
	var/maxY = S.y + SLC.rangey
	return (minX <= T.x && T.x <= maxX && minY <= T.y && T.y <= maxY)

/*
		INTERNAL, DON'T CALL THESE DIRECTLY YOU
*/

// push sounds to any clients in range, register with sound_zone_manager for dynamic updates
/datum/sound_emitter/proc/activate(key)
	// bookkeeping
	active_sound = sounds[key]
	if (!active_sound)
		CRASH("[key] not found in sounds cache for emitter on [source]")

	update_env_effect()
	SEND_SIGNAL(src, SIGNAL_SOUND_STARTED)

/datum/sound_emitter/proc/update_env_effect()
	if (active_sound == null || src.ignore_space)
		return
	var/source_atten = attenuate_for_location(source)
	if (source_atten <= SPACE_ATTEN_MIN)
		src.spaced = TRUE
	else
		src.spaced = FALSE
	active_sound.volume_mutator = source_atten

/*subtype for big stuff that needs to locate its center oh my god pelase make sure it has the get_center proc*/
/datum/sound_emitter/big
	var/obj/machinery/the_singularity/whatevs_source

/datum/sound_emitter/big/New(atom/A)
	. = ..()
	whatevs_source = source

/datum/sound_emitter/big/update_source(atom/new_source)
	. = ..()
	whatevs_source = source

/datum/sound_emitter/big/on_source_moved(atom/mover)
	if (mover != source)
		CRASH("Called on_source_moved while mover ([mover]) != source ([source])")
	var/turf/T = whatevs_source.get_center()
	if (!T)
		CRASH("Failed to get source turf")
	sound_zone_manager.update_emitter(src, T.x, T.y, T.z)

/datum/sound_emitter/big/contains(turf/T)
	if (!T)
		return FALSE
	var/turf/S = whatevs_source.get_center()
	if (!S)
		CRASH("Failed to get source turf in contains")
	var/minX = S.x - rangex
	var/maxX = S.x + rangex
	var/minY = S.y - rangey
	var/maxY = S.y + rangey
	return (minX <= T.x && T.x <= maxX && minY <= T.y && T.y <= maxY)

/datum/sound_emitter/big/contains_bugfix(datum/sound_listener_context/SLC, turf/T)
	var/turf/S = whatevs_source.get_center()
	if (!S)
		CRASH("Failed to get source turf in contains_bugfix")
	var/minX = S.x - SLC.rangex
	var/maxX = S.x + SLC.rangex
	var/minY = S.y - SLC.rangey
	var/maxY = S.y + SLC.rangey
	return (minX <= T.x && T.x <= maxX && minY <= T.y && T.y <= maxY)
