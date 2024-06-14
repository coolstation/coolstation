//Full effects:
//-40% from every occupied tool slot (5->3)
//-50% from robot parts and upgrade drain (varies, but easily the largest drain depending on loadout)
//-100% base cell drain (1->0)
//I think there's supposed to be an exponential penalty for getting borg expansion upgrades too, but that's missing from actual cell usage code and borked in the other proc that calculates cell usage. Quality code, y'all.

/obj/item/roboupgrade/efficiency
	name = "cyborg efficiency upgrade"
	desc = "A more advanced cooling system that causes a cyborg to consume less cell charge."
	icon_state = "up-power"
	passive = 1
