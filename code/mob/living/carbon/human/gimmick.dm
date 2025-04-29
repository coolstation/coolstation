// cluwne

/mob/living/carbon/human/cluwne
	New()
		..()
		SPAWN_DBG(0)
			src.gender = "male"
			src.real_name = "cluwne"
			src.contract_disease(/datum/ailment/disease/cluwneing_around,null,null,1)
			src.contract_disease(/datum/ailment/disability/clumsy,null,null,1)

			src.equip_new_if_possible(/obj/item/clothing/under/gimmick/cursedclown, slot_w_uniform)
			src.equip_new_if_possible(/obj/item/clothing/shoes/cursedclown_shoes, slot_shoes)
			src.equip_new_if_possible(/obj/item/clothing/mask/cursedclown_hat, slot_wear_mask)
			src.equip_new_if_possible(/obj/item/clothing/gloves/cursedclown_gloves, slot_gloves)
			src.make_jittery(1000)
			src.bioHolder.AddEffect("clumsy")
			src.take_brain_damage(80)

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1
		if (isdead(src))
			return
		jitteriness = INFINITY
		stuttering = INFINITY
		HealDamage("All", INFINITY, INFINITY)
		take_oxygen_deprivation(-INFINITY)
		take_toxin_damage(-INFINITY)
		if(prob(5))
			SPAWN_DBG(0)
				src.say("HANK!")
				playsound(src.loc, "sound/musical_instruments/Boathorn_1.ogg", 22, 1)

/mob/living/carbon/human/cluwne/floor
	nodamage = 1
	anchored = 1
	layer = 0
	plane = PLANE_UNDERFLOOR

	var/name_override = "floor cluwne"
	New()
		..()
		SPAWN_DBG(0)
			ailments.Cut()
			real_name = name_override
			name = name_override

	cluwnegib()
		return

	ex_act()
		return

/mob/living/carbon/human/cluwne/floor/gimmick
	layer = 4
	plane = PLANE_DEFAULT
	nodamage = 0

	New()
		..()
		SPAWN_DBG(0)
			src.add_ability_holder(/datum/abilityHolder/gimmick)
			abilityHolder.addAbility(/datum/targetable/gimmick/reveal)
			abilityHolder.addAbility(/datum/targetable/gimmick/movefloor)
			abilityHolder.addAbility(/datum/targetable/gimmick/floorgrab)
			SPAWN_DBG(1 SECOND)
				abilityHolder.updateButtons()

// Come to collect a poor unfortunate soul
/mob/living/carbon/human/satan
	nodamage = 1
	anchored = 1
	layer = 0
	plane = PLANE_UNDERFLOOR
	New()
		..()
		SPAWN_DBG(0)
			src.gender = "male"
			src.real_name = "Satan"
			src.name = "Satan"
			src.equip_new_if_possible(/obj/item/clothing/under/misc/lawyer/red/demonic, src.slot_w_uniform)
			src.bioHolder.AddEffect("horns", 0, 0, 1)
			src.bioHolder.AddEffect("aura_fire", 0, 0, 1)

/mob/living/carbon/human/satan/gimmick
	anchored = 1
	layer = 4
	plane = PLANE_DEFAULT

	New()
		..()
		src.add_ability_holder(/datum/abilityHolder/gimmick)
		src.real_name = "Satan"
		src.nodamage = 1

		src.bioHolder.AddEffect("horns", 0, 0, 1)
		src.bioHolder.AddEffect("hell_fire", 0, 0, 1)
		abilityHolder.addAbility(/datum/targetable/gimmick/spawncontractsatan)
		abilityHolder.addAbility(/datum/targetable/gimmick/go2hell)
		abilityHolder.addAbility(/datum/targetable/gimmick/highway2hell)
		abilityHolder.addAbility(/datum/targetable/gimmick/reveal)
		abilityHolder.addAbility(/datum/targetable/gimmick/movefloor)
		SPAWN_DBG(1 SECOND)
			abilityHolder.updateButtons()

			src.equip_new_if_possible(/obj/item/clothing/under/misc/lawyer/red/demonic, src.slot_w_uniform)
			src.equip_new_if_possible(/obj/item/clothing/suit/labcoat/hitman/satansuit, slot_wear_suit)
			src.equip_new_if_possible(/obj/item/clothing/shoes/red, slot_shoes)
			src.equip_new_if_possible(/obj/item/storage/backpack, slot_back)
			src.equip_new_if_possible(/obj/item/clothing/gloves/ring/wizard/teleport, slot_gloves) //Yes I could make a special satan teleport power, or I can give him a ring. Fuck it right?
			src.equip_new_if_possible(/obj/item/device/radio/headset, slot_ears)
			src.put_in_hand_or_drop(new /obj/item/storage/briefcase/satan)

	initializeBioholder()
		bioHolder.age = 400
		bioHolder.mobAppearance.customization_first = new /datum/customization_style/hair/short/pomp
		bioHolder.mobAppearance.customization_first_color = "#000000"
		bioHolder.mobAppearance.gender = "male"
		bioHolder.mobAppearance.underwear = "boxers"
		. = ..()

/mob/living/carbon/human/jester

	New()
		..()
		SPAWN_DBG(0)
			src.real_name = "Jester"
			src.add_ability_holder(/datum/abilityHolder/gimmick)
			src.nodamage = 1
			src.bioHolder.AddEffect("accent_void", 0, 0, 1)
			abilityHolder.addAbility(/datum/targetable/gimmick/spooky)
			abilityHolder.addAbility(/datum/targetable/gimmick/Jestershift)
			abilityHolder.addAbility(/datum/targetable/gimmick/scribble)

		SPAWN_DBG(1 SECOND)
			abilityHolder.updateButtons()

			src.equip_new_if_possible(/obj/item/clothing/under/gimmick/jester, src.slot_w_uniform)
			src.equip_new_if_possible(/obj/item/clothing/shoes/jester, slot_shoes)
			src.equip_new_if_possible(/obj/item/storage/backpack, slot_back)
			src.equip_new_if_possible(/obj/item/clothing/mask/jester, slot_wear_mask)
			src.equip_new_if_possible(/obj/item/device/radio/headset, slot_ears)
			src.equip_new_if_possible(/obj/item/clothing/head/jester, slot_head)

/mob/living/carbon/human/cluwne/floor/anticheat
	name_override = "anti-cheat cluwne"

mob/living/carbon/human/cluwne/satan
	New()
		..()
		SPAWN_DBG(0)
			src.bioHolder.AddEffect("horns", 0, 0, 0, 1)
			src.bioHolder.AddEffect("aura_fire", 0, 0, 0, 1)
			src.bioHolder.AddEffect("superfartgriff")
			src.bioHolder.AddEffect("bigpuke", 0, 0, 0, 1)
			src.bioHolder.AddEffect("melt", 0, 0, 0, 1)

mob/living/carbon/human/cluwne/satan/megasatan //someone can totally use this for an admin gimmick.
	New()
		..()
		SPAWN_DBG(0)
			src.unkillable = 1 //for the megasatan in you

/*
 * Chicken man belongs in human zone, not ai zone
 */
/mob/living/carbon/human/chicken
	name = "chicken man"
	real_name = "chicken man"
	desc = "half man, half BWAHCAWCK!"
#ifdef IN_MAP_EDITOR
	icon_state = "m-none"
#endif
	New()
		. = ..()
		SPAWN_DBG(0.5 SECONDS)
			if (!src.disposed)
				src.bioHolder.AddEffect("chicken", 0, 0, 1)

/mob/living/carbon/human/chicken/ai_controlled
	is_npc = TRUE
	uses_mobai = TRUE
	New()
		. = ..()
		src.ai = new /datum/aiHolder/wanderer(src)

/datum/aiHolder/wanderer
	New()
		. = ..()
		var/datum/aiTask/timed/wander/W =  get_instance(/datum/aiTask/timed/wander, list(src))
		W.transition_task = W
		default_task = W

/datum/aiHolder/wandererf
	New()
		. = ..()
		var/datum/aiTask/timed/wander/f/W =  get_instance(/datum/aiTask/timed/wander/f, list(src))
		W.transition_task = W
		default_task = W

/mob/living/carbon/human/fathergraham
	New()
		..()
		src.equip_new_if_possible(/obj/item/clothing/shoes/red, slot_shoes)
		src.equip_new_if_possible(/obj/item/clothing/under/misc/chaplain, slot_w_uniform)

	initializeBioholder()
		. = ..()
		bioHolder.mobAppearance.gender = "male"
		src.real_name = "Father Graham"
		bioHolder.bloodType = "B+"

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if(prob(1) && !src.stat)
			if(prob(50))
				SPAWN_DBG(0) src.say(pick("My wife left me...","My wife left me!","MY WIFE, SHE LEFT ME.", "But, the bathrooms...", "Just wait until the mothers mailing list hears of this...", "They took my programme...", "You remember \"The Tech Storage Guys\" right? I wrote that.", "I'm just thinking about the bathrooms... the pee...", "Why won't my kids call?", "I'm just really out of steam right now..."))
			else
				emote(pick("sigh","cry","sob","whimper","pout"))
	/*
	attackby(obj/item/W, mob/M)
		if (istype(W, /obj/item/paper/postcard/owlery))
			if(ON_COOLDOWN(src, "attackby_chatter", 3 SECONDS)) return
			boutput(M, "<span class='notice'><b>You show [W] to [src]</b> </span>")
			SPAWN_DBG(1 SECOND)
				say("Aye! Bill won't stop talking about it!")
			return
		..()
	*/

	//special response to a dracula
	/*
	was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0, var/intent = null)
		. = ..()
		if (special) //vamp or ling
			src.target = M
			src.ai_state = AI_ATTACKING
			src.ai_threatened = world.timeofday
			src.ai_target = M
		*/

		//Bartender isnt' used right now.
		//Whoever does eventually put him back in the game : Use a global list of bartenders or something. Dont check all_viewers
		//	for (var/mob/living/carbon/human/npc/diner_bartender/BT in all_viewers(7, src))
			//	BT.protect_from(M, src)


proc/empty_mouse_params()//TODO MOVE THIS!!!
	.= list()
	.["icon-x"] = 0
	.["icon-y"] = 0
	.["screen-loc"] = 0
	.["left"] = 1
	.["middle"] = 0
	.["right"] = 0
	.["ctrl"] = 0
	.["shift"] = 0
	.["alt"] = 0
	.["drag-cell"] = 0
	.["drop-cell"] = 0
	.["drag"] = 0


/mob/living/carbon/human/proc/auto_interact(var/msg)
	.= 0
	var/list/hudlist = list()

	if (src.client)
		for (var/atom/I in src.hud.inventory_bg)
			if (istype(I,/atom/movable/screen/hud))
				hudlist += I

	for (var/obj/item/I in src.contents)
		if (istype(I,/obj/item/organ) || istype(I,/obj/item/skull) || istype(I,/obj/item/parts)) continue //FUCK
		hudlist += I
		if (istype(I,/obj/item/storage))
			hudlist += I.contents
	hudlist += src.item_abilities

	var/list/close_match = list()
	for (var/atom/I in view(1,src) + hudlist)
		if (!I.mouse_opacity) continue
		if (TWITCH_BOT_INTERACT_BLOCK(I)) continue
		if (istype(I,/obj/item/organ) || istype(I,/obj/item/skull) || istype(I,/obj/item/parts)) continue  //fuck x3
		if ((msg == "airlock" || msg == "door") && istype(I,/obj/machinery/door))
			close_match += I
			continue
		if ((msg == "internals" || msg == "internal" || msg == "o2" || msg == "oxygen" || msg == "air") && istype(I,/obj/ability_button/tank_valve_toggle))
			close_match += I
			continue
		if ((msg == "jetpack" || msg == "jet" || msg == "fly") && istype(I,/obj/ability_button/jetpack_toggle))
			close_match += I
			continue

		if (I.name == msg)
			close_match.len = 0
			close_match += I
			break
		else if (findtext(I.name,msg))
			close_match += I

	if (close_match.len)
		var/atom/picked = pick(close_match)

		var/obj/item/W = src.equipped()
		if (!src.restrained())
			if (istype(picked,/atom/movable/screen/hud))
				var/atom/movable/screen/hud/HUD = picked
				var/list/params = empty_mouse_params()
				HUD.clicked(HUD.id, src, params)
			else if (istype(picked,/obj/ability_button))
				var/obj/ability_button/A = picked
				A.execute_ability()
			else if (istype(picked,/obj/machinery/vehicle))
				var/obj/machinery/vehicle/V = picked
				V.board_pod(src)
			else if (istype(picked,/obj/vehicle))
				var/obj/vehicle/V = picked
				V.MouseDrop_T(src,src)
			else if(W)
				W.attack(picked, src, ran_zone("chest"))
			else
				picked.Attackhand(src)

		.= picked


// merchant

/mob/living/carbon/human/merchant
	New()
		..()
		SPAWN_DBG(0)
			src.gender = "male"
			src.real_name = pick("Slick", "Fast", "Frugal", "Thrifty", "Clever", "Shifty") + " " + pick_string_autokey("names/first_male.txt")
			src.equip_new_if_possible(/obj/item/clothing/shoes/black, slot_shoes)
			src.equip_new_if_possible(/obj/item/clothing/under/gimmick/merchant, slot_w_uniform)
			src.equip_new_if_possible(/obj/item/clothing/suit/merchant, slot_wear_suit)
			src.equip_new_if_possible(/obj/item/clothing/glasses/sunglasses, slot_glasses)
			src.equip_new_if_possible(/obj/item/clothing/head/merchant_hat, slot_head)

// myke
// what the fuck is this??
/*
/mob/living/carbon/human/myke
	New()
		..()
		src.gender = "male"
		src.real_name = "Myke"
		src.equip_new_if_possible(/obj/item/clothing/shoes/red, slot_shoes)
		src.equip_new_if_possible(/obj/item/clothing/under/color/lightred, slot_w_uniform)
		src.equip_new_if_possible(/obj/item/clothing/mask/breath, slot_wear_mask)
		src.internal = src.back

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1
		src.changeStatus("weakened", 5 SECONDS)
		if(prob(15))
			SPAWN_DBG(0) emote(pick("giggle", "laugh"))
		if(prob(1))
			SPAWN_DBG(0) src.say(pick("You guys wanna hear me play bass?", stutter("HUFFFF"), "I missed my AA meeting to play Left 4 Dead...", "I got my license suspended AGAIN", "I got fired from [pick("McDonald's", "Boston Market", "Wendy's", "Burger King", "Starbucks", "Menard's")]..."))
*/
// waldo

// Where's WAL[DO/LY]???

/mob/living/carbon/human/waldo
	New()
		..()
		SPAWN_DBG(0)
			src.gender = "male"
			src.real_name = "Waldo"

			src.equip_new_if_possible(/obj/item/clothing/shoes/brown, slot_shoes)
			src.equip_new_if_possible(/obj/item/clothing/under/gimmick/waldo, slot_w_uniform)
			src.equip_new_if_possible(/obj/item/clothing/head/waldohat, slot_head)
			src.equip_new_if_possible(/obj/item/device/radio/headset, slot_ears)
			src.equip_new_if_possible(/obj/item/storage/backpack, slot_back)

/mob/living/carbon/human/fake_waldo
	nodamage = 1
	New()
		..()
		var/shoes = text2path("/obj/item/clothing/shoes/" + pick("black","brown","red"))
		src.equip_new_if_possible(shoes, slot_shoes)
		src.equip_new_if_possible(/obj/item/clothing/under/gimmick/fake_waldo, slot_w_uniform)
		src.equip_new_if_possible(/obj/item/device/radio/headset, slot_ears)
		src.equip_new_if_possible(/obj/item/storage/backpack, slot_back)
		if(prob(75))
			src.equip_new_if_possible(/obj/item/clothing/head/fake_waldohat, slot_head)
		else if(prob(20))
			src.equip_new_if_possible(/obj/item/clothing/glasses/sunglasses, slot_glasses)
		walk(src, pick(cardinal), 1)
		sleep(rand(150, 600))
		illusion_expire()

	initializeBioholder()
		. = ..()
		src.bioHolder.mobAppearance.s_tone = pick("#FAD7D0", "#BD8A57", "#935D37")
		src.bioHolder.mobAppearance.s_tone_original = src.bioHolder.mobAppearance.s_tone
		src.gender = "male"
		src.real_name = "[pick(prob(150); "W", "V")][pick(prob(150); "a", "au", "o", "e")][pick(prob(150); "l", "ll")][pick(prob(150); "d", "t")][pick(prob(150); "o", "oh", "a", "e")]"

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1
		if(prob(33) && canmove && isturf(loc))
			step(src, pick(cardinal))
	proc/illusion_expire(mob/user)
		if(user)
			boutput(user, "<span class='alert'><B>You reach out to attack the Waldo illusion but it explodes into dust, knocking you off your feet!</B></span>")
			user.changeStatus("weakened", 4 SECONDS)
		for(var/mob/M in viewers(src, null))
			if(M.client && M != user)
				M.show_message("<span class='alert'><b>The Waldo illusion explodes into smoke!</b></span>")
		var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
		smoke.set_up(1, 0, src.loc)
		smoke.start()
		SPAWN_DBG(0)
			qdel(src)
		return
	attack_hand(mob/user)
		return illusion_expire(user)
	attackby(obj/item/W, mob/user)
		return illusion_expire(user)
	MouseDrop(mob/M)
		if(iscarbon(M) && !M.hasStatus("handcuffed"))
			return illusion_expire(M)

/mob/living/carbon/human/don_glab
	real_name = "Donald \"Don\" Glabs"
	gender = MALE

	New()
		..()
		src.equip_new_if_possible(/obj/item/clothing/shoes/orange, slot_shoes)
		src.equip_new_if_possible(/obj/item/clothing/under/suit/red, slot_w_uniform)
		src.equip_if_possible(new /obj/item/clothing/glasses/sunglasses, slot_glasses)
		src.equip_new_if_possible(/obj/item/clothing/head/cowboy, slot_head)

	initializeBioholder()
		. = ..()
		bioHolder.age = 44
		bioHolder.bloodType = "Worchestershire"
		bioHolder.mobAppearance.customization_first = new /datum/customization_style/hair/short/pomp
		bioHolder.mobAppearance.customization_first_color = "#F6D646"
		bioHolder.mobAppearance.gender = "male"
		bioHolder.mobAppearance.underwear = "boxers"

	attackby(obj/item/W, mob/M)
		if (istype(W, /obj/item/paper/postcard/owlery))
			if(ON_COOLDOWN(src, "attackby_chatter", 3 SECONDS)) return
			boutput(M, "<span class='notice'><b>You show [W] to [src]</b> </span>")
			SPAWN_DBG(1 SECOND)
				say("Oh yeah sure, I seen it. That ol- how would he say it, [BILL_PICK("insults")]? He won't stop going on and on and on...")
		..()

	was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0, var/intent = null)
		. = ..()
		if (special) //vamp or ling
			src.target = M
			src.ai_state = AI_ATTACKING
			src.ai_threatened = world.timeofday
			src.ai_target = M

		//Bartender isnt' used right now.
		//Whoever does eventually put him back in the game : Use a global list of bartenders or something. Dont check all_viewers
		//	for (var/mob/living/carbon/human/npc/diner_bartender/BT in all_viewers(7, src))
			//	BT.protect_from(M, src)

/mob/living/carbon/human/tommy
	sound_list_laugh = list('sound/voice/tommy_hahahah.ogg', 'sound/voice/tommy_hahahaha.ogg')
	sound_list_scream = list('sound/voice/tommy_you-are-tearing-me-apart-lisauh.ogg', 'sound/voice/tommy_did-not-hit-hehr.ogg')
	sound_list_flap = list('sound/voice/tommy_weird-chicken-noise.ogg')

	New()
		..()
		src.equip_new_if_possible(/obj/item/clothing/shoes/black {cant_drop = 1; cant_other_remove = 1; cant_self_remove = 1} , slot_shoes)
		src.equip_new_if_possible(/obj/item/clothing/under/suit {cant_drop = 1; cant_other_remove = 1; cant_self_remove = 1} , slot_w_uniform)

		src.equip_new_if_possible(/obj/item/device/radio/headset, slot_ears)
		src.equip_new_if_possible(/obj/item/storage/backpack, slot_back)
		src.equip_new_if_possible(/obj/item/football, slot_in_backpack)

	initializeBioholder()
		. = ..()
		src.real_name = Create_Tommyname()

		src.gender = "male"
		bioHolder.mobAppearance.customization_first = new /datum/customization_style/hair/long/dreads
		bioHolder.mobAppearance.gender = "male"
		bioHolder.mobAppearance.s_tone = "#FAD7D0"
		bioHolder.mobAppearance.s_tone_original = "#FAD7D0"
		bioHolder.AddEffect("accent_tommy")

/mob/living/carbon/human/waiter
	real_name = "Cade Plids"

	New()
		..()
		SPAWN_DBG(0)
		JobEquipSpawned("Waiter")

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if(prob(1) && !src.stat)
			SPAWN_DBG(0) src.say(pick( "Oh my god!", "No, no, they can't be gone!", "This can't be happening!", "How did I get here?!","Where is everyone else?!"))
		if(prob(1) && !src.stat)
			SPAWN_DBG(0) src.emote(pick("shiver","shudder","blink","sob","faint","pale","twitch","scream"))

/mob/living/carbon/human/secret
	unobservable = 1

/datum/aiHolder/human/yank
	New()
		..()
		var/datum/aiTask/timed/targeted/human/suplex/A = get_instance(/datum/aiTask/timed/targeted/human/suplex, list(src))
		var/datum/aiTask/timed/targeted/human/boxing/B = get_instance(/datum/aiTask/timed/targeted/human/boxing, list(src))
		var/datum/aiTask/timed/targeted/human/get_weapon/C = get_instance(/datum/aiTask/timed/targeted/human/get_weapon, list(src))
		var/datum/aiTask/timed/targeted/human/boxing/D = get_instance(/datum/aiTask/timed/targeted/human/boxing, list(src))
		var/datum/aiTask/timed/targeted/human/flee/F = get_instance(/datum/aiTask/timed/targeted/human/flee, list(src))
		F.transition_task = B
		B.transition_task = C
		C.transition_task = D
		D.transition_task = A
		A.transition_task = F
		default_task = B




/mob/living/carbon/human/proc/spacer_name(var/type = "spacer")
	var/constructed_name = ""

	switch(type)
		if("spacer")
			constructed_name = "[prob(10)?SPACER_PICK("honorifics")+" ":""][prob(80)?SPACER_PICK("pejoratives")+" ":SPACER_PICK("superlatives")+" "][prob(10)?SPACER_PICK("stuff")+" ":""][SPACER_PICK("firstnames")]"
		if("juicer")
			constructed_name = "[prob(10)?SPACER_PICK("honorifics")+" ":""][prob(20)?SPACER_PICK("stuff")+" ":""][SPACER_PICK("firstnames")+" "][prob(80)?SPACER_PICK("nicknames")+" ":""][prob(50)?SPACER_PICK("firstnames"):SPACER_PICK("lastnames")]"

	return constructed_name


/mob/living/carbon/human/spacer
	is_npc = 1
	uses_mobai = 1
	New()
		..()
		src.say("Hey there [JOHN_PICK("insults")]")//debug

		src.equip_new_if_possible(/obj/item/clothing/shoes/orange, slot_shoes)
		src.equip_new_if_possible(/obj/item/clothing/under/rank/chief_engineer, slot_w_uniform)
		src.equip_if_possible(new /obj/item/clothing/glasses/sunglasses, slot_glasses)

		src.ai = new /datum/aiHolder/human/yank(src)
		remove_lifeprocess(/datum/lifeprocess/blindness)
		remove_lifeprocess(/datum/lifeprocess/viruses)
		src.ai.enabled = 0

	initializeBioholder()
		. = ..()
		SPAWN_DBG(0) // ok, this crap actually needs to be spawned (for now!) because of organHolders being initialized at weird times
			randomize_look(src, 1, 1, 1, 1, 1, 0)
			real_name = spacer_name(pick("spacer","juicer"))
			gender = pick(MALE,FEMALE)

	was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0, var/intent = null)
		. = ..()
		if(isdead(src))
			return
		if(prob(10))
			say(pick("Oh no you don't - not today, not ever!","Nice try fuckass, but I ain't goin' down so easy!","IMMA SCREAM BUDDY!","You wanna fuck around bucko? You wanna try your luck?"))
			src.ai.interrupt()
		src.ai.target = M
		src.ai.enabled = 1

// This is Big Yank, one of John Bill's old buds. Yank owes John a favor. He's a Juicer.
/mob/living/carbon/human/big_yank
	gender = MALE
	is_npc = 1
	uses_mobai = 1

	New()
		..()
		src.equip_new_if_possible(/obj/item/clothing/shoes/orange, slot_shoes)
		src.equip_new_if_possible(/obj/item/clothing/under/rank/chief_engineer, slot_w_uniform)
		src.equip_if_possible(new /obj/item/clothing/glasses/sunglasses, slot_glasses)

		src.ai = new /datum/aiHolder/human/yank(src)
		remove_lifeprocess(/datum/lifeprocess/blindness)
		remove_lifeprocess(/datum/lifeprocess/viruses)
		src.ai.enabled = 0

	initializeBioholder()
		. = ..()
		bioHolder.age = 49
		bioHolder.mobAppearance.customization_first = new /datum/customization_style/beard/fullbeard
		bioHolder.mobAppearance.customization_first_color = "#555555"
		bioHolder.mobAppearance.gender = "male"
		bioHolder.mobAppearance.underwear = "boxers"
		real_name = "[pick("Chut","Brendt","Franko","Steephe","Geames","Whitney","Thom","Cheddar")] \"Big Yank\" Whitney"


	attack_hand(mob/M)
		..()

		if(isdead(src))
			return
		if (prob(30))
			say(pick("Hey you better back off [pick_string("johnbill.txt", "insults")]- I'm busy.","You feelin lucky, [pick_string("johnbill.txt", "insults")]?"))
			src.ai.target = null
			src.ai.enabled = 0

	attackby(obj/item/W, mob/M)
		if (istype(W, /obj/item/paper/tug/invoice))
			if(ON_COOLDOWN(src, "attackby_chatter", 3 SECONDS)) return
			boutput(M, "<span class='notice'><b>You show [W] to [src]</b> </span>")
			SPAWN_DBG(1 SECOND)
				say(pick("Brudder, I did that job months ago. Fuck outta here with that.","Oh come on, quit wastin my time [pick_string("johnbill.txt", "insults")]."))
			return
		..()
#ifdef SECRETS_ENABLED
		if (istype(W, yank_object))
			if(ON_COOLDOWN(src, "attackby_chatter", 3 SECONDS)) return
			boutput(M, "<span class='notice'><b>You show [W] to [src]</b> </span>")
			SPAWN_DBG(1 SECOND)
				yank_reaction(W)
			return
#endif

	was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0, var/intent = null)
		. = ..()
		if(isdead(src))
			return
		if(prob(20))
			say(pick("Oh no you don't - not today, not ever!","Nice try asshole, but I ain't goin' down so easy!","Gonna take more than that to take out THIS Juicer!","You wanna fuck around bucko? You wanna try your luck?"))
			src.ai.interrupt()
		src.ai.target = M
		src.ai.enabled = 1


#undef BILL_PICK

/mob/living/carbon/human/geneticist
	is_npc = 1
	uses_mobai = 1
	real_name = "Juicer Gene"
	gender = NEUTER
	max_health = 50

	New()
		..()
		src.ai = new /datum/aiHolder/human/geneticist(src)
		src.equip_new_if_possible(/obj/item/clothing/shoes/dress_shoes, slot_shoes)
		src.equip_new_if_possible(/obj/item/clothing/under/rank/geneticist, slot_w_uniform)
		src.equip_new_if_possible(/obj/item/clothing/suit/labcoat/pathology, slot_wear_suit)
		src.equip_new_if_possible(/obj/item/card/id/juicer/gene, slot_wear_id)
		if(prob(50))
			src.equip_new_if_possible(/obj/item/clothing/glasses/regular, slot_glasses)


/mob/living/carbon/human/gunsemanne
	is_npc = 1
	//uses_mobai = 1
	real_name = "Pingin' \"Grand\" Thum"
	gender = NEUTER
	max_health = 150
	var/obj/item/part_in_inventory = null
	var/price_expected = 0

	proc/appraise(obj/item/W, mob/M)
		M.u_equip(W)
		W.unequipped(M)
		W.dropped(M)
		W.set_loc(src)
		part_in_inventory = W

		if(istype(W, /obj/item/gun/modular))
			price_expected = 0
			var/obj/item/gun/modular/gun = W

			if(!gun.gun_DRM)
				src.say("This is already cracked, juicer. [pick("Gimme something else.","You easily startled?","You know the drill.","C'mon.","You alright?")]")
				part_in_inventory.set_loc(src.loc)
				W.throw_at(M.loc, 10, 2)
				part_in_inventory = null
				return
			else if(gun.gun_DRM & GUN_NANO)
				price_expected = rand(9,11)
				src.say("Nano tech's kind of tricky. [price_expected] Hundo. Non-negotiable.")
				price_expected *= 100

			else if(gun.gun_DRM & GUN_JUICE)
				price_expected = rand(200,300)
				src.say("Childs play. [price_expected] bucks.")

			else if(gun.gun_DRM & GUN_SOVIET)
				price_expected = rand(800,900)
				src.say("Oooh hoo, vintage communist gear. Not easy. [price_expected]?")

			else if(gun.gun_DRM & GUN_ITALIAN)
				price_expected = 100
				src.say("Christ these things basically crack themselves. One crisp double-zero.")

			else if(gun.gun_DRM & GUN_FOSS)
				price_expected = 1000
				src.say("Uhhhh... I mean, a thousand bucks will get you somewhere but I don't think you're getting that past security.")


		else if(istype(W, /obj/item/gun_parts))
			price_expected = 0
			var/obj/item/gun_parts/part = W

			if(!part.part_DRM)
				src.say("This is already cracked, juicer. [pick("Gimme something else.","You easily startled?","You know the drill.","C'mon.","You alright?")]")
				part_in_inventory.set_loc(src.loc)
				W.throw_at(M.loc, 10, 2)
				part_in_inventory = null
				return

			else if(part.part_DRM & GUN_FOSS)
				price_expected = 500
				src.say("At this point i'm not even gonna ask. Five hundred, no less.")

			else if(part.part_DRM & GUN_NANO)
				price_expected = 350
				src.say("Nanotrasen parts... ugh. Whatever, 350?")

			else if(part.part_DRM & GUN_SOVIET)
				price_expected = 250
				src.say("These things are getting scarce. Two-Fifty.")

			else if(part.part_DRM & GUN_JUICE)
				price_expected = 100
				src.say("These used to come unregistered, yknow. Hundred bucks.")


			else if(part.part_DRM & GUN_ITALIAN)
				price_expected = 100
				src.say("Not sure why you'd want that... but alright. Cool hundo.")



		else
			src.say("Uhhhh... I guess I can't read this. Call a coder. That's fucked.")
			return


	proc/crack_the_drm(mob/M)
		price_expected = 0
		if(!part_in_inventory)
			src.say("Uhhhh... I guess I lost it. Call a coder. That's fucked.")
			return
		else
			if(istype(part_in_inventory, /obj/item/gun/modular))
				var/obj/item/gun/modular/gun = part_in_inventory
				gun.gun_DRM = null

			if(istype(part_in_inventory, /obj/item/gun_parts))
				var/obj/item/gun_parts/part = part_in_inventory
				part.part_DRM = null

			src.say("aaaaaall right, there we go.")
			sleep(1 SECOND)
			part_in_inventory.set_loc(src.loc)
			part_in_inventory.throw_at(M.loc, 10, 2)
			part_in_inventory = null



	attack_hand(mob/M)
		if((M.a_intent == INTENT_HELP || M.a_intent == INTENT_DISARM) && part_in_inventory)
			src.say("Sure, it's yours after all.")
			part_in_inventory.set_loc(src.loc)
			part_in_inventory.throw_at(M.loc, 10, 2)
			part_in_inventory = null
			price_expected = 0
		else
			..()



	attackby(obj/item/W, mob/M)
		if(istype(W, /obj/item/gun/modular) || istype(W, /obj/item/gun_parts))
			if(price_expected && part_in_inventory)
				src.say("You gonna pay me first? You owe me [price_expected] bucks, or you can have [part_in_inventory] back.")
				return
			else
				appraise(W,M)
				return
		else if(istype(W, /obj/item/spacecash))
			var/obj/item/spacecash/dosh = W
			if(!price_expected)
				src.say("You making a donation? I didn't ask you for shit.")
				return
			else if(part_in_inventory && (dosh.amount >= price_expected))
				src.say("Right. [price_expected] septims, numbers filed.")
				dosh.change_stack_amount(0 - price_expected)
				SPAWN_DBG(2 SECONDS)
					crack_the_drm(M)
				return
		else
			..()

	was_harmed(var/mob/M as mob, var/obj/item/weapon = 0, var/special = 0, var/intent = null)
		. = ..()
		if(isdead(src))
			return

		src.ai.target = M
		src.ai.enabled = 1

	New()
		gender = pick(NEUTER,MALE,FEMALE,PLURAL)
		..()
		src.ai = new /datum/aiHolder/human/yank(src) // todo: replace this (its fine for now)
		src.equip_new_if_possible(/obj/item/clothing/shoes/swat/knight, slot_shoes)
		src.equip_new_if_possible(/obj/item/clothing/under/rank/det, slot_w_uniform)
		src.equip_new_if_possible(/obj/item/clothing/suit/armor/gunsemanne, slot_wear_suit)
		src.equip_new_if_possible(/obj/item/card/id/juicer/security, slot_wear_id)
		if(prob(50))
			src.equip_new_if_possible(/obj/item/clothing/glasses/sunglasses, slot_glasses)
		else
			src.equip_new_if_possible(/obj/item/clothing/glasses/nightvision, slot_glasses)

	initializeBioholder()
		. = ..()
		bioHolder.mobAppearance.customization_first = new /datum/customization_style/moustache/devil
		bioHolder.mobAppearance.customization_first_color = "#281400"
		bioHolder.mobAppearance.customization_second = new /datum/customization_style/hair/hairup/ponytail
		bioHolder.mobAppearance.customization_second_color = "#311800"
		bioHolder.mobAppearance.customization_third = new /datum/customization_style/beard/trampstains
		bioHolder.mobAppearance.customization_third_color = "#663300"
		bioHolder.age = 43
		bioHolder.bloodType = "M1"
		bioHolder.mobAppearance.gender = NEUTER
		bioHolder.mobAppearance.underwear = "briefs"
		bioHolder.mobAppearance.u_color = "#7aa668"
