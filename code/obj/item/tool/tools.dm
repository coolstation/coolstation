//Shoving all the tiny codefiles for common tools in here. They were all like 50 lines long
//Left the more substantial ones (welders & omnitools) in their own little things though.

/* Contains:
Crowbar
Screwdriver
Wirecutters
Wrench
Multitool
Hammer
Handsaw
*/


//--------------------------- Crowbars ------------------------------------------

/obj/item/crowbar
	name = "crowbar"
	desc = "A tool used as a lever to pry objects."
	icon = 'icons/obj/items/tools/tools.dmi'
	// TODO: crowbar inhand icon
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "crowbar"
	item_state = "crowbar"

	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	tool_flags = TOOL_PRYING
	w_class = W_CLASS_SMALL

	force = 8
	throwforce = 7
	stamina_damage = 35
	stamina_cost = 12
	stamina_crit_chance = 10

	m_amt = 50
	rand_pos = 8
	custom_suicide = 1

	New()
		..()
		src.setItemSpecial(/datum/item_special/tile_fling)
		BLOCK_SETUP(BLOCK_ROD)

	attack(mob/living/carbon/M as mob, mob/user as mob)
		if (!pry_surgery(M, user))
			return ..()

	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] beats [him_or_her(user)]self in the head with a crowbar, like some kind of suicidal theoretical physicist.</b></span>")
		take_bleeding_damage(user, null, 25, src.hit_type)
		user.TakeDamage("head", 160, 0)
		return 1

/obj/item/crowbar/vr
	icon_state = "crowbar-vr"

/obj/item/crowbar/red
	name = "crowbar"
	desc = "A tool used as a lever to pry objects. This one appears to have been painted red as an indicator of its important emergency tool status, or maybe someone forgot to clean the blood off."
	icon_state = "crowbar-red"

/obj/item/crowbar/yellow
	desc = "A tool used as a lever to pry objects. This one's a nice lemon color."
	icon_state = "crowbar-yellow"




//--------------------------- Screwdrivers ------------------------------------------

/obj/item/screwdriver
	name = "screwdriver"
	desc = "A tool used to turn slotted screws and other slotted objects."
	icon = 'icons/obj/items/tools/tools.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "screwdriver"

	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	tool_flags = TOOL_SCREWING
	w_class = W_CLASS_TINY

	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	stamina_damage = 10
	stamina_cost = 5
	stamina_crit_chance = 30
	hit_type = DAMAGE_STAB
	hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'

	rand_pos = 8
	custom_suicide = 1

	New()
		..()
		BLOCK_SETUP(BLOCK_KNIFE)
		//src.setItemSpecial(/datum/item_special/jab)

	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] jams the screwdriver into [his_or_her(user)] eye over and over and over.</b></span>")
		take_bleeding_damage(user, null, 25, DAMAGE_STAB)
		user.TakeDamage("head", 160, 0)
		return 1

/obj/item/screwdriver/vr
	icon_state = "screwdriver-vr"
	item_state = "screwdriver"

/obj/item/screwdriver/yellow
	desc = "A tool used to turn slotted screws and other slotted objects. This one has a nice lemon color."
	icon_state = "screwdriver-yellow"
	item_state = "screwdriver-yellow"


//--------------------------- Wirecutters ------------------------------------------

/obj/item/wirecutters
	name = "wirecutters"
	desc = "A tool used to cut wires and bars of metal."
	icon = 'icons/obj/items/tools/tools.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "wirecutters"

	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	tool_flags = TOOL_SNIPPING
	w_class = W_CLASS_SMALL

	force = 6
	throw_speed = 2
	throw_range = 9
	hit_type = DAMAGE_STAB
	hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'
	m_amt = 80
	stamina_damage = 15
	stamina_cost = 10
	stamina_crit_chance = 30
	rand_pos = 8

	New()
		..()
		BLOCK_SETUP(BLOCK_KNIFE)

	attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
		if (!src.remove_bandage(M, user) && !snip_surgery(M, user))
			return ..()

	attack_self(mob/user as mob)
		var/fail_chance = 8
		if (!iscarbon(user))
			return
		if (user.bioHolder.HasEffect("clumsy"))
			fail_chance = 33
		if (iscluwne(user))
			fail_chance = 100
		if (prob(fail_chance))
			user.visible_message("<span class='alert'><b>[user.name]</b> accidentally cuts [himself_or_herself(user)] while fooling around with [src] and drops them!</span>")
			playsound(src.loc, "sound/impact_sounds/Flesh_Stab_1.ogg", 50, 1, -6)
			user.TakeDamage(user.zone_sel.selecting, 3, 0)
			take_bleeding_damage(user, user, 3, DAMAGE_CUT)
			user.drop_item()
			return
		else
			user.visible_message("<b>[user.name]</b> snips [src].")
			playsound(src.loc, "sound/items/Wirecutter.ogg", 50, 1, -6)
			sleep(0.3 SECONDS)
			playsound(src.loc, "sound/items/Wirecutter.ogg", 50, 1, -6)
		return

/obj/item/wirecutters/vr
	icon_state = "wirecutters-vr"
	item_state = "wirecutters"

/obj/item/wirecutters/yellow
	desc = "A tool used to cut wires and bars of metal. This pair has a yellow handle."
	icon_state = "wirecutters-yellow"
	item_state = "wirecutters-yellow"


//--------------------------- Wrenches ------------------------------------------

/obj/item/wrench
	name = "wrench"
	desc = "A tool used to apply torque to turn nuts and bolts."
	icon = 'icons/obj/items/tools/tools.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "wrench"

	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	tool_flags = TOOL_WRENCHING
	w_class = W_CLASS_SMALL

	force = 5
	throwforce = 7
	stamina_damage = 40
	stamina_cost = 14
	stamina_crit_chance = 15

	m_amt = 150
	rand_pos = 8

	New()
		..()
		BLOCK_SETUP(BLOCK_ROD)

/obj/item/wrench/gold
	name = "golden wrench"
	desc = "A generic wrench, but now with gold plating!"
	icon_state = "wrench-gold"
	item_state = "wrench"

/obj/item/wrench/monkey
	name = "monkey wrench"
	desc = "What the FUCK is that thing???"
	icon_state = "wrench-monkey"
	item_state = "wrench"

/obj/item/wrench/vr
	icon_state = "wrench-vr"
	item_state = "wrench"

/obj/item/wrench/battle //for nuke ops class
	name = "battle wrench"
	desc = "A heavy industrial wrench that packs a mean punch when used as a bludgeon. Can be applied to the Nuclear bomb to repair it in small increments."
	icon_state = "wrench-battle"
	item_state = "wrench-battle"
	force = 10
	stamina_damage = 35

/obj/item/wrench/yellow
	desc = "A tool used to apply torque to turn nuts and bolts. This one has a bright yellow handle."
	icon_state = "wrench-yellow"
	item_state = "wrench"


//--------------------------- Multitools ------------------------------------------

/obj/item/device/multitool
	name = "multitool"
	desc = "You can use this on airlocks or APCs to try to hack them without cutting wires."
	icon = 'icons/obj/items/tools/tools.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "multitool"

	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	tool_flags = TOOL_PULSING
	w_class = W_CLASS_SMALL

	force = 5
	throwforce = 5
	throw_range = 15
	throw_speed = 3

	m_amt = 50
	g_amt = 20
	mats = list("CRY-1", "CON-2")

	New()
		..()
		src.setItemSpecial(/datum/item_special/elecflash)

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] connects the wires from the multitool onto [his_or_her(user)] tongue and presses pulse. It's pretty shocking to look at.</b></span>")
		user.TakeDamage("head", 0, 160)
		return 1

/obj/item/device/multitool/afterattack(atom/target, mob/user , flag)
	//Get the NETID from bots/computers/everything else
	//There's a lot of local vars so this is somewhat evil code
	//Tried to keep it self contained, read only, and tried to do the appropriate checks
	var/net_id
	//And the wifi frequency
	var/frequency
	//Beacon and control frequencies for bots!
	var/control
	var/beacon
	//turf and data_terminal for powernet check
	var/turf/T = get_turf(target.loc)
	var/obj/machinery/power/data_terminal/test_link = locate() in T
	var/obj/item/implant/tracking/targetimplant = locate() in target.contents
	//net_id block, except computers, where we do it all in one go
	if (hasvar(target, "net_id"))
		net_id = target:net_id
	else if (hasvar(target, "botnet_id"))
		net_id = target:botnet_id
	else if (istype(target,/obj/machinery/computer3))
		var/obj/computer = target
		var/obj/item/peripheral/network/peripheral = locate(/obj/item/peripheral/network) in computer.contents
		var/obj/item/peripheral/network/radio/radioperipheral = locate(/obj/item/peripheral/network/radio) in computer.contents
		var/obj/item/peripheral/network/omni/omniperipheral = locate(/obj/item/peripheral/network/omni) in computer.contents
		if (peripheral)
			net_id = peripheral.net_id
		if (radioperipheral)
			frequency = radioperipheral.frequency
		//laptops are special too!
		if(omniperipheral)
			frequency = omniperipheral.frequency
	else if (targetimplant)
		net_id = targetimplant.net_id
		frequency = targetimplant.pda_alert_frequency

	//frequency block
	if (hasvar(target, "alarm_frequency"))
		frequency = target:alarm_frequency
	else if (hasvar(target, "freq"))
		frequency = target:freq
	else if (hasvar(target, "control_freq"))
		control = target:control_freq
		if (hasvar(target, "beacon_freq"))
			beacon = target:beacon_freq
	else if (hasvar(target, "radio_connection.frequency"))
		var/datum/radio_frequency/radiofreq = target:radio_connection
		frequency = radiofreq.frequency
	else if (hasvar(target, "frequency"))
		if(isnum(target:frequency) || istext(target:frequency))
			frequency = target:frequency
	//We'll do lockers safely since nothing else seems to store the frequency exactly like this
	else if (istype(target, /obj/storage/secure))
		var/obj/storage/secure/lockerfreq = target
		frequency = lockerfreq.radio_control.frequency

	if(net_id)
		boutput(user, "<span class='alert'>NETID#[net_id]</span>")
	if(frequency)
		boutput(user, "<span class='alert'>FREQ#[frequency]</span>")
	if(control)
		boutput(user, "<span class='alert'>CTRLFREQ#[control]</span>")
	if(beacon)
		boutput(user, "<span class='alert'>BCKNFREQ#[beacon]</span>")
	//Powernet Test Block
	//If we have a net_id but no wireless frequency, we're probably a powernet device
	if(isturf(T) && net_id && !frequency)
		if(!test_link || !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
			boutput(user, "<span class='alert'>ERR#NOLINK</span>")
	if (test_link)
		if (length(test_link.powernet.cables) < 1)
			boutput(user, "<span class='alert'>ERR#NOTATERM</span>")


//--------------------------- Please Hammer Don't Hurt 'Em (1990) ------------------------------------------
//
/obj/item/hammer
	name = "hammer"
	desc = "Used by carpenters and moral philosophers alike."
	//a better place than one of the worn exosuit dmis it used to be in, but I don't want to do more of every tool getting a dmi for 4 sprites
	//Like I should merge all these tiny files into one.
	icon = 'icons/obj/items/tools/tools.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "hammer"

	//Idea: move a good deal of those carpenter/engineering trait checks into checks for holding a hammer.
	tool_flags = TOOL_HAMMERING
	force = 10 //It's a hammer
	throwforce = 10

	afterattack(atom/target, mob/user, reach, params)
		if (ismob(target))
			user.add_karma(0.1)
		..()


//--------------------------- Handsaw ------------------------------------------
//no plans, but we have the sprites so
/obj/item/handsaw
	name = "handsaw"
	desc = "In the unlikely event you're beset by space wood."
	icon = 'icons/obj/items/tools/tools.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "handsaw"

	tool_flags = TOOL_SAWING
	force = 4 //despite being sharp I can't imagine it being an easy thing to maim someone with, no hard opinion though.
	throwforce = 5
	hit_type = DAMAGE_CUT

