//Tuneable radio and TV
//Note that these are not the only things that can receive a broadcast.
//You can call SUBSCRIBE_BROADCAST on just about anything. There's a button in the admin tilde menu for it even.


ABSTRACT_TYPE(/obj/tuneable_receiver)
/obj/tuneable_receiver
	var/on = FALSE
	var/station = TR_CAT_RADIO_BROADCAST_RECEIVERS
	var/video_dmi = null //Optional:

	icon_state = "transmitter"
	icon = 'icons/obj/machines/loudspeakers.dmi'

	New()
		..()
		//The 1 is there for consistency with what by_cat was doing before I did my hack.
		if(on)
			SUBSCRIBE_BROADCAST(station, (video_dmi ? video_dmi : 1))
			icon_state = "transmitter-on"

	disposing()
		//Fix edge case where no radio/tv starts turned on, so the by_cat list was never initialised when trying to unsub
		if (on)
			UNSUBSCRIBE_BROADCAST(station)
		..()

/obj/tuneable_receiver/radio

/obj/tuneable_receiver/teevee
	video_dmi = 'icons/misc/broadcastsPOC.dmi'
	//var/icon_base = "POCteevee"

/obj/ceiling_speaker
	name = "ceiling loudspeaker"
	desc = "they're putting these things on the ceiling now???"
	mouse_opacity = FALSE //just don't click
	plane = PLANE_NOSHADOW_ABOVE
	icon = 'icons/obj/machines/loudspeakers.dmi'
	icon_state = "loudspeaker-ceiling"
	#ifdef IN_MAP_EDITOR
	alpha = 128
	#else
	alpha = 50
	#endif
	var/image/speakerimage = null
	var/station = TR_CAT_CEILING_BROADCAST_DEFAULT
	var/id = "awa" //departmental ceiling speakers in the future?

	New()
		..()
		START_TRACKING //track these by type and not just broadcast category
		//cause we can only tune these in code.

		SUBSCRIBE_BROADCAST(station, 1)

		//make it show up better when actually looking up
		speakerimage = image(src.icon,src,initial(src.icon_state),PLANE_NOSHADOW_ABOVE -1,src.dir)
		//i think this is loaded before the CLIENT_IMAGE_GROUP_CEILING_ICONS define is so, oh well,
		get_image_group("ceiling_icons").add_image(speakerimage)
		speakerimage.alpha = 100

	disposing()
		STOP_TRACKING
		..()

/obj/ceiling_speaker/proc/tune(new_channel, target_id)
	if (target_id == src.id || target_id == "ALL")
		UNSUBSCRIBE_BROADCAST(station)
		SUBSCRIBE_BROADCAST(new_channel, 1)
		current_channel = new_channel

/proc/tune_ceiling_speakers(new_channel, target_id = "ALL")
	for_by_tcl(speaker, /obj/ceiling_speaker)
		speaker.tune(new_channel, target_id)



//Phase these binches out please they need to die

/obj/shitty_radio
	name = "shitty test radio"
	desc = "fuck me that's one shitty radio"
	var/on = FALSE
	var/station = TR_CAT_RADIO_BROADCAST_RECEIVERS
	var/video_dmi = null //Optional:

	icon_state = "transmitter"
	icon = 'icons/obj/machines/loudspeakers.dmi'
	color = "#AAAAAA"

	New()
		..()
		//The 1 is there for consistency with what by_cat was doing before I did my hack.
		if(on)
			SUBSCRIBE_BROADCAST(station, (video_dmi ? video_dmi : 1))
			icon_state = "transmitter-on"

	disposing()
		//Fix edge case where no radio/tv starts turned on, so the by_cat list was never initialised when trying to unsub
		if (on)
			UNSUBSCRIBE_BROADCAST(station)
		..()


	attack_hand(mob/user)
		if (on)
			on = FALSE
			UNSUBSCRIBE_BROADCAST(station)
			icon_state = "transmitter"
		else
			SUBSCRIBE_BROADCAST(station, (video_dmi ? video_dmi : 1))
			on = TRUE
			icon_state = "transmitter-on"
		. = ..()
/*
/obj/shitty_radio/finite_demo
	name = "shittier test radio"
	desc = "god damn this fucking blight on the station (use a multitool to start this)"
	color = "#541771"
	station = TR_CAT_FINITE_BROADCAST_RECEIVERS

	attackby(obj/item/I, mob/user)
		if (istool(I, TOOL_PULSING))
			broadcast_controls.broadcast_start("demo_finite")
		..()
*/

//little test but also might be a good candidate for maptext-free as an option for certain broadcasts (Mall loops and such)
/obj/shitty_radio/ceiling
	name = "shitty ceiling loudspeaker"
	desc = "they're putting these things on the ceiling now???"
	mouse_opacity = FALSE //just don't click
	alpha = 50
	plane = PLANE_NOSHADOW_ABOVE

	icon_state = "loudspeaker-ceiling"
	#ifdef IN_MAP_EDITOR
	alpha = 128
	#endif
	color = "#c3bddb"
	var/image/speakerimage = null

	New()
		..()

		//make it show up better when actually looking up
		speakerimage = image(src.icon,src,initial(src.icon_state),PLANE_NOSHADOW_ABOVE -1,src.dir)
		//i think this is loaded before the CLIENT_IMAGE_GROUP_CEILING_ICONS define is so, oh well,
		get_image_group("ceiling_icons").add_image(speakerimage)
		speakerimage.alpha = 100
/*
/obj/shitty_radio/queueing_and_interruption_demo //Testing for proper queue behaviour and priority sorting
	name = "queue test radio"
	desc = "Wat een verkakt stuk schroot (use a multitool to start this)"
	color = "#54B771"
	station = TR_CAT_FINITE_BROADCAST_RECEIVERS
	var/ignore = FALSE

	attackby(obj/item/I, mob/user)
		if (istool(I, TOOL_PULSING) && !ignore)
			ignore = TRUE
			broadcast_controls.broadcast_start(new /datum/directed_broadcast/queue_test_series/one)
			broadcast_controls.broadcast_start(new /datum/directed_broadcast/queue_test_series/two)
			broadcast_controls.broadcast_start(new /datum/directed_broadcast/queue_test_series/three)
			broadcast_controls.broadcast_start(new /datum/directed_broadcast/queue_test_series/four)
			SPAWN_DBG(5 SECONDS) //
				broadcast_controls.broadcast_start(new /datum/directed_broadcast/queue_test_series/priority)
				broadcast_controls.broadcast_start(new /datum/directed_broadcast/queue_test_series/highpriority)
				ignore = FALSE

		..()
*/
/obj/shitty_radio/shitty_tv
	name = "shitty test TV"
	desc = "And you thought those radios were fucking garbage"
	icon_state = "POCteevee"
	icon = 'icons/misc/broadcastsPOC.dmi'
	station = TR_CAT_TEEVEE_BROADCAST_RECEIVERS
	video_dmi = 'icons/misc/broadcastsPOC.dmi'
	color = null

	//shitcode override but it's a demo object so who cares
	attack_hand(mob/user)
		..()
		if (on)
			icon_state = "POCteevee-on"
		else
			icon_state = "POCteevee"
