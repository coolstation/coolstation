////////////////
// CLEANABLES //
////////////////
//HI! ARE YOU FRUSTRATED BECAUSE YOUR CLEANABLE KEEPS TURNING INTO A FUCKING LIQUID AFTER THEY ALL STACK TOGETHER DURING THE UNPOOLING? ME TOO!
//IF THIS IS BEHAVIOUR THAT YOU DON'T WANT TO EXHIBIT ON YOUR CLEANABLES, HEAD DOWN TO FLUID_CORE.DM AND ADD YOUR REAGENT TO THE LIST TO PREVENT IT FROM DOING THIS.
//WHO KNOWS, MAYBE THIS SHOULDN'T BE THE DEFAULT BEHAVIOUR FOR SAMPLE REAGENTS BUT WHAT DO I KNOW!
////////////////

////////////////
proc/make_cleanable(var/type,var/loc,var/list/viral_list)
	var/obj/decal/cleanable/C = new type()
	C.name = initial(C.name) // ugh
	C.setup(loc,viral_list)
	.= C

/obj/decal/cleanable
	density = 0
	anchored = 1
	var/can_sample = 0
	var/sampled = 0
	var/sample_amt = 10
	var/sample_reagent = "water"
	var/sample_verb = "scoop"
	var/list/diseases = list()
	var/slippery = 0 // set it to the probability that you want people to slip in the stuff, ie urine's slippery is 80 so you have an 80% chance to slip on it
	var/slipped_in_blood = 0 // self explanitory hopefully
	var/can_dry = 0
	var/dry = 0 // if it's slippery to start, is it dry now?
	var/stain = null // clothing will be stained with this message if the decal is created in the same tile as them
	var/last_color = null
	var/gross = 0 //is this going to contaminate some food with grime? gibs and poo and dirt, yeah. post it notes, not so much.

	var/can_fluid_absorb = 1
	//var/turf/last_turf //unset 'messy' on my last turf after a move
	//moved up to atom/movable

	var/last_dry_start = 0
	var/dry_time = 100

	flags = NOSPLASH | FPRINT | OPENCONTAINER
	layer = CLEANABLE_DECAL_LAYER
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER

	plane = PLANE_NOSHADOW_BELOW

	New(var/loc,var/list/viral_list)
		..()
		if (!pooled)
			setup(loc,viral_list)
		if (isturf(src.loc) && src.reagents)
			var/twoluckywinners = 0
			for (var/obj/item/reagent_containers/food/snacks/snack in src.loc)
				if (twoluckywinners <= 2)
					src.reagents.trans_to(snack,1)
				else
					break

	setup(var/L,var/list/viral_list)
		..()
		src.real_name = src.name

		if (length(viral_list))
			for (var/datum/ailment_data/AD in viral_list)
				src.diseases += AD
		if (src.can_dry)
			src.Dry()

		if (src.loc != null)
			var/area/Ar = get_area(src)
			if (Ar)
				Ar.sims_score = max(Ar.sims_score - 6, 0)

			if (src.stain)
				src.Stain()

			if(isturf(src.loc))
				var/turf/T = src.loc
				T.messy++
				if (src.gross && !(istype(T,/turf/space)))
					T.clean = 0
				last_turf = T

			if (istype(src.loc, /turf/floor))
				var/turf/T = src.loc
				T.cleanable_fluid_react()

	disposing()
		if (can_dry)
			processing_items.Remove(src)

		if (istype(src.loc, /turf/floor))
			var/turf/T = src.loc
			T.messy = max(T.messy-1, 0)
			if (!T.messy) //no mess left at all?
				T.clean	= 1 //we're probably being cleaned

		var/area/Ar = get_area(src)
		if (Ar)
			Ar.sims_score = min(Ar.sims_score + 6, 100)
		..()
/*
	unpooled()
		..()
		dry = initial(dry)
		src.stain = initial(stain)
		src.name = initial(name)
		src.desc = initial(desc)
		color = initial(color)

		src.diseases.len = 0

	pooled()
		..()
		src.sampled = initial(src.sampled) //I had to fix fire not resetting on magnesium, and now I find out sampled only resets on magnesium?
*/
	proc/process()
		if (world.time > last_dry_start + dry_time)
			end_dry()

	ex_act(severity)
		if (isrestrictedz(src.z))
			return
		else
			qdel(src)

	Move(NewLoc, direct)
		. = ..()
		if (last_turf && istype(last_turf))
			last_turf.messy = max(last_turf.messy-1, 0)
		last_turf = src.loc

		if (isturf(src.loc))
			var/turf/F = src.loc
			F.messy++

	HasEntered(AM as mob|obj)
		..()
		if (src.qdeled || src.pooled)
			return
		if (src.stain && !src.dry && (ishuman(AM) || istype(AM, /obj/item/clothing)))
			src.Stain(AM)
		if (!src.slippery || src.dry)
			return
		if (src.reagents && src.reagents.total_volume < 5)
			return
		if (istype(src.loc, /turf/space))
			return
		if (iscarbon(AM))
			var/mob/M =	AM
			if (prob(src.slippery))
				if (M.slip())
					M.visible_message("<span class='alert'><b>[M]</b> slips on [src]!</span>",\
					"<span class='alert'>You slip on [src]!</span>")

					if (src.slipped_in_blood)
						M.add_blood(src)

	attackby(obj/item/W, mob/user)
		if (src.can_sample && W.is_open_container() && W.reagents)
			src.Sample(W, user)
		if (istype(W,/obj/item/mop))
			return
		else
			return ..()


	blob_act(var/power)
		if(prob(75))
			qdel(src)
			return

	proc/Dry(var/time = rand(600,1000))
		if (!src.can_dry || src.dry)
			return 0

		dry_time = time
		last_dry_start = world.time
		processing_items.Add(src)

	proc/end_dry()
		qdel(src)

	proc/Sample(var/obj/item/W as obj, var/mob/user as mob)
		if (!src.can_sample || !W.reagents)
			return 0

		if (src.reagents)
			var/amt_to_sample = min(src.reagents.total_volume, 10)
			if(!amt_to_sample)
				user.show_text("There's not enough left of [src] to [src.sample_verb] into [W].", "red")
				return 0
			else if (W.reagents.total_volume >= W.reagents.maximum_volume)
				user.show_text("[W] is too full!", "red")
				return 0
			else
				src.reagents.trans_to(W, amt_to_sample)
				user.visible_message("<span class='notice'><b>[user]</b> [src.sample_verb]s some of [src] into [W].</span>",\
				"<span class='notice'>You [src.sample_verb] some of [src] into [W].</span>")
				W.reagents.handle_reactions()
				src.sampled = 1
				return 1


		else if (src.sample_amt && src.sample_reagent)
			if (src.sampled)
				user.show_text("There's not enough left of [src] to [src.sample_verb] into [W].", "red")
				return 0
			if (W.reagents.total_volume >= W.reagents.maximum_volume - (src.sample_amt - 1))
				user.show_text("[W] is too full!", "red")
				return 0
			else
				W.reagents.add_reagent(src.sample_reagent, src.sample_amt)
				user.visible_message("<span class='notice'><b>[user]</b> [src.sample_verb]s some of [src] into [W].</span>",\
				"<span class='notice'>You [src.sample_verb] some of [src] into [W].</span>")
				W.reagents.handle_reactions()
				src.sampled = 1
				return 1

	proc/Stain(var/atom/movable/AM)
		if (src.stain)
			if (AM)
				if (ishuman(AM))
					var/mob/living/carbon/human/H = AM
					if (H.lying)
						if (H.wear_suit)
							H.wear_suit.add_stain(src.stain)
						else if (H.w_uniform)
							H.w_uniform.add_stain(src.stain)
					//else
						//if (H.shoes)
							//H.shoes.add_stain(src.stain)
					return
				else if (istype(AM, /obj/item/clothing))
					var/obj/item/clothing/C = AM
					C.add_stain(src.stain)
					return
			else
				SPAWN_DBG(0) //sorry. i want to lagcheck this. DO SOMETHING BETTER LATER ARUUGh
					for (var/mob/living/carbon/human/H in src.loc)
						if (H.lying)
							if (H.wear_suit)
								H.wear_suit.add_stain(src.stain)
							else if (H.w_uniform)
								H.w_uniform.add_stain(src.stain)
						//else
							//if (H.shoes)
								//H.shoes.add_stain(src.stain)
						LAGCHECK(LAG_REALTIME)
					LAGCHECK(LAG_HIGH)
					for (var/obj/item/clothing/C in src.loc)
						C.add_stain(src.stain)
						LAGCHECK(LAG_REALTIME)

	proc/create_overlay(var/list/icons_to_choose, var/add_color, var/direction, var/overlay_icon, var/add_alpha)
		var/overlay_icon_state
		if (islist(icons_to_choose) && length(icons_to_choose))
			overlay_icon_state = pick(icons_to_choose)
		else if (istext(icons_to_choose))
			overlay_icon_state = icons_to_choose
		else
			return
		if (overlay_icon_state)
			var/image/new_overlay// = image(overlay_icon, overlay_icon_state)
			if (direction)
				new_overlay = image(overlay_icon, overlay_icon_state, dir = direction)
				new_overlay.pixel_x += rand(-1,1)
				new_overlay.pixel_y += rand(-1,1)
			else
				new_overlay = image(overlay_icon, overlay_icon_state)
				new_overlay.transform = turn(new_overlay.transform, pick(0, 180)) // gets funky with 0,90,180,-90
				new_overlay.pixel_x += rand(-4,4)
				new_overlay.pixel_y += rand(-4,4)
			if (new_overlay)
				if (add_color)
					new_overlay.color = add_color
					src.last_color = add_color

				if(add_alpha)
					new_overlay.alpha = add_alpha

				if (src.overlays.len >= 4) //stop adding more overlays you're lagging client FPS!!!!
					src.UpdateOverlays(new_overlay, "cleanablefinal")
				else
					src.UpdateOverlays(new_overlay, "cleanble[length(src.overlays)]")

#define DRY_REAGENTS 1
#define FRESH_REAGENTS -1

/obj/decal/cleanable/tracked_reagents
	name = "spill"
	icon = 'icons/obj/decals/blood.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	slippery = 10
	can_dry = 1
	sample_reagent = null
	stain = null
	can_sample = TRUE

	var/can_track = 1
	var/reagents_max = 30

	Sample(obj/item/W, mob/user)
		. = ..()
		if(src.reagents && !src.reagents.total_volume)
			qdel(src)

	on_reagent_change(add)
		src.update_color()
		src.UpdateName()
		src.stain = src.real_name + "-stained"
		..()

	started_reagent_combustion()
		var/turf/T = get_turf(src)
		if(T)
			SPAWN_DBG(0.1 SECONDS)
				for (var/D in cardinal)
					var/turf/Q = get_step(T, D)
					if(Q.messy)
						var/obj/decal/cleanable/tracked_reagents/adjacent_spill = locate() in Q
						if(adjacent_spill?.reagents)
							open_flame_reaction(adjacent_spill.reagents)
					var/obj/fluid/adjacent_fluid = Q.active_liquid
					if(adjacent_fluid?.group?.reagents)
						open_flame_reaction(adjacent_fluid.group.reagents)
					var/obj/fluid/adjacent_smoke = Q.active_airborne_liquid
					if(adjacent_smoke?.group?.reagents)
						open_flame_reaction(adjacent_fluid.group.reagents, TRUE)
		..()

	stopped_reagent_combustion()
		if(src.reagents && !src.reagents.total_volume)
			qdel(src)
			return
		..()

	proc/set_sample_reagent_custom(var/reagent_id, var/amt = 10)
		if(isnull(reagent_id))
			return
		if (!src.reagents)
			src.create_reagents(reagents_max)

		src.sample_reagent = reagent_id
		src.reagents.add_reagent(reagent_id, amt)

	proc/update_color()
		if(src.reagents?.total_volume > 0.01)
			var/datum/color/average = src.reagents.get_average_color()
			src.color = rgb(average.r, average.g, average.b)
			src.alpha = average.a
		else
			var/datum/reagent/reagent = reagents_cache[src.sample_reagent]
			if(reagent)
				src.color = rgb(reagent.fluid_r, reagent.fluid_g, reagent.fluid_b)
				src.alpha = reagent.transparency

	HasEntered(var/mob/living/L as mob)
		..()
		if (!istype(L))
			return
		if (src.dry == FRESH_REAGENTS && src.reagents.total_volume >= 2 && src.can_track)
			if (ishuman(L))
				var/mob/living/carbon/human/H = L
				if (H.lying)
					if (H.wear_suit)
						H.wear_suit.add_blood(src)
						H.set_clothing_icon_dirty()
					else if (H.w_uniform)
						H.w_uniform.add_blood(src)
						H.set_clothing_icon_dirty()
				else
					if (H.shoes)
						H.shoes.add_blood(src)
						H.set_clothing_icon_dirty()
				if (H.m_intent != "walk")
					src.reagents.trans_to_direct(H.tracked_reagents, rand(2, 4))
					H.set_clothing_icon_dirty()
			else
				L.add_blood(src)
				if (!L.anchored)
					src.reagents.trans_to(L.tracked_reagents, rand(1, src.reagents.total_volume-1))

	Dry(var/time = rand(300,600))
		if (!src.can_dry || src.dry == DRY_REAGENTS)
			src.stain = null
			return 0
		if (ticker) // don't do this unless the game has started
			src.dry = FRESH_REAGENTS // fresh!!
			src.UpdateName()

		dry_time = time
		last_dry_start = world.time
		processing_items.Add(src)

	end_dry()
		if (src.dry == FRESH_REAGENTS)
			src.dry = 0
			src.UpdateName()
			src.dry_time = rand(300,600)
		else
			src.dry = DRY_REAGENTS
			src.stain = null
			processing_items.Remove(src)
			if(src.reagents)
				for(var/reagent_id in src.reagents.reagent_list)
					var/datum/reagent/reagent = src.reagents.reagent_list[reagent_id]
					if(reagent.evaporates_cleanly)
						src.reagents.del_reagent(reagent_id)
				if(src.reagents.total_volume)
					src.UpdateName()
				else
					qdel(src)

	disposing()
		var/obj/decal/bloodtrace/B = locate() in src.loc
		if (!B) // hacky solution because I don't want there to be a million blood traces on a tile, ideally one trace should contain more samples
			diseases = list()
			B = new /obj/decal/bloodtrace(src.loc)
			B.blood_DNA = src.blood_DNA // okay so we shouldn't check to see if B has DNA/type because it's brand new and it does not, duh
			B.blood_type = src.blood_type
			B.icon = src.icon
			B.icon_state = src.icon_state
			B.color = "#3399FF"
			B.alpha = 100
		..()

	UpdateName()
		if(src.reagents)
			src.real_name = src.reagents.get_master_reagent_name()
		src.name = "[name_prefix(null, 1)][src.dry == DRY_REAGENTS ? "dried " : null][src.real_name][name_suffix(null, 1)]"

	get_desc(dist)
		. = "It's [src.real_name]."
		if(src.real_name == "poo")
			. += " Ewww, doesn't this violate health code?"
		if (src.dry) // either fresh (-1) or dry (1)
			. += " It's [src.dry == DRY_REAGENTS ? "dry and flakey" : "fresh"]."

// I don't think every blood decal needed these lists on them, I can't imagine that was nice for performance
var/list/blood_decal_low_icon_states = list("drip1a", "drip1b", "drip1c", "drip1d", "drip1e", "drip1f")
var/list/blood_decal_med_icon_states = list("drip2a", "drip2b", "drip2c", "drip2d", "drip2e", "drip2f")
var/list/blood_decal_high_icon_states = list("drip3a", "drip3b", "drip3c", "drip3d", "drip3e", "drip3f")
var/list/blood_decal_max_icon_states = list("drip4a", "drip4b", "drip4c", "drip4d", "drip5a", "drip5b", "drip5c", "drip5d")
var/list/blood_decal_violent_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7", "gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5")

#define list_and_len(x) (istype(x, /list) && x:len) // just to make sure it's a list and it's got something in it

// now tentatively useable for tracking any reagent across the floor
/obj/decal/cleanable/tracked_reagents/dynamic
	desc = null
	icon_state = "blank" // if you make any more giant white cumblobs all over my nice blood decals
	random_icon_states = null // I swear to god I will fucking end you
	slippery = 0 // increases as blood volume does
	color = null
	var/last_volume = 1
	reagents_max = 100

	disposing()
		diseases = list()
		var/obj/decal/bloodtrace/B = locate() in src.loc
		if(!B) // hacky solution because I don't want there to be a million blood traces on a tile, ideally one trace should contain more samples
			B = new /obj/decal/bloodtrace(src.loc)
			B.blood_DNA = src.blood_DNA
			B.blood_type = src.blood_type
			B.icon = src.icon
			B.icon_state = src.icon_state
		var/image/working_image
		for (var/i in src.overlay_refs)
			working_image = GetOverlayImage(i)
			if (!working_image)
				break
			working_image.color = "#3399FF"
			working_image.alpha = 100
			B.UpdateOverlays(working_image, i)

		..(B)
/*
	unpooled()
		..()
*/

	Dry(var/time = rand(300,600))
		if (!src.can_dry) // if it's already dry, unlike the non-dynamic blood decals, we don't wanna return, since the blood will be freshened up again
			src.stain = null
			return 0
		if (ticker) // don't do this unless the game has started
			src.dry = FRESH_REAGENTS // fresh!!
			src.UpdateName()
			src.dry_time = time
			last_dry_start = world.time
			processing_items |= src
			return 1

	proc/transfer_volume(var/datum/reagents/source, var/amount = 1, var/bDNA = null, var/btype = null, var/i_state = null, var/direction = null, var/do_fluid_react = 1, var/violent = FALSE)
		if (bDNA)
			src.blood_DNA = bDNA
			src.blood_type = btype

		if(source)
			if(!src.reagents)
				src.create_reagents(src.reagents_max)
			source.trans_to(src, amount, do_fluid_react = FALSE)
			if(QDELETED(src))
				return

		var/turf/floor/T = src.loc
		if (istype(T) && do_fluid_react)
			if (T.cleanable_fluid_react(src))
				return

		if (i_state)
			create_overlay(i_state, src.color, direction, 'icons/obj/decals/blood.dmi', src.alpha)
		else
			var/switchin = src.reagents.total_volume
			if(violent)
				switchin = 500
			switch (switchin)
				if (-INFINITY to 2)
					if (!list_and_len(blood_decal_low_icon_states))
						return
					create_overlay(blood_decal_low_icon_states, src.color, direction, 'icons/obj/decals/blood.dmi', src.alpha)
					// no increase in slipperiness if there's just a little bit of blood being added
				if (2 to 4)
					if (!list_and_len(blood_decal_med_icon_states))
						return
					create_overlay(blood_decal_med_icon_states, src.color, direction, 'icons/obj/decals/blood.dmi', src.alpha)
					src.slippery = min(src.slippery+1, 10)
				if (4 to 6)
					if (!list_and_len(blood_decal_high_icon_states))
						return
					create_overlay(blood_decal_high_icon_states, src.color, direction, 'icons/obj/decals/blood.dmi', src.alpha)
					src.slippery = min(src.slippery+2, 10)
				if (6 to 10)
					if (!list_and_len(blood_decal_max_icon_states))
						return
					create_overlay(blood_decal_max_icon_states, src.color, direction, 'icons/obj/decals/blood.dmi', src.alpha)
					src.slippery = min(src.slippery+5, 10)
				if (10 to INFINITY)
					if (!list_and_len(blood_decal_violent_icon_states))
						return
					create_overlay(blood_decal_violent_icon_states, src.color, direction, 'icons/obj/decals/blood.dmi', src.alpha) // for when you wanna create a BIG MESS
					src.slippery = 10

		src.Dry(rand(src.reagents.total_volume*16,src.reagents.total_volume*24))
		var/blood_amount = floor((src.reagents.get_reagent_amount("blood") + src.reagents.get_reagent_amount("bloodc")) * 0.5)
		if(blood_amount)
			var/counter = 0
			for (var/obj/I in get_turf(src))
				if(prob(blood_amount))
					I.add_blood(src)
				if(counter++>25)break

/obj/decal/cleanable/tracked_reagents/dynamic/tracks
	can_track = 0

	transfer_volume(var/datum/reagents/volume, var/amount = 1, var/bDNA = null, var/btype = null, var/i_state = null, var/direction = null, var/e_tracking = 1, var/do_fluid_react = 1, violent = FALSE)
		// e_tracking will be set to 0 by the track_blood() proc mobs run when moving, so anything that doesn't set it to 0 is a regular sort of bleed and should re-enable tracking
		if (e_tracking)
			src.can_track = 1
		..()

	get_desc()
		return "Someone walked through some [src.real_name] and got it everywhere, jeez!"

/obj/decal/cleanable/tracked_reagents/blood
	sample_reagent = "blood"

	New()
		src.create_reagents(reagents_max)
		src.reagents.add_reagent("blood", 10)
		..()

	setup()
		if (!src.reagents)
			src.create_reagents(reagents_max)
		else
			src.reagents.clear_reagents()
		src.reagents.add_reagent("blood", 10)

		..()

		SPAWN_DBG(0)
			if(src.loc && !src.disposed)
				var/counter = 0
				for (var/obj/I in get_turf(src))
					if(prob(src?.reagents?.total_volume))
						I.add_blood(src)
					if(counter++>15)break

/obj/decal/cleanable/tracked_reagents/blood/drip
	New()
		..()
		src.pixel_y += rand(0,16)

/obj/decal/cleanable/tracked_reagents/blood/drip/low
	random_icon_states = list("drip1a", "drip1b", "drip1c", "drip1d", "drip1e", "drip1f")
/obj/decal/cleanable/tracked_reagents/blood/drip/med
	random_icon_states = list("drip2a", "drip2b", "drip2c", "drip2d", "drip2e", "drip2f")
/obj/decal/cleanable/tracked_reagents/blood/drip/high
	random_icon_states = list("drip3a", "drip3b", "drip3c", "drip3d", "drip3e", "drip3f")

/obj/decal/cleanable/tracked_reagents/blood/splatter
	random_icon_states = list("gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5")

/obj/decal/cleanable/tracked_reagents/blood/splatter/extra
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7", "gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5")


/obj/decal/cleanable/tracked_reagents/blood/tracks
	icon_state = "tracks"
	random_icon_states = null

/obj/decal/cleanable/tracked_reagents/blood/hurting1
	icon_state = "hurting1"
	random_icon_states = null

	hurting2
		icon_state = "hurting2"


/obj/decal/cleanable/tracked_reagents/blood/gibs
	name = "gibs"
	desc = "Grisly..."
	anchored = 0
	layer = OBJ_LAYER
	icon = 'icons/obj/decals/blood.dmi'
	icon_state = "gibbl5"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")
	color = "#FFFFFF"
	slippery = 5
	can_dry = 0
	can_fluid_absorb = 0

	attack_hand(var/mob/user as mob)
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (H.job == "Chef" || H.job == "Sous-Chef")
				user.visible_message("<span class='notice'><b>[H]</b> starts rifling through \the [src] with their hands. What a weirdo.</span>",\
				"<span class='notice'>You rake through \the [src] with your bare hands.</span>")
				playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
				if (H.gloves)
					H.gloves.blood_DNA = src.blood_DNA
				else
					H.blood_DNA = src.blood_DNA
				if (src.sampled)
					H.show_text("You didn't find anything useful. Now your hands are all bloody for nothing!", "red")
				else
					if (H.job == "Sous-Chef" && prob(30))
						H.show_text("The... meat... slips through your inexperienced hands.", "blue")
					else
						H.show_text("You find some... salvageable... meat.. you guess?", "blue")
						H.unlock_medal("Sheesh!", 1)
						new /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat(src.loc)
					#ifdef DATALOGGER
					game_stats.Increment("workplacesafety") //It's just not sanitary
					#endif
					src.sampled = 1
			else
				return ..()
		else
			return ..()

/obj/decal/cleanable/tracked_reagents/blood/gibs/body
	random_icon_states = list("gibhead", "gibtorso")

/obj/decal/cleanable/tracked_reagents/blood/gibs/core
	random_icon_states = list("gibmid1", "gibmid2", "gibmid3")

#undef DRY_REAGENTS
#undef FRESH_REAGENTS

/obj/decal/cleanable/glitter //WE'RE TRYING THIS NOW
	name = "glitter"
	desc = "You can try to clean it up, but there'll always be a little bit left."
	icon = 'icons/effects/glitter.dmi'
	icon_state = "glitter"
	random_dir = 4
	random_icon_states = list("glitter-1", "glitter-2", "glitter-3", "glitter-4", "glitter-5", "glitter-6", "glitter-7", "glitter-8", "glitter-9", "glitter-10")
	can_sample = 1
	sample_reagent = "glitter"
	sample_verb = "scrape"
	stain = "sparkly"
	gross = 1

/obj/decal/cleanable/glitter/harmless //updated to not be lethal
	sample_reagent = "sparkles"
	gross = 0

/obj/decal/cleanable/ketchup //It's ketchup that looks like blood.
	name = "blood"
	desc = "It's strangely bright red. Smells a bit like tomatoes as well." //Grody
	icon = 'icons/obj/decals/blood.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	color = "#cc0000" //Just a bit brighter than DEFAULT_BLOOD_COLOR
	slippery = 10
	can_sample = 1
	sample_reagent = "ketchup"


/obj/decal/cleanable/pathogen_sweat
	name = "weirdly colored sweat"
	desc = "Ew, better not step in this stuff."
	icon = 'icons/obj/decals/blood.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	color = "#12b828"
	slippery = 5
	can_sample = 1
	sample_reagent = "pathogen"
	can_dry = 1
	can_fluid_absorb = 0
	gross = 1

	HasEntered(AM)
		. = ..()
		if(prob(4))
			src.reagents.reaction(AM, TOUCH)

/obj/decal/cleanable/pathogen_cloud
	name = "disease particles"
	desc = "The air in that particular area gives you a bad vibe."
	icon = 'icons/obj/decals/blood.dmi'
	icon_state = "pathogen_cloud"
	color = "#12b828"
	slippery = 5
	can_sample = 1
	sample_reagent = "pathogen"
	can_dry = 1
	can_fluid_absorb = 0
	gross = 1

	HasEntered(AM)
		. = ..()
		if(!ishuman(AM))
			return

		var/mob/living/carbon/human/H = AM
		var/chance = 10
		if(H.wear_mask)
			chance *= H.wear_mask.path_prot
		if(H.head)
			chance *= H.head.path_prot

		if(prob(chance))
			src.reagents.reaction(AM, INGEST)


/obj/decal/cleanable/paper
	name = "paper"
	desc = "Ripped up little flecks of paper."
	icon = 'icons/obj/decals/cleanables.dmi'
	icon_state = "paper"
	random_dir = 4
	can_sample = 1
	sample_reagent = "paper"
	sample_verb = "scrape"

	New()
		..()
		pixel_y += rand(-4,4)
		pixel_x += rand(-4,4)
		return

/obj/decal/cleanable/leaves
	name = "leaves"
	desc = "A sad little pile of leaves from a sad, destroyed bush."
	icon = 'icons/obj/decals/cleanables.dmi'
	icon_state = "leaves"
	random_dir = 4
	gross = 1

/obj/decal/cleanable/rust
	name = "rust"
	desc = "That sure looks safe."
	icon = 'icons/obj/decals/cleanables.dmi'
	icon_state = "rust1"
	random_icon_states = list("rust1", "rust2", "rust3","rust4","rust5")
	can_sample = 1
	sample_reagent = "iron_oxide"
	sample_verb = "scrape"
	gross = 1

/obj/decal/cleanable/rust/jen
	icon_state = "rust_jen"
	random_icon_states = null
	plane = PLANE_NOSHADOW_BELOW

	// This is a big sprite that covers up most of the turf, so here's a way to interact with turfs without bludgeoning the rust
	attack_hand(obj/M, mob/user)
		return 0

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/sponge) || istype(W, /obj/item/mop))
			..()
		else
			src.loc.Attackby(user.equipped(), user)

/obj/decal/cleanable/balloon
	name = "balloon"
	desc = "The remains of a balloon."
	icon = 'icons/obj/items/balloon.dmi'
	icon_state = "balloon_white_pop"

/obj/decal/cleanable/writing
	name = "writing"
	desc = "Someone's scribbled something here."
	layer = TURF_LAYER + 1
	icon = 'icons/obj/decals/writing.dmi'
	icon_state = "writing1"
	color = "#000000"
	random_icon_states = list("writing1", "writing2", "writing3", "writing4", "writing5", "writing6", "writing7")
	var/words = "Nothing."
	var/font = null
	var/webfont = 0
	var/font_color = "#000000"
	var/color_name = null
	var/artist = null//the key of the one who wrote it
	real_name = "writing"

	get_desc(dist)
		. = "<br><span class='notice'>It says[src.material ? src.material : src.color_name ? " in [src.color_name]" : null]:</span><br>[words]"
		//. = "[src.webfont ? "<link href='http://fonts.googleapis.com/css?family=[src.font]' rel='stylesheet' type='text/css'>" : null]<span class='notice'>It says:</span><br><span style='[src.font ? "font-family: [src.font][src.webfont ? ", cursive" : null];" : null]color: [src.font_color]'>[words]</span>"

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.real_name][name_suffix(null, 1)]"

/obj/decal/cleanable/writing/maptext_dummy
	icon_state = ""

	setup(var/L,var/list/viral_list)
		. = ..()
		icon_state = initial(icon_state)
		maptext_width = 16
/*
	pooled()
		. = ..()
		src.maptext = ""
*/
/obj/decal/cleanable/writing/spooky
	icon = 'icons/obj/decals/writing_animated_blood.dmi'
	color = null
	gross = 1
/obj/decal/cleanable/writing/infrared
	name = "infrared writing"
	desc = "Someone's scribbled something here, with infrared ink. Ain't that spiffy?"
	icon_state = "IRwriting1"
	color = "#D20040"
	random_icon_states = list("IRwriting1", "IRwriting2", "IRwriting3", "IRwriting4", "IRwriting5", "IRwriting6", "IRwriting7")
	infra_luminosity = 4
	invisibility = 1
	font_color = "#D20040"

/obj/decal/cleanable/writing/postit
	name = "sticky note"
	desc = "Someone's stuck a little note here."
	icon_state = "postit"
	random_icon_states = list()
	color = null
	words = ""
	var/max_message = 128

	New()
		..()
		pixel_y += rand(-12,12)
		pixel_x += rand(-12,12)

	attackby(obj/item/W as obj, mob/living/user as mob)
		if (istype(W, /obj/item/stamp))

			var/obj/item/stamp/S = W
			switch (S.current_mode)
				if ("Approved")
					src.icon_state = "postit-approved"
				if ("Rejected")
					src.icon_state = "postit-rejected"
				if ("Void")
					src.icon_state = "postit-void"
				if ("X")
					src.icon_state = "postit-x"
				else
					boutput(user, "It doesn't look like that kind of stamp fits here...")
					return

			// words here, info there, result is same: SCREEAAAAAAAMMMMMMMMMMMMMMMMMMM
			src.words += "<br>\[[S.current_mode]\]<br>"
			boutput(user, "<span class='notice'>You stamp \the [src].</span>")


		else if (istype(W, /obj/item/pen))
			if(!user.literate)
				boutput(user, "<span class='alert'>You don't know how to write.</span>")
				return ..()
			var/obj/item/pen/pen = W
			pen.in_use = 1
			var/t = input(user, "What do you want to write?", null, null) as null|text
			if (!t)
				pen.in_use = 0
				return
			if ((length(src.words) + length(t)) > src.max_message)
				user.show_text("All that won't fit on [src]!", "red")
				pen.in_use = 0
				return
			logTheThing("station", user, null, "writes on [src] with [pen] at [showCoords(src.x, src.y, src.z)]: [t]")
			t = copytext(html_encode(t), 1, MAX_MESSAGE_LEN)
			if (pen.uses_handwriting && user?.mind?.handwriting)
				src.font = user.mind.handwriting
				src.webfont = 1
			else if (pen.font)
				src.font = pen.font
				if (pen.webfont)
					src.webfont = 1
			if (src.words)
				src.words += "<br>"
			if (src.icon_state == initial(src.icon_state))
				var/search_t = lowertext(t)
				if (copytext(search_t, -1) == "?")
					src.icon_state = "postit-quest"
				else if (copytext(search_t, -1) == "!")
					src.icon_state = "postit-excl"
				else
					src.icon_state = "postit-writing"
			src.words += "[t]"
			pen.in_use = 0
		else
			return ..()

/obj/decal/cleanable/water
	name = "water"
	desc = "Water, on the floor. Amazing!"
	icon = 'icons/effects/water.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3")
	can_dry = 1
	slippery = 90
	can_sample = 1
	sample_reagent = "water"
	sample_amt = 5
	stain = "damp"

	Crossed(atom/movable/O)
		if (istype(O, /obj/item/clothing/under/towel))
			var/obj/item/clothing/under/towel/T = O
			T.dry_turf(get_turf(src))
			return
		else
			return ..()

/obj/decal/cleanable/urine
	name = "urine"
	desc = "It's yellow, and it smells."
	icon = 'icons/obj/decals/urine.dmi'
	icon_state = "floor1"
	blood_DNA = null
	blood_type = null
	random_icon_states = list("floor1", "floor2", "floor3")
	var/thrice_drunk = 0
	can_dry = 1
	slippery = 80
	can_sample = 1
	sample_amt = 4
	sample_reagent = "urine"
	stain = "piss-soaked"
	gross = 1

	Crossed(atom/movable/O)
		if (istype(O, /obj/item/clothing/under/towel))
			var/obj/item/clothing/under/towel/T = O
			T.dry_turf(get_turf(src))
			return
		else
			return ..()

	Sample(var/obj/item/W as obj, var/mob/user as mob)
		if (!src.can_sample)
			return 0

		if (W.is_open_container() && W.reagents)
			if (W.reagents.total_volume >= W.reagents.maximum_volume - 2)
				user.show_text("[W] is too full!", "red")
				return

			else
				user.visible_message("<span class='notice'><b>[user]</b> is splashing the urine puddle into \the [W]. How singular.</span>",\
				"<span class='notice'>You splash a little urine into \the [W].</span>")

				switch (thrice_drunk)
					if (0)
						W.reagents.add_reagent("urine", 1)
					if (1)
						W.reagents.add_reagent("urine", 1)
						W.reagents.add_reagent("toeoffrog", 1)
					if (2)
						W.reagents.add_reagent("urine", 1)
						W.reagents.add_reagent("woolofbat", 1)
					if (3)
						W.reagents.add_reagent("urine", 1)
						W.reagents.add_reagent("tongueofdog", 1)
					if (4)
						W.reagents.add_reagent("triplepiss",1)

				if (prob(25))
					qdel(src)

				W.reagents.handle_reactions()
				return 1

/obj/decal/cleanable/vomit
	name = "pool of vomit"
	desc = "Someone lost their lunch."
	icon = 'icons/obj/decals/vomit.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3")
	slippery = 30
	can_dry = 1
	can_sample = 1
	sample_amt = 5
	sample_reagent = "vomit"
	sample_verb = "scrape"
	stain = "puke-coated"
	gross = 1

	Dry(var/time = rand(200,500))
		if (!src.can_dry || src.dry)
			return 0
		dry_time = time
		last_dry_start = world.time
		processing_items.Add(src)

	end_dry()
		src.dry = 1
		src.stain = null
		src.name = "dried [src.real_name]"
		src.desc = "It's all gummy. Ew."

	Sample(var/obj/item/W as obj, var/mob/user as mob)
		if (!src.can_sample || !W.reagents)
			return 0
		if (src.sampled)
			user.show_text("There's not enough left of [src] to [src.sample_verb] into [W].", "red")
			return 0

		if (src.sample_amt && src.sample_reagent)
			if (W.reagents.total_volume >= W.reagents.maximum_volume - (src.sample_amt - 1))
				user.show_text("[W] is too full!", "red")
				return 0
			else
				W.reagents.add_reagent(src.sample_reagent, src.sample_amt)
				user.visible_message("<span class='notice'><b>[user]</b> is sticking their fingers into [src] and pushing it into [W]. It's probably best not to ask.</span>",\
				"<span class='notice'>You [src.sample_verb] some of the puke into [W]. You are absolutely disgusting.</span>")
				W.reagents.handle_reactions()
				playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
				src.sampled = 1
				return 1

/obj/decal/cleanable/vomit/spiders
	desc = "Someone lost their lunch. Oh god their lunch was spiders?!"
	random_icon_states = list("spiders1", "spiders2", "spiders3")

	Sample(var/obj/item/W as obj, var/mob/user as mob)
		if (!src.can_sample || !W.reagents)
			return 0
		if (src.sampled)
			user.show_text("There's not enough left of [src] to [src.sample_verb] into [W].", "red")
			return 0

		if (W.reagents.total_volume >= W.reagents.maximum_volume - (src.sample_amt - 1))
			user.show_text("[W] is too full!", "red")
			return 0
		else
			W.reagents.add_reagent("vomit", 2)
			W.reagents.add_reagent("black_goop", 2)
			W.reagents.add_reagent("spiders", 1)

			var/fluff = pick("twitches", "wriggles", "wiggles", "skitters")
			var/fluff2
			if (prob(10))
				fluff2 = ""
			else // I only code good & worthwhile things  :D
				var/swear1 = pick("Oh", "Holy[pick("", " fucking")]", "Fucking", "Goddamn[pick("", " fucking")]", "Mother of[pick("", " fucking")]", "Jesus[pick("", " fucking")]")
				var/swear2 = pick("shit", "fuck", "hell", "heck", "hellfarts", "piss")
				var/that_is = " that is the [pick("worst", "most vile", "most utterly horrendous", "grodiest", "most horrific")] thing you've seen[pick(" in your entire life", " this week", " today", "", "!")]"
				fluff2 = " [swear1] [swear2][prob(50) ? "[that_is]" : null][pick(".", "!", "!!")]"

			user.visible_message("<span class='notice'><b>[user]</b> is sticking their fingers into [src] and pushing it into [W].<span class='alert'>It [fluff] a bit.[fluff2]</span></span>",\
			"<span class='notice'>You [src.sample_verb] some of the puke into [W].<span class='alert'>It [fluff] a bit.[fluff2]</span></span>")
			W.reagents.handle_reactions()
			playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
			src.sampled = 1
			return 1

/obj/decal/cleanable/greenpuke
	name = "green vomit"
	desc = "That's just wrong."
	density = 0
	anchored = 1
	icon = 'icons/obj/decals/vomit.dmi'
	icon_state = "green1"
	var/dried = 0
	random_icon_states = list("green1", "green2", "green3")
	can_dry = 1
	slippery = 35
	can_sample = 1
	sample_amt = 5
	sample_reagent = "gvomit"
	sample_verb = "scrape"
	stain = "green-puke-coated"
	gross = 1

	Dry(var/time = rand(200,500))
		if (!src.can_dry)
			return 0
		dry_time = time
		last_dry_start = world.time
		processing_items.Add(src)

	end_dry()
		src.dry = 1
		src.stain = null
		src.name = "dried [src.real_name]"
		src.desc = "It's all gummy. Ew."

	Sample(var/obj/item/W as obj, var/mob/user as mob)
		if (!src.can_sample || !W.reagents)
			return 0
		if (src.sampled)
			user.show_text("There's not enough left of [src] to [src.sample_verb] into [W].", "red")
			return 0

		if (src.sample_amt && src.sample_reagent)
			if (W.reagents.total_volume >= W.reagents.maximum_volume - (src.sample_amt - 1))
				user.show_text("[W] is too full!", "red")
				return 0
			else
				W.reagents.add_reagent(src.sample_reagent, src.sample_amt)
				user.show_text("You scoop some of the sticky, slimy, stringy green puke into [W]. You are absolutely horrifying.", "blue")
				for (var/mob/O in AIviewers(user, null))
					if (O != user)
						O.show_message("<span class='notice'><b>[user]</b> is sticking their fingers into [src] and pushing it into [W]. It's all slimy and stringy. Oh god.</span>", 1)
						if (prob(33) && ishuman(O))
							O.show_message("<span class='alert'>You feel ill from watching that.</span>")
							for (var/mob/V in viewers(O, null))
								V.show_message("<span class='alert'>[O] pukes all over [himself_or_herself(O)]. Thanks, [user].</span>", 1)
								O.vomit()

				W.reagents.handle_reactions()
				playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
				src.sampled = 1
				return 1

/obj/decal/cleanable/mess
	name = "mess"
	icon = 'icons/obj/decals/cleanables.dmi'
	icon_state = "mess1"
	gross = 1

	random_splotch
		random_icon_states = list("mess1", "mess2", "mess3", "mess4")

	splotch_one
		icon_state = "mess1"

	splotch_two
		icon_state = "mess2"

	splotch_three
		icon_state = "mess3"

	splotch_four
		icon_state = "mess4"

	random_food
		icon_state = "messfood"
		random_icon_states = list("messnoodle1sauce", "messnoodle1meatball", "messnoodle1", "messnoodle2sauce", "messnoodle2meatball", "messnoodle2", "messfries", "messchips", "messburrito", "messmaple")

	random_litter
		icon_state = "messlitter"
		random_icon_states = list("messfries", "messchips", "messcan1", "messcan2", "messnougat")

	noodles
		name = "spilled plain noodles"
		icon_state = "messnoodle1"
		random_icon_states = list("messnoodle1", "messnoodle2")

		attack_hand(mob/user as mob)
			if (user.lying)
				user.visible_message("<span class='notice'><b>[user]</b> just kind of eats [src] right off the floor.</span>",\
				"<span class='notice'>You eat [src] right off the floor.</span>")
				playsound(user.loc,"sound/items/eatfood.ogg", rand(10, 50), 1)
				user.reagents.add_reagent("grime", 1)
				qdel(src)
				return

	noodles/random_sauce
		name = "spilled noodles in sauce"
		icon_state = "messnoodle1sauce"
		random_icon_states = list("messnoodle1sauce", "messnoodle2sauce")

	noodles/random_meatballs
		name = "spilled noodles with meatballs"
		icon_state = "messnoodle1meatball"
		random_icon_states = list("messnoodle1meatball", "messnoodle2meatball")

	noodles/random_all
		icon_state = "messnoodle1sauce"
		random_icon_states = list("messnoodle1sauce", "messnoodle1meatball", "messnoodle1", "messnoodle2sauce", "messnoodle2meatball", "messnoodle2")

	fries
		name = "spilled fries"
		icon_state = "messfries"

	chips
		name = "spilled chips"
		icon_state = "messchips"

	sodacan
		name = "discarded soda can"
		icon_state = "messcan1"
		random_icon_states = list("messcan1", "messcan2")

	nougat
		name = "discarded nougat wrapper"
		icon_state = "messnougat"

	burrito
		name = "squashed burrito"
		icon_state = "messburrito"

	maple
		name = "shattered maple syrup bottle"
		icon_state = "messmaple"

/obj/decal/cleanable/tomatosplat
	name = "ruined tomato"
	desc = "Gallows humour."
	icon = 'icons/obj/decals/blood.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	color = "#FF0000"
	slippery = 10
	can_sample = 1
	sample_reagent = "juice_tomato"

/obj/decal/cleanable/eggsplat
	name = "smashed egg"
	desc = "This mess is no yolk. Well, maybe a little."
	icon = 'icons/effects/water.dmi'
	icon_state = "egg1"
	random_icon_states = list("egg1", "egg2", "egg3")
	slippery = 5
	can_sample = 1
	sample_amt = 5
	sample_reagent = "egg"

/obj/decal/cleanable/eggshell
	name = "egg shell"
	desc = "Be careful when you walk on this."
	icon = 'icons/obj/decals/cleanables.dmi'
	icon_state = "eggshell1"
	random_icon_states = list("eggshell1", "eggshell2", "eggshell3", "eggshell4")
	slippery = 0
	can_sample = 0

/obj/decal/cleanable/ash
	name = "ashes"
	desc = "Ashes to ashes, dust to dust."
	icon = 'icons/obj/objects.dmi'
	icon_state = "ash"
	can_sample = 1
	sample_reagent = "ash"
	sample_verb = "scrape"
	stain = "dirty"
	gross = 1

	Sample(var/obj/item/W as obj, var/mob/user as mob)
		..()
		qdel(src)

	attack_hand(mob/user as mob)
		user.show_text("The ashes slip through your fingers.", "blue")
		qdel(src)
		return

/obj/decal/cleanable/sakura
	name = "sakura petals"
	desc = "cherryblossom petals floating around from...somewhere?"
	icon = 'icons/obj/dojo.dmi'
	icon_state = "sakura_overlay"

/obj/decal/cleanable/bigchallenges
	name = "Big Challenges"
	desc = "They're really big challenges. They're really consequential challenges."
	icon = 'icons/obj/decals/graffiti.dmi'
	icon_state = "bigchallenges"

/obj/decal/cleanable/slime // made by slugs and snails
	name = "slime"
	desc = "Eww."
	icon = 'icons/obj/decals/cleanables.dmi'
	icon_state = "slimeline1"
	random_icon_states = list("slimeline1", "slimeline2", "slimeline3", "slimeline4")
	color = "#A5BC64"
	slippery = 10
	can_dry = 1
	can_sample = 1
	sample_reagent = "slime"
	stain = "slimy"
	gross = 1

	Dry(var/time = rand(100,200))
		if (!src.can_dry)
			return 0

		dry_time = time
		last_dry_start = world.time
		processing_items.Add(src)

	end_dry()
		src.dry = 1
		src.stain = null
		src.name = "dried [src.real_name]"
		src.desc = "It's all gummy. Ew."

/obj/decal/cleanable/generic
	name = "clutter"
	desc = "Someone should clean that up."
	layer = TURF_LAYER
	icon = 'icons/obj/objects.dmi'
	icon_state = "shards"
	gross = 1

/obj/decal/cleanable/dirt
	name = "dirt"
	desc = "Someone should clean that up."
	icon = 'icons/obj/decals/cleanables.dmi'
	icon_state = "dirt"
	random_dir = 1
	stain = "dirty"
	can_sample = 1
	sample_reagent = "carbon"
	gross = 1

	dirt2
		icon_state = "dirt2"

	dirt3
		icon_state = "dirt3"

	dirt4
		icon_state = "dirt4"
		random_dir = 0

	dirt5
		icon_state = "dirt5"

	random
		New()
			..()
			icon_state = pick("dirt","dirt2","dirt3","dirt5") //dirt4 is very directional and parses weird on its own, like mulebot blood trails

	jen
		icon_state = "dirt_jen"
		plane = PLANE_NOSHADOW_BELOW

		// This is a big sprite that covers up most of the turf, so here's a way to interact with turfs without bludgeoning the dirt
		attack_hand(obj/M, mob/user)
			return 0

		attackby(obj/item/W, mob/user)
			if (istype(W, /obj/item/sponge) || istype(W, /obj/item/mop))
				..()
			else
				src.loc.Attackby(user.equipped(), user)

/obj/decal/cleanable/cobweb
	name = "cobweb"
	desc = "Someone should remove that."
	layer = MOB_LAYER+1
	icon = 'icons/obj/decals/cleanables.dmi'
	icon_state = "cobweb1"
	gross = 1

/obj/decal/cleanable/molten_item
	name = "gooey grey mass"
	desc = "huh."
	layer = OBJ_LAYER
	icon = 'icons/obj/chemical.dmi'
	icon_state = "molten"
	gross = 1

/obj/decal/cleanable/cobweb2
	name = "cobweb"
	desc = "Someone should remove that."
	layer = MOB_LAYER+1
	icon = 'icons/obj/decals/cleanables.dmi'
	icon_state = "cobweb2"
	gross = 1

/obj/decal/cleanable/cobwebFloor
	name = "cobweb"
	desc = "\"Will you walk into my parlour?\" said the spider to the fly."
	layer = MOB_LAYER-1
	icon = 'icons/obj/decals/cleanables.dmi'
	icon_state = "cobweb_floor-c"
	event_handler_flags = USE_CANPASS
	gross = 1

	CanPass(atom/A, turf/T)
		if (ismob(A))
			A.changeStatus("slowed", 0.2 SECONDS)
			SPAWN_DBG(-1)
				qdel(src)		//break when walked over
		else return 1
		..()


/obj/decal/cleanable/fungus
	name = "space fungus"
	desc = "A fungal growth. Looks pretty nasty."
	icon = 'icons/obj/decals/cleanables.dmi'
	icon_state = "fungus1"
	var/amount = 1
	can_sample = 1
	sample_reagent = "space_fungus"
	sample_verb = "scrape"
	gross = 1

	New()
		if (prob(5))
			src.amount += rand(1,2)
			src.update_icon()
		..()
		return
/*
	unpooled()
		..()
		if (prob(5))
			src.amount += rand(1,2)
			src.update_icon()
*/
	proc/update_icon()
		src.icon_state = "fungus[max(1,min(3, amount))]"

	Sample(var/obj/item/W as obj, var/mob/user as mob)
		if (!src.can_sample || !W.reagents)
			return 0

		else if (src.sample_amt && src.sample_reagent)
			if (W.reagents.total_volume >= W.reagents.maximum_volume - (src.sample_amt - 1))
				user.show_text("[W] is too full!", "red")
				return 0
			else
				W.reagents.add_reagent(src.sample_reagent, src.sample_amt)
				user.visible_message("<span class='notice'><b>[user]</b> [src.sample_verb]s some of [src] into [W].</span>",\
				"<span class='notice'>You [src.sample_verb] some of [src] into [W].</span>")
				W.reagents.handle_reactions()
				playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
				src.amount--
				if (src.amount <= 0)
					qdel(src)
				src.update_icon()
				return 1


/obj/decal/cleanable/martian_viscera
	name = "chunky martian goop"
	desc = "Gross alien flesh. Do not ingest. Do not apply to face."
	anchored = 0
	layer = OBJ_LAYER
	sample_reagent = "martian_flesh"
	sample_verb = "scoop"
	can_sample = 1
	icon = null
	icon_state = "rel-gib2"
	gross = 1

/obj/decal/cleanable/martian_viscera/fluid
	name = "sticky martian goop"
	icon_state = "goop1"
	random_icon_states = list("goop1", "goop2", "goop3", "goop4")

/obj/decal/cleanable/flockdrone_debris
	name = "weird stringy crystal fibres"
	desc = "Aw hell it's probably going to ruin your lungs if you breathe those. It's probably space alien asbestos or something. They're all sticky too, eww."
	anchored = 0
	layer = OBJ_LAYER
	sample_reagent = "flockdrone_fluid"
	sample_verb = "scoop"
	can_sample = 1
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "gib1"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5")
	slippery = 30
	gross = 1

/obj/decal/cleanable/flockdrone_debris/fluid
	name = "viscous teal fluid"
	desc = "Is it like weird alien blood? Weird alien oil? Aw man that looks like it'd never wash out."
	random_icon_states = list("fluid1", "fluid2", "fluid3")
	anchored = 1
	slippery = 50
	stain = "teal-stained"

/obj/decal/cleanable/machine_debris
	name = "twisted shrapnel"
	desc = "A chunk of broken and melted scrap metal."
	anchored = 0
	layer = OBJ_LAYER
	icon = 'icons/mob/robots.dmi'
	icon_state = "gib1"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7")
	gross = 1

/obj/decal/cleanable/robot_debris
	name = "robot debris"
	desc = "Useless heap of junk."
	anchored = 0
	layer = OBJ_LAYER
	icon = 'icons/mob/robots.dmi'
	icon_state = "gib1"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7")
	gross = 1

	attack_hand(var/mob/user as mob)
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (H.job == "Roboticist" || H.job == "Engineer" || H.job == "Mechanic")
				user.visible_message("<span class='notice'><b>[H]</b> starts rifling through \the [src] with their hands. What a weirdo.</span>",\
				"<span class='notice'>You rake through \the [src] with your bare hands.</span>")
				playsound(src.loc, "sound/effects/sparks3.ogg", 50, 1)
				if (src.sampled)
					H.show_text("You didn't find anything useful. Now you have grime all over your hands for nothing!", "red")
				else
					H.show_text("You find some... salvageable... wires.. you guess?", "blue")
					new /obj/item/cable_coil/cut/small(src.loc)
				src.sampled = 1
			if (H.job == "Chef" || H.job == "Sous-Chef")
				user.visible_message("<span class='notice'><b>[H]</b> starts rifling through \the [src] with their hands. What a weirdo.</span>",\
				"<span class='notice'>You rake through \the [src] with your bare hands.</span>")
				playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
				if (src.sampled)
					H.show_text("You didn't find anything useful. Now your hands are all grimey for nothing!", "red")
				else
					if (H.job == "Sous-Chef" && prob(30))
						H.show_text("The... twitching meat... slips through your inexperienced hands.", "blue")
					else
						H.show_text("You find some... salvageable... twitching meat.. you guess?", "blue")
						var/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/M = new /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/(src.loc)
						M.cybermeat = 1
						M.name = "meatal"
						M.desc = "Raw, twitching silicon based muscle. Eww."
						M.icon_state = "cybermeat"
						if (prob(25))
							M.reagents.add_reagent("nanites", 2)
					src.sampled = 1
			else
				return ..()
		else
			return ..()

/obj/decal/cleanable/robot_debris/limb
	random_icon_states = list("gibarm", "gibleg")

/obj/decal/cleanable/oil
	name = "motor oil"
	desc = "It's black."
	icon = 'icons/obj/decals/oil.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	slippery = 70
	can_sample = 1
	sample_reagent = "oil"
	stain = "oily"
	gross = 1

/obj/decal/cleanable/oil/streak
	random_icon_states = list("streak1", "streak2", "streak3", "streak4", "streak5")

/obj/decal/cleanable/paint
	name = "marker paint"
	desc = "It's a fluorescent orange"
	icon = 'icons/obj/decals/blood.dmi'
	icon_state = "blank"
	random_icon_states = null
	slippery = 0
	can_dry = 0
	can_sample = 0
	sample_reagent = "juice_orange"
	stain = "painted"
	gross = 1

/obj/decal/cleanable/imprint
	name = "footprint"
	desc = "An imprint in the sand left by a foot."
	icon = 'icons/obj/decals/blood.dmi'
	random_icon_states = null
	slippery = 0
	can_dry = 0
	can_sample = 0
	gross = 0

/obj/decal/cleanable/sand
	name = "sand"
	desc = "It gets everywhere!"
	icon = 'icons/obj/decals/blood.dmi' //waiting for wack icon,for now it's blood
	random_icon_states = null
	slippery = 0
	can_dry = 0
	can_sample = 0
	stain = "sandy"
	gross = 0

/obj/decal/cleanable/greenglow
	name = "green glow"
	desc = "Eerie."
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenglow"
	can_dry = 1
	dry_time = 1200
	var/datum/light/light
	gross = 1
/*
	unpooled()
		light = new /datum/light/point
		light.set_brightness(0.4)
		light.set_height(0.5)
		light.set_color(0.2, 1, 0.2)
		light.attach(src)
		light.enable()
		..()
*/
	disposing()
		if(light)
			qdel(light)
		..()

	setup()
		..()

/obj/decal/cleanable/saltpile
	name = "salt pile"
	desc = "Bad luck, that."
	icon = 'icons/obj/decals/salt.dmi'
	icon_state = "0"
	can_sample = 1
	sample_reagent = "salt"
	sample_verb = "scrape"
	var/health = 30

	New()
		..()
		src.updateIcon()
		var/turf/T = get_turf(src)
		if (T)
			updateSurroundingSalt(T)

	setup()
		..()
		src.updateIcon()
		health = 30
		var/turf/T = get_turf(src)
		if (T)
			updateSurroundingSalt(T)

	HasEntered(AM as mob|obj)
		..()
		if (istype(AM, /obj/critter/slug))
			var/obj/critter/slug/S = AM
			S.visible_message("<span class='alert'>[S] shrivels up!</span>")
			S.CritterDeath()
			return
		else if (!isliving(AM) || isobj(AM) || isintangible(AM))
			return
		var/mob/M = AM
		var/oopschance = 0
		if (ismob(AM))
			if (istype(AM, /mob/living/critter/small_animal/slug)) // slugs are not good with salt
				M.visible_message("<span class='alert'>[M] shrivels up!</span>",\
				"<span class='alert'><b>OH GOD THE SALT [pick("IT BURNS","HOLY SHIT THAT HURTS","JESUS FUCK YOU'RE DYING")]![pick("","!","!!")]</b></span>")
				M.TakeDamage(null, 15, 15)
				qdel(src)
				return
			if (isghostdrone(AM) || isghostcritter(AM)) // slugs are not good with salt
				return
			if (M.m_intent != "walk") // walk, don't run
				oopschance += 28
			if (prob(oopschance))
				health -= 5
				if (health <= 0)
					M.visible_message("<span class='alert'>[M.name] accidentally scuffs a foot across the [src], scattering it everywhere! [pick("Fuck!", "Shit!", "Damnit!", "Welp.")]</span>")
					qdel(src)
				else

	get_desc(dist)
		if (health >= 30)
			. = " It's a good size."
		else if (health >= 15)
			. = " It's slightly scuffed."
		else if (health > 0)
			. = " It's very small."

	disposing()
		var/turf/T = get_turf(src)
		..()
		updateSurroundingSalt(T)

	Sample(var/obj/item/W as obj, var/mob/user as mob)
		..()
		qdel(src)

	proc/updateIcon()
		if (!src.loc)
			return
		var/dirs = 0
		for (var/dir in cardinal)
			var/turf/T = get_step(src, dir)
			if (istype(T))
				var/obj/decal/cleanable/saltpile/S = T.getSaltHere()
				if (S)
					dirs |= dir

		icon_state = num2text(dirs)
		//need sprites for this

		// var/hp_name
		// if (health >= 30)
		// 	hp_name = "big"
		// else if (health >= 15)
		// 	hp_name = "med"
		// else if (health > 0)
		// 	hp_name = "small"
		//icon_state = "[hp_name]-[num2text(dirs)]"				//for health

/proc/updateSurroundingSalt(var/turf/T)
	if (!istype(T)) return
	for (var/obj/decal/cleanable/saltpile/S in orange(1,T))
		S.updateIcon()

/obj/decal/cleanable/magnesiumpile
	name = "magnesium pile"
	desc = "Uh-oh."
	icon = 'icons/obj/decals/salt.dmi'
	icon_state = "0"
	can_sample = 1
	sample_reagent = "magnesium"
	sample_verb = "scrape"
	var/on_fire = null
	var/burn_time = 4
	gross = 1

	New()
		..()
		src.updateIcon()
		updateSurroundingMagnesium(get_turf(src))

	setup()
		..()
		src.updateIcon()
		updateSurroundingMagnesium(get_turf(src))

	disposing()
		var/turf/T = get_turf(src)
		..()
		updateSurroundingMagnesium(T)

	Sample(var/obj/item/W as obj, var/mob/user as mob)
		..()
		qdel(src)

	proc/updateIcon()
		var/dirs = 0
		for (var/dir in cardinal)
			var/turf/T = get_step(src, dir)
			var/obj/decal/cleanable/magnesiumpile/S = locate(/obj/decal/cleanable/magnesiumpile) in T
			if (S)
				dirs |= dir
		icon_state = num2text(dirs)

	proc/ignite()
		if (on_fire)
			return
		on_fire = image('icons/effects/fire.dmi', "2old")
		visible_message("<span class='alert'>[src] ignites!</span>")
		src.overlays += on_fire
		SPAWN_DBG(0)
			var/turf/T = get_turf(src)
			while (burn_time > 0)
				if (loc == T && !disposed && on_fire)
					fireflash_sm(T, 0, T0C + 3100, 0, 1, 0)
					if (burn_time <= 2)
						for (var/D in cardinal)
							var/turf/Q = get_step(T, D)
							var/obj/decal/cleanable/magnesiumpile/M = locate() in Q
							if (M)
								M.ignite()
						if (src.loc && src.loc.reagents && src.loc.reagents.total_volume)
							for (var/i in 1 to 10)
								src.loc.reagents.temperature_reagents(T0C + 3100, 10)
						if (src.loc)
							for (var/obj/O in src.loc)
								if (O != src && O.reagents && O.reagents.total_volume)
									for (var/i in 1 to 10)
										O.reagents.temperature_reagents(T0C + 3100, 10)
					sleep(0.5 SECONDS)
				else
					return
				burn_time--

			if (on_fire)
				overlays -= on_fire
				on_fire = null
				burn_time = initial(burn_time)
			qdel(src)

	reagent_act(id, volume)
		if (disposed)
			return
		if (id == "water")
			if (on_fire)
				if (volume >= 10)
					explosion_new(src, get_turf(src), 1)
					qdel(src)
				else
					overlays -= on_fire
					on_fire = null
					burn_time = initial(burn_time)
		else if (id == "ff-foam")
			if (on_fire)
				overlays -= on_fire
				on_fire = null
				burn_time = initial(burn_time)

	temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		if (exposed_temperature >= T0C + 473)
			ignite()
		..()

/turf/proc/getSaltHere()
	for (var/obj/decal/cleanable/saltpile/S in src.contents)
		return S

/proc/updateSurroundingMagnesium(var/turf/T)
	if (!istype(T)) return
	for (var/obj/decal/cleanable/magnesiumpile/S in orange(1,T))
		S.updateIcon()

/obj/decal/cleanable/nitrotriiodide
	name = "gooey mess"
	desc = "Someone should DEFINITELY clean that up"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nitrotri_wet"
	color = "#cb5e97"
	can_dry = 1
	var/do_bang = 0
	gross = 1

	HasEntered(AM as mob|obj)
		if( !src.dry || !(isliving(AM) || isobj(AM)) ) return
		src.bang()

	attackby(var/obj/item/W, var/mob/user)
		if (src.dry)
			src.bang()
			return
		return ..()

	attack_hand(var/mob/user)
		if (src.dry)
			src.bang()
		else
			boutput(user, "<span class='notice'>You poke the mess. It's slightly viscous and smells strange. [prob(25) ? pick("Ew.", "Grody.", "Weird.") : null]</span>")

	proc/bang()
		src.visible_message("<b>The dust emits a loud bang!</b>")
		if(prob(20))
			var/datum/effects/system/bad_smoke_spread/smoke = new /datum/effects/system/bad_smoke_spread()
			smoke.set_up(5, 0, src.loc, ,"#cb5e97")
			smoke.start()

		explosion(src, src.loc, -1, -1, -1, 1)
		qdel(src)

	Dry(var/time = 200 + 20 * rand(0,30))
		if (!src.can_dry || src.dry)
			return 0
		last_dry_start = world.time
		dry_time = time
		return 1

	end_dry()
		src.dry = 1
		name = "dusty powder"
		desc = "Janitor's clearly not doing his job properly, sigh."
		icon_state = "nitrotri_dry"
		if (prob(25)) //This emulates the effect of air randomly passing over the stuff
			src.bang()

// GANG TAGS

/obj/decal/cleanable/gangtag
	name = "gang tag"
	desc = "A spraypainted gang tag."
	density = 0
	anchored = 1
	layer = OBJ_LAYER
	icon = 'icons/obj/decals/gang_tags.dmi'
	icon_state = "gangtag0"
	var/datum/gang/owners = null

	proc/delete_same_tags()
		for(var/obj/decal/cleanable/gangtag/T in get_turf(src))
			if(T.owners == src.owners && T != src) qdel(T)

	New()
		..()
		for(var/obj/decal/cleanable/gangtag/T in get_turf(src))
			T.layer = 3
		src.layer = 4

	setup()
		..()
		for(var/obj/decal/cleanable/gangtag/T in get_turf(src))
			T.layer = 3
		src.layer = 4

	disposing(var/uncapture = 1)
		var/area/tagarea = get_area(src)
		if(tagarea.gang_owners == src.owners && uncapture)
			tagarea.gang_owners = null
			var/turf/T = get_turf(src)
			T.tagged = 0
		..()

/obj/decal/cleanable/greenface
	name = "graffiti"
	desc = "What a funky dude. He'll never attain political power."
	icon = 'icons/obj/decals/graffiti.dmi'
	icon_state = "graffiti-single-1"

/// Input a cardinal direction, it'll throw it somewhere within +-45 degrees of that direction. More or less.
/obj/decal/cleanable/proc/streak_cleanable(var/list/directions, var/randcolor = 0, var/full_streak)
	if(isnull(get_turf(src)))
		CRASH("Attempting to streak cleanable [src] which is in null.")

	var/destination
	var/dist = rand(1,6)
	if(prob(10))
		dist = 30 // Occasionally throw the chunk somewhere *interesting*
	if(length(directions))
		destination = pick(directions)
		if(!(destination in cardinal))
			destination = null
	else if(isnum(directions))
		destination = directions

	if(destination)
		destination = GetRandomPerimeterTurf(get_turf(src), dist, destination)
	else
		destination = GetRandomPerimeterTurf(get_turf(src), dist)

	var/list/linepath = getline(src, destination)

	var/kind_of_cleanable
	if(istype(src, /obj/decal/cleanable/tracked_reagents/blood))
		kind_of_cleanable = "BLOOD"
	else if(istype(src, /obj/decal/cleanable/machine_debris))
		kind_of_cleanable = "MACHINE"
	else if(istype(src, /obj/decal/cleanable/robot_debris))
		kind_of_cleanable = "ROBOT"
	else if(istype(src, /obj/decal/cleanable/martian_viscera))
		kind_of_cleanable = "MARTIAN"
	else if(istype(src, /obj/decal/cleanable/flockdrone_debris))
		kind_of_cleanable = "FLOCK"
	else
		kind_of_cleanable = "BLOOD"
	SPAWN_DBG(0)
		/// Number of tiles where it should try to make a splatter
		var/num_splats = rand(round(dist * 0.2), dist) + 1
		for (var/turf/T in linepath)
			if(step_to(src, T, 0, 300) && num_splats-- >= 1)
				switch(kind_of_cleanable)
					if("BLOOD")
						var/obj/decal/cleanable/tracked_reagents/blood/b = make_cleanable( /obj/decal/cleanable/tracked_reagents/blood/splatter/extra,get_turf(src))
						if (!b) continue //ZeWaka: fix for null.diseases
						if (src?.diseases)
							b.diseases += src.diseases
						if (src.blood_DNA && src.blood_type) // For forensics (Convair880).
							b.blood_DNA = src.blood_DNA
							b.blood_type = src.blood_type
						b.color = src.color
						if (randcolor) // only used by funnygibs atm. in the future, the possibilities are endless for this var. imagine what it could do..........
							b.color = random_saturated_hex_color()
						if(src.sample_reagent)
							b.set_sample_reagent_custom(src.sample_reagent, 10)

					if("MARTIAN")
						if (prob(40))
							var/obj/decal/cleanable/tracked_reagents/blood/b = make_cleanable( /obj/decal/cleanable/tracked_reagents/blood/splatter/extra,get_turf(src))
							b.blood_DNA = src.blood_DNA
							b.blood_type = src.blood_type
							b.color = "#0b1f8f"
						else if (prob(10))
							elecflash(src)
					if("FLOCK")
						make_cleanable( /obj/decal/cleanable/flockdrone_debris/fluid,src.loc)
					if("MACHINE", "ROBOT")
						if (prob(40))
							make_cleanable(/obj/decal/cleanable/oil/streak,src.loc)
						else if (prob(10))
							elecflash(src)
			sleep(0.1 SECONDS)

/*
                                  ''''''
IIIIIIIIIITTTTTTTTTTTTTTTTTTTTTTT '::::'   SSSSSSSSSSSSSSS      PPPPPPPPPPPPPPPPP        OOOOOOOOO          OOOOOOOOO     PPPPPPPPPPPPPPPPP
I::::::::IT:::::::::::::::::::::T '::::' SS:::::::::::::::S     P::::::::::::::::P     OO:::::::::OO      OO:::::::::OO   P::::::::::::::::P
I::::::::IT:::::::::::::::::::::T ':::''S:::::SSSSSS::::::S     P::::::PPPPPP:::::P  OO:::::::::::::OO  OO:::::::::::::OO P::::::PPPPPP:::::P
II::::::IIT:::::TT:::::::TT:::::T':::'  S:::::S     SSSSSSS     PP:::::P     P:::::PO:::::::OOO:::::::OO:::::::OOO:::::::OPP:::::P     P:::::P
  I::::I  TTTTTT  T:::::T  TTTTTT''''   S:::::S                   P::::P     P:::::PO::::::O   O::::::OO::::::O   O::::::O  P::::P     P:::::P
  I::::I          T:::::T               S:::::S                   P::::P     P:::::PO:::::O     O:::::OO:::::O     O:::::O  P::::P     P:::::P
  I::::I          T:::::T                S::::SSSS                P::::PPPPPP:::::P O:::::O     O:::::OO:::::O     O:::::O  P::::PPPPPP:::::P
  I::::I          T:::::T                 SS::::::SSSSS           P:::::::::::::PP  O:::::O     O:::::OO:::::O     O:::::O  P:::::::::::::PP
  I::::I          T:::::T                   SSS::::::::SS         P::::PPPPPPPPP    O:::::O     O:::::OO:::::O     O:::::O  P::::PPPPPPPPP
  I::::I          T:::::T                      SSSSSS::::S        P::::P            O:::::O     O:::::OO:::::O     O:::::O  P::::P
  I::::I          T:::::T                           S:::::S       P::::P            O:::::O     O:::::OO:::::O     O:::::O  P::::P
  I::::I          T:::::T                           S:::::S       P::::P            O::::::O   O::::::OO::::::O   O::::::O  P::::P
II::::::II      TT:::::::TT             SSSSSSS     S:::::S     PP::::::PP          O:::::::OOO:::::::OO:::::::OOO:::::::OPP::::::PP
I::::::::I      T:::::::::T             S::::::SSSSSS:::::S     P::::::::P           OO:::::::::::::OO  OO:::::::::::::OO P::::::::P
I::::::::I      T:::::::::T             S:::::::::::::::SS      P::::::::P             OO:::::::::OO      OO:::::::::OO   P::::::::P
IIIIIIIIII      TTTTTTTTTTT              SSSSSSSSSSSSSSS        PPPPPPPPPP               OOOOOOOOO          OOOOOOOOO     PPPPPPPPPP
*/


/obj/item/reagent_containers/food/snacks/ingredient/mud
	name = "mud"
	desc = "It is poo."
	icon = 'icons/obj/decals/not_poo.dmi'
	icon_state = "mud1"
	color = DEFAULT_MUD_COLOR
	//item_state = "poop"
	var/mob/living/carbon/owner = null
	var/mob/living/carbon/human/last_touched
	amount_per_transfer_from_this = 10
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER

	attack_hand(var/mob/user)
		last_touched = user
		..()

	New(turf/newLoc, var/amount = 9)
		..()
		src.create_reagents(30)
		src.reagents.add_reagent("poo", amount)
		icon_state = "mud[rand(1,3)]"
		name = pick("shit","turd","poop","poo","loaf","deuce","brick")

	heal(var/mob/living/M)
		if (prob(33))
			boutput(M, "<span class='alert'>You briefly think you probably shouldn't be eating this.</span>")
			M.contract_disease(/datum/ailment/disease/food_poisoning, null, null, 1) // path, name, strain, bypass resist

	throw_impact(atom/A, datum/thrown_thing/thr)
		var/turf/T = get_turf(A)
		playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 100, 1)

		if (istype(T))

			var/obj/decal/cleanable/tracked_reagents/dynamic/B = null
			if (T.messy > 0)
				B = locate(/obj/decal/cleanable/tracked_reagents/dynamic) in T

			if (!B) // look for an existing dynamic blood decal and add to it if you find one
				B = make_cleanable( /obj/decal/cleanable/tracked_reagents/dynamic,T)

			B.transfer_volume(src.reagents, src.reagents.total_volume, do_fluid_react = (src.reagents.total_volume >= 15))

			B.stain = "shit-stained"

		else if (ishuman(A))
			var/mob/living/carbon/human/H = A
			if (H.wear_suit)
				H.wear_suit.add_mud(src)
				H.set_clothing_icon_dirty()
			else if (H.w_uniform)
				H.w_uniform.add_mud(src)
				H.set_clothing_icon_dirty()
			else
				if (H.shoes)
					H.shoes.add_mud(src)
					H.set_clothing_icon_dirty()
			if (H.sims)
				H.sims.affectMotive("fun", -10)
				if (owner && (owner == H)) // double humiliation if it's your own shit
					H.sims.affectMotive("fun", -10)
			if (istype(last_touched) && (last_touched in viewers(src)) && last_touched != H)
				if (last_touched.sims)
					last_touched.sims.affectMotive("fun", 10)

		else if(ismovable(A))
			A.add_mud(src, src.reagents.total_volume ? src.reagents.total_volume : 15)

		qdel(src)

		..()

/obj/item/reagent_containers/food/snacks/ingredient/mud/HasEntered(AM as mob|obj)
	if(istype(src.loc, /turf/space))
		return
	if (iscarbon(AM))
		var/mob/M =	AM
		if (M.slip(ignore_actual_delay = 1))

			boutput(M, "<span class='notice'>You slipped on [src]!</span>")
			M.lastgasp()
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if (H.sims)
					H.sims.affectMotive("fun", -10)
					if (owner && (owner == H)) // double humiliation if it's your own shit
						H.sims.affectMotive("fun", -10)
			if (istype(last_touched) && (last_touched in viewers(src)) && last_touched != M)
				if (last_touched.sims)
					last_touched.sims.affectMotive("fun", 10)
			if(M.bioHolder.HasEffect("clumsy"))
				M.changeStatus("weakened", 5 SECONDS)
				JOB_XP(M, "Clown", 2)
			else
				if (prob(50))
					JOB_XP(last_touched, "Clown", 1)

			src.throw_impact(M) //splat the poo after it's been slipped on


/obj/decal/cleanable/tracked_reagents/mud
	name = "poo"
	desc = "Ewww, doesn't this violate health code?"
	sample_reagent = "poo"
	can_sample = 1
	color = DEFAULT_MUD_COLOR
	icon = 'icons/obj/decals/not_poo.dmi'
	icon_state = "floor1"
	var/datum/ailment/disease/virus = null
	slippery = 50
	can_dry = 1
	stain = "shit-stained"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7", "floor8")
	gross = 1 //like, above all others, this is the epitome of not safe for food

	New()
		src.create_reagents(reagents_max)
		src.reagents.add_reagent("poo", 10)
		..()

	setup()
		if (!src.reagents)
			src.create_reagents(reagents_max)
		else
			src.reagents.clear_reagents()
		src.reagents.add_reagent("poo", 10)
		..()

/obj/decal/cleanable/tracked_reagents/mud/drip
	New()
		..()
		src.pixel_y += rand(0,16)

/obj/decal/cleanable/tracked_reagents/mud/drip/low
	random_icon_states = list("drip1a", "drip1b", "drip1c", "drip1d", "drip1e", "drip1f")
/obj/decal/cleanable/tracked_reagents/mud/drip/med
	random_icon_states = list("drip2a", "drip2b", "drip2c", "drip2d", "drip2e", "drip2f")
/obj/decal/cleanable/tracked_reagents/mud/drip/high
	random_icon_states = list("drip3a", "drip3b", "drip3c", "drip3d", "drip3e", "drip3f")

/obj/decal/cleanable/tracked_reagents/mud/splatter
	random_icon_states = list("gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5")

/obj/decal/cleanable/tracked_reagents/mud/splatter/extra
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7", "gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5")


/obj/decal/cleanable/tracked_reagents/mud/tracks
	icon_state = "tracks"
	random_icon_states = null
	color = "#FFFFFF"

/obj/decal/cleanable/tracked_reagents/mud/hurting1
	icon_state = "hurting1"
	color = "#FFFFFF"
	random_icon_states = null

	hurting2
		icon_state = "hurting2"

/obj/decal/cleanable/tooth
	name = "loose tooth"
	desc = "Some schmuck got this knocked straight out of their head."
	icon = 'icons/obj/decals/blood.dmi'
	random_icon_states = list("tooth1", "tooth2", "tooth3", "tooth4")

/obj/decal/cleanable/edge_grit //harming people is what the shard items are for we're here just for flavour
	name = "glass grit"
	desc = "A whole lot of tiny shards, too small to be harmful."
	icon = 'icons/obj/decals/cleanables.dmi'
	icon_state = "grit_edge"

/obj/decal/cleanable/grit
	name = "glass grit"
	desc = "A whole lot of tiny shards, too small to be harmful."
	icon = 'icons/obj/decals/cleanables.dmi'
	icon_state = "grit_full"

	small
		color = "#A3DCFF" //stolen from glass mat
		random_icon_states = list("grit1", "grit2", "grit3", "grit4")
