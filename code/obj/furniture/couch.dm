/* ================================================= */
/* -------------------- Couches -------------------- */
/* ================================================= */

/obj/stool/chair/couch
	name = "comfy brown couch"
	desc = "You've probably lost some space credits in these things before."
	icon_state = "chair_couch-brown"
	rotatable = 0
	foldable = 0
	var/damaged = 0
	comfort_value = 5
	deconstructable = 0
	securable = 0
	var/max_uses = 0 // The maximum amount of time one can try to look under the cushions for items.
	var/spawn_chance = 0 // How likely is this couch to spawn something?
	var/last_use = 0 // To prevent spam.
	var/time_between_uses = 400 // The default time between uses.
	var/list/items = list (/obj/item/device/light/zippo,
	/obj/item/wrench,
	/obj/item/device/multitool,
	/obj/item/toy/plush/small/buddy,
	/obj/item/toy/plush/small/stress_ball,
	/obj/item/paper/lunchbox_note,
	/obj/item/plant/herb/cannabis/spawnable,
	/obj/item/reagent_containers/food/snacks/candy/candyheart,
	/obj/item/bananapeel,
	/obj/item/reagent_containers/food/snacks/lollipop/random_medical,
	/obj/item/spacecash/random/small,
	/obj/item/spacecash/random/tourist,
	/obj/item/spacecash/buttcoin)

	New()
		..()
		max_uses = rand(0, 2) // Losing things in a couch is hard.
		spawn_chance = rand(1, 20)

		if (prob(10)) //time to flail
			items.Add(/obj/critter/meatslinky)

		if (prob(1))
			desc = "A vague feeling of loss emanates from this couch, as if it is missing a part of itself. A global list of couches, perhaps."

	disposing()
		..()

	proc/damage(severity)
		if(severity > 1 && damaged < 2)
			damaged += 2
			overlays += image('icons/obj/objects.dmi', "couch-tear")
		else if(damaged < 1)
			damaged += 1
			overlays += image('icons/obj/objects.dmi', "couch-rip")

	attack_hand(mob/user as mob)
		if (!user) return
		if (damaged || stool_user) return ..()

		user.lastattacked = src

		playsound(src.loc, "rustle", 66, 1, -5) // todo: find a better sound.

		if (max_uses > 0 && ((last_use + time_between_uses) < world.time) && prob(spawn_chance))

			var/something = pick(items)

			if (ispath(something))
				var/thing = new something(src.loc)
				user.put_in_hand_or_drop(thing)
				if (istype(thing, /obj/critter/meatslinky)) //slink slink
					user.emote("scream")
					random_brute_damage(user, 10)
					user.visible_message("<span class='notice'><b>[user.name]</b> rummages through the seams and behind the cushions of [src] and pulls [his_or_her(user)] hand out in pain! \An [thing] slithers out of \the [src]!</span>",\
					"<span class='notice'>You rummage through the seams and behind the cushions of [src] and your hand gets bit by \an [thing]!</span>")
				else
					user.visible_message("<span class='notice'><b>[user.name]</b> rummages through the seams and behind the cushions of [src] and pulls \an [thing] out of it!</span>",\
					"<span class='notice'>You rummage through the seams and behind the cushions of [src] and you find \an [thing]!</span>")
				last_use = world.time
				max_uses--

		else if (max_uses <= 0)
			user.visible_message("<span class='notice'><b>[user.name]</b> rummages through the seams and behind the cushions of [src] and pulls out absolutely nothing!</span>",\
			"<span class='notice'>You rummage through the seams and behind the cushions of [src] and pull out absolutely nothing!</span>")
		else
			user.visible_message("<span class='notice'><b>[user.name]</b> rummages through the seams and behind the cushions of [src]!</span>",\
			"<span class='notice'>You rummage through the seams and behind the cushions of [src]!</span>")

	blue
		name = "comfy blue couch"
		icon_state = "chair_couch-blue"

	red
		name = "comfy red couch"
		icon_state = "chair_couch-red"

	green
		name = "comfy green couch"
		icon_state = "chair_couch-green"

	yellow
		name = "comfy yellow couch"
		icon_state = "chair_couch-yellow"

	purple
		name = "comfy purple couch"
		icon_state = "chair_couch-purple"
	lblue
		name = "comfy light blue couch"
		icon_state = "comfy_couch-lblue"
	orange
		name = "comfy orange couch"
		icon_state = "comfy_couch-orange"
