/* ================================================= */
/* -------------------- Stools --------------------- */
/* ================================================= */

//originally in code/obj/stool.dm
//stools and benches and pews the objects have been pulled out of that hellmess for legibility

/obj/stool/bee_bed
	// idk. Not a bed proper since humans can't lay in it. Weirdos.
	// would also be cool to make these work with bees.
	// it's hip to tuck bees!
	name = "bee bed"
	icon = 'icons/mob/critter.dmi'
	icon_state = "beebed"
	desc = "A soft little bed the general size and shape of a space bee."
	cando_flags = 0
	parts_type = /obj/item/furniture_parts/stool/bee_bed

/obj/stool/bar
	name = "bar stool"
	icon_state = "bar-stool"
	desc = "Like a stool, but in a bar."
	//spins
	swivels = 1
	//not moving
	anchored = 1
	//can be unscrewed for comedy
	securable = 1
	//welded to the floor
	detachable = 1
	//click 2 sit. authentic bar experience
	density = 1
	//can construct/deconstruct
	parts_type = /obj/item/furniture_parts/stool/bar

/obj/stool/wooden
	name = "wooden stool"
	icon_state = "wstool"
	desc = "Like a stool, but just made out of wood."
	parts_type = /obj/item/furniture_parts/woodenstool

/* ================================================= */
/* -------------------- Benches -------------------- */
/* ================================================= */

/obj/stool/bench
	name = "bench"
	desc = "It's a bench! You can sit on it!"
	icon = 'icons/obj/furniture/bench.dmi'
	icon_state = "0"
	anchored = 1
	cando_flags = STOOL_SIT | STOOL_STAND
	var/auto = 0
	var/auto_path = null
	parts_type = /obj/item/furniture_parts/bench

	New()
		..()
		SPAWN_DBG(0)
			if (src.auto && ispath(src.auto_path))
				src.set_up(1)

	proc/set_up(var/setup_others = 0)
		if (!src.auto || !ispath(src.auto_path))
			return
		var/dirs = 0
		for (var/dir in cardinal)
			var/turf/T = get_step(src, dir)
			if (locate(src.auto_path) in T)
				dirs |= dir
		icon_state = num2text(dirs)
		if (setup_others)
			for (var/obj/stool/bench/B in orange(1,src))
				if (istype(B, src.auto_path))
					B.set_up()

	deconstruct()
		if (!src.deconstructable)
			return
		var/oldloc = src.loc
		..()
		for (var/obj/stool/bench/B in orange(1,oldloc))
			if (B.auto)
				B.set_up()
		return

/obj/stool/bench/auto
	auto = 1
	auto_path = /obj/stool/bench/auto

/* ---------- Red ---------- */

/obj/stool/bench/red
	icon = 'icons/obj/furniture/bench_red.dmi'
	parts_type = /obj/item/furniture_parts/bench/red

/obj/stool/bench/red/auto
	auto = 1
	auto_path = /obj/stool/bench/red/auto

/* ---------- Blue ---------- */

/obj/stool/bench/blue
	icon = 'icons/obj/furniture/bench_blue.dmi'
	parts_type = /obj/item/furniture_parts/bench/blue

/obj/stool/bench/blue/auto
	auto = 1
	auto_path = /obj/stool/bench/blue/auto

/* ---------- Green ---------- */

/obj/stool/bench/green
	icon = 'icons/obj/furniture/bench_green.dmi'
	parts_type = /obj/item/furniture_parts/bench/green

/obj/stool/bench/green/auto
	auto = 1
	auto_path = /obj/stool/bench/green/auto

/* ---------- Yellow ---------- */

/obj/stool/bench/yellow
	icon = 'icons/obj/furniture/bench_yellow.dmi'
	parts_type = /obj/item/furniture_parts/bench/yellow

/obj/stool/bench/yellow/auto
	auto = 1
	auto_path = /obj/stool/bench/yellow/auto

/* ---------- Wooden ---------- */

/obj/stool/bench/wooden
	icon = 'icons/obj/furniture/bench_wood.dmi'
	parts_type = /obj/item/furniture_parts/bench/wooden

/obj/stool/bench/wooden/auto
	auto = 1
	auto_path = /obj/stool/bench/wooden/auto

/* ---------- Sauna ---------- */

/obj/stool/bench/sauna
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "saunabench"

/* ============================================== */
/* -------------------- Pews -------------------- */
/* ============================================== */

/obj/stool/chair/pew // pew pew
	name = "pew"
	desc = "It's like a bench, but more holy. No, not <i>holey</i>, <b>holy</b>. Like, godly, divine. That kinda thing.<br>Okay, it's actually kind of holey, too, now that you look at it closer."
	icon_state = "pew"
	anchored = 1
	rotatable = 0
	foldable = 0
	comfort_value = 2
	deconstructable = TRUE
	securable = 0
	parts_type = /obj/item/furniture_parts/bench/pew
	var/image/arm_image = null
	var/arm_icon_state = null

	New()
		..()
		if (arm_icon_state)
			src.update_icon()

	update_icon()
		if (src.dir == NORTH)
			src.layer = FLY_LAYER+1
		else
			src.layer = OBJ_LAYER
			if ((src.dir == WEST || src.dir == EAST) && !src.arm_image)
				src.arm_image = image(src.icon, src.arm_icon_state)
				src.arm_image.layer = FLY_LAYER+1
				src.UpdateOverlays(src.arm_image, "arm")

	left
		icon_state = "pewL"
	center
		icon_state = "pewC"
	right
		icon_state = "pewR"

/obj/stool/chair/pew/fancy
	icon_state = "fpew"
	arm_icon_state = "arm-fpew"

	left
		icon_state = "fpewL"
		arm_icon_state = "arm-fpewL"
	center
		icon_state = "fpewC"
		arm_icon_state = null
	right
		icon_state = "fpewR"
		arm_icon_state = "arm-fpewR"
