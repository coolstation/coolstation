
//infrastructure
/obj/decal/fakeobjects/apc_broken
	name = "broken APC"
	desc = "A smashed local power unit."
	icon = 'icons/obj/machines/power.dmi'
	icon_state = "apc-b"
	anchored = 1

/obj/decal/fakeobjects/broken_governor
	name = "busted AI governor"
	desc = "A big cabinet of electronics that facilitate the AI to manage certain tasks. This one is damaged well beyond repair. Hope it wasn't critical."
	icon = 'icons/obj/machines/networked.dmi'
	icon_state = "governor_body-damaged"
	anchored = 1
	density = 1
	pass_unstable = FALSE
	var/stripe_colour = "#AA0000"
	New()
		..()
		var/image/stripe = image(src.icon, "governor_stripe")
		stripe.color = stripe_colour
		UpdateOverlays(stripe, "stripe")
		UpdateOverlays(image(src.icon, "governor_guts-smashed", layer = FLOAT_LAYER), "guts")
		UpdateOverlays(image(src.icon, "governor_glass-shattered", layer = FLOAT_LAYER+1), "glass")

/obj/decal/fakeobjects/firealarm_broken
	name = "broken fire alarm"
	desc = "This fire alarm is burnt out, ironically."
	icon = 'icons/obj/machines/monitors.dmi'
	icon_state = "firex"
	anchored = 1

/obj/decal/fakeobjects/lighttube_broken
	name = "shattered light tube"
	desc = "Something has broken this light."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-broken"
	anchored = 1
	layer = EFFECTS_LAYER_UNDER_1
	plane = PLANE_NOSHADOW_ABOVE

/obj/decal/fakeobjects/lightbulb_broken
	name = "shattered light bulb"
	desc = "Something has broken this light."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "bulb-broken"
	anchored = 1
	layer = EFFECTS_LAYER_UNDER_1
	plane = PLANE_NOSHADOW_ABOVE

/obj/decal/fakeobjects/firelock_broken
	name = "rusted firelock"
	desc = "Rust has rendered this firelock useless."
	icon = 'icons/obj/doors/door_fire2.dmi'
	icon_state = "door0"
	anchored = 1

/obj/decal/fakeobjects/falseladder
	name = "ladder"
	desc = "The ladder is blocked, you can't get down there."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "ladder"
	anchored = 1
	density = 0

//transport
/obj/decal/fakeobjects/teleport_pad
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pad0"
	name = "teleport pad"
	anchored = 1
	layer = FLOOR_EQUIP_LAYER1
	desc = "A pad used for scientific teleportation."

/obj/decal/fakeobjects/cargopad
	name = "Cargo Pad"
	desc = "Used to recieve objects transported by a Cargo Transporter."
	icon = 'icons/obj/objects.dmi'
	icon_state = "cargopad"
	anchored = 1
	plane = PLANE_FLOOR

//atmos

/obj/decal/fakeobjects/airmonitor_broken
	name = "broken air monitor"
	desc = "Something has broken this air monitor."
	icon = 'icons/obj/machines/monitors.dmi'
	icon_state = "alarmx"
	anchored = 1

/obj/decal/fakeobjects/pipe
	name = "rusted pipe"
	desc = "Good riddance."
	icon = 'icons/obj/atmospherics/pipes/color_pipe.dmi'
	icon_state = "intact"
	color = "#AAAAAA"
	anchored = 1
	layer = PIPE_LAYER
	plane = PLANE_NOSHADOW_BELOW

	heat
		icon = 'icons/obj/atmospherics/pipes/heat_pipe.dmi'

/obj/decal/fakeobjects/oldcanister
	name = "old gas canister"
	desc = "All the gas in it seems to be long gone."
	icon = 'icons/misc/evilreaverstation.dmi'
	icon_state = "old_oxy"
	anchored = 0
	density = 1

	plasma
		name = "old plasma canister"
		icon_state = "old_plasma"
		desc = "This used to be the most feared piece of equipment on the station, don't you believe it?"

//computers

/obj/decal/fakeobjects/console_lever
	name = "lever console"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "lever0"
	density = 1

/obj/decal/fakeobjects/console_randompc
	name = "computer console"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "randompc"
	density = 1

/obj/decal/fakeobjects/console_radar
	name = "radar console"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "radar"
	density = 1

//factoryish stuff
/obj/decal/fakeobjects/pcb
	name = "PCB constructor"
	desc = "A combination pick and place machine and wave soldering gizmo.  For making boards.  Buddy boards.   Well, it would if the interface wasn't broken."
	icon = 'icons/obj/machines/manufacturer.dmi'
	icon_state = "fab"
	anchored = 1
	density = 1

//Broken grody coffee maker so I can justify scattering coffee cups around azones
/obj/decal/fakeobjects/coffeemaker
	name = "coffeemaker"
	desc = "Had this still worked, it'd probably make something undrinkable."
	icon = 'icons/obj/foodNdrink/espresso.dmi'
	icon_state = "coffeemaker_effed"
	density = 1
	anchored = 1
	object_flags = CAN_BE_LIFTED
