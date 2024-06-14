//heals 6 brute & 6 burn every time cell usage ticks, divided over all parts. That's 1 of each per part if you're not missing anything.
//From the looks of it, healing isn't spread toward damaged bits in particular so some is wasted on "healing" healthy parts.

/obj/item/roboupgrade/repair
	name = "cyborg self-repair upgrade"
	desc = "An arc welder that allows a cyborg to repair sustained damage."
	icon_state = "up-repair"
	drainrate = 60
	borg_overlay = "up-repair"
