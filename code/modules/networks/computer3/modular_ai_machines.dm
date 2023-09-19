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
		//Repairs (placeholder-ish)
		if (istype(W, /obj/item/cable_coil))
			if (health < 60 && W.change_stack_amount(-2))
				health += 10
				boutput(user, "<span class='alert'>You fix some of the circuitry.</span>")
				if (health >= 0)
					UpdateOverlays(image(src.icon, "governor_guts-spinning", layer = FLOAT_LAYER), "guts")
					on_enable()
				return
			else
				boutput(user, "<span class='alert'>The circuitry is fine.</span>")
				return
		else if (istype(W, /obj/item/sheet) && W.material && (W.material.material_flags & MATERIAL_CRYSTAL) && W.change_stack_amount(-5))
			if (health >= 60 && health < 90)
				health = initial(src.health)
				boutput(user, "<span class='alert'>You replace the glass panel.</span>")
				UpdateOverlays(image(src.icon, "governor_glass", layer = FLOAT_LAYER+1), "glass")
				return


		/*
		A friend gave me this formula, it's largely arbitrary but the point is I wanted something to bring the damage of various weapons closer
		to a single value (15) since most weapons have fairly low values in the 5-12 range, but there's a few outliers. I didn't want those to level
		the	governor immediately but also it shouldn't take someone with a wrench like 30 hits to break this.
		Breaking a governor shouldn't be hard, but there should be a bit of drama involved. :3
		*/

		if (isnull(W.force)) return ..()
		var/adjusted_damage = (W.force - 15)/2.5 + 15
		user.lastattacked = src
		attack_particle(user,src)
		playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg' , 75, 1, pitch = 1.6)
		if (src.health > -10)
			src.take_damage(adjusted_damage, user)
		else
			elecflash(src,power=2) //

	ex_act(severity)
		//TODO adjust for new severity
		take_damage(160 + rand(-10, 10) - (50*(severity-1))) //150-170 for severity 1 (a guaranteed robogib), 100-120 for severity 2 (only unharmed governors survive), 50-70 for severity 3



/obj/machinery/networked/ai_governor/proc/take_damage(damage)
	//glass breaking first
	if (health >= 90 && (health - damage) < 90)
		playsound(src.loc, 'sound/impact_sounds/Glass_Shards_Hit_1.ogg' , 65, 1)
		UpdateOverlays(image(src.icon, "governor_glass-burst", layer = FLOAT_LAYER+1), "glass")
	else if (health >= 60 && (health - damage) < 60)
		playsound(src.loc, 'sound/impact_sounds/Glass_Shatter_2.ogg' , 65, 1)
		UpdateOverlays(image(src.icon, "governor_glass-shattered", layer = FLOAT_LAYER+1), "glass")
	else if (health < 60 && prob(70)) //smashing into the electronics
		elecflash(src,power=2)

	health -= damage

	if (health <= 0)
		UpdateOverlays(image(src.icon, "governor_guts-smashed", layer = FLOAT_LAYER), "guts")
		icon_state = "governor_body-damaged"
		//color = "#BB0000"
		on_disable()
	if (health <= -25 && !src.disposed)
		robogibs(get_turf(src), null)
		qdel(src)

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
	name = "\improper AI governor (airlocks)"
	desc_func = "interface with airlocks"
	registry_ID = AI_GOVERNOR_AIRLOCKS
	stripe_colour = "#99BB77" //significantly lighter than the radio governor

/obj/machinery/networked/ai_governor/APCs
	name = "\improper AI governor (APCs)"
	desc_func = "interface with APCs"
	registry_ID = AI_GOVERNOR_APCS
	stripe_colour = "#FFBB44"

/obj/machinery/networked/ai_governor/cameras
	name = "\improper AI governor (tracking)"
	desc_func = "track people over the camera network"
	registry_ID = AI_GOVERNOR_TRACKING
	stripe_colour = "#AAAAAA"

/obj/machinery/networked/ai_governor/killswitch
	name = "\improper AI governor (don't use, not implemented)"
	desc_func = "receive and automatically obey killswitch orders"
	registry_ID = AI_GOVERNOR_KILLSWITCH
	stripe_colour = "#BB1234"

/obj/machinery/networked/ai_governor/viewports
	name = "\improper AI governor (viewports)"
	desc_func = "make and maintain viewports"
	registry_ID = AI_GOVERNOR_VIEWPORTS
	stripe_colour = "#CC88FF"

/obj/machinery/networked/ai_governor/general_radio	//:1
	name = "\improper AI governor (don't use, sucks)"
	desc_func = "use the general radio channel"
	registry_ID = AI_GOVERNOR_GENRADIO
	stripe_colour = RADIOC_STANDARD

/obj/machinery/networked/ai_governor/core_radio //:2
	name = "\improper AI governor (don't use, sucks)"
	desc_func = "use the AI core radio channel"
	registry_ID = AI_GOVERNOR_CORERADIO
	stripe_colour = "#7F7FE2" //AI intercoms don't use a define IDK why

/obj/machinery/networked/ai_governor/department_radio //:3
	name = "\improper AI governor (departmental radio)"
	desc_func = "use departmental radio channels"
	registry_ID = AI_GOVERNOR_DEPRADIO
	stripe_colour = RADIOC_COMMAND
