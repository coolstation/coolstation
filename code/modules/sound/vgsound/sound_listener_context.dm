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
	SPAWN_DBG(1 SECOND)
		if(!client)
			return
		if (client.listener_context)
			// results in sounds restarting when switching mobs... not great, not terrible
			var/slc = client.listener_context
			qdel(slc) // dont ask me why its like this. i dont know.
			client.listener_context = null
		if(client.byond_build > 1673)
			client.listener_context = new /datum/sound_listener_context(client, src, SOUND_BUCKET_SIZE)
		else if(client.byond_build >= 1653)
			client.listener_context = new /datum/sound_listener_context/byond_sound_falloff_bug(client, src, SOUND_BUCKET_SIZE)
/*
/mob/living/silicon/ai/Login()
	..()
	if (client.listener_context)
		var/slc = client.listener_context
		qdel(slc)
		client.listener_context = null
	client.listener_context = new /datum/sound_listener_context/ai(client, src, src, SOUND_BUCKET_SIZE)
	if (eyeobj)
		client.listener_context.reset_proxy(eyeobj)
*/

/datum/sound_listener_context
	var/client/client = null
	var/mob/proxy = null
	var/list/current_channels_by_emitter = list()
	var/list/free_channels = list()
	var/rangex = SOUND_BUCKET_SIZE
	var/rangey = SOUND_BUCKET_SIZE

/datum/sound_listener_context/New(client/C, mob/P)
	. = ..()
	client = C
	proxy = P
	current_channels_by_emitter = list()
	free_channels = list()
	for (var/i in SOUNDCHANNEL_CLIENT_MIN to SOUNDCHANNEL_CLIENT_MAX)
		free_channels += i
	sound_zone_manager.register_listener(src)

/datum/sound_listener_context/disposing()
	for (var/datum/sound_emitter/E in current_channels_by_emitter)
		stop_hearing(E)
		release(E)
		unsubscribe_from(E)
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

/datum/sound_listener_context/proc/stop_hearing(datum/sound_emitter/E)
	// which channel this client is using for this emitter
	var/chan = current_channels_by_emitter[E]
	if (!chan)
		return //no channel to release, no sound to stop (hopefully)
	// flush it
	var/sound/nullsound = sound(file = null)
	nullsound.channel = chan
	nullsound.status = SOUND_UPDATE | SOUND_MUTE
	client << nullsound

/datum/sound_listener_context/proc/reset_proxy(mob/P)
	sound_zone_manager.unregister_listener(src)
	proxy = P
	sound_zone_manager.register_listener(src)

/datum/sound_listener_context/proc/apply_proxymob_effects(sound/S, datum/sound_emitter/emitter)
	. = S
	if (proxy.ears_protected_from_sound())
		S.volume *= 0.04
		S.environment = EAX_DRUGGED
		S.echo = SPACED_ECHO
		return

	if (!(S.atom in view(10, proxy)))
		S.volume *= 0.7

	var/listener_atten = 1
	if(!emitter.ignore_space)
		listener_atten = attenuate_for_location(proxy)
		if(listener_atten <= SPACE_ATTEN_MIN)
			if(emitter.spaced)
				S.environment = SPACED_ENV
				S.echo = SPACED_ECHO
				S.volume += 65
				return
			S.environment = SPACED_ENV
			S.echo = SPACED_ECHO
			S.volume *= 0.3
			return
	var/area/A = get_area(proxy)
	S.environment = A?.sound_environment
	S.echo = ECHO_AFAR
	S.volume *= listener_atten

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
	var/chan = current_channels_by_emitter[emitter] // try to assign the channel immediately, even if its silent
	if(!chan)
		chan = assign_channel(emitter)

	if (emitter.active_sound == null)
		return // start hearing what?

	var/sound/S = emitter.active_sound.get()

	// important note - clearing SOUND_UPDATE means that the sound will play FROM THE BEGINNING.
	// this system was originally built with short repeating sounds in mind (machine hum, etc) however
	// if you try to do something longer and more varied like music then this is very noticeable and unwanted.
	// would best be handled by an expansion of /datum/managed_sound to use sound.len, tracking playback
	// progress and modifying S.offset to start at the correct point

	apply_proxymob_effects(S, emitter)
	if(S.volume > TOO_QUIET)
		if (!chan)
			CRASH("Sound emitter on [emitter.source] failed to reserve a channel for [src]")
		S.status &= ~SOUND_UPDATE
		S.channel = chan
		client << S

/datum/sound_listener_context/proc/hear_once(sound/S, datum/sound_emitter/emitter)
	apply_proxymob_effects(S, emitter)
	if(S.volume > TOO_QUIET)
		client << S

/datum/sound_listener_context/proc/release(datum/sound_emitter/E)
	var/chan = current_channels_by_emitter[E]
	current_channels_by_emitter -= E
	free_channels += chan

/datum/sound_listener_context/proc/on_sound_update(datum/sound_emitter/emitter)
	var/chan = current_channels_by_emitter[emitter]
	if (!chan)
		return // we aren't hearing this emitter anyway
	if (!emitter.active_sound)
		return // emitter isn't playing anything, get out of here
	var/sound/S = emitter.active_sound.get()
	apply_proxymob_effects(S, emitter)
	if(S.volume > TOO_QUIET)
		S.status |= SOUND_UPDATE
		S.channel = chan
		client << S

/datum/sound_listener_context/proc/on_enter_range(datum/sound_emitter/E)
	start_hearing(E) // this can throw if channel reservation fails, subscribe after its safe
	subscribe_to(E)

/datum/sound_listener_context/proc/on_exit_range(datum/sound_emitter/E)
	stop_hearing(E)
	release(E)
	unsubscribe_from(E)

/datum/sound_listener_context/byond_sound_falloff_bug
	rangex = 11
	rangey = 8
