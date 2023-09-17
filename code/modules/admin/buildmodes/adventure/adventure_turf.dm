/datum/adventure_submode/turf
	New()
		..()
		marker = new /obj/adventurepuzzle/marker()
	var/turf/A = null
	var/turftype = null
	var/obj/marker = null

	var/static/list/turfs = list("Ancient floor" = /turf/floor/setpieces/iomoon/ancient, \
	"Ancient wall" = /turf/wall/setpieces/iomoon/ancient, "Cave floor" = /turf/floor/cave, \
	"Cave wall" = /turf/wall/cave,  "Data floor: Blue" = /turf/floor/techfloor, \
	"Data floor: Red" = /turf/floor/techfloor/red, "Data floor: Purple" = /turf/floor/techfloor/purple, \
	"Data floor: Yellow" = /turf/floor/techfloor/yellow, "Data floor: Green" = /turf/floor/techfloor/green, \
	"Dirt" = /turf/aprilfools/dirt, "Grass" = /turf/aprilfools/grass, \
	"Hive floor" = /turf/floor/setpieces/hivefloor, "Hive wall" = /turf/wall/setpieces/hive, \
	"Ice" = /turf/floor/arctic/snow/ice, "Lava" = /turf/floor/lava, "Martian floor" = /turf/floor/setpieces/martian, \
	"Martian wall" = /turf/wall/setpieces/martian, "Normal floor" = /turf/floor, "Normal wall" = /turf/wall, \
	"Reinforced floor" = /turf/floor/engine, "Reinforced wall" = /turf/wall/r_wall, "Shielded floor" = /turf/floor/engine, \
	"Shielded wall" = /turf/wall/setpieces/leadwall, "Shielded window" = /turf/wall/setpieces/leadwindow, "Showcase" = /turf/floor/wizard/showcase, \
	"Shuttle floor" = /turf/floor/shuttle, "Shuttle wall" = /turf/shuttle/wall, "Snow" = /turf/floor/arctic/snow, \
	"Void floor" = /turf/floor/void, "Void wall" = /turf/wall/void, "Wizard carpet: Cross" = /turf/floor/wizard/carpet/cross, "Wizard carpet: Edge" = /turf/floor/wizard/carpet/edge, \
	"Wizard carpet: Inner corners (1-2)" = /turf/floor/wizard/carpet/inner_corner_onetwo, "Wizard carpet: Inner Corners (3-4)" = /turf/floor/wizard/carpet/inner_corner_threefour, \
	"Wizard carpet: Narrow" = /turf/floor/wizard/carpet/narrow, "Wizard carpet: Narrow crossing" = /turf/floor/wizard/carpet/narrow/crossing, "Wizard carpet: Plain" = /turf/floor/wizard/carpet, \
	"Wizard false wall" = /turf/wall/adaptive/wizard_fake, "Wizard floor" = /turf/floor/wizard, "Wizard plating" = /turf/floor/wizard/plating,  \
	"Wizard stairs" = /turf/floor/wizard/stairs, "Wizard wall" = /turf/wall/adaptive/wizard, "Wizard window" = /turf/wall/adaptive/wizard_window)

	name = "Turf"

	click_left(var/atom/object, location, control, params)
		if(!turftype)
			return
		if (!A)
			A = get_turf(object)
			A.overlays += marker
			return
		else
			var/turf/B = get_turf(object)
			if (A.z != B.z)
				boutput(usr, "<span class='alert'>The two corners must be on the same Z!</span>")
				return

			for(var/turf/T in block(A, B))
				var/turf/at = T
				T.ReplaceWith(turftype, force=1)
				at.set_dir(holder.dir)
				blink(at)
				new /area/adventure(at)
				at.RL_Reset()
			A.overlays -= marker
			A = null

	click_right(var/atom/object, location, control, params)
		if (!A)
			A = get_turf(object)
			A.overlays += marker
			return
		else
			var/turf/B = get_turf(object)
			if (A.z != B.z)
				boutput(usr, "<span class='alert'>The two corners must be on the same Z!</span>")
				return

			for(var/turf/T in block(A, B))
				for(var/obj/O in T)
					qdel(O)
				blink(T)
				new /area(T)
				T.ReplaceWithSpaceForce()

			A.overlays -= marker
			A = null

	settings(var/ctrl, var/alt, var/shift)
		selected()

	selected()
		var/kind = input(usr, "What kind of turf?", "Turf type", "Ancient floor") in src.turfs
		turftype = src.turfs[kind]
		boutput(usr, "<span class='notice'>Now building [kind] turfs in wide area spawn mode.</span>")

	deselected()
		if (A)
			A.overlays -= marker
			A = null
