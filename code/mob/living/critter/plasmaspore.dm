/mob/living/critter/plasmaspore
	name = "plasma spore"
	real_name = "plasma spore"
	desc = "A barely intelligent colony of organisms. Very volatile."
	density = 1
	icon_state = "spore"
	custom_gib_handler = /proc/gibs
	hand_count = 0
	can_throw = 0
	blood_id = "plasma"
	health_brute = 10
	health_brute_vuln = 5
	health_burn = 10
	health_burn_vuln = 25

	death(var/gibbed)
		src.visible_message("<b>[src]</b> ruptures and explodes!")
		var/turf/T = get_turf(src.loc)
		if(T)
			T.hotspot_expose(700,125)
			explosion(src, T, -1, -1, 2, 3)
		ghostize()
		qdel(src)
