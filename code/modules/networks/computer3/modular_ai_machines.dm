/*	2023-3-1	-	BatElite
Kinda experimental: tying the AI's abilities to physical objects

-door control
-cam tracking (deciding against cams in general since blinding the AI won't be good for them)
-killswitching & lockdown
-PDA control
-viewports (1 per cab?)
-department radio?

Goals (I'm making this up as I go):
-can't be harmed by silicons (if anything they'll want to protect most cabs, just to keep em bludgeoning the killswitch cab every round)
-but they can repair maybe
-breaking one is as simple as hitting it with a heavy thing (BLUNT/CRUSH most effective)
-including a type on the map registers that ability as cab bound, so you can just not add the ones you don't like (gotta make sure folks can't get their hands on the software)
-copying the internals off of one so you can make replacements
-not


Having seen a bit of how law racks worked out on goon, I'm pretty convinced that these need to globally affect AIs because players will just not bother with anything more complicated than one set of rules for all silicons
*/

//Associative list of a string for a particular action, and active governors' refs. Broken governors aren't in this
//In a bit of sneaky dickery, an empty list for a particular string means that action is blocked, but if the string isn't in this list at all it's free
//which is how governor types are opt-in per map, it's kinda gross but
var/list/governor_registry = list()

///
/obj/machinery/networked/ai_governor
	name = "\improper AI governor"
	desc = "A big cabinet of electronics that facilitate the AI to manage certain tasks. What, you thought that all of this would fit in the metal box with the happy face on it?"
	icon_state = "governor_body"
	var/health = 125 //check attackby, cause governor health isn't as simple as for most things
	///
	var/desc_func = "uhhh...yell at the coders"
	/*var/net_id = null
	var/host_id = null //Who are we connected to? (If we have a single host)
	var/old_host_id = null //Were we previously connected to someone?  Do we care?
	*/
	//var/obj/machinery/power/data_terminal/link = null
	device_tag = "MAINFRAME_FUNC" //following the AI itself using MAINFRAME_AI for some reason

	var/registry_ID = null
	var/stripe_colour = "#FFFFFF"

	New()
		..()
		on_enable()
		var/image/stripe = image(src.icon, "governor_stripe")
		stripe.color = stripe_colour
		UpdateOverlays(stripe, "stripe")
		SPAWN_DBG(rand(0,7)) //try to desync the animations on these
			UpdateOverlays(image(src.icon, "governor_guts-spinning", layer = FLOAT_LAYER), "guts")
		UpdateOverlays(image(src.icon, "governor_glass", layer = FLOAT_LAYER+1), "glass")

	disposing()
		on_disable()
		..()

	get_desc(dist)
		. = "<br>This one allows the AI to <b>[desc_func].</b>"

	attackby(obj/item/W as obj, mob/user as mob, params, is_special = 0)
		/*
		A friend gave me this formula, it's largely arbitrary but the point is I wanted something to bring the damage of various weapons closer
		to a single value (15) since most weapons have fairly low values in the 5-12 range, but there's a few outliers. I didn't want those to level
		the	governor immediately but also it shouldn't take someone with a wrench like 30 hits to break this.
		Breaking a governor shouldn't be hard, but there should be a bit of drama involved. :3

		A 0 force item will do about 8 damage, a 5 force item about 10, 10 force does about 12
		conversely, the 30 force airlock sledge will do around 22 and the 60 force csaber will do about 30

		As a result of this math bullshit, this thing's health isn't gonna be fake-integer a lot of the time.
		*/

		//You can copy-paste this into desmos if you want a visual: f(x)=(x-15)^{\left(\frac{5}{7}\right)}+15
		var/force_no_null_plox = isnull(W.force) ? 0 : W.force
		var/adjusted_damage = (force_no_null_plox - 15)**(5/7) + 15
		health -= adjusted_damage
		if (health <= 0)
			color = "#BB0000"
			on_disable()

///Whenever a governor goes up it updates the registry
/obj/machinery/networked/ai_governor/proc/on_enable()
	SHOULD_CALL_PARENT(TRUE)
	if (registry_ID)
		if (!(registry_ID in governor_registry))
			governor_registry[registry_ID] = list()
		governor_registry[registry_ID] |= src
		if (length(governor_registry[registry_ID]) == 1) //we're the first :)
			on_total_enable()

///Whenever a governor shuts down it updates the registry
/obj/machinery/networked/ai_governor/proc/on_disable()
	SHOULD_CALL_PARENT(TRUE)
	if (registry_ID && (registry_ID in governor_registry))
		governor_registry[registry_ID] -= src
		if (length(governor_registry[registry_ID]) == 0) //we're the last :(
			on_total_disable()

///Whenever the first governor of its type (re-)enables an AI function it'll call this
/obj/machinery/networked/ai_governor/proc/on_total_enable() //(I came up with on_total_disable first and this proc's name is just for consistency, even if it doesn't make as much sense)
	return

///Whenever the last governor of its type shuts down (disabling the AI function) it'll call this
/obj/machinery/networked/ai_governor/proc/on_total_disable()
	return

///When a new AI mob is created mid-round it'll call this on every governor so they can update it's shit if necessary. Chances are the mob won't have a player yet at the point of calling.
///obj/machinery/networked/ai_governor/proc/register_AI(mob/living/silicon/ai/new_AI)
//	return


/obj/machinery/networked/ai_governor/airlocks
	desc_func = "interface with airlocks"
	registry_ID = AI_GOVERNOR_AIRLOCKS
	stripe_colour = "#99BB77" //significantly lighter than the radio governor

/obj/machinery/networked/ai_governor/APCs
	desc_func = "interface with APCs"
	registry_ID = AI_GOVERNOR_APCS
	stripe_colour = "#FFBB44"

/obj/machinery/networked/ai_governor/cameras
	desc_func = "track people over the camera network"
	registry_ID = AI_GOVERNOR_TRACKING
	stripe_colour = "#AAAAAA"

/obj/machinery/networked/ai_governor/killswitch
	desc_func = "receive and automatically obey killswitch orders"
	registry_ID = AI_GOVERNOR_KILLSWITCH
	stripe_colour = "#BB1234"

/obj/machinery/networked/ai_governor/viewports
	desc_func = "make and maintain viewports"
	registry_ID = AI_GOVERNOR_VIEWPORTS
	stripe_colour = "#CC88FF"

/obj/machinery/networked/ai_governor/general_radio	//:1
	desc_func = "use the general radio channel"
	registry_ID = AI_GOVERNOR_GENRADIO
	stripe_colour = RADIOC_STANDARD

/obj/machinery/networked/ai_governor/core_radio //:2
	desc_func = "use the AI core radio channel"
	registry_ID = AI_GOVERNOR_CORERADIO
	stripe_colour = "#7F7FE2" //AI intercoms don't use a define IDK why

/obj/machinery/networked/ai_governor/department_radio //:3
	desc_func = "use departmental radio channels"
	registry_ID = AI_GOVERNOR_DEPRADIO
	stripe_colour = RADIOC_COMMAND
