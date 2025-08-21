/client/proc/spawn_survival_shit()
	set name = "spawn_survival_shit"
	set desc = "spawn_survival_shit."
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set popup_menu = 0
	admin_only
	var/list/spawn_metal_normal = list(/obj/item/material_piece/cloth, /obj/item/material_piece/mauxite, /obj/item/material_piece/pharosium)
	var/list/spawn_metal_valuable = list(/obj/item/material_piece/cerenkite, /obj/item/material_piece/claretine, /obj/item/material_piece/bohrum, /obj/item/material_piece/uqill)
	var/list/spawn_item = list(/obj/item/bat,\
		/obj/item/storage/firstaid/brute,\
		/obj/item/gun/modular/italian/sniper/improved,\
		/obj/item/gun/modular/italian/rattler/basic,\
		/obj/item/gun/modular/italian/rattler/saucy,\
		/obj/item/gun/modular/italian/revolver/basic,\
		/obj/item/gun/modular/italian/revolver/improved,\
		/obj/item/clothing/suit/armor/vest)
	var/list/spawn_ammo = list(/obj/item/stackable_ammo/pistol/NT/ten,\
		/obj/item/stackable_ammo/pistol/NT/HP/five,\
		/obj/item/stackable_ammo/rifle/NT/five)

	for (var/obj/machinery/disposal/mail/MB in world)
		var/turf/spawn_turf = get_turf(MB)
		if (prob(40))
			var/pth = pick(spawn_metal_normal)
			var/obj/item/material_piece/P = new pth(spawn_turf)
			P?.amount = 4
		if (prob(10))
			var/pth = pick(spawn_metal_valuable)
			var/obj/item/material_piece/P = new pth(spawn_turf)
			P?.amount = 3
		if (prob(25))
			var/pth = pick(spawn_item)
			new pth(spawn_turf)
		if (prob(40))
			var/pth = pick(spawn_ammo)
			new pth(spawn_turf)
		if (prob(60))
			new /obj/item/plank/anti_zombie(spawn_turf)

