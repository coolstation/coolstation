/*
██████╗ ███╗   ██╗ ██████╗     ███████╗████████╗██╗   ██╗███╗   ██╗███████╗
██╔══██╗████╗  ██║██╔════╝     ██╔════╝╚══██╔══╝██║   ██║████╗  ██║██╔════╝
██████╔╝██╔██╗ ██║██║  ███╗    ███████╗   ██║   ██║   ██║██╔██╗ ██║███████╗
██╔══██╗██║╚██╗██║██║   ██║    ╚════██║   ██║   ██║   ██║██║╚██╗██║╚════██║
██║  ██║██║ ╚████║╚██████╔╝    ███████║   ██║   ╚██████╔╝██║ ╚████║███████║
╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝     ╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═══╝╚══════╝

FRIEND WARCRIMES is amassing all the weapons with simplified RNG stun right here,
such that it might become easier to compare them to others, and do massive batch
balancing in a way that is not painful. Eventually perhaps these will return to
their respective object definitions, but for now they are cozy and warm. love u.

	var/rng_stun_rate = 0 // % chance to old-stun
	var/rng_stun_time = 0 // how many ticks to old-stun
	var/rng_stun_diso = 0 // how many ticks to disorient on an old-stun
	var/rng_stun_weak = 0 // how many ticks to weaken (down) on an old-stun


 */
/obj/item/storage/toolbox
	//warcrimes - rng stuns - toolboxes disorient and stun but won't down
	rng_stun_rate = 7 //%
	rng_stun_time = 3 SECONDS
	rng_stun_diso = 6 SECONDS
	rng_stun_weak = 0 SECONDS

/obj/item/brick
	rng_stun_rate = 4 //%
	rng_stun_time = 2 SECONDS
	rng_stun_diso = 3 SECONDS
	rng_stun_weak = 0 SECONDS

/obj/item/chair/folded
	rng_stun_rate = 7 // %
	rng_stun_time = 0 SECONDS
	rng_stun_diso = 5 SECONDS
	rng_stun_weak = 2 SECONDS


/obj/item/extinguisher
	//warc - rng stuns - down and disorient without full stun
	rng_stun_rate = 9 // %
	rng_stun_time = 0 SECONDS
	rng_stun_diso = 5 SECONDS
	rng_stun_weak = 3 SECONDS

/obj/item/crowbar
	//warc - rng stuns - down and disorient without full stun
	rng_stun_rate = 8 // %
	rng_stun_time = 0 SECONDS
	rng_stun_diso = 5 SECONDS
	rng_stun_weak = 2 SECONDS

/obj/item/tank/
	rng_stun_rate = 7 // %
	rng_stun_time = 0 SECONDS
	rng_stun_diso = 4 SECONDS
	rng_stun_weak = 3 SECONDS

/obj/item/fish
	rng_stun_rate = 10 // %
	rng_stun_time = 0 SECONDS
	rng_stun_diso = 4 SECONDS
	rng_stun_weak = 0 SECONDS

/obj/item/slag_shovel
	rng_stun_rate = 6 // %
	rng_stun_time = 0 SECONDS
	rng_stun_diso = 6 SECONDS
	rng_stun_weak = 0 SECONDS

/obj/item/tank/jetpack
	rng_stun_rate = 5
	rng_stun_time = 1 SECOND
	rng_stun_diso = 0 SECONDS
	rng_stun_weak = 0 SECONDS

/obj/item/tank/emergency_oxygen
	rng_stun_rate = 4
	rng_stun_weak = 1 SECONDS
	rng_stun_diso = 3 SECONDS
	rng_stun_weak = 0 SECONDS

/obj/item/saw/syndie
	rng_stun_rate = 13 //%
	rng_stun_time = 2 SECOND
	rng_stun_diso = 10 SECONDS
	rng_stun_weak = 3 SECONDS

/obj/item/sword
	rng_stun_rate = 7 //%
	rng_stun_time = 2 SECONDS
	rng_stun_diso = 0 SECONDS
	rng_stun_weak = 5 SECONDS

/obj/item/mining_tools/pick
	rng_stun_rate = 4 //%
	rng_stun_time = 0 SECOND
	rng_stun_diso = 0 SECONDS
	rng_stun_weak = 4 SECONDS

/obj/item/bat
	rng_stun_rate = 6 //%
	rng_stun_time = 1 SECOND
	rng_stun_diso = 5 SECONDS
	rng_stun_weak = 2 SECONDS

/obj/item/scissors
	rng_stun_rate = 2 //%
	rng_stun_time = 3 SECOND
	rng_stun_diso = 0 SECONDS
	rng_stun_weak = 0 SECONDS

/obj/item/mop
	rng_stun_rate = 3 //%
	rng_stun_time = 0 SECOND
	rng_stun_diso = 10 SECONDS
	rng_stun_weak = 2 SECONDS

/obj/item/gnomechompski
	rng_stun_rate = 7 //%
	rng_stun_time = 0 SECOND
	rng_stun_diso = 10 SECONDS
	rng_stun_weak = 0 SECONDS

/obj/item/clothing/mask/cigarette
	rng_stun_rate = 0 //this gets changed to some % when it is lit.
	rng_stun_time = 2 SECOND
	rng_stun_diso = 3 SECONDS
	rng_stun_weak = 0 SECONDS

