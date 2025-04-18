/obj/item/proc/dbg_itemspecial()
	set name = "Give Special"
	var/sel = input(usr,"Type:","Select type") in childrentypesof(/datum/item_special)
	src.max_stack = INFINITY
	src.amount = INFINITY
	src.setItemSpecial(sel)
	return

/datum/limb/proc/dbg_itemspecial()
	var/sel = input(usr,"Type:","Select type for Disarm:") in childrentypesof(/datum/item_special)
	src.setDisarmSpecial(sel)
	sel = input(usr,"Type:","Select type for Harm:") in childrentypesof(/datum/item_special)
	src.setHarmSpecial(sel)

/proc/get_dir_alt(var/atom/source, var/atom/target) //Opposite of default get dir, only returns diagonal if target perfectly diagonal
	if(abs(source.x-target.x) > abs(source.y-target.y)) //Mostly left/right with a little up or down
		if(source.x > target.x) //Target left
			return WEST
		else if (source.x < target.x) //Target right
			return EAST
	else if (abs(source.x-target.x) < abs(source.y-target.y)) //Mostly up/down with a little left right
		if(source.y > target.y) //Target below
			return SOUTH
		else if (source.y < target.y) //Target above
			return NORTH
	else if (abs(source.x-target.x) == abs(source.y-target.y)) //Perfectly diagonal
		if(source.x > target.x) //Target left
			if(source.y > target.y) //Target below
				return SOUTHWEST
			else if (source.y < target.y) //Target above
				return NORTHWEST
		else if (source.x < target.x) //Target right
			if(source.y > target.y) //Target below
				return SOUTHEAST
			else if (source.y < target.y) //Target above
				return NORTHEAST
	return NORTH

/proc/get_dir_pixel(var/atom/source, var/atom/target, params) //Get_dir using pixel coordinates of mouse
	var/dx = (target.x - source.x) * 32
	var/dy = (target.y - source.y) * 32

	if (!islist(params))
		params = params2list(params)

	if(params["icon-x"])
		dx += (text2num(params["icon-x"]) - 16)

	if(params["icon-y"])
		dy += (text2num(params["icon-y"]) - 16)

	var/angle = arctan(dy,dx)
	//boutput(world, "[dx] : [dy] ::: makes for [angle]")

	//oh no ! i'm bad!!!!!!!!!!!
	//note that the diagonals have a slightly smaller click area than cardinals.
	if (angle >= 0)
		if (angle < 25)
			return NORTH
		else if (angle <= 65)
			return NORTHEAST
		else if (angle < 115)
			return EAST
		else if (angle <= 155)
			return SOUTHEAST
		else
			return SOUTH
	else if (angle < 0)
		if (angle > -25)
			return NORTH
		else if (angle >= -65)
			return NORTHWEST
		else if (angle > -115)
			return WEST
		else if (angle >= -155)
			return SOUTHWEST
		else
			return SOUTH

	return NORTH




#define ITEMSPECIAL_PIXELDIST_SQUARED  (70 * 70) //lol i'm putting the define RIGHT HERE.
// These two numbers will be compared later (pixeldist squared AND the result of this function). We don't need to do unnessecary sqrt cause this is just a simple < > comparison!
/proc/get_dist_pixel_squared(var/atom/source, var/atom/target, params)
	var/dx = (target.x - source.x) * 32
	var/dy = (target.y - source.y) * 32

	if (!islist(params))
		params = params2list(params)

	if(params["icon-x"])
		dx += (text2num(params["icon-x"]) - 16)

	if(params["icon-y"])
		dy += (text2num(params["icon-y"]) - 16)

	return ((dx*dx) + (dy*dy))

#define WYSIWYG_SPECIAL_SCALE 1 // at 0, this means you can be hit by a special through your entire movement. at 1, 50%, at 2, 33%, and so on. Raise if specials feel too good across the board
/// Finds every mob that is currently moving away from a turf, but has not reached the end of their movement.
/proc/atoms_in_combat_range(var/turf/target)
	var/list/atom/atoms = list()
	for(var/atom/A in target)
		atoms += A
	if(whatcha_see_is_whatcha_get)
		for(var/mob/dude in range(1,target))
			if (dude.next_move > ((world.time + dude.next_move * WYSIWYG_SPECIAL_SCALE) / (1 + WYSIWYG_SPECIAL_SCALE) ) && dude.prev_loc == target)
				atoms |= dude

	return atoms
#undef WYSIWYG_SPECIAL_SCALE

//Handles setup for specials and adds / removes them from items.
/obj/item/proc/setItemSpecial(var/type = null)
	if(!ispath(type))
		if(isnull(type))
			src.special?.onRemove()
			src.special = null
		return null

	src.special?.onRemove()

	var/datum/item_special/S = new type
	S.master = src
	S.onAdd()
	src.special = S
	return S

/datum/limb/proc/setDisarmSpecial(var/type = null)
	if(!ispath(type))
		if(isnull(type))
			src.disarm_special?.onRemove()
			src.disarm_special = null
		return null

	src.disarm_special?.onRemove()

	src.disarm_special = new type
	src.disarm_special.onAdd()
	return src.disarm_special

/datum/limb/proc/setHarmSpecial(var/type = null)
	if(!ispath(type))
		if(isnull(type))
			src.harm_special?.onRemove()
			src.harm_special = null
		return null

	src.harm_special?.onRemove()

	src.harm_special = new type
	src.harm_special.onAdd()
	return src.harm_special


//This needs to happen in process_move(), not Move() so we can change the delay modifier before it is put to use
/mob/living/process_move(keys)
	if (apply_movement_delay_until != -1)
		if (apply_movement_delay_until >= world.time)
			//Don't pick a delay modifier that will exceed the bounds of our delay apply window
			movement_delay_modifier = min(movement_delay_modifier, (apply_movement_delay_until - world.time))
	return ..(keys)

/datum/item_special/dummy //These don't do anything and are simply used for the tooltip. Used when the special is implemented in another way. Hacky and ugly.
	getDesc()
		return desc	+ "<br>"
	usable()
		return 0


/datum/item_special
	var/obj/item/master = null //Item that owns this attack
	var/last_use = 0				//Last world.time this was used.

	var/cooldown = 20			//Cooldown time of attack
	var/moveDelay = 10		//Slow movement by this much after attack
	var/moveDelayDuration = 10 //Slow for this long (in BYOND time)
	var/restrainDuration = 0 //time in 1/10th seconds during which we are held in place following an attack

	var/overrideCrit = 0 //Temporarily switch item to this crit chance during attacks. (if not -1/negative)
	var/overrideStaminaDamage = -1 //Temporarily set item stamina damage to this during attacks (if not -1/negative)

	var/image = "whirlwind"
	var/name = "Whirlwind"
	var/desc = ""
	var/prefix = "" //optional prefix this might apply to some crafted items.

	var/damageMult = 1

	var/animation_color

	var/manualTriggerOnly = 0 //If 1, the special will not trigger from normal "out of melee range" clicks but has to be triggered manually from somewhere.
							  //This means none of the mouse procs or pixelaction will be called.

	proc/onAdd() //Called when added to an item.
		return

	proc/onRemove() //Called when removed from an item.
		src.master = null
		return

	proc/getDesc()
		var/infoStr = "[round(cooldown/10, 0.1)]s CD<br>"
		return infoStr + desc

	proc/onMouseDrag(src_object,atom/over_object,src_location,over_location,src_control,over_control,params)
		return

	proc/onMouseDown(atom/target,location,control,params)
		return

	proc/onMouseUp(atom/target,location,control,params)
		return

	proc/pixelaction(atom/target, params, mob/user, reach)
		return

	//move to define probably?
	proc/isTarget(var/atom/A, var/mob/user = null)
		if (istype(A, /obj/itemspecialeffect))
			var/obj/itemspecialeffect/E = A
			return (E.can_clash && world.time != E.create_time && E.clash_time > 0 && world.time <= E.create_time + E.clash_time)
		.= ((istype(A, /obj/critter) || (ismob(A) && isliving(A))) && A != usr && A != user)

	proc/showEffect(var/name = null, var/direction = NORTH, var/mob/user, alpha=255)
		if(name == null || master == null) return
		if(!user) user = usr
		var/obj/itemspecialeffect/E = new()
		if(src.animation_color)
			E.color = src.animation_color
		E.alpha = alpha
		E.setup(get_turf(user))
		E.set_dir(direction)
		E.icon_state = name

	proc/usable(var/mob/user)
		if (!user) user = usr

		if(world.time < (last_use + cooldown))
			return 0

		if(user.a_intent == "help" || user.a_intent == "grab")
			if(!(user.equipped() && (user.equipped().item_function_flags & USE_SPECIALS_ON_ALL_INTENTS)))
				return 0

		if (user.check_block())
			return 0

		if (!istype(user.loc, /turf))
			return 0

		return 1

	//Should be called before attacks begin. Make sure you call this when appropriate in your mouse procs etc.
	//MBC : Removed Damage/Stamina modifications from preUse() and afterUse() and moved their to item.attack() to avoid race condition
	proc/preUse(var/mob/person)
		SHOULD_CALL_PARENT(1)
		if(moveDelayDuration && moveDelay)
			SPAWN_DBG(0)
				person.movement_delay_modifier += moveDelay
				person.apply_movement_delay_until = world.time + moveDelayDuration //handle move() started mid-delay
				sleep(moveDelayDuration)
				person.movement_delay_modifier = 0
				person.apply_movement_delay_until = -1
		last_use = world.time

	//Should be called after everything is done and all attacks are finished. Make sure you call this when appropriate in your mouse procs etc.
	proc/afterUse(var/mob/person)
		SHOULD_CALL_PARENT(1)
		if(master)
			SEND_SIGNAL(master, COMSIG_ITEM_SPECIAL_POST, person)
		if(restrainDuration)
			person.restrain_time = TIME + restrainDuration

	//For using the result of the attack to determine fancy behavior
	proc/modify_attack_result(var/mob/user, var/mob/target, var/datum/attackResults/msgs)
		return msgs

	rush
		cooldown = 20
		image = "rush"
		name = "Rush"
		desc = "Click once to charge, click again to rush."
		var/maxRange = 15
		var/move_delay = 0.1 SECONDS
		var/starting_progress = 0
		damageMult = 2

		var/datum/action/bar/private/icon/rush/action = null

		onMouseUp(atom/target,location,control,params)
			if(!target)
				return
			var/list/parameters = params2list(params)
			if(parameters["left"])
				if(action)
					if (target)
						action.target = target
					action.params = params
					action.state = ACTIONSTATE_FINISH
				else
					if(!isturf(target.loc) && !isturf(target)) return
					if(!usable()) return
					if(master && get_dist_pixel_squared(usr, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
						action = new(src, usr, target)
						action.params = params
						actions.start(action, usr)
			return

		proc/rush(mob/user, atom/target, progress, params)
			preUse(user)
			user.pass_through_mobs = TRUE
			action = null
			src.cooldown = round(max(10, initial(src.cooldown) * progress))

			var/turf/lastTurf = get_turf(user)

			SPAWN_DBG(0)
				for(var/i=0, i < max(1,round(maxRange * progress)), i++)

					var/direction = get_dir_pixel(user, target, params)
					var/list/attacked = list()
					var/blurX = 0
					var/blurY = 0

					switch(direction)
						if(NORTH)
							blurY = 10
						if(SOUTH)
							blurY = -10
						if(EAST)
							blurX = 10
						if(WEST)
							blurX = -10
						if(NORTHEAST)
							blurX = 10
							blurY = 10
						if(SOUTHEAST)
							blurY = -10
							blurX = 10
						if(SOUTHWEST)
							blurY = -10
							blurX = -10
						if(NORTHWEST)
							blurY = 10
							blurX = -10

					sleep(move_delay)

					step(user, direction)
					user.set_dir(direction)
					src.onStep(user)
					var/newTurf = get_turf(user)

					if(newTurf == lastTurf)
						break

					lastTurf = newTurf

					var/obj/itemspecialeffect/glitter/E = new()
					E.setup(user.loc)
					E.filters = filter(type="motion_blur", x=blurX, y=blurY)

					animate(E, alpha=255,time=0,loop=0)
					animate(alpha=0,pixel_x=((blurX*(-1))*3),pixel_y=((blurY*(-1))*3), time=(15+(i*3)),loop=0)

					var/hit = 0
					for(var/atom/A in atoms_in_combat_range(lastTurf))
						if(A in attacked) continue
						if(isTarget(A, user) && A != user)
							A.Attackby(master, user, params, 1)
							attacked += A
							hit = 1
							src.onHit(A, user)

					if(hit)
						var/obj/itemspecialeffect/rushhit/R = new()
						R.setup(user.loc)

					if(newTurf == get_turf(target))
						break


				if(user)
					user.pass_through_mobs = FALSE
			afterUse(user)
			playsound(master, 'sound/effects/sprint_puff.ogg', 60, 0)
			return

		proc/onHit(atom/target, mob/user)
			return

		proc/onStep(mob/user)
			return

		basketball
			maxRange = 8
			move_delay = 0.3 SECONDS
			starting_progress = 0.6
			name = "Ball On 'Em"
			desc = "Click once to shuffle, click again to ball on the competition."

			onHit(atom/target, mob/user)
				..()
				animate(user, time = 0.1 SECONDS, pixel_y = user.pixel_y + 22)
				animate(time = 0.2 SECONDS, pixel_y = user.pixel_y - 22)

	throwing
		cooldown = 10
		moveDelay = 0
		moveDelayDuration = 0
		overrideCrit = -1

		image = "throw"
		name = "Throw"
		desc = "Throw one of your weapons."
		onMouseUp(atom/target,location,control,params)
			if(!usable()) return
			if(!isturf(target.loc) && !isturf(target)) return
			var/list/parameters = params2list(params)
			if(parameters["left"] && master && get_dist_pixel_squared(usr, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
				var/obj/item/copy = master.split_stack(1)
				if(copy)
					preUse(usr)
					var/atom/step = get_step(usr, get_dir_pixel(usr, target, params))
					copy.set_loc(step)
					copy.throw_at(target, 20, 3, params)
					afterUse(usr)
					playsound(master, 'sound/effects/swoosh.ogg', 50, 0)
			return

	simple
		cooldown = 0
		moveDelay = 0//5
		moveDelayDuration = 0//4
		damageMult = 1

		image = "simple"
		name = "Attack"
		desc = "Attack in direction. No crits."
		var/directional = FALSE
		var/obj/itemspecialeffect/specialEffect = /obj/itemspecialeffect/simple

		onAdd()
			if(master)
				overrideStaminaDamage = master.stamina_damage * 1
			return

		pixelaction(atom/target, params, mob/user, reach)
			if(!isturf(target.loc) && !isturf(target)) return
			if(!usable(user)) return
			if(params["left"] && master && get_dist_pixel_squared(user, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
				preUse(user)
				var/direction = get_dir_pixel(user, target, params)
				var/turf/turf = get_step(master, direction)

				var/obj/itemspecialeffect/simple/S = new specialEffect
				if(src.animation_color)
					S.color = src.animation_color
				if(directional)
					S.set_dir(direction)
				S.setup(turf)

				var/hit = 0
				for(var/atom/A in atoms_in_combat_range(turf))
					if(isTarget(A))
						A.Attackby(master, user, params, 1)
						hit = 1
						break

				afterUse(user)

				if (!hit)
					playsound(master, 'sound/effects/swoosh.ogg', 50, 0)
			return

		kendo_light
			name = "Light Attack"
			desc = "A weak, but fast and economic attack."
			animation_color = "#a3774d"

		kendo_heavy
			name = "Heavy Attack"
			desc = "A powerful, but slow and draining attack."
			moveDelay = 5
			moveDelayDuration = 5
			animation_color = "#a3774d"

	jab
		cooldown = 2 SECONDS
		moveDelay = 5
		moveDelayDuration = 4
		damageMult = 0.75
		overrideCrit = 0 // no crits, prevent insane bleeds

		image = "jab"
		name = "Jab"
		desc = "Quickly jab in a direction. Lowers cooldown massively on a successful hit."

		//cooldown on successful hit
		//with a 75% damage mult this is ~1.9x bonus, but will be massively bumped down by even a little bit of armor
		var/success_cooldown = 4 DECI SECONDS

		onAdd()
			if(master)
				overrideStaminaDamage = master.stamina_damage * 0.4
			return

		pixelaction(atom/target, params, mob/user, reach)
			if(!isturf(target.loc) && !isturf(target)) return
			if(!usable(user)) return
			if(params["left"] && master && get_dist_pixel_squared(user, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
				preUse(user)
				var/direction = get_dir_pixel(user, target, params)
				var/turf/turf = get_step(master, direction)

				var/obj/itemspecialeffect/jab/effect = new /obj/itemspecialeffect/jab
				effect.set_dir(direction)
				effect.setup(turf)

				var/hit = FALSE
				for(var/atom/A in turf)
					if(isTarget(A))
						A.Attackby(master, user, params, 1)
						hit = TRUE
						last_use = world.time - (cooldown - success_cooldown)
						break
				afterUse(user)
				if (!hit)
					playsound(master, 'sound/effects/swoosh.ogg', 50, FALSE)
			return


	rangestab
		cooldown = 0 //10
		moveDelay = 5
		moveDelayDuration = 5

		image = "stab"
		name = "Stab"
		desc = "Attack with a 2 tile range."

		onAdd()
			if(master)
				//cooldown = master.click_delay
				overrideStaminaDamage = master.stamina_damage * 1
			return

		pixelaction(atom/target, params, mob/user, reach)
			if(!isturf(target.loc) && !isturf(target)) return
			if(!usable(user)) return
			if(params["left"] && master && get_dist_pixel_squared(user, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
				preUse(user)
				var/direction = get_dir_pixel(user, target, params)
				var/list/attacked = list()

				var/turf/one = get_step(master, direction)
				var/turf/two = get_step(one, direction)

				showEffect("spear", direction)

				var/hit = 0
				for(var/turf/T in list(one, two))
					for(var/atom/A in T)
						if(A in attacked) continue
						if(isTarget(A))
							A.Attackby(master, user, params, 1)
							attacked += A
							hit = 1

				afterUse(user)
				if (!hit)
					playsound(master, 'sound/effects/swoosh.ogg', 50, 0)
			return

		kendo_thrust
			name = "Thrust"
			desc = "A powerful ranged stab."
			damageMult = 1
			animation_color = "#a3774d"

			onAdd()
				return
	swipe
		cooldown = 0 //30
		moveDelay = 5
		moveDelayDuration = 5

		damageMult = 1

		image = "swipe"
		name = "Swipe"
		desc = "Attack with a wide swing."
		var/swipe_color
		var/ignition = false	//If true, the swipe will ignite stuff in it's reach.

		onAdd()
			if(master)
				overrideStaminaDamage = master.stamina_damage * 0.8
				var/obj/item/toy/sword/saber = master
				if (istype(saber))
					swipe_color = get_hex_color_from_blade(saber.bladecolor)
				var/obj/item/syndicate_destruction_system/sds = master
				if (istype(sds))
					swipe_color = "#FFFBCC"
					ignition = true
			return

				//Sampled these hex colors from each c-saber sprite.
		proc/get_hex_color_from_blade(var/C as text)
			switch(C)
				if("R")
					return "#FF0000"
				if("O")
					return "#FF9A00"
				if("Y")
					return "#FFFF00"
				if("G")
					return "#00FF78"
				if("C")
					return "#00FFFF"
				if("B")
					return "#0081DF"
				if("P")
					return "#CC00FF"
				if("Pi")
					return "#FFCCFF"
				if("W")
					return "#EBE6EB"
			return "RAND"

		pixelaction(atom/target, list/params, mob/user, reach)
			if(!isturf(target.loc) && !isturf(target)) return
			if(!usable(user)) return
			if(params["left"] && master && get_dist_pixel_squared(user, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
				preUse(user)
				var/direction = get_dir_pixel(user, target, params)
				if(direction == NORTHEAST || direction == NORTHWEST || direction == SOUTHEAST || direction == SOUTHWEST)
					direction = (prob(50) ? turn(direction, 45) : turn(direction, -45))

				var/list/attacked = list()

				var/turf/one = get_step(master, direction)
				var/turf/effect = get_step(one, direction)
				var/turf/two = get_step(one, turn(direction, 90))
				var/turf/three = get_step(one, turn(direction, -90))

				var/obj/itemspecialeffect/swipe/swipe = new()
				//pick random colour from get_hex_color_from_blade if the bladecolor/swipe_color is null. Randomized color each swing cause this saber is multicolored.
				if (swipe_color == "RAND")
					swipe.color = pick("#FF0000","#FF9A00","#FFFF00","#00FF78","#00FFFF","#0081DF","#CC00FF","#FFCCFF","#EBE6EB")
				else
					swipe.color = swipe_color
				swipe.setup(effect)
				swipe.set_dir(direction)

				var/hit = 0
				for(var/turf/T in list(one, two, three))
					for(var/atom/movable/A in T)
						if(A in attacked) continue
						if(isTarget(A))
							A.Attackby(master, user, params, 1)
							attacked += A
							hit = 1
					if(ignition)
						T.hotspot_expose(3000,1)
						for(var/A in T)
							if(ismob(A))
								var/mob/M = A
								M.changeStatus("burning", 8 SECONDS)
							else if(iscritter(A))
								var/obj/critter/crit = A
								crit.blob_act(8) //REMOVE WHEN WE ADD BURNING OBJCRITTERS

				afterUse(user)
				if (!hit)
					if (!ignition)
						playsound(master, "sound/effects/swoosh.ogg", 50, 0)
					else
						playsound(master, "sound/effects/flame.ogg", 50, 0)
			return

		csaber //no stun and less damage than normal csaber hit ( see sword/attack() )

			damageMult = 0.54

			onAdd()
				if(master)
					//cooldown = master.click_delay
					overrideStaminaDamage = master.stamina_damage * 0.9
					var/obj/item/sword/saber = master
					if (istype(saber))
						swipe_color = get_hex_color_from_blade(saber.bladecolor)
				return

		relicclaws

			manualTriggerOnly = 1 //Is triggered from the claws equipment_click instead.
			damageMult = 1

			onAdd()
				return

		kendo_sweep
			name = "Sweep"
			desc = "An AoE attack with a chance to disarm."
			//cooldown = 0 //30
			swipe_color = "#a3774d"
			damageMult = 0.8

			onAdd()
				if(master)
					overrideStaminaDamage = master.stamina_damage * 0.8
				return

		baseball
			name = "Baseball Swing"
			desc = "An AoE attack with a chance for a home run."

			modify_attack_result(mob/user, mob/target, datum/attackResults/msgs)
				if (msgs.damage > 0 && prob(master.stamina_crit_chance))
					var/turf/target_turf = get_edge_target_turf(target, get_dir(user, target))
					target.throw_at(target_turf, 4, 1, throw_type = THROW_BASEBALL)
					msgs.played_sound = 'sound/impact_sounds/bat_wood_crit.ogg'
				return msgs

	launch_projectile
		cooldown = 3 SECONDS
		moveDelay = 0
		/// projectile datum containing data for projectile objects
		var/datum/projectile/projectile = null
		/// type path of the special effect
		var/special_effect_type = /obj/itemspecialeffect/simple

		image = "simple"
		name = "Cast"
		desc = "Utilize the power of your wand to cast a bolt of magic."

		pixelaction(atom/target, params, mob/user, reach)
			. = ..()
			if (!projectile) return
			var/turf/T = get_turf(target)
			if(!T) return
			if(!usable(user)) return
			if(params["left"] && master && get_dist_pixel_squared(user, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
				preUse(user)
				var/pox = text2num(params["icon-x"]) - 16
				var/poy = text2num(params["icon-y"]) - 16
				var/obj/itemspecialeffect/S = new special_effect_type()
				S.setup(get_step(user, get_dir(user, target)))
				shoot_projectile_ST_pixel(user, projectile, target, pox, poy)
				afterUse(user)

		disposing()
			projectile = null
			. = ..()

		fireball
			projectile = new/datum/projectile/fireball

		monkey_organ
			projectile = new/datum/projectile/special/spawner
			New()
				. = ..()
				var/datum/projectile/special/spawner/P = projectile
				P.damage_type = D_KINETIC
				P.power = 5
				P.typetospawn = /obj/random_item_spawner/organs/bloody/one_to_three
				P.icon = 'icons/mob/monkey.dmi'
				P.icon_state = "monkey"
				P.shot_sound = "sound/voice/screams/monkey_scream.ogg"
				P.hit_sound = "sound/impact_sounds/Slimy_Splat_1.ogg"
				P.name = "monkey"

	slam
		cooldown = 50
		moveDelay = 15
		moveDelayDuration = 20
		restrainDuration = 1
		damageMult = 0.22

		image = "slam"
		name = "Slam"
		desc = "Knock back and damage targets."
		prefix = "Massive"

		onAdd()
			if(master)
				overrideStaminaDamage = master.stamina_damage * 0.7
			return

		afterUse(var/mob/person)
			..()
			if (istype(master,/obj/item/mining_tool))
				var/obj/item/mining_tool/M = master
				if (M.status)
					M.process_charges(30)

		pixelaction(atom/target, params, mob/user, reach)
			if(!isturf(target.loc) && !isturf(target)) return
			if(!usable(user)) return

			if(params["left"] && (master || user) && get_dist_pixel_squared(user, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
				preUse(user)
				var/direction = get_dir_pixel(user, target, params)
				if(direction == NORTHEAST || direction == NORTHWEST || direction == SOUTHEAST || direction == SOUTHWEST)
					direction = (prob(50) ? turn(direction, 45) : turn(direction, -45))

				var/list/attacked = list()

				var/turf/one = get_step((master || user), direction)

				var/turf/two = get_step(one, direction)
				var/turf/twoB = get_step(two, direction)

				var/turf/three = get_step(two, turn(direction, 90))
				var/turf/four = get_step(two, turn(direction, -90))

				var/turf/threeB = get_step(three, direction)
				var/turf/fourB = get_step(four, direction)

				var/obj/itemspecialeffect/cracks = new()
				cracks.setup(two)
				cracks.set_dir(direction)
				animate(cracks, alpha=0, time=30)

				for(var/mob/M in viewers())
					shake_camera(M, 8, 24)

				for(var/turf/T in list(one, two, three, four, twoB, threeB, fourB))
					animate_shake(T,5,2,2,T.pixel_x,T.pixel_y)
					for(var/atom/movable/A in T)
						if(A in attacked) continue
						if(isTarget(A))
							if(master)
								A.Attackby(master, user, params, 1)
							else
								A.Attackhand(user, params)
							attacked += A
							A.throw_at(get_edge_target_turf(A,direction), 5, 3)

				afterUse(user)
				playsound(master, 'sound/effects/exlow.ogg', 50, 0)
			return

	slam/no_item_attack //slam without item attackby
		pixelaction(atom/target, params, mob/user, reach)
			if(!isturf(target.loc) && !isturf(target)) return
			if(!usable(user)) return

			if(params["left"] && get_dist_pixel_squared(user, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
				preUse(user)
				var/direction = get_dir_pixel(user, target, params)
				if(direction == NORTHEAST || direction == NORTHWEST || direction == SOUTHEAST || direction == SOUTHWEST)
					direction = (prob(50) ? turn(direction, 45) : turn(direction, -45))

				var/list/attacked = list()

				var/turf/one = get_step(user, direction)

				var/turf/two = get_step(one, direction)
				var/turf/twoB = get_step(two, direction)

				var/turf/three = get_step(two, turn(direction, 90))
				var/turf/four = get_step(two, turn(direction, -90))

				var/turf/threeB = get_step(three, direction)
				var/turf/fourB = get_step(four, direction)

				var/obj/itemspecialeffect/cracks = new()
				cracks.setup(two)
				cracks.set_dir(direction)
				animate(cracks, alpha=0, time=30)

				for(var/mob/M in viewers())
					shake_camera(M, 8, 24)

				for(var/turf/T in list(one, two, three, four, twoB, threeB, fourB))
					animate_shake(T,5,2,2,T.pixel_x,T.pixel_y)
					for(var/atom/movable/A in T)
						if(A in attacked) continue
						if(isTarget(A))
							if (isliving(A))
								var/mob/living/L = A
								L.TakeDamage("chest", 0, rand(1,5), 0, DAMAGE_BLUNT)
							attacked += A
							A.throw_at(get_edge_target_turf(A,direction), 5, 3)

				afterUse(user)
				playsound(user, 'sound/effects/exlow.ogg', 50, 0)
			return


	whirlwind
		cooldown = 20
		restrainDuration = 5
		image = "whirlwind"
		name = "Whirlwind"
		desc = "Hit all enemies around you."

		onMouseUp(atom/target,location,control,params)
			if(!target || (!isturf(target.loc) && !isturf(target))) return
			if(!usable()) return
			var/list/parameters = params2list(params)
			if(parameters["left"] && master && get_dist_pixel_squared(usr, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
				preUse(usr)
				var/list/attacked = list()

				for(var/turf/T in orange(2,get_turf(master)))
					for(var/atom/A in T)
						if(A in attacked) continue
						if(isTarget(A))
							A.Attackby(master, usr, params, 1)
							attacked += A

				showEffect("whirlwind", NORTH)
				afterUse(usr)
				playsound(master, 'sound/effects/swoosh_double.ogg', 100, 0)
			return

	//Disarm and Harm are odd ones out. They have no master item, they are attached to a limb. As such, some vars (like all of our item damage/crit modifiers) won't affect these. See the top of the limb.dm file if you want to adjust how they are enacted
	//kind of messying things up, sorry!!
	//Right now, item specials will NOT accept MouseUp and MouseDown events from limbs. Only pixelaction cause i'm lazsy

	disarm
		cooldown = 0
		moveDelay = 0
		moveDelayDuration = 0

		image = "conc"
		name = "Shove"
		desc = "Shove someone backwards."

		var/datum/limb/L

		preUse(var/mob/person)
			..()
			L = person.equipped_limb()
			if (!L)
				return
			L.special_next = 1

		afterUse(var/mob/person)
			..()
			if (L)
				L.special_next = 0

		pixelaction(atom/target, params, mob/user, reach)
			if(!isturf(target.loc) && !isturf(target)) return
			if(!usable(user)) return
			if(params["left"] && get_dist_pixel_squared(user, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
				preUse(user)
				var/direction = get_dir_pixel(user, target, params)
				var/turf/turf = get_step(user, direction)

				var/obj/itemspecialeffect/conc/C = new()
				C.setup(turf)

				var/hit = 0
				for(var/atom/A in atoms_in_combat_range(turf))
					if(isTarget(A))
						A.Attackhand(user,params)
						hit = 1
						break

				afterUse(user)

				if (!hit)
					playsound(user, 'sound/impact_sounds/Generic_Swing_1.ogg', 40, 0)
			return

	harm
		cooldown = 0
		moveDelay = 0
		moveDelayDuration = 0

		image = "conc"
		name = "Harm"
		desc = "Throw a punch."

		var/datum/limb/L

		preUse(var/mob/person)
			..()
			L = person.equipped_limb()
			if (!L)
				return
			L.special_next = 1

		afterUse(var/mob/person)
			..()
			if (L)
				L.special_next = 0

		pixelaction(atom/target, params, mob/user, reach)
			if(!isturf(target.loc) && !isturf(target)) return
			if(!usable(user)) return
			if(params["left"] && get_dist_pixel_squared(user, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
				preUse(user)
				var/direction = get_dir_pixel(user, target, params)
				var/turf/turf = get_step(user, direction)

				var/obj/itemspecialeffect/conc/C = new()
				C.setup(turf)

				var/hit = 0
				for(var/atom/A in atoms_in_combat_range(turf))
					if(isTarget(A))
						A.Attackhand(user,params)
						hit = 1
						break

				afterUse(user)

				if (!hit)
					playsound(user, 'sound/impact_sounds/Generic_Swing_1.ogg', 40, 0)
			return

	swipe/limb //meant for use on limbs
		var/datum/limb/L

		preUse(var/mob/person)
			..()
			L = person.equipped_limb()
			if (!L)
				return
			L.special_next = 1

		afterUse(var/mob/person)
			..()
			if (L)
				L.special_next = 0

		pixelaction(atom/target, params, mob/user, reach)
			if(!isturf(target.loc) && !isturf(target)) return
			if(!usable(user)) return
			if(params["left"] && get_dist_pixel_squared(user, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
				preUse(user)
				var/direction = get_dir_pixel(user, target, params)
				if(direction == NORTHEAST || direction == NORTHWEST || direction == SOUTHEAST || direction == SOUTHWEST)
					direction = (prob(50) ? turn(direction, 45) : turn(direction, -45))

				var/list/attacked = list()

				var/turf/one = get_step(user, direction)
				var/turf/effect = get_step(one, direction)
				var/turf/two = get_step(one, turn(direction, 90))
				var/turf/three = get_step(one, turn(direction, -90))

				var/obj/itemspecialeffect/swipe/swipe = new()
				swipe.setup(effect)
				swipe.set_dir(direction)

				var/hit = 0
				for(var/turf/T in list(one, two, three))
					for(var/atom/movable/A in T)
						if(A in attacked) continue
						if(isTarget(A))
							A.Attackhand(user,params)
							attacked += A
							hit = 1

				afterUse(user)
				if (!hit)
					playsound(user, 'sound/effects/swoosh.ogg', 50, 0)
			return

	spark
		cooldown = 0
		moveDelay = 5
		moveDelayDuration = 3

		image = "sparks"
		name = "Spark"
		desc = "Throw a spark from the end of your baton."

		var/secondhit_delay = 1
		var/stamina_damage = 50
		var/mult = 1


		pixelaction(atom/target, params, mob/user, reach)
			if(!isturf(target.loc) && !isturf(target)) return
			if(!usable(user)) return
			if(user.a_intent != INTENT_DISARM) return //only want this to deploy on disarm intent
			if(master && istype(master, /obj/item/baton) && !master:can_stun())
				playsound(master, 'sound/weapons/Gunclick.ogg', 50, 0, 0.1, 2)
				return

			if(params["left"] && master && get_dist_pixel_squared(user, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
				preUse(user)
				var/direction = get_dir_pixel(user, target, params)
				var/list/attacked = list()

				var/turf/effect = get_step(master, direction)

				var/obj/itemspecialeffect/spark/spark = new()
				spark.setup(effect)
				spark.set_dir(direction)

				var/hit = 0
				for(var/atom/movable/A in effect)
					if(A in attacked) continue
					if(isTarget(A))
						on_hit(A,2)
						attacked += A
						hit = 1
						if (ishuman(user) && master  && istype(master, /obj/item/clothing/gloves))
							user.unlock_medal("High Five!", 1)
						break
				if (!hit)
					SPAWN_DBG(secondhit_delay)
						step(spark, direction, 2)
						for(var/atom/movable/A in spark.loc)
							if(A in attacked) continue
							if(isTarget(A))
								on_hit(A, mult)
								attacked += A
								hit = 1
								break

				if(master && istype(master, /obj/item/baton))
					master:process_charges(-1, user)
				if(master && istype(master, /obj/item/clothing/gloves) && master:uses)
					var/obj/item/clothing/gloves/G = master
					G.uses = max(0, G.uses - 1)
					if (G.uses < 1)
						G.icon_state = "yellow"
						G.item_state = "ygloves"
						user.update_clothing() // Was missing (Convair880).
						user.show_text("The gloves are no longer electrically charged.", "red")
						G.overridespecial = 0
					else
						user.show_text("The gloves have [G.uses]/[G.max_uses] charges left!", "red")
				afterUse(user)
				//if (!hit)
				playsound(master, 'sound/effects/sparks6.ogg', 70, 0)
			return


		proc/on_hit(var/mob/hit, var/mult = 1)
			if (ishuman(hit))
				var/mob/living/carbon/human/H = hit
				H.do_disorient(src.stamina_damage * mult, weakened = 10)

			hit.TakeDamage("chest", 0, rand(2 * mult,5 * mult), 0, DAMAGE_BLUNT)
			hit.bodytemperature += 4 * mult

			playsound(hit, 'sound/effects/electric_shock.ogg', 60, 1, 0.1, 2.8)

	double
		cooldown = 0
		moveDelay = 5
		moveDelayDuration = 5
		damageMult = 0.80

		image = "dagger"
		name = "Slice"
		desc = "Attack twice in rapid succession."

		var/secondhitdelay = 2

		onAdd()
			if(master)
				overrideStaminaDamage = master.stamina_damage * 0.5
			return

		pixelaction(atom/target, params, mob/user, reach)
			if(!isturf(target.loc) && !isturf(target)) return
			if(!usable(user)) return
			if(params["left"] && master && get_dist_pixel_squared(user, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
				preUse(user)
				var/direction = get_dir_pixel(user, target, params)
				var/turf/turf = get_step(master, direction)

				var/obj/itemspecialeffect/simple2/S = new()
				S.setup(turf)

				var/hit = 0
				for(var/atom/A in atoms_in_combat_range(turf))
					if(isTarget(A))
						A.Attackby(master, user, params, 1)
						hit = 1
						break
				if (!hit)
					playsound(user, 'sound/impact_sounds/Generic_Swing_1.ogg', 40, 0, 0.1, 1.4)

				SPAWN_DBG(secondhitdelay)

					turf = get_step(master, direction)
					var/obj/itemspecialeffect/simple2/SS = new()
					SS.setup(turf)

					hit = 0
					for(var/atom/A in atoms_in_combat_range(turf))
						if(isTarget(A))
							A.Attackby(master, user, params, 1)
							hit = 1
							break
					if (!hit)
						playsound(user, 'sound/impact_sounds/Generic_Swing_1.ogg', 40, 0, 0.1, 1.4)

				afterUse(user)

			return

	barrier
		cooldown = 0
		moveDelay = 7
		moveDelayDuration = 6
		damageMult = 1
		restrainDuration = 10

		image = "barrier"
		name = "Energy Barrier"
		desc = "Deploy a temporary barrier that reflects projectiles. The barrier can be easily broken by any attack or a sustained push. "

		onAdd()
			if(master)
				overrideStaminaDamage = master.stamina_damage * 0.8
			return

		pixelaction(atom/target, params, mob/user, reach)
			if(!isturf(target.loc) && !isturf(target)) return
			if(!usable(user)) return
			if(params["left"] && master && get_dist_pixel_squared(user, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
				preUse(user)
				var/direction = get_dir_pixel(user, target, params)
				var/turf/turf = get_step(master, direction)

				var/obj/itemspecialeffect/barrier/E = new()
				E.setup(turf)
				E.master = user
				E.set_dir(direction)
				if(master && istype(master, /obj/item/barrier))
					var/obj/item/barrier/B = master
					B.destroy_deployed_barrier(user)
					B.E = E //set barrier
					var/mob/living/L = user

					//set move callback (when user moves, shield go down)
					if (islist(L.move_laying))
						L.move_laying += B
					else
						if (L.move_laying)
							L.move_laying = list(L.move_laying, B)
						else
							L.move_laying = list(B)

				var/hit = 0
				for(var/atom/A in atoms_in_combat_range(turf))
					if(isTarget(A))
						A.Attackby(master, user, params, 1)
						hit = 1
						break

				if (hit)
					E.was_clashed(0)
				else
					playsound(master, 'sound/items/miningtool_on.ogg', 30, 0.1, 0, 2)

				afterUse(user)
			return


	flame
		cooldown = 0
		moveDelay = 5
		moveDelayDuration = 2

		damageMult = 0.8


		image = "flame"
		name = "Flame"
		desc = "Pop out a flame 1 tile away from you in a direction."

		var/time = 6 SECONDS
		var/tiny_time = 1 SECOND

		onAdd()
			if(master)
				overrideStaminaDamage = master.stamina_damage * 0.8
			return

		pixelaction(atom/target, params, mob/user, reach)
			if(!isturf(target.loc) && !isturf(target)) return
			if(!usable(user)) return
			if(params["left"] && master && get_dist_pixel_squared(user, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
				preUse(user)
				var/direction = get_dir_pixel(user, target, params)

				//THIS IS BAD, FIX IT! (the random shit)
				if(direction == NORTHEAST || direction == NORTHWEST || direction == SOUTHEAST || direction == SOUTHWEST)
					direction = (prob(50) ? turn(direction, 45) : turn(direction, -45))

				var/turf/turf = get_step(master, direction)

				var/obj/itemspecialeffect/flame/S = new()
				S.set_dir(direction)
				turf = get_step(turf,S.dir)

				var/flame_succ = 0
				if (master)
					if(istype(master,/obj/item/device/light/zippo) && master:on)
						var/obj/item/device/light/zippo/Z = master
						if (Z.reagents.get_reagent_amount("fuel"))
							Z.reagents.remove_reagent("fuel", 1)
							flame_succ = 1
						else
							flame_succ = 0
					if (isweldingtool(master) && master:try_weld(user,0,-1,0,0))
						if (master.reagents.get_reagent_amount("fuel"))
							master.reagents.remove_reagent("fuel", 1)
							flame_succ = 1
						else
							flame_succ = 0

				if (flame_succ)
					S.setup(turf)
					flick("flame",S)
				else
					S.setup(turf)
					flick("spark",S)


				if (flame_succ)
					turf.hotspot_expose(T0C + 400, 400)
					for(var/A in turf)
						if(!isTarget(A))
							continue
						if(ismob(A))
							var/mob/M = A
							M.changeStatus("burning", flame_succ ? time : tiny_time)
						else if(iscritter(A))
							var/obj/critter/crit = A
							crit.blob_act(8) //REMOVE WHEN WE ADD BURNING OBJCRITTERS
						break

					playsound(master, 'sound/effects/flame.ogg', 50, 0)
				else
					turf.hotspot_expose(T0C + 50, 50)
					playsound(master, 'sound/effects/spark_lighter.ogg', 50, 0)

				afterUse(user)
			return

	elecflash
		cooldown = 0
		moveDelay = 5
		moveDelayDuration = 2

		damageMult = 0.8


		image = "pulse"
		name = "Pulse"
		desc = "Pulse 1 tile away from you in any direction. The pulse will emit a mild shock that spreads in a random direction."

		onAdd()
			if(master)
				overrideStaminaDamage = master.stamina_damage * 0.8
			return

		pixelaction(atom/target, params, mob/user, reach)
			if(!isturf(target.loc) && !isturf(target)) return
			if(!usable(user)) return
			if(params["left"] && master && get_dist_pixel_squared(user, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
				preUse(user)
				var/direction = get_dir_pixel(user, target, params)
				var/turf/turf = get_step(master, direction)


				var/obj/itemspecialeffect/conc/C = new()
				C.setup(turf)
				for (var/obj/O in turf.contents)
					if (istype(O, /obj/blob))
						boutput(user, "<span class='alert'><b>You try to pulse a spark, but [O] is too wet for it to take!</b></span>")
						return
					if (istype(O, /obj/spacevine))
						var/obj/spacevine/K = O
						if (K.current_stage >= 2)	//if it's med density
							boutput(user, "<span class='alert'><b>You try to pulse a spark, but [O] is too dense for it to take!</b></span>")
							return

				elecflash(turf,0, power=2, exclude_center = 0)
				afterUse(user)
			return

///////////////////////////////////
	spark/ntso
		cooldown = 0
		moveDelay = 5
		moveDelayDuration = 2

		image = "baton-spark-ntso"
		name = "Baton Hit"
		desc = "Attack in direction with baton. Stun safety features overridden for more damage."

		secondhit_delay = 1
		stamina_damage = 50

		//default to regular hit if we can't stun.
		proc/default_to_simple()
			var/datum/item_special/simple/S = new/datum/item_special/simple(src)
			S.pixelaction()


		pixelaction(atom/target, params, mob/user, reach)
			if(!isturf(target.loc) && !isturf(target)) return
			if(!usable(user)) return

			if(params["left"] && master && get_dist_pixel_squared(user, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
				preUse(user)

				var/direction = get_dir_pixel(user, target, params)

				var/turf/effect = get_step(master, direction)

				var/obj/itemspecialeffect/E = null

				//sorry about this, it's so I don't unpool a simple effect twice by mistake
				if(istype(master, /obj/item/baton))
					if (!master:can_stun())
						E = new()
					else
						E = new()
						master:process_charges(-1)
						// master:process_charges(-1, user)
				else
					E = new()


				E.setup(effect)
				E.set_dir(direction)

				var/hit = 0
				for(var/atom/movable/A in effect)
					if(isTarget(A))
						on_hit(A)
						//fake harmbaton it
						A.Attackby(master, user, params, 1)
						hit = 1
						playsound(master, 'sound/effects/sparks6.ogg', 70, 0)
						break

				afterUse(user)
				if (!hit)
					if (E.type == /obj/itemspecialeffect/simple)
						playsound(master, 'sound/effects/swoosh.ogg', 50, 0)
					else
						playsound(master, 'sound/effects/sparks1.ogg', 70, 0)

			return

		usable(var/mob/user)
			if (!..())
				return 0
			if(istype(master, /obj/item/baton/ntso))
				if (master:state == 1)
					return 0
			return 1

		on_hit(var/mob/hit, var/mult = 1)
			//maybe add this in, chance to weaken. I dunno a good amount offhand so leaving out for now - kyle
			// if (ishuman(hit))
			// 	var/mob/living/carbon/human/H = hit
			// 	H.do_disorient(src.stamina_damage * mult, weakened = 10)
			if(istype(master, /obj/item))
				hit.TakeDamage("chest", 0/*master.force*/, rand(2 * mult,5 * mult), 0, DAMAGE_BLUNT)
				hit.bodytemperature += 4 * mult

			playsound(hit, 'sound/effects/electric_shock.ogg', 60, 1, 0.1, 2.8)

	katana_dash
		cooldown = 30
		moveDelay = 0
		moveDelayDuration = 0

		image = "rush"
		name = "Katana Dash"
		desc = "Instantly dash to a location like you saw in all those Japanese cartoons."

		var/secondhit_delay = 1
		var/stamina_damage = 80
		var/obj/item/katana/K
		var/reversed = 0

		onAdd()
			if(istype(master, /obj/item/katana))
				K = master
			return

		pixelaction(atom/target, params, mob/user, reach)
			if(!isturf(target.loc) && !isturf(target)) return
			if(!usable(user)) return

			if(params["left"] && (master && K) && get_dist_pixel_squared(user, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
				preUse(user)
				var/direction = get_dir_pixel(user, target, params)
				if (reversed)
					direction = turn(direction, 180)
				var/list/attacked = list()

				var/turf/T1 = get_turf(user)
				var/turf/T2 = null
				var/turf/T3 = null
				var/turf/T4 = null

				//This steps the user to his destination and gets the turfs needed for drawing the effects and where the attack hits
				var/stopped = 0
				if (step(user, direction))
					T2 = get_turf(user)
				else
					stopped = 1

				if (!stopped && step(user, direction))
					T3 = get_turf(user)
				else
					stopped = 2

				if (!stopped && step(user, direction))
					T4 = get_turf(user)
				else
					stopped = 3

				//Draws the effects // I did this backwards maybe, but won't fix it -kyle
				K.start.loc = T1
				K.start.set_dir(direction)
				flick(K.start.icon_state, K.start)
				sleep(0.1 SECONDS)
				if (T4)
					K.mid1.loc = T2
					K.mid1.set_dir(direction)
					flick(K.mid1.icon_state, K.mid1)
					sleep(0.1 SECONDS)
					K.mid2.loc = T3
					K.mid2.set_dir(direction)
					flick(K.mid2.icon_state, K.mid2)
					sleep(0.1 SECONDS)
					K.end.loc = T4
					K.end.set_dir(direction)
					flick(K.end.icon_state, K.end)
				else if (T3)
					K.mid1.loc = T2
					K.mid1.set_dir(direction)
					flick(K.mid1.icon_state, K.mid1)
					sleep(0.1 SECONDS)
					K.end.loc = T3
					K.end.set_dir(direction)
					flick(K.end.icon_state, K.end)
				else if (T2)
					K.end.loc = T2
					K.end.set_dir(direction)
					flick(K.end.icon_state, K.end)

				//Reset the effects after they're drawn and put back into master for re-use later
				SPAWN_DBG(0.8 SECONDS)
					K.start.loc = master
					K.mid1.loc = master
					K.mid2.loc = master
					K.end.loc = master
				// var/hit = 0
				for(var/atom/movable/A in get_step(user, direction))
					if(A in attacked) continue
					if(isTarget(A))
						on_hit(A)
						attacked += A
						A.Attackby(master, user, params, 1)
						// hit = 1
						break
				afterUse(user)
				//if (!hit)
				playsound(master, 'sound/effects/sparks6.ogg', 70, 0)
			return

		proc/on_hit(var/mob/hit)
			if (ishuman(hit))
				var/mob/living/carbon/human/H = hit
				H.do_disorient(src.stamina_damage, stunned = 10)
			return

	katana_dash/reverse
		reversed = 1

		on_hit(var/mob/hit)
			if (ishuman(hit))
				var/mob/living/carbon/human/H = hit
				H.do_disorient(src.stamina_damage, stunned = 10)


	katana_dash/limb
		cooldown = 0
		moveDelay = 0
		moveDelayDuration = 0

		image = "rush"
		name = "Dash"
		desc = "Instantly dash to a location while attacking."

		secondhit_delay = 1
		reversed = 0

		var/datum/limb/L

		preUse(var/mob/person)
			..()
			L = person.equipped_limb()
			if (!L)
				return
			L.special_next = 1

		afterUse(var/mob/person)
			..()
			if (L)
				L.special_next = 0

		pixelaction(atom/target, params, mob/user, reach)
			if(!isturf(target.loc) && !isturf(target)) return
			if(!usable(user)) return

			if(params["left"] && params["ai"] || get_dist_pixel_squared(user, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
				preUse(user)
				var/direction = get_dir_pixel(user, target, params)
				if (reversed)
					direction = turn(direction, 180)
				var/list/attacked = list()

				var/turf/T1 = get_turf(user)
				var/turf/T2 = null
				var/turf/T3 = null
				var/turf/T4 = null

				//This steps the user to his destination and gets the turfs needed for drawing the effects and where the attack hits
				var/stopped = 0
				var/prev_loc = get_turf(user)
				step(user, direction)
				if (get_turf(user) != prev_loc)
					T2 = get_turf(user)
				else
					stopped = 1

				sleep(world.tick_lag)

				prev_loc = get_turf(user)
				step(user, direction)
				if (!stopped && get_turf(user) != prev_loc)
					T3 = get_turf(user)
				else
					stopped = 2

				sleep(world.tick_lag)

				prev_loc = get_turf(user)
				step(user, direction)
				if (!stopped && get_turf(user) != prev_loc)
					T4 = get_turf(user)
				else
					stopped = 3

				sleep(world.tick_lag)

				var/obj/itemspecialeffect/conc/start = new
				var/obj/itemspecialeffect/katana_dash/mid/mid1 = new
				var/obj/itemspecialeffect/katana_dash/mid/mid2 = new
				var/obj/itemspecialeffect/conc/end = new

				start.do_flick = 1
				mid1.do_flick = 1
				mid2.do_flick = 1
				end.do_flick = 1

				//Draws the effects // I did this backwards maybe, but won't fix it -kyle
				start.setup(T1)
				start.set_dir(direction)
				if (T4)
					mid1.setup(T2)
					mid1.set_dir(direction)
					mid2.setup(T2)
					mid2.set_dir(direction)
					end.setup(T4)
					end.set_dir(direction)
				else if (T3)
					mid1.setup(T2)
					mid1.set_dir(direction)
					end.setup(T3)
					end.set_dir(direction)
				else if (T2)
					end.setup(T2)
					end.set_dir(direction)

				for(var/atom/movable/A in get_step(user, direction))
					if(A in attacked) continue
					if(isTarget(A))
						attacked += A
						A.Attackhand(user,params)
						// hit = 1
						break

				afterUse(user)
				//if (!hit)
				playsound(user, 'sound/effects/swoosh.ogg', 40, 1, pitch = 2.3)
			return

	nunchucks
		cooldown = 30
		moveDelay = 5
		moveDelayDuration = 5

		damageMult = 0.75

		image = "dagger"
		name = "double hit"
		desc = "Attack with two quick hits."

		onAdd()
			if(master)
				overrideStaminaDamage = master.stamina_damage * 0.6 //maybe too low? thinking about stuff like baseball bat or rolling pin tho
			return

		pixelaction(atom/target, params, mob/user, reach)
			if(!isturf(target.loc) && !isturf(target)) return
			if(!usable(user)) return
			if(params["left"] && master && get_dist_pixel_squared(user, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
				preUse(user)
				var/direction = get_dir_pixel(user, target, params)
				if(direction == NORTHEAST || direction == NORTHWEST || direction == SOUTHEAST || direction == SOUTHWEST)
					direction = (prob(50) ? turn(direction, 45) : turn(direction, -45))

				var/list/attacked = list()

				var/turf/one = get_step(master, direction)
				var/turf/effect = get_step(one, direction)
				var/turf/two = get_step(one, turn(direction, 90))
				var/turf/three = get_step(one, turn(direction, -90))

				var/obj/itemspecialeffect/nunchucks/nunchuck = new()
				nunchuck.setup(effect)
				nunchuck.set_dir(direction)

				var/hit = 0
				for(var/turf/T in list(two, three))
					for(var/atom/movable/A in T)
						if(A in attacked) continue
						if(isTarget(A))
							A.Attackby(master, user, params, 1)
							attacked += A
							hit = 1

				for(var/atom/movable/A in one)
					if(A in attacked) continue
					if(isTarget(A))
						A.Attackby(master, user, params, 1)
						SPAWN_DBG(0.5 SECONDS)
							A.Attackby(master, user, params, 1)
						attacked += A
						hit = 1

				afterUse(user)
				if (!hit)
					playsound(master, 'sound/effects/swoosh.ogg', 50, 0)
			return


	tile_fling
		cooldown = 0
		moveDelay = 0
		moveDelayDuration = 0
		damageMult = 1

		image = "throw"
		name = "Tile Fling"
		desc = "If available, fling a floor tile from the ground in front of you. Otherwise attacks in direction. No crits."

		onAdd()
			if(master)
				overrideStaminaDamage = master.stamina_damage * 1
			return

		pixelaction(atom/target, params, mob/user, reach)
			if(!isturf(target.loc) && !isturf(target)) return
			if(!usable(user)) return
			if(params["left"] && master && get_dist_pixel_squared(user, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
				preUse(user)
				var/direction = get_dir_pixel(user, target, params)
				var/turf/turf = get_step(master, direction)

				var/obj/itemspecialeffect/simple/S = new()
				S.setup(turf)

				var/hit = 0
				for(var/atom/A in atoms_in_combat_range(turf))
					if(isTarget(A))
						A.Attackby(master, user, params, 1)
						hit = 1
						break

				afterUse(user)

				if (!hit)
					if (istype(turf,/turf/floor))
						var/turf/floor/F = turf
						var/obj/item/tile = F.pry_tile(master, user, params)
						if (tile)
							hit = 1
							user.visible_message("<span class='alert'><b>[user] flings a tile from [turf] into the air!</b></span>")
							logTheThing("combat", user, null, "fling throws a floor tile ([F]) from [turf].")

							user.lastattacked = user //apply combat click delay
							tile.throw_at(target, tile.throw_range, tile.throw_speed, params)

				if (!hit)
					playsound(master, 'sound/effects/swoosh.ogg', 50, 0)
			return


/datum/item_special/graffiti
	cooldown = 3 SECONDS
	moveDelay = 5
	moveDelayDuration = 5

	damageMult = 1

	image = "swipe"
	name = "Spray Burst"
	desc = "Use a burst of spray paint to harmlessly blind, deface & disorient an opponent."
	var/spray_color
	/// If true, the swipe will ignite stuff in it's reach.
	var/ignition = FALSE
	var/flipped = FALSE

	afterUse(mob/user)
		..()
		if(istype(master, /obj/item/spray_paint))
			var/obj/item/spray_paint/spraycan = master
			spraycan.charges--
			if (spraycan.charges <= 0)
				boutput(user, SPAN_ALERT("The graffiti can's empty!"))
				playsound(user.loc, "sound/items/can_crush-[rand(1,3)].ogg", 50, 1)
				spraycan.icon_state = "spraycan_crushed"
				spraycan.setItemSpecial(/datum/item_special/simple)
				spraycan.tooltip_rebuild = 1
			spraycan.update_icon()

	pixelaction(atom/target, list/params, mob/user, reach)
		if(!isturf(target.loc) && !isturf(target)) return
		if(!usable(user)) return
		if(!params["left"] || !master || !get_dist_pixel_squared(user, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
			return
		preUse(user)
		var/direction = get_dir_pixel(user, target, params)
		if(direction == NORTHEAST || direction == NORTHWEST || direction == SOUTHEAST || direction == SOUTHWEST)
			direction = (prob(50) ? turn(direction, 45) : turn(direction, -45))

		var/list/attacked = list()

		var/turf/one = get_step(master, direction)
		var/turf/effect = get_step(one, direction)
		var/turf/two = get_step(one, turn(direction, 90))
		var/turf/three = get_step(one, turn(direction, -90))
		var/obj/itemspecialeffect/graffiti
		if (flipped)
			graffiti = new /obj/itemspecialeffect/graffiti_flipped
		else
			graffiti = new /obj/itemspecialeffect/graffiti
		flipped = !flipped
		graffiti.color = pick("#FF0000","#FF9A00","#FFFF00","#00FF78","#00FFFF","#0081DF","#CC00FF","#FFCCFF","#EBE6EB")

		graffiti.setup(effect)
		graffiti.set_dir(direction)

		if(isopenflametool(user.l_hand) || isopenflametool(user.r_hand))
			ignition = TRUE

		for(var/turf/T in list(one, two, three))
			for(var/atom/movable/A in T)
				if(ignition)
					T.hotspot_expose(1200,50)
				if(A in attacked) continue
				if(!isliving(A)) continue
				var/mob/living/loser = A
				if(ignition)
					loser.changeStatus("burning", 10 SECONDS)
				var/tag_int = pick(1,2,3)
				var/image/tag = image('icons/effects/effects.dmi',"graffiti_mask_[tag_int]")
				tag.pixel_y = rand(-1,5)
				if (ismonkey(A))
					tag.pixel_y = tag.pixel_y - 6
				if (loser.bioHolder.HasEffect("dwarf"))
					tag.pixel_y = tag.pixel_y - 4
				tag.blend_mode = BLEND_INSET_OVERLAY
				tag.alpha = 200
				tag.color = graffiti.color
				tag.appearance_flags = KEEP_TOGETHER
				A.setStatus("graffiti_blind", 5 SECONDS)
				var/datum/statusEffect/graffiti/status = A.hasStatus("graffiti_blind")
				A.UpdateOverlays(tag,"graffitisplat[length(status.tag_images)+1]")
				status.tag_images += tag

				loser.visible_message(SPAN_COMBAT("[user] sprays paint into [loser]'s face!"),SPAN_COMBAT("[user] sprays paint in your face!"))
				logTheThing("combat", user, loser, "attacks [constructTarget(loser,"combat")] with [master] ([master.type], object name: [initial(master.name)]) at [log_loc(user)].")
				loser.was_harmed(user, master, TRUE)

				hit_twitch(A)
				if (ishuman(A) && prob(40))
					var/mob/living/carbon/human/victim = A
					victim.emote("cough")
				attacked += A

		afterUse(user)
		playsound(master, 'sound/items/graffitispray3.ogg', 50, TRUE)

/datum/item_special/simple/bloodystab
	cooldown = 0
	moveDelay = 5
	moveDelayDuration = 5

	image = "stab"
	name = "Stab"
	desc = "Aim for the throat for bloody crits."
	directional = TRUE
	specialEffect = /obj/itemspecialeffect/dagger

	var/stab_color = "#FFFFFF"

	modify_attack_result(mob/user, mob/target, datum/attackResults/msgs) //bleed on crit!
		if (msgs.damage > 0 && msgs.stamina_crit)
			msgs.bleed_always = TRUE
			// bleed people wearing armor less
			msgs.bleed_bonus = 10 + round(20 * clamp(msgs.damage / master.force, 0, 1))
			msgs.played_sound= 'sound/impact_sounds/Flesh_Stab_1.ogg'
			blood_slash(target,1,null, turn(user.dir,180), 3)
		return msgs

/datum/item_special/heavy_swing
	cooldown = 55 // slightly slower than the time to get up from a wallstun
	moveDelay = 10
	moveDelayDuration = 20
	restrainDuration = 15

	var/damageMultHit = 0.75
	var/damageMultShove = 0.2

	image = "heavyswing"
	name = "Heavy swing"
	desc = "Step forward and do a wide swing. Interrupted if you step into something."

	pixelaction(atom/target, params, mob/user, reach)
		if(!isturf(target.loc) && !isturf(target)) return
		if(!usable(user)) return
		var/direction = get_dir_pixel(user, target, params)
		var/list/attacked = list()

		if(direction == NORTHEAST || direction == NORTHWEST || direction == SOUTHEAST || direction == SOUTHWEST)
			direction = (prob(50) ? turn(direction, 45) : turn(direction, -45))
		var/turf/T2 = null
		user.next_move = world.time + 6 DECI SECONDS
		T2 = get_step(master, direction)
		for(var/atom/A in T2)
			if(isTarget(A) && ismob(A))
				var/mob/M = A
				M.throw_at(get_edge_cheap(T2, direction), 3, 20)
				var/obj/itemspecialeffect/heavybump/bumpeffect = new /obj/itemspecialeffect/heavybump
				bumpeffect.set_dir(direction)
				bumpeffect.setup(T2)
				damageMult = damageMultShove
				M.Attackby(master, user, params, 1)
				playsound(master,"sound/impact_sounds/metal_thump.ogg", 50, FALSE)
				return
		if (!step(user, direction)) return

		var/obj/itemspecialeffect/heavystep/stepeffect = new /obj/itemspecialeffect/heavystep
		stepeffect.set_dir(direction)
		stepeffect.setup(T2)
		playsound(master,"sound/misc/step/step_heavyboots_[pick(1,2,3)].ogg", 50, FALSE)

		SPAWN_DBG(3 DECI SECONDS)
			var/turf/one = get_step(T2, turn(direction, 90))
			var/turf/three = get_step(T2, direction) // front middle tile
			var/turf/two = get_step(three, turn(direction, 90))
			var/turf/four = get_step(three, turn(direction, -90))
			var/turf/five = get_step(T2, turn(direction, -90))
			damageMult = damageMultHit

			var/obj/itemspecialeffect/wide_swipe/swipe = new /obj/itemspecialeffect/wide_swipe
			swipe.set_dir(direction)
			swipe.setup(T2)

			var/hit = 0
			for(var/turf/T in list(five,four))
				for(var/atom/A in T)
					if(A in attacked) continue
					if(isTarget(A))
						A.Attackby(master, user, params, 1)
						attacked += A
						hit = 1
			SPAWN_DBG(1 DECI SECONDS)
				for(var/turf/T in list(three,two,one))
					for(var/atom/A in T)
						if(A in attacked) continue
						if(isTarget(A))
							A.Attackby(master, user, params, 1)
							attacked += A
							hit = 1

			if (!hit)
				playsound(master, 'sound/effects/swoosh.ogg', 50, FALSE)

/datum/item_special/massacre
	cooldown = 3 SECONDS
	moveDelay = 8
	moveDelayDuration = 30
	damageMult = 1
	image = "dagger"
	name = "Butcher"
	desc = "Repeatedly attack a target. The longer the chain goes, the more damage you deal per hit, but the longer you are staggered if interrupted."

	var/current_chain = 0
	/// Maximum number of hits
	var/max_chain = 10
	/// Damage multiplier, initial
	var/damage_mult_start = 0.2
	/// Damage multiplier increase per chain
	var/damage_mult_increment = 0.075
	///Disorient when interrupted
	var/penalty_disorient = TRUE
	///Disorient time on interrupt
	var/disorient_duration_base = 3 SECONDS
	///Extra disorient duration per extra swing
	var/disorient_duration_additive = 0.5 SECONDS
	var/alternate = FALSE
	onAdd()
		if(master)
			overrideStaminaDamage = master.stamina_damage * 0.8

	pixelaction(atom/target, params, mob/user, reach)
		damageMult = damage_mult_start
		if(!isturf(target.loc) && !isturf(target)) return
		if(!usable(user) || !isliving(user)) return

		var/mob/living/H = user
		if(!params["left"] || !master || !get_dist_pixel_squared(user, target, params) > ITEMSPECIAL_PIXELDIST_SQUARED)
			return
		preUse(user)
		current_chain = 0
		var/direction = get_dir_pixel(user, target, params)
		var/turf/turf = get_step(master, direction)

		var/obj/itemspecialeffect/cleave/cleave_effect = new /obj/itemspecialeffect/cleave
		cleave_effect.set_dir(direction)
		cleave_effect.setup(turf)
		alternate = TRUE
		var/hit = FALSE
		for(var/atom/A in turf)
			if(isTarget(A))
				A.Attackby(master, user, params, TRUE)
				hit = TRUE
				break
		if (!hit)
			playsound(user, 'sound/impact_sounds/Generic_Swing_1.ogg', 40, FALSE, 0.1, 1.4)

		while (hit && H.equipped() == master && current_chain < max_chain)
			H.next_click = world.time + 5 SECONDS
			last_use = world.time
			current_chain++
			if (current_chain == 13)
				sleep(0.2 SECONDS)
				var/string ="[H] raises \the [master] up high!"
				H.show_message(SPAN_ALERT(string), 1, assoc_maptext = make_chat_maptext(H, "<I>[string]</I>", "color: #C2BEBE;", alpha = 140))
				sleep(2 SECONDS)
				damageMult = 5
			else if (current_chain == 3)
				sleep(0.2 SECONDS)
				user.emote("twirl")
				sleep(1.4 SECONDS)
				damageMult = damage_mult_start+(current_chain*damage_mult_increment)
			else if (current_chain < 3)
				damageMult = damage_mult_start+(current_chain*damage_mult_increment)
				sleep(rand(7,9) DECI SECONDS)
			else
				sleep(rand(4,6) DECI SECONDS)
			if(!H.equipped() == master)
				break
			turf = get_step(master, direction)
			if (alternate)
				cleave_effect = new/obj/itemspecialeffect/cleave_flipped
			else
				cleave_effect = new/obj/itemspecialeffect/cleave
			alternate = !alternate
			cleave_effect.set_dir(direction)
			cleave_effect.setup(turf)
			if (prob(10) && current_chain > 3)
				user.emote(pick("laugh","cackle","grin"))

			hit = 0
			for(var/atom/A as anything in turf)
				if(isTarget(A))
					A.Attackby(master, user, params, TRUE)
					hit = TRUE
					break
			if (!hit)
				playsound(user, 'sound/impact_sounds/Generic_Swing_1.ogg', 40, FALSE, 0.1, 1.4)

		if (current_chain > 1 && current_chain < max_chain && penalty_disorient) // penalise getting interrupted after the first
			var/string ="[H] swings \the [master] too hard and loses their balance!"
			H.show_message(SPAN_ALERT(string), 1)
			H.changeStatus("disorient", disorient_duration_base + disorient_duration_additive * current_chain)
		afterUse(user)

	afterUse(mob/user)
		last_use = world.time
		user.next_click = world.time + 5 SECONDS
		..()

	modify_attack_result(mob/user, mob/target, datum/attackResults/msgs) //bleed on crit!
		if (msgs.damage > 0 && (msgs.stamina_crit || current_chain > 3))
			msgs.bleed_always = TRUE
			var/slash_flipped = (current_chain%2) * 180
			var/blood_dir = angle2dir(get_angle(user,target)+90 - slash_flipped)
			blood_slash(target,1,null, blood_dir, 3)
			if (current_chain > 3)
				msgs.played_sound= pick('sound/impact_sounds/Flesh_Stab_1.ogg','sound/impact_sounds/Slimy_Splat_1.ogg')
		return msgs

	slasher
		name = "Massacre"
		desc = "Repeatedly attack a target. Decapitate if left uninterrupted."
		max_chain = 13
		disorient_duration_additive = 0
		damage_mult_start = 0.6
		damage_mult_increment = 0.1
		penalty_disorient = FALSE
		modify_attack_result(mob/user, mob/target, datum/attackResults/msgs)
			..()
			if (msgs.damage > 0 && isliving(target))
				var/mob/living/carbon/human/H = target
				var/list/limbs = list("l_arm","r_arm","l_leg","r_leg")
				var/the_limb = null
				if (current_chain > 10 && current_chain < 13)
					msgs.played_sound = 'sound/impact_sounds/Flesh_Tear_2.ogg'
					if (user.zone_sel.selecting in limbs)
						the_limb = user.zone_sel.selecting
					else
						the_limb = pick("l_arm","r_arm","l_leg","r_leg")

					if (the_limb)
						H.sever_limb(the_limb)
				else if (current_chain == 13)
					msgs.played_sound = 'sound/impact_sounds/Flesh_Tear_2.ogg'
					H.organHolder.drop_and_throw_organ("head", dist = 5, speed = 1, showtext = 1)
					user.emote("laugh")
			return msgs



/obj/itemspecialeffect
	name = ""
	desc = ""
	icon = 'icons/effects/160x160.dmi'
	icon_state = ""
	anchored = 1
	layer = EFFECTS_LAYER_1
	pixel_x = -64
	pixel_y = -64
	var/can_clash = 0
	var/del_self = 1
	var/del_time = 5 SECONDS

	var/create_time = 0
	var/clash_time = 6

	var/do_flick = 1
	New()
		..()


	proc/setup(atom/location)
		src.set_loc(location)
		//src.loc = location
		if (do_flick)
			flick(icon_state,src)
		create_time = world.time //mbc : kind of janky lightweight way of making us not clash with ourselves. compare spawn time.
		if (del_self)
			SPAWN_DBG(del_time)
				qdel(src)
/*
	unpooled()
		..()

	pooled()
		..()
*/
	attackby()
		was_clashed()

	attack_hand()
		was_clashed()

	proc/was_clashed(var/playsound = 1)
		if (playsound)
			playsound(src.loc, 'sound/impact_sounds/Stone_Cut_1.ogg', 50, 0.1, 0, 2)
		var/obj/itemspecialeffect/clash/C = new()
		C.setup(src.loc)


	zantetsuken
		icon = 'icons/effects/64x64.dmi'
		icon_state = "zantetsuken"
		pixel_x = -16
		pixel_y = -16
		blend_mode = BLEND_ADD
		layer = EFFECTS_LAYER_1 + 1

		setup(atom/location)
			loc = location
			var/matrix/M = matrix()
			M.Scale(0.01)
			animate(src, transform=M, time=0)
			animate(transform=matrix(), time=2)
			animate(time=10)
			M = matrix()
			M.Scale(2)
			animate(alpha=0,transform=M, time=10)
			..()

	rushhit
		icon = 'icons/effects/64x64.dmi'
		icon_state = "rushhit"
		pixel_x = -16
		pixel_y = -16
		blend_mode = BLEND_ADD
		layer = EFFECTS_LAYER_1 + 1

	cracks
		icon = 'icons/effects/96x96.dmi'
		icon_state = "cracks"
		pixel_x = -32
		pixel_y = -32
		layer = OBJ_LAYER

	swipe
		icon = 'icons/effects/meleeeffects.dmi'
		icon_state = "sabre"
		pixel_x = -32
		pixel_y = -32
		can_clash = 1

	wide_swipe
		icon = 'icons/effects/96x96.dmi'
		icon_state = "wide_swipe"
		pixel_x = -32
		pixel_y = -32

	heavybump
		icon = 'icons/effects/effects.dmi'
		icon_state = "heavybump"
		pixel_x = 0
		pixel_y = 0

	heavystep
		icon = 'icons/effects/effects.dmi'
		icon_state = "heavystep"
		pixel_x = 0
		pixel_y = 0

	dagger
		icon = 'icons/effects/meleeeffects.dmi'
		icon_state = "dagger"
		pixel_x = -32
		pixel_y = -32

	bluefade
		icon = 'icons/effects/effects.dmi'
		icon_state = "bluefade2"
		pixel_x = 0
		pixel_y = 0
		blend_mode = BLEND_ADD

	glitter
		icon = 'icons/effects/effects.dmi'
		icon_state = "glitter"
		pixel_x = 0
		pixel_y = 0

	simple
		icon = 'icons/effects/effects.dmi'
		icon_state = "simple"
		pixel_x = 0
		pixel_y = 0
		can_clash = 1

	conc
		icon = 'icons/effects/effects.dmi'
		icon_state = "conc_fast"
		pixel_x = 0
		pixel_y = 0
		can_clash = 1

	spark
		icon = 'icons/effects/effects.dmi'
		icon_state = "sparks_attack"
		pixel_x = 0
		pixel_y = 0

		ntso
			icon = 'icons/effects/effects.dmi'
			icon_state = "baton-spark-ntso"
			pixel_x = 0
			pixel_y = 0
			can_clash = 1

	simple2
		icon = 'icons/effects/effects.dmi'
		icon_state = "hammer"
		pixel_x = 0
		pixel_y = 0
		can_clash = 0

	clash
		icon = 'icons/effects/effects.dmi'
		icon_state = "clash"
		pixel_x = 0
		pixel_y = 0
/*
		pooled()
			..()
			transform = null
			color = null
*/
	barrier
		name = "energy barrier"
		icon = 'icons/effects/effects.dmi'
		icon_state = "barrier"
		pixel_x = 0
		pixel_y = 0
		can_clash = 1
		density = 1
		del_self = 0
		clash_time = -1
		event_handler_flags = USE_CANPASS

		//mouse_opacity = 1
		var/bump_count = 0
		var/mob/master = 0

		setup(atom/location)
			src.density = 1
			..()

		disposing()
			density = 0
			..()

		was_clashed(var/playsound = 1)
			..(0)
			if (playsound)
				playsound(src.loc, 'sound/impact_sounds/Crystal_Shatter_1.ogg', 50, 0.1, 0, 0.5)
			qdel(src)

		proc/deactivate()
			if (src.qdeled || src.pooled)
				return
			playsound(src.loc, 'sound/items/miningtool_off.ogg', 30, 0.1, 0, 2)
			qdel(src)

		Bumped()
			bump_count++
			if(bump_count >= 4)
				was_clashed()

		bullet_act(var/obj/projectile/P)
			if (!P.goes_through_mobs)
				var/obj/projectile/Q = shoot_reflected_to_sender(P, src)
				P.die()

				src.visible_message("<span class='alert'>[src] reflected [Q.name]!</span>")
				playsound(src.loc, 'sound/impact_sounds/Energy_Hit_1.ogg', 40, 0.1, 0, 2.6)

				//was_clashed()
				return

	poof
		icon = 'icons/effects/64x64.dmi'
		icon_state = "poof"
		pixel_x = -16
		pixel_y = -8
		can_clash = 0
		mouse_opacity = 0

		setup(atom/location, forced = 0)
			loc = location
			if (del_self)
				SPAWN_DBG(5 SECONDS)
					qdel(src)

		was_clashed(var/playsound = 1)
			.=0

	screech
		icon = 'icons/effects/64x64.dmi'
		icon_state = "screamstack"
		pixel_x = -16
		pixel_y = -8
		can_clash = 0
		mouse_opacity = 0

	glare
		icon = 'icons/effects/64x64.dmi'
		icon_state = "glare"
		pixel_x = -16
		pixel_y = -8
		can_clash = 0

	derev
		icon = 'icons/effects/64x64.dmi'
		icon_state = "derev"
		pixel_x = -16
		pixel_y = -8
		can_clash = 0

	flame
		icon = 'icons/effects/effects.dmi'
		icon_state = "flame"
		pixel_x = 0
		pixel_y = 0
		can_clash = 0
		do_flick = 0

	katana_dash
		icon = 'icons/effects/effects.dmi'
		pixel_x = 0
		pixel_y = 0
		do_flick = 0
		can_clash = 0
		icon_state = "ka-start"
		del_time = 2 SECONDS

		start
			icon_state = "ka-start"
		mid
			icon_state = "ka-mid"
		end
			icon_state = "ka-end"

	nunchucks
		icon = 'icons/effects/meleeeffects.dmi'
		icon_state = "nunchucks"
		pixel_x = -32
		pixel_y = -32
		can_clash = 1

	graffiti
		icon = 'icons/effects/meleeeffects.dmi'
		icon_state = "graffiti1"
		pixel_x = -32
		pixel_y = -32

	graffiti_flipped
		icon = 'icons/effects/meleeeffects.dmi'
		icon_state = "graffiti2"
		pixel_x = -32
		pixel_y = -32

	chop //vertical slash
		plane = PLANE_SELFILLUM
		icon = 'icons/effects/meleeeffects.dmi'
		icon_state = "chop1"
		pixel_x = -32
		pixel_y = -32

	chop_flipped
		plane = PLANE_SELFILLUM
		icon = 'icons/effects/meleeeffects.dmi'
		icon_state = "chop2"
		pixel_x = -32
		pixel_y = -32

	cleave //horizontal slash
		plane = PLANE_SELFILLUM
		icon = 'icons/effects/meleeeffects.dmi'
		icon_state = "cleave1"
		pixel_x = -32
		pixel_y = -32

	cleave_flipped
		plane = PLANE_SELFILLUM
		icon = 'icons/effects/meleeeffects.dmi'
		icon_state = "cleave2"
		pixel_x = -32
		pixel_y = -32

	jab
		icon = 'icons/effects/effects.dmi'
		icon_state = "quickjab"
		pixel_x = 0
		pixel_y = 0

		New()
			pixel_x = rand(-5,5)
			pixel_y = rand(-5,5)
			..()

/obj/itemspecialeffect/impact
	icon = 'icons/effects/impacts.dmi'
	del_time = 2 SECONDS
	pixel_x = 0
	pixel_y = 0


	New()
		pixel_x = rand(-3,3)
		pixel_y = rand(-15,6)
		..()

/obj/itemspecialeffect/impact/blood
	icon_state = "blood_impact1"

	New()
		..()
		if (prob(50))
			icon_state = "blood_impact2"

/obj/itemspecialeffect/impact/energy
	icon_state = "energy_impact"

/obj/itemspecialeffect/impact/taser
	icon_state = "taser_impact"

/obj/itemspecialeffect/impact/silicon
	icon_state = "silicon_impact1"

	New()
		..()
		if (prob(66))
			icon_state = "silicon_impact2"

/////////REFERENCES

/datum/action/bar/private/icon/rush
	id = "rush"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACTION
	var/datum/item_special/rush/special
	var/mob/user
	var/atom/target
	var/progress = 0.01
	var/params = null
	duration = -1

	New(var/datum/item_special/rush/D, var/mob/U, var/atom/T)
		..()
		if(!istype(D, /datum/item_special/rush))
			interrupt(INTERRUPT_ALWAYS)
		if(!D || !U || !T)
			interrupt(INTERRUPT_ALWAYS)
		else
			special = D
			progress = D.starting_progress
			user = U
			target = T

	disposing()
		if(special)
			special.action = null
		..()

	onStart()
		..()
		user.canmove = 0

	onInterrupt(var/flag)
		..()
		user.canmove = initial(user.canmove)
		if(special)
			special.action = null
		return

	onEnd()
		..()
		user.canmove = initial(user.canmove)
		if(target == null || user == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(special)
			if(special.master == user.equipped() && istype(special, /datum/item_special/rush))
				special.rush(user, target, progress, params)
			special.action = null
			return

	onUpdate()
		if(target == null || user == null || !istype(special, /datum/item_special/rush))
			interrupt(INTERRUPT_ALWAYS)
			return

		if(special)
			if(special.master != user.equipped())
				interrupt(INTERRUPT_ALWAYS)
				return

		progress = min(progress + 0.2, 1)

		bar.color = "#0000FF"
		bar.transform = matrix(progress, 1, MATRIX_SCALE)
		bar.pixel_x = -nround( ((30 - (30 * progress)) / 2) )

		if(progress == 1)
			state = ACTIONSTATE_FINISH
			return
