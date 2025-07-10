//this handles basically all of the grigori trap stuff, except for the components, which are in grigoritraps.dm (i know, sue me. It's with the rest of the components)


/*
================================================================================================
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ TRAP ITEMS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
================================================================================================
*/

/obj/item/device/grigori_trap_hand
	name = "inhand grigori trap"
	icon_state = "placeholder"
	var/obj/item/device/grigori_trigger/trigger_type
	var/armed = FALSE
	var/trap_type = null

	//var/list/valid_triggers = list("door_touch","computer_touch","chair_sit","switch_flick") //we're doing too many switches and defining these too many times, a central list would be helpful

	flags = USEDELAY
	w_class = W_CLASS_BULKY
	item_state = "placeholder"
	desc = "abstract trap. Hand? !!!"

	New()
		..()
		trigger_type = new /obj/item/device/grigori_trigger

	attack_self(var/mob/user as mob)
		if(src.armed)
			boutput(user, "<span class='alert'>You disarm the [src.name]</span>")
			src.disarm(user)
		else
			boutput(user, "<span class='alert'>You arm the [src.name]. [src.trigger_type?.trigger_desc]</span>") //probably need an associated list to have proper instructions (ie, door_touch = door, door_enter = door usw.)
			src.arm(user)

	attackby(obj/item/W, mob/user)
		if(istype(W,/obj/item/device/grigori_trigger))
			if(!trigger_type?.name == "null trigger")
				var/obj/item/device/grigori_trigger/dropped = new trigger_type
				user.put_in_hand_or_drop(dropped)
			trigger_type = W
			playsound(user, "sound/items/Screwdriver.ogg",50,4)
			boutput(user, "<span class='alert'>You attach the [W.name] to the [src.name]. [trigger_type.trigger_desc]</span>")
			qdel(W)

	afterattack(var/atom/target, var/mob/user as mob)
		if(!src.armed)
			boutput(user, "<span class='alert'>The trap isn't armed!</span>")
			return
		if(trigger_type.check_deploy(target, user))
			actions.start(new/datum/action/bar/icon/grigori_trap_place(src, target),user)


	proc/arm(var/mob/user)
		//play some sounds, animate the icon, mark armed to true
		playsound(user, "sound/effects/sword_unsheath2.ogg",50,4)
		src.armed = TRUE

	proc/disarm(var/mob/user)
		//play some sounds, animate the icon, mark armed to false
		playsound(user, "sound/effects/sword_unsheath1.ogg",50,4) //we could use better sounds for this

		src.armed = FALSE

	proc/deploy(var/obj/target, var/mob/user)
		new src.trap_type(target,trigger_type)

		boutput(user, "<span class='alert'>You set the trap on the [target.name].</span>")
		playsound(user, "sound/items/Screwdriver.ogg",50,4)
		//animations and sounds here
		qdel(src)


/obj/item/device/grigori_trap_hand/chopper //a blade cuts a random limb off
	name = "hidden blade trap"
	icon_state = "placeholder"
	item_state = "placeholder"
	trap_type = /datum/grigori_trap/chopper
	desc = "A hidden blade trap that takes a limb from its target when they set off the trigger."


/*
===================================================================================================
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ TRIGGER ITEMS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
===================================================================================================
*/
//the plan is to make grigoris able to create triggers out of random items via their ability holder

/obj/item/device/grigori_trigger
	name = "null trigger"
	icon_state = "placeholder"
	item_state = "placeholder"
	desc = "abstract trigger, how did you get this"

	var/trigger_desc = "This trap does not have a trigger set yet. Hit it with a trigger to set the trigger type."

	w_class = W_CLASS_SMALL

	proc/check_deploy(var/atom/target, var/mob/user as mob)
		if (istype(src,/obj/item/device/grigori_trigger/door_touch))
			if(istype(target,/obj/machinery/door))
				return 1

		else if(istype(src,/obj/item/device/grigori_trigger/computer_touch))
			if(istype(target,/obj/machinery/computer))
				return 1

		else if(istype(src,/obj/item/device/grigori_trigger/chair_sit))
			if(istype(target,/obj/stool/chair))
				return 1

		else if(istype(src,/obj/item/device/grigori_trigger/switch_flick))
			if(istype(target,/obj/machinery/light_switch) && !istype(target,/obj/machinery/conveyor_switch) && !istype(target,/obj/machinery/ignition_switch))
				return 1

		else if(src.name == "null trigger")
			boutput(user, "<span class='alert'>This trap has no trigger set.</span>")
			return 0

		boutput(user, "<span class='alert'>This trap can't fit here.</span>")
		return 0

	proc/set_component(var/mob/user)
		boutput(user,"<span class='alert'>This trap is broken. Bug report this</span>")
		return 0

/obj/item/device/grigori_trigger/door_touch
	name = "door trap trigger"
	desc = "Attach this trigger to a trap to make it able to be placed on doors."
	trigger_desc = "This trap can be attached to any door, and is sprung when someone tries to open it."

	set_component(var/obj/linked_obj,var/datum/grigori_trap/trap)
		trap.AddComponent(/datum/component/activate_trap_on_door_touch,linked_obj,trap)
		return 1

/obj/item/device/grigori_trigger/computer_touch
	name = "computer trap trigger"
	desc = "Attach this trigger to a trap to make it able to be placed on computers."
	trigger_desc = "This trap can be attached to any computer, and is sprung when someone interacts with it."

	set_component(var/obj/linked_obj,var/datum/grigori_trap/trap)
		trap.AddComponent(/datum/component/activate_trap_on_computer_touch,linked_obj,trap)
		return 1

/obj/item/device/grigori_trigger/chair_sit
	name = "chair trap trigger"
	desc = "Attach this trigger to a trap to make it able to be set on chairs."
	trigger_desc = "This trap can be attached to a chair with a back, and is sprung when someone buckles into it."

	set_component(var/obj/linked_obj,var/datum/grigori_trap/trap)
		trap.AddComponent(/datum/component/activate_trap_on_chair_buckle,linked_obj,trap)
		return 1

/obj/item/device/grigori_trigger/switch_flick
	name = "switch trap trigger"
	desc = "Attach this trigger to a trap to make it able to be set on switches."
	trigger_desc = "This trap can be attached to a switch, and is sprung when someone flips it."

	set_component(var/obj/linked_obj,var/datum/grigori_trap/trap)
		trap.AddComponent(/datum/component/activate_trap_on_door_touch,linked_obj,trap)
		return 1




/*
=================================================================================================
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ TRAP DATUMS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=================================================================================================
*/



/datum/grigori_trap
	var/obj/linked_obj
	var/list/tomtech = list("DAAAAAAA!!!!!","YEEEEOOOOOWCH!","AAAAAAAAAHHH!!!","rraaaAAAAAAAAA!!!!!","OOOOOOOOWWWWIIIIEEE!!!") //load bearing
	var/list/disarm_steps_range = list(1,4) //are vector2s a thing in dm? idk
	var/list/disarm_tools = list(TOOL_SNIPPING,TOOL_SCREWING,TOOL_WRENCHING)


	var/disarm_hint
	var/list/disarm_steps = list()

	New(var/obj/target,var/obj/item/device/grigori_trigger/trigger_type)
		..()
		linked_obj = target
		target.linked_trap = src
		target.isTrapped = 1
		var/i = rand(disarm_steps_range[1],disarm_steps_range[2])
		for(var/j = 1, j <= i, j++)
			disarm_steps += list(pick(disarm_tools)) //generates a random list of disarm steps to make disarming traps annoying and dangerous
		src.apply_disarm_hint()

		if(!trigger_type.set_component(target,src))
			boutput(world,"<B>DEBUG: why the fuck is the trap qdelling</B>")
			qdel(src)

	proc/trap_triggered(var/mob/target)
		if(!target)
			return 0

	proc/attempt_disarm(var/mob/user,var/obj/item/tool)
		if(!tool || !tool.tool_flags)
			trap_triggered(user)

		if(tool.tool_flags & disarm_steps[1])
			actions.start(new/datum/action/bar/private/icon/grigori_trap_disarm(src,src.linked_obj,tool),user)
		else
			trap_triggered(user)

	proc/trap_disarmed(var/mob/user,var/obj/item/tool)
		qdel(src)
		//handle more feedback here

	disposing()
		linked_obj.isTrapped = 0
		linked_obj.linked_trap = null
		..()

	proc/apply_disarm_hint()
		var/list/starters = list("It looks like this trap ","You think this trap ","This trap ", "The voices tell you this trap ", "You pray that this trap ")
		var/list/middle = list()
		var/list/enders = list("to be disarmed.","to be safely disarmed.","to be unsafely disarmed","to maybe disarm it","to hopefully disarm it.")
		if(!disarm_steps[1])
			return
		if(disarm_steps[1] & TOOL_SNIPPING)
			middle = list("needs to be snipped ","needs to be cut ","needs to be precisely cut ","needs to have scissor blades jammed into it ")
			//snip desc
		else if(disarm_steps[1] & TOOL_SCREWING)
			middle = list("needs to be screwed ","needs a screwdriver ","needs to have the screws loosened ")
			//screw desc (18+)
		else if(disarm_steps[1] & TOOL_WRENCHING)
			middle = list("needs a good wrenching ", "has to be loosened with a wrench ", "needs a good whack or two from a wrench ", "needs to be wrenched ")
			//wrench desc
		src.disarm_hint = "[pick(starters)][pick(middle)][pick(enders)]"


/datum/grigori_trap/chopper //this'll take an arm off! maybe even a leg!
	var/list/choppableBits = list("r_arm","l_arm","r_leg","l_leg","tail") //non-lethal!
	trap_triggered(var/mob/target,var/isAttacked)
		if(..()) //is this awful?
			return 0

		var/mob/living/carbon/human/H
		if(istype(target, /mob/living/carbon/human))
			H = target
			if(!H.organHolder?.tail)
				choppableBits.Remove("tail")
			if(!H.limbs.r_arm)
				choppableBits.Remove("r_arm")
			if(!H.limbs.l_arm)
				choppableBits.Remove("l_arm")
			if(!H.limbs.r_leg)
				choppableBits.Remove("r_leg")
			if(!H.limbs.l_leg)
				choppableBits.Remove("l_leg")
			var/targetedLimb = pick(choppableBits)

			if(targetedLimb == "tail")
				H.drop_and_throw_organ("tail",dist=3,speed=1)
			else
				H.sever_limb(targetedLimb)
			target.TakeDamage("chest",30,0,0,DAMAGE_CUT,0)
		else
			target.TakeDamage("All",50,0,0,DAMAGE_CUT,0)
		if(target.buckled)
			target.buckled.unbuckle()

		//call animation here
		//play sound here

		playsound(target, pick("sound/impact_sounds/Flesh_Stab_3.ogg","sound/impact_sounds/Flesh_Cut_1.ogg"), 75,4)
		boutput(target, "<span class='alert'><B>[pick(src.tomtech)]</B></span>")
		qdel(src)

/*
=================================================================================================
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ACTION BARS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
=================================================================================================
*/
/datum/action/bar/icon/grigori_trap_place //when a grigori places a trap somewhere
	duration = 35
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	//icon should be the grigori trap
	var/obj/item/device/grigori_trap_hand/trap
	var/atom/target

	New(var/obj/item/device/grigori_trap_hand/t,var/atom/ta)
		..()
		trap = t
		target = ta

	onUpdate()
		..()
		if(get_dist(owner, target) > 1 || trap == null || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if(trap != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		playsound(owner, "sound/items/Screwdriver.ogg",55,4)
		owner.visible_message("<span class='notice'>[owner] is rigging something to [target]!</span>")

	onEnd()
		..()
		owner.visible_message("<span class='notice'>[owner] fits something to [target]!</span>")
		trap.deploy(target,owner)
		logTheThing("station", owner, null, "sets trap: [trap.name] at loc: [target.loc] of type: [trap.trigger_type.name],[trap.trap_type]")

/datum/action/bar/private/icon/grigori_trap_disarm
	duration = 15
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	var/datum/grigori_trap/trap
	var/atom/linked
	var/obj/item/tool
	var/sound/toolsound

	New(var/datum/grigori_trap/t,var/atom/a,var/obj/item/tt)
		..()
		trap = t
		linked = a
		tool = tt
		if(tt.tool_flags & TOOL_WRENCHING)
			toolsound = "sound/items/Ratchet.ogg"
		else if(tt.tool_flags & TOOL_SCREWING)
			toolsound = "sound/items/Screwdriver.ogg"
		else if(tt.tool_flags & TOOL_SNIPPING)
			toolsound = "sound/items/Wirecutter.ogg"

	onUpdate()
		..()
		if(get_dist(owner, linked) > 1 || trap == null || linked == null || owner == null || tool == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if(tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		playsound(owner, toolsound, 50,4)
		boutput(owner, "<span class='alert'>You start to disarm the trap...</span>")

	onEnd()
		..()
		if(prob(90)) //remember to check for engi training
			trap.disarm_steps.Remove(trap.disarm_steps[1])
			if(!length(trap.disarm_steps))
				trap.trap_disarmed(owner, tool)
			else
				trap.apply_disarm_hint()
		else
			boutput(owner, "<span class='alert'>Wait.. that wasn't right! <b>OH FUCK!</b></span>")
			//broken thing sound
			sleep(0.6 SECONDS) //give them a moment to realize they fucked up
			trap.trap_triggered(owner)

	onInterrupt()
		boutput(owner, "<span class='alert'>You slip while trying to disarm the trap! <b>OH SHIT!</b></span>")
		//have like, a screwdriver slipping sound or something
		trap.trap_triggered(owner)
		..()

