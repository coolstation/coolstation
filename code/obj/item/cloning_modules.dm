/*

Modules to do things with cloning modules

These ones slot into the clone pod, as opposed to /obj/item/cloner_upgrade for things that go in the computer and /obj/item/grinder_upgrade for the reclaimer.
*/


// This one makes clones come out faster. Nice!
/obj/item/cloneModule/speedyclone
	icon = 'icons/obj/items/module.dmi'
	icon_state = "speedyclone"
	name = "\improper SpeedyClone2000"
	desc = "An experimental cloning module. Greatly speeds up the cloning process. Also voids the cloning pod warranty."


// This one makes the pod more efficient. For filthy space hippies who are into that recycling stuff.
/obj/item/cloneModule/efficientclone
	icon = 'icons/obj/items/module.dmi'
	icon_state = "efficientclone"
	name = "biomatter recycling unit"
	desc = "An experimental cloning module. Lowers the amount of biomatter a cloning pod needs by recycling old biomatter."


// A spooky module. Zaps the memories of anyone who gets cloned in a machine using this
/obj/item/cloneModule/minderaser
	icon = 'icons/obj/items/module.dmi'
	icon_state = "mindwipe"
	name = "\improper Prototype Rehabilitation Module #17"
	desc = "An experimental treatment device meant for only the worst of criminals. Fires a barrage of electrical signals to the brain during medical procedues. It looks like it has some cloning goop and blood smeared on it - yuck."

/obj/item/cloneModule/insurgent_module
	icon = 'icons/obj/cloning.dmi'
	icon_state = "insurgentmodule"
	name = "insurgent cloning module"
	desc = "A powerful device that remaps people's brains when they get cloned to make them completely loyal to the owner of this module."

//RIP clone pod auto-starting 2020-2025, but I figured we could work it into loot tables somewhere. as a treat. maybe.
/obj/item/cloneModule/auto_start
	icon = 'icons/obj/items/module.dmi'
	icon_state = "autostart"
	name = "pre-cloning automation unit"
	desc = "An experimental cloning module. Allows a cloning pod to get a head start on new clones, even before the target genotype is finalised."

/obj/item/storage/box/insurgent_module_kit
	name = "Insurgent module kit"
	icon_state = "box"
	desc = "A box with an insurgent cloning module and a cloning lab. Yes, a whole cloning lab. In a box. Somehow."

	make_my_stuff()
		..()
		new /obj/item/cloneModule/insurgent_module(src)
		new /obj/item/electronics/soldering(src)


		// Creates premade mechanics scanned items. That way you can make a cloning lab faster.

		var/obj/item/electronics/frame/F1 = new/obj/item/electronics/frame(src)
		F1.name = "Boxed Cloning Computer"
		F1.store_type = /obj/machinery/computer/cloning
		F1.viewstat = 2
		F1.secured = 2
		F1.icon_state = "dbox"

		var/obj/item/electronics/frame/F2 = new/obj/item/electronics/frame(src)
		F2.name = "Disassembled Cloning Pod"
		F2.store_type = /obj/machinery/clonepod
		F2.viewstat = 2
		F2.secured = 2
		F2.icon_state = "dbox"

		var/obj/item/electronics/frame/F3 = new/obj/item/electronics/frame(src)
		F3.name = "Compacted Giant Blender"
		F3.store_type = /obj/machinery/clonegrinder
		F3.viewstat = 2
		F3.secured = 2
		F3.icon_state = "dbox"

		var/obj/item/electronics/frame/F4 = new/obj/item/electronics/frame(src)
		F4.name = "Expandable DNA Scanner"
		F4.store_type = /obj/machinery/clone_scanner
		F4.viewstat = 2
		F4.secured = 2
		F4.icon_state = "dbox"

/obj/item/cloneModule/genepowermodule
	icon = 'icons/obj/items/module.dmi'
	icon_state = "genemodule"
	name = "Gene power module"
	desc = "A module that automatically inserts a gene into clones. It has a slot in the back that looks like it would hold a DNA injector."

	var/datum/bioEffect/BE = null

/obj/item/cloneModule/genepowermodule/attackby(obj/item/W as obj, mob/user as mob)
	if (!BE && istype(W, /obj/item/genetics_injector/dna_injector))
		var/obj/item/genetics_injector/dna_injector/injector = W
		if (!injector.uses) //weird that this wasn't here before, but we have empty injectors now so
			boutput(user, "This injector is empty.")
			return
		boutput(user, "You put the DNA injector into the slot on the cartridge.")
		BE = injector.BE
		user.drop_item()
		qdel(W)
	else ..() //call yer parents :/
