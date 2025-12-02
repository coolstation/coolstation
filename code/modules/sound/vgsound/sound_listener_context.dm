/**
 * copyright 2025 Inorien
 */

/*
	This is a client datum that tracks which sound channels are in use for the client.
	Previously channel management was serverside and global, meaning that for every single client,
	  a SMES in Engineering and a SMES on some random derelict would be on channel 1, for example.
	This new architecture is designed to offload channel reservation to the client and keep
	  sound_emitters as passive data sources.
	There is also the added benefit of vastly simplified flushing in the event of ckey transfers
	  between mobs. Rather than keeping a /mob/var/list/current_sound_emitters which has to be
	  carefully updated on instances of things like ghosting or being set to a body, this data
	  is maintained at the client level where such transfers are much cleaner to work with.
	It also makes sense because sounds are sent to the client anyway, not to the mob.

	Lifetime is largely tied to the mob, as mob changes typically imply a change in audible sounds.
	When an SLC is constructed/destructed it registers/unregisters the the sound_zone_manager, which
	  requires access to the SLC proxy (a /mob) for event handling. When anything registers with the
	  SZM it triggers an `on_player_move` call, which flushes old emitters/channels and updates with
	  new ones.
	Client deletion (such as on disconnect) requires this to be cleaned up.
*/

/client
	var/datum/sound_listener_context/listener_context = null

/client/Del()
	qdel(listener_context)
	return ..()

/mob/Login()
	. = ..()
	SPAWN_DBG(0)
		if (client.listener_context)
			// results in sounds restarting when switching mobs... not great, not terrible
			var/slc = client.listener_context
			qdel(slc) // dont ask me why its like this. i dont know.
			client.listener_context = null
		client.listener_context = new /datum/sound_listener_context(client, src, world.view)

/*
/mob/living/silicon/ai/Login()
	..()
	if (client.listener_context)
		var/slc = client.listener_context
		qdel(slc)
		client.listener_context = null
	client.listener_context = new /datum/sound_listener_context/ai(client, src, src, world.view)
	if (eyeobj)
		client.listener_context.reset_proxy(eyeobj)
*/

/datum/sound_listener_context
	var/client/client = null
	var/mob/proxy = null
	var/list/current_channels_by_emitter = list()
	var/list/free_channels = list()
	var/list/audible_emitters = list()
	var/range = null

/datum/sound_listener_context/New(client/C, mob/P, hearing_range = SOUND_BUCKET_SIZE)
	. = ..()
	client = C
	proxy = P
	current_channels_by_emitter = list()
	free_channels = list()
	audible_emitters = list()
	for (var/i = SOUNDCHANNEL_CLIENT_MIN, i <= SOUNDCHANNEL_CLIENT_MAX, i++)
		free_channels += i
	range = hearing_range
	sound_zone_manager.register_listener(src)

/datum/sound_listener_context/disposing()
	for (var/datum/sound_emitter/E in current_channels_by_emitter)
		release(E)
	for (var/datum/sound_emitter/E in audible_emitters)
		unsubscribe_from(E)
	audible_emitters.Cut()
	free_channels.Cut()
	current_channels_by_emitter.Cut()
	sound_zone_manager.unregister_listener(src)
	client = null
	proxy = null
	return ..()

/datum/sound_listener_context/proc/assign_channel(datum/sound_emitter/E)
	if (E in current_channels_by_emitter)
		return current_channels_by_emitter[E]

	var/channel = null
	if (length(free_channels))
		channel = free_channels[1]
		free_channels -= channel
	if (channel)
		current_channels_by_emitter[E] = channel
		return channel

/datum/sound_listener_context/proc/release(datum/sound_emitter/E)
	// which channel this client is using for this emitter
	var/chan = current_channels_by_emitter[E]
	if (!chan)
		return //no channel to release, no sound to stop (hopefully)
	// flush it
	var/sound/nullsound = sound(file = null)
	nullsound.channel = chan
	nullsound.status = SOUND_UPDATE | SOUND_MUTE
	client << nullsound

	current_channels_by_emitter -= E
	free_channels += chan

/datum/sound_listener_context/proc/reset_proxy(mob/P)
	sound_zone_manager.unregister_listener(src)
	proxy = P
	sound_zone_manager.register_listener(src)

/datum/sound_listener_context/proc/apply_proxymob_effects(sound/S)
	. = S
	if (proxy.ear_deaf)
		S.volume *= 0.1
		return

	if (!(S.atom in view(range, proxy)))
		S.volume *= 0.5

	var/p_effect = attenuate_for_location(proxy)
	S.volume *= p_effect

/datum/sound_listener_context/proc/subscribe_to(datum/sound_emitter/E)
	RegisterSignal(E, SIGNAL_SOUND_UPDATED, PROC_REF(on_sound_update))
	RegisterSignal(E, SIGNAL_SOUND_STARTED, PROC_REF(start_hearing))
	RegisterSignal(E, SIGNAL_SOUND_STOPPED, PROC_REF(stop_hearing))
	RegisterSignal(E, SIGNAL_SOUND_PUSHED, PROC_REF(hear_once))

/datum/sound_listener_context/proc/unsubscribe_from(datum/sound_emitter/E)
	UnregisterSignal(E, SIGNAL_SOUND_UPDATED)
	UnregisterSignal(E, SIGNAL_SOUND_STARTED)
	UnregisterSignal(E, SIGNAL_SOUND_STOPPED)
	UnregisterSignal(E, SIGNAL_SOUND_PUSHED)

/datum/sound_listener_context/proc/start_hearing(datum/sound_emitter/emitter)
	if (emitter.active_sound == null)
		return // start hearing what?
	var/chan = assign_channel(emitter)
	if (!chan)
		CRASH("Sound emitter on [emitter.source] failed to reserve a channel for [src]")
	var/sound/S = emitter.active_sound.get()

	// important note - clearing SOUND_UPDATE means that the sound will play FROM THE BEGINNING.
	// this system was originally built with short repeating sounds in mind (machine hum, etc) however
	// if you try to do something longer and more varied like music then this is very noticeable and unwanted.
	// would best be handled by /datum/managed_sound using sound.len, tracking playback
	// progress and modifying S.offset to start at the correct point
	S.status &= ~SOUND_UPDATE
	S.channel = chan
	apply_proxymob_effects(S)
	client << S

/datum/sound_listener_context/proc/hear_once(sound/S, datum/sound_emitter/emitter)
	apply_proxymob_effects(S)
	client << S

/datum/sound_listener_context/proc/stop_hearing(datum/sound_emitter/emitter)
	release(emitter)

/datum/sound_listener_context/proc/on_sound_update(datum/sound_emitter/emitter)
	var/chan = current_channels_by_emitter[emitter]
	if (!chan)
		return // we aren't hearing this emitter anyway
	if (!emitter.active_sound)
		return // emitter isn't playing anything, get out of here
	var/sound/S = emitter.active_sound.get()
	S.status |= SOUND_UPDATE
	S.channel = chan
	apply_proxymob_effects(S)
	client << S

/datum/sound_listener_context/proc/on_enter_range(datum/sound_emitter/E)
	start_hearing(E) // this can throw if channel reservation fails, subscribe after its safe
	subscribe_to(E)
	audible_emitters |= E

/datum/sound_listener_context/proc/on_exit_range(datum/sound_emitter/E)
	stop_hearing(E)
	unsubscribe_from(E)
	audible_emitters -= E
