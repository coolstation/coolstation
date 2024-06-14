//Effects:
//flat damage reduction from blobs
//-3 severity from explosions
//flat damage reduction from D_PIERCING/D_SLASHING projectiles
//protection against meteors
//flat brute damage reduction

/obj/item/roboupgrade/physshield
	name = "cyborg force shield upgrade"
	desc = "A force field generator that protects a cyborg from physical harm."
	icon_state = "up-Pshield"
	drainrate = 100
	borg_overlay = "up-pshield"
	var/damage_reduction = 4
	var/cell_drain_per_damage_reduction = 100
