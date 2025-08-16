/* ========================================================= */
/* -------------------- Electric Chairs -------------------- */
/* ========================================================= */

/obj/stool/chair/e_chair
	name = "electrified chair"
	desc = "A chair that has been modified to conduct current with over 2000 volts, enough to kill a human nearly instantly."
	icon_state = "e_chair0"
	foldable = 0
	var/on = 0
	var/obj/item/assembly/shock_kit/part1 = null
	var/last_time = 1
	var/lethal = 0
	var/image/image_belt = null
	comfort_value = -3
	securable = 0

	New()
		..()
		SPAWN_DBG(2 SECONDS)
			if (src)
				if (!(src.part1 && istype(src.part1)))
					src.part1 = new /obj/item/assembly/shock_kit(src)
					src.part1.master = src
				src.update_icon()
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if (iswrenchingtool(W))
			var/obj/stool/chair/C = new /obj/stool/chair(get_turf(src))
			if (src.material)
				C.setMaterial(src.material)
			playsound(src.loc, "sound/items/Ratchet.ogg", 50, 1)
			C.set_dir(src.dir)
			if (src.part1)
				src.part1.set_loc(get_turf(src))
				src.part1.master = null
				src.part1 = null
			qdel(src)
			return

	verb/controls()
		set src in oview(1)
		set category = "Local"

		src.control_interface(usr)

	// Seems to be the only way to get this stuff to auto-refresh properly, sigh (Convair880).
	proc/control_interface(mob/user as mob)
		if (!user.hasStatus("handcuffed") && isalive(user))
			src.add_dialog(user)

			var/dat = ""

			var/area/A = get_area(src)
			if (!isarea(A) || !A.powered(EQUIP))
				dat += "\n<font color='red'>ERROR:</font> No power source detected!</b>"
			else
				dat += {"<A href='byond://?src=\ref[src];on=1'>[on ? "Switch Off" : "Switch On"]</A><BR>
				<A href='byond://?src=\ref[src];lethal=1'>[lethal ? "<font color='red'>Lethal</font>" : "Nonlethal"]</A><BR><BR>
				<A href='byond://?src=\ref[src];shock=1'>Shock</A><BR>"}

			user.Browse("<TITLE>Electric Chair</TITLE><b>Electric Chair</b><BR>[dat]", "window=e_chair;size=180x180")

			onclose(user, "e_chair")
		return

	Topic(href, href_list)
		if (usr.getStatusDuration("stunned") || usr.getStatusDuration("weakened") || usr.stat || usr.restrained()) return
		if (!in_interact_range(src, usr)) return

		if (href_list["on"])
			toggle_active()
		else if (href_list["lethal"])
			toggle_lethal()
		else if (href_list["shock"])
			if (src.stool_user)
				// The log entry for remote signallers can be found in item/assembly/shock_kit.dm (Convair880).
				logTheThing("combat", usr, src.stool_user, "activated an electric chair (setting: [src.lethal ? "lethal" : "non-lethal"]), shocking [constructTarget(src.stool_user,"combat")] at [log_loc(src)].")
			shock(lethal)

		src.control_interface(usr)
		src.add_fingerprint(usr)
		return

	proc/toggle_active()
		src.on = !(src.on)
		src.update_icon()
		return src.on

	proc/toggle_lethal()
		src.lethal = !(src.lethal)
		src.update_icon()
		return

	update_icon()
		src.icon_state = "e_chair[src.on]"
		if (!src.image_belt)
			src.image_belt = image(src.icon, "e_chairo[src.on][src.lethal]", layer = FLY_LAYER + 1)
			src.UpdateOverlays(src.image_belt, "belts")
			return
		src.image_belt.icon_state = "e_chairo[src.on][src.lethal]"
		src.UpdateOverlays(src.image_belt, "belts")

	// Options:      1) place the chair anywhere in a powered area (fixed shock values),
	// (Convair880)  2) on top of a powered wire (scales with engine output).
	proc/get_connection()
		var/turf/T = get_turf(src)
		if (!istype(T, /turf/floor))
			return 0

		for (var/obj/cable/C in T)
			return C.get_netnumber()

		return 0

	proc/get_gridpower()
		var/netnum = src.get_connection()

		if (netnum)
			var/datum/powernet/PN
			if (powernets && powernets.len >= netnum)
				PN = powernets[netnum]
				return PN.avail

		return 0

	proc/shock(lethal)
		if (!src.on)
			return
		if ((src.last_time + 50) > world.time)
			return
		src.last_time = world.time

		// special power handling
		var/area/A = get_area(src)
		if (!isarea(A))
			return
		if (!A.powered(EQUIP))
			return
		A.use_power(EQUIP, 5000)
		A.updateicon()

		for (var/mob/M in AIviewers(src, null))
			M.show_message("<span class='alert'>The electric chair went off!</span>", 3)
			if (lethal)
				playsound(src.loc, "sound/effects/electric_shock.ogg", 50, 0)
			else
				playsound(src.loc, "sound/effects/sparks4.ogg", 50, 0)

		if (src.stool_user && ishuman(src.stool_user))
			var/mob/living/carbon/human/H = src.stool_user

			if (src.lethal)
				var/net = src.get_connection() // Are we wired-powered (Convair880)?
				var/power = src.get_gridpower()
				if (!net || (net && (power < 2000000)))
					H.shock(src, 2000000, "chest", 0.3, 1) // Nope or not enough juice, use fixed values instead (around 80 BURN per shock).
				else
					//DEBUG_MESSAGE("Shocked [H] with [power]")
					src.electrocute(H, 100, net, 1) // We are, great. Let that global proc calculate the damage.
			else
				H.shock(src, 2500, "chest", 1, 1)
				H.changeStatus("stunned", 10 SECONDS)

			if (ticker?.mode && istype(ticker.mode, /datum/game_mode/revolution))
				if ((H.mind in ticker.mode:revolutionaries) && !(H.mind in ticker.mode:head_revolutionaries) && prob(66))
					ticker.mode:remove_revolutionary(H.mind)

		A.updateicon()
		return
