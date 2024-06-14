///Summary of what this does from skimming borg code:
//-prevents erebite cell detonations
//-minus 3 severity to explosions
//-flat damage reduction from D_ENERGY/D_BURNING/D_RADIOACTIVE projectiles (more or less energy guns, probably. haven't checked thoroughly)
//-protection from flaming meteors (unused)
//-flat damage reduction from burn attacks

//Given that borgs tend to get attacked physically more often than with lasers, this is probably not as useful as the force shield.
//The erebite cell protection is neat, but numerically the heat shield has 10x the drain rate than the cell generates.
//That probably gets skewed by timing differences between the borg life loop and the item loop, but that's still a ton.

/obj/item/roboupgrade/fireshield
	name = "cyborg heat shield upgrade"
	desc = "An air diffusion field that protects a cyborg from heat damage."
	icon_state = "up-Fshield"
	drainrate = 100
	borg_overlay = "up-fshield"
	var/damage_reduction = 4
	var/cell_drain_per_damage_reduction = 100
