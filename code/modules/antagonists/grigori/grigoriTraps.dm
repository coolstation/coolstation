/obj/item/device/grigori_trap_hand
	name = "inhand grigori trap"
	icon_state = "placeholder"
	var/trigger_type = "door_touch"
	var/armed = FALSE
	var/trap_type = null
	flags = USEDELAY
	w_class = W_CLASS_BULKY
	item_state = "placeholder"
	desc = "abstract trap. Hand? !!!"



	attack_self(var/mob/user as mob)
		if(src.armed)
			boutput(user, "<span class='alert'>You disarm the [src.name]</span>")
			src.disarm(user)
		else
			boutput(user, "<span class='alert'>You arm the [src.name]. Click on a [trigger_type] to set the trap.</span>") //probably need an associated list to have proper instructions (ie, door_touch = door, door_enter = door usw.)
			src.arm(user)

	afterattack(var/atom/target, var/mob/user as mob)
		if(!src.armed)
			boutput(user, "<span class='alert'>The trap isn't armed!</span>")
			return

		switch(src.trigger_type)
			if ("door_touch")
				if(!istype(target,/obj/machinery/door))
					boutput(user, "<span class='alert'>This trap can't fit here.</span>")
					return 0
			else
				boutput(user, "<span class='alert'>This trap can't fit here.</span>") //be more descriptive later
				return 0
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
	name = "hidden door blade trap"
	icon_state = "placeholder"
	item_state = "placeholder"
	trap_type = /datum/grigori_trap/chopper
	desc = "A hidden blade that can be fastened to a door. When a victim tries to open the door, a blade will come from the door and chop a random limb off."

/datum/grigori_trap
	var/obj/linked_obj
	var/list/tomtech = list("DAAAAAAA!!!!!","YEEEEOOOOOWCH!","AAAAAAAAAHHH!!!","rraaaAAAAAAAAA!!!!!","OOOOOOOOWWWWIIIIEEE!!!") //load bearing
	var/list/disarm_steps_range = list(1,4) //are vector2s a thing in dm? idk
	var/list/disarm_tools = list(TOOL_SNIPPING,TOOL_SCREWING,TOOL_WRENCHING)

	var/disarm_hint
	var/list/disarm_steps = list()

	New(var/obj/target,var/trigger_type)
		..()
		linked_obj = target
		target.linked_trap = src
		target.isTrapped = 1
		var/i = rand(disarm_steps_range[1],disarm_steps_range[2])
		for(var/j = 1, j <= i, j++)
			disarm_steps += list(pick(disarm_tools)) //generates a random list of disarm steps to make disarming traps annoying and dangerous
		src.apply_disarm_hint()
		switch(trigger_type)
			if("door_touch")
				AddComponent(/datum/component/activate_trap_on_door_touch,linked_obj,src)

	proc/trap_triggered(var/mob/target,var/isAttacked)
		if(isAttacked)
			return disarm_step(target, target.equipped())

			//boutput(world, "<b>DEBUG: ran through</b>")

	proc/disarm_step(var/mob/user, var/obj/item/tool)
		//boutput(world, "<b>DEBUG: entered disarm_step, T:[tool.name]</b>")
		if(!tool || !tool.tool_flags)
			//boutput(world, "<b>DEBUG: exit at first check</b>")
			return 0

		if(tool.tool_flags & disarm_steps[1])
			//right tool, handle checks and progress bar
			if(prob(90)) //make engineers have a higher chance of doing this, clumsy people lower
				disarm_steps.Remove(disarm_steps[1])
				if(!length(disarm_steps))
					src.trap_disarmed(user, tool)
				else
					src.apply_disarm_hint()
				return 1
				//user feedback
			else
				boutput(user, "<span class='alert'>You slip while trying to disarm the trap! <b>OH SHIT!</b></span>")
				//have like, a screwdriver slipping sound or something
				sleep(0.6 SECONDS) //give them a moment to realize they fucked up
				return 0
		else
			boutput(user, "<span class='alert'>Wait a second... that wasn't the right tool! <b>OH SHIT!</b></span>")
			//do some sort of sound
			sleep(0.6 SECONDS) //give them a moment to realize they fucked up
			return 0
		//boutput(world, "<b>DEBUG: runs through</b>")

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
	var/list/choppableBits = list("r_arm","l_arm","r_leg","l_leg") //non-lethal!
	//run a check to see what limbs the target has, prune missing ones from the list. Makes our life easier
	trap_triggered(var/mob/target,var/isAttacked)
		if(..()) //is this awful?
			return 0
		var/mob/living/carbon/human/H
		if(istype(target, /mob/living/carbon/human))
			H = target
			if(H.organHolder?.tail)
				choppableBits.Add("tail")
			var/targetedLimb = pick(choppableBits) //whatever

			if(targetedLimb == "tail")
				H.drop_and_throw_organ("tail",dist=3,speed=1)
			else
				H.sever_limb(targetedLimb)
		else
			//do flat damage ig
			boutput(world,"<b>you triggered it pal</b>") //debug
			//lol what if we checked specifically for beepsky and made him detonate
			return
		//call animation here
		//play sound here

		playsound(target, pick("sound/impact_sounds/Flesh_Stab_3.ogg","sound/impact_sounds/Flesh_Cut_1.ogg"), 75,4)
		boutput(target, "<span class='alert'><B>[pick(src.tomtech)]</B></span>")
		qdel(src) //move this to a special destroy proc or whatever, throw defusals in there too why not
		//do random chopping code here - have the trap be layerd ontop of whatever machine, and the linked object passes interactions from attackby to a proc here if the trap is present



// PROGRESS BARS
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
		logTheThing("station", owner, null, "sets trap: [trap.name] at loc: [target.loc] of type: [trap.trigger_type],[trap.trap_type]")
