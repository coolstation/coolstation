/* ---------- Stool Parts ---------- */
/obj/item/furniture_parts/stool
	name = "stool parts"
	desc = "A collection of parts that can be used to make a stool."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "stool_parts"
	stamina_damage = 15
	stamina_cost = 15
	furniture_type = /obj/stool
	furniture_name = "stool"

/obj/item/furniture_parts/woodenstool
	name = "wooden stool parts"
	desc = "A collection of parts that can be used to make a wooden stool."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "wstool_parts"
	stamina_damage = 15
	stamina_cost = 15
	furniture_type = /obj/stool/wooden
	furniture_name = "wooden stool"


/obj/item/furniture_parts/stool/bee_bed
	name = "bee bed parts"
	desc = "A collection of parts that can be used to make a bee bed."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "comf_chair_parts-b"	// @TODO new icon, mprobably
	furniture_type = /obj/stool/bee_bed
	furniture_name = "bee bed"

/obj/item/furniture_parts/stool/bar
	name = "bar stool parts"
	desc = "A collection of parts that can be used to make a bar stool."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "bstool_parts"
	furniture_type = /obj/stool/bar
	furniture_name = "bar stool"

/obj/item/furniture_parts/stepladder
	name = "stepladder parts"
	desc = "A collection of parts that can be used to make a stepladder."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "stool_parts"
	stamina_damage = 15
	stamina_cost = 15
	furniture_type = /obj/stool/chair/stepladder
	furniture_name = "stepladder"

/obj/item/furniture_parts/stepladder/wrestling
	name = "wrestling stepladder parts"
	desc = "A collection of parts that can be used to make a wrestling stepladder. Like a regular stepladder, but for wrestling."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "stool_parts"
	stamina_damage = 15
	stamina_cost = 15
	furniture_type = /obj/stool/chair/stepladder/wrestling
	furniture_name = "wrestling stepladder"



/* ---------- Bench Parts ---------- */
/obj/item/furniture_parts/bench
	name = "bench parts"
	desc = "A collection of parts that can be used to make a bench."
	icon = 'icons/obj/furniture/bench.dmi'
	icon_state = "bench_parts"
	stamina_damage = 15
	stamina_cost = 15
	furniture_type = /obj/stool/bench/auto
	furniture_name = "bench"

/obj/item/furniture_parts/bench/red
	icon = 'icons/obj/furniture/bench_red.dmi'
	furniture_type = /obj/stool/bench/red/auto

/obj/item/furniture_parts/bench/blue
	icon = 'icons/obj/furniture/bench_blue.dmi'
	furniture_type = /obj/stool/bench/blue/auto

/obj/item/furniture_parts/bench/green
	icon = 'icons/obj/furniture/bench_green.dmi'
	furniture_type = /obj/stool/bench/green/auto

/obj/item/furniture_parts/bench/yellow
	icon = 'icons/obj/furniture/bench_yellow.dmi'
	furniture_type = /obj/stool/bench/yellow/auto

/obj/item/furniture_parts/bench/purple
	icon = 'icons/obj/furniture/bench_purple.dmi'
	furniture_type = /obj/stool/bench/purple/auto

/obj/item/furniture_parts/bench/orange
	icon = 'icons/obj/furniture/bench_orange.dmi'
	furniture_type = /obj/stool/bench/orange/auto

/obj/item/furniture_parts/bench/navy
	icon = 'icons/obj/furniture/bench_navy.dmi'
	furniture_type = /obj/stool/bench/navy/auto

/obj/item/furniture_parts/bench/wooden
	name = "wooden bench parts"
	desc = "A collection of parts that can be used to make a wooden bench."
	icon = 'icons/obj/furniture/bench_wood.dmi'
	furniture_type = /obj/stool/bench/wooden/auto

/obj/item/furniture_parts/bench/pew
	name = "pew parts"
	desc = "A collection of parts that can be used to make a pew."
	icon = 'icons/obj/furniture/bench_wood.dmi'
	furniture_type = /obj/stool/chair/pew

/* ---------- Chair Parts ---------- */
/obj/item/furniture_parts/wood_chair
	name = "wooden chair parts"
	desc = "A collection of parts that can be used to make a wooden chair."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "wchair_parts"
	stamina_damage = 15
	stamina_cost = 15
	furniture_type = /obj/stool/chair/wooden
	furniture_name = "wooden chair"

/obj/item/furniture_parts/wood_chair/regal
	name = "regal chair parts"
	desc = "A collection of parts that can be used to make a regal chair."
	icon_state = "regalchair_parts"
	furniture_type = /obj/stool/chair/wooden/regal

/obj/item/furniture_parts/wheelchair
	name = "wheelchair parts"
	desc = "A collection of parts that can be used to make a wheelchair."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "whchair_parts"
	stamina_damage = 15
	stamina_cost = 15
	furniture_type = /obj/stool/chair/comfy/wheelchair
	furniture_name = "wheelchair"

/obj/item/furniture_parts/barber_chair
	name = "barber chair parts"
	desc = "A collection of parts that can be used to make a barber chair. You know, for cutting hair?"
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "barberchair_parts"
	stamina_damage = 15
	stamina_cost = 15
	furniture_type = /obj/stool/chair/comfy/barber_chair
	furniture_name = "barber chair"

/obj/item/furniture_parts/office_chair
	name = "office chair parts"
	desc = "A collection of parts that can be used to make an office chair."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "ochair_parts"
	stamina_damage = 15
	stamina_cost = 15
	furniture_type = /obj/stool/chair/office
	furniture_name = "office chair"

/obj/item/furniture_parts/office_chair/red
	icon_state = "ochair_parts-r"
	furniture_type = /obj/stool/chair/office/red

/obj/item/furniture_parts/office_chair/green
	icon_state = "ochair_parts-g"
	furniture_type = /obj/stool/chair/office/green

/obj/item/furniture_parts/office_chair/blue
	icon_state = "ochair_parts-b"
	furniture_type = /obj/stool/chair/office/blue

/obj/item/furniture_parts/office_chair/yellow
	icon_state = "ochair_parts-y"
	furniture_type = /obj/stool/chair/office/yellow

/obj/item/furniture_parts/office_chair/purple
	icon_state = "ochair_parts-p"
	furniture_type = /obj/stool/chair/office/purple

/obj/item/furniture_parts/office_chair/lblue
	icon_state = "ochair_parts-lb"
	furniture_type = /obj/stool/chair/office/lblue

/obj/item/furniture_parts/office_chair/orange
	icon_state = "ochair_parts-o"
	furniture_type = /obj/stool/chair/office/orange

/obj/item/furniture_parts/comfy_chair
	name = "comfy chair parts"
	desc = "A collection of parts that can be used to make a comfy chair."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "comf_chair_parts"
	stamina_damage = 15
	stamina_cost = 15
	furniture_type = /obj/stool/chair/comfy
	furniture_name = "comfy chair"

/obj/item/furniture_parts/comfy_chair/blue
	icon_state = "comf_chair_parts-b"
	furniture_type = /obj/stool/chair/comfy/blue

/obj/item/furniture_parts/comfy_chair/red
	icon_state = "comf_chair_parts-r"
	furniture_type = /obj/stool/chair/comfy/red

/obj/item/furniture_parts/comfy_chair/green
	icon_state = "comf_chair_parts-g"
	furniture_type = /obj/stool/chair/comfy/green

/obj/item/furniture_parts/comfy_chair/yellow
	icon_state = "comf_chair_parts-y"
	furniture_type = /obj/stool/chair/comfy/yellow

/obj/item/furniture_parts/comfy_chair/purple
	icon_state = "comf_chair_parts-p"
	furniture_type = /obj/stool/chair/comfy/purple

/obj/item/furniture_parts/comfy_chair/lblue
	icon_state = "comf_chair_parts-lb"
	furniture_type = /obj/stool/chair/comfy/lblue

/obj/item/furniture_parts/comfy_chair/orange
	icon_state = "comf_chair_parts-o"
	furniture_type = /obj/stool/chair/comfy/orange

/obj/item/furniture_parts/throne_gold
	name = "golden throne parts"
	desc = "A collection of parts that can be used to make a golden throne."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "thronegold_parts"
	stamina_damage = 15
	stamina_cost = 15
	furniture_type = /obj/stool/chair/comfy/throne_gold
	furniture_name = "golden throne"
