/datum/abilityHolder/vampire/var/list/bat_orbiters

/datum/abilityHolder/vampire/proc/launch_bat_orbiters()
	if (length(bat_orbiters))
		for (var/obj/projectile/P in bat_orbiters)
			if (get_dist(P,src.owner) < 4)
				P.targets = 0

		bat_orbiters.len = 0

/datum/targetable/vampire/call_bats
	name = "Call Frost Bats"
	desc = "Calls a swarm of frost bat spirits. They will orbit you, protecting your personal space from projectiles and living assailants. You can use the Flip emote to launch them."
	icon_state = "frostbats"
	targeted = 0
	target_nodamage_check = 0
	max_range = 5 // so that ai uses correctly
	cooldown = 600
	pointCost = 0//150
	when_stunned = 0
	not_when_handcuffed = 0
	unlock_message = "You have gained Call Frost Bats, a protection spell."
	attack_mobs = TRUE

	var/datum/projectile/special/homing/orbiter/spiritbat/P = new

	var/datum/abilityHolder/vampire/vamp_holder

	onAttach(datum/abilityHolder/H)
		. = ..()
		src.vamp_holder = H

	disposing()
		src.vamp_holder = null
		..()

	flip_callback()
		src.vamp_holder.launch_bat_orbiters()

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner

		if (!M)
			return 1

		var/turf/T = get_turf(M)
		if (T && isturf(T))
			//play sound pls
			//either here or in projectile launch

			vamp_holder.bat_orbiters = list()

			var/create = 4
			var/turf/shoot_at = get_step(M,pick(alldirs))

			for (var/i = 0, i < create, i += 0.1) //pay no mind :)
				var/obj/projectile/proj = initialize_projectile_ST(M, P, shoot_at)
				if (proj && !proj.disposed)
					proj.targets = list(M)

					vamp_holder.bat_orbiters += proj

					proj.launch()
					proj.special_data["orbit_angle"] = floor(i)/create * 360

					i++

		else
			boutput(M, __red("The bats did not respond to your call!"))
			return 1 // No cooldown here, though.

		if (src.pointCost && istype(vamp_holder))
			vamp_holder.blood_tracking_output(src.pointCost)

		playsound(M.loc, 'sound/effects/gust.ogg', 60, 1)

		logTheThing("combat", M, null, "uses call bats at [log_loc(M)].")
		return 0
