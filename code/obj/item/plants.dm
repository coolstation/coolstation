
/// Inedible Produce
/obj/item/plant/
	name = "plant"
	var/crop_suffix = ""
	var/crop_prefix = ""
	desc = "You shouldn't be able to see this item ingame!"
	icon = 'icons/obj/hydroponics/items_hydroponics.dmi'
	var/brewable = 0 // will hitting a still with it do anything?
	var/brew_result = null // what will it make if it's brewable?
	rand_pos = 8

	New()
		..()
		make_reagents()
		//unpooled()

	proc/make_reagents()
		if (!src.reagents)
			src.create_reagents(100)
/*
	unpooled()
		src.reagents?.clear_reagents()
		..()
		make_reagents()
		// hopefully prevent issues of "jumbo perfect large incredible nice perfect superb strawberry"
		src.name = initial(name)
*/
	disposing()
		..()
		if (src.reagents)
			src.reagents.clear_reagents()

/obj/item/plant/herb
	name = "herb base"
	burn_point = 330
	burn_output = 800
	burn_possible = TRUE
	item_function_flags = COLD_BURN
	crop_suffix	= " leaf"
	value = 75 //base commodity price

	attackby(obj/item/W as obj, mob/user as mob)
		if (!src.reagents)
			src.make_reagents()

		if (istype(W, /obj/item/spacecash) || istype(W, /obj/item/paper))
			boutput(user, "<span class='alert'>You roll up [W] into a cigarette.</span>")
			var/obj/item/clothing/mask/cigarette/custom/P = new(user.loc)

			P.name = build_name(W)
			P.reagents.maximum_volume = src.reagents.total_volume
			src.reagents.trans_to(P, src.reagents.total_volume)
			W.force_drop(user)
			src.force_drop(user)
			qdel(W)
			qdel(src)
			user.put_in_hand_or_drop(P)
			JOB_XP(user, "Botanist", 1)
			JOB_XP_FORCE(user,"CIGARETTE",2)

		else if (istype(W, /obj/item/bluntwrap))
			boutput(user, "<span class='alert'>You roll [src] up in [W] and make a fat doink.</span>")
			var/obj/item/clothing/mask/cigarette/cigarillo/doink = new(user.loc)
			var/obj/item/bluntwrap/B = W
			if(B.flavor)
				doink.flavor = B.flavor
			doink.name = "[reagent_id_to_name(doink.flavor)]-flavored [src.name] [pick("doink","'Rillo","cigarillo","brumbpo")]"
			doink.reagents.clear_reagents()
			doink.reagents.maximum_volume = (src.reagents.total_volume + 50)
			W.reagents.trans_to(doink, W.reagents.total_volume)
			src.reagents.trans_to(doink, src.reagents.total_volume)
			W.force_drop(user)
			src.force_drop(user)
			qdel(W)
			qdel(src)
			user.put_in_hand_or_drop(doink)
			JOB_XP(user, "Botanist", 2)
			JOB_XP_FORCE(user,"CIGARETTE",5)

	combust_ended()
		smoke_reaction(src.reagents, 1, get_turf(src), do_sfx = 0)
		..()

	proc/build_name(obj/item/W)
		return "[istype(W, /obj/item/spacecash) ? "[W.amount]-credit " : ""][pick("joint","doobie","spliff","roach","blunt","roll","fatty","reefer")]"

/obj/item/plant/herb/cannabis/
	name = "cannabis leaf"
	desc = "Leafs for reefin'!"
	icon_state = "cannabisleaf"
	brewable = 1
	brew_result = list("THC", "CBD")
	contraband = 1
	w_class = W_CLASS_TINY
	value = -5 //small crime
	alt_value = 50 //but why not

/obj/item/plant/herb/cannabis/spawnable
	make_reagents()
		src.create_reagents(85)
		reagents.add_reagent("THC", 60)
		reagents.add_reagent("CBD", 20)

/obj/item/plant/herb/cannabis/mega
	name = "cannabis leaf"
	crop_prefix = "rainbow "
	desc = "Is it supposed to be glowing like that...?"
	icon_state = "megaweedleaf"
	brew_result = list("THC", "LSD")
	value = -50 //medium crime
	alt_value = 250

/obj/item/plant/herb/cannabis/mega/spawnable
	make_reagents()
		src.create_reagents(85)
		reagents.add_reagent("THC", 40)
		reagents.add_reagent("LSD", 40)

/obj/item/plant/herb/cannabis/black
	name = "cannabis leaf"
	crop_prefix = "black "
	desc = "Looks a bit dark. Oh well."
	icon_state = "blackweedleaf"
	brew_result = list("THC", "cyanide")
	value = -500 //big crime
	alt_value = 500 //but someone might sell it...

/obj/item/plant/herb/cannabis/black/spawnable
	make_reagents()
		src.create_reagents(85)
		reagents.add_reagent("THC", 40)
		reagents.add_reagent("cyanide", 40)

/obj/item/plant/herb/cannabis/white
	name = "cannabis leaf"
	crop_prefix = "white "
	desc = "It feels smooth and nice to the touch."
	icon_state = "whiteweedleaf"
	brew_result = list("THC", "omnizine")
	value = 100 //okay they might actually buy it
	alt_value = 300

/obj/item/plant/herb/cannabis/white/spawnable
	make_reagents()
		src.create_reagents(85)
		reagents.add_reagent("THC", 40)
		reagents.add_reagent("omnizine", 40)

/obj/item/plant/herb/cannabis/omega
	name = "glowing cannabis leaf"
	crop_prefix = "glowing "
	desc = "You feel dizzy looking at it. What the fuck?"
	icon_state = "Oweedleaf"
	brew_result = list("THC", "LSD", "suicider", "space_drugs", "mercury", "lithium", "atropine", "haloperidol", "methamphetamine",\
	"capsaicin", "psilocybin", "hairgrownium", "ectoplasm", "bathsalts", "itching", "crank", "krokodil", "catdrugs", "histamine")
	value = -500 //holy shit
	alt_value = 2500 //piss

/obj/item/plant/herb/cannabis/omega/spawnable
	make_reagents()
		src.create_reagents(800)
		reagents.add_reagent("THC", 40)
		reagents.add_reagent("LSD", 40)
		reagents.add_reagent("suicider", 40)
		reagents.add_reagent("space_drugs", 40)
		reagents.add_reagent("mercury", 40)
		reagents.add_reagent("lithium", 40)
		reagents.add_reagent("atropine", 40)
		reagents.add_reagent("haloperidol", 40)
		reagents.add_reagent("methamphetamine", 40)
		reagents.add_reagent("THC", 40)
		reagents.add_reagent("capsaicin", 40)
		reagents.add_reagent("psilocybin", 40)
		reagents.add_reagent("hairgrownium", 40)
		reagents.add_reagent("ectoplasm", 40)
		reagents.add_reagent("bathsalts", 40)
		reagents.add_reagent("itching", 40)
		reagents.add_reagent("crank", 40)
		reagents.add_reagent("krokodil", 40)
		reagents.add_reagent("catdrugs", 40)
		reagents.add_reagent("histamine", 40)

/obj/item/plant/herb/tobacco
	name = "tobacco leaf"
	desc = "A leaf from a tobacco plant. This could probably be smoked..."
	icon_state = "tobacco"
	brewable = 1
	brew_result = list("nicotine")
	value = 50

	build_name(obj/item/W)
		return "[istype(W, /obj/item/spacecash) ? "[W.amount]-credit " : ""]rolled cigarette"

	attackby(obj/item/W as obj, mob/user as mob)
		..()
		if((W.tool_flags & TOOL_CUTTING) || (W.hit_type & DAMAGE_CUT) || (W.hit_type & DAMAGE_STAB))
			var/obj/item/bluntwrap/B = new(user.loc)
			if(src.reagents)
				B.reagents.remove_any(20)
				src.reagents.trans_to(B, 20)
			B.name = "natural tobacco blunt wrap"
			boutput(user, "<span class='alert'>You cut [src] square to make a blunt wrapper.</span>")
			qdel(src)
			user.put_in_hand_or_drop(B)



/obj/item/plant/herb/tobacco/twobacco
	name = "twobacco leaf"
	desc = "A leaf from the twobacco plant. This could probably be smoked- wait, is it already smoking?"
	icon_state = "twobacco"
	brewable = 1
	brew_result = list("nicotine2")
	value = 100

/obj/item/plant/wheat
	name = "wheat"
	desc = "Never eat shredded wheat."
	icon_state = "wheat"
	brewable = 1
	brew_result = "beer"
	value = 10

/obj/item/plant/wheat/durum
	name = "durum wheat"
	desc = "A harder wheat for a harder palate."
	icon_state = "wheat"
	brewable = 1
	brew_result = "beer"

/obj/item/plant/wheat/metal
	name = "steelwheat"
	desc = "Never eat iron filings."
	icon_state = "metalwheat"
	brew_result = list("beer", "iron")

	make_reagents()
		..()
		src.setMaterial(getMaterial("steel"))

/obj/item/plant/oat
	name = "oat"
	desc = "A bland but healthy cereal crop. Good source of fiber."
	icon_state = "oat"
	value = 10

/obj/item/plant/sugar/
	name = "sugar cane"
	crop_suffix	= " cane"
	desc = "Grown lovingly in our space plantations."
	icon_state = "sugarcane"
	brewable = 1
	brew_result = "rum"
	value = 10

/obj/item/plant/herb/grass
	name = "grass"
	desc = "Fresh free-range spacegrass."
	icon_state = "grass"
	value = -1 //trash

/obj/item/plant/herb/contusine
	name = "contusine leaves"
	crop_suffix	= " leaves"
	desc = "Dry, bitter leaves known for their wound-mending properties."
	icon_state = "contusine"

/obj/item/plant/herb/nureous
	name = "nureous leaves"
	crop_suffix	= " leaves"
	desc = "Chewy leaves often manufactured for use in radiation treatment medicine."
	icon_state = "nureous"

/obj/item/plant/herb/nureous/fuzzy
	name = "nureous leaves"
	crop_suffix = " leaves"
	desc = "Chewy leaves often manufactured for use in radiation treatment medicine. They seem strangely hairy."
	icon_state = "nureousfuzzy"
	value = 150

/obj/item/plant/herb/asomna
	name = "asomna bark"
	crop_suffix	= " bark"
	desc = "Often regarded as a delicacy when used for tea, Asomna also has stimulant properties."
	icon_state = "asomna"
	brewable = 1
	brew_result = "tea"

/obj/item/plant/herb/asomna/robust
	name = "asomna bark"
	crop_suffix = " bark"
	desc = "Often regarded as a delicacy when used for tea, Asomna also has stimulant properties. This particular chunk looks extra spicy."
	icon_state = "asomnarobust"
	brewable = 1
	brew_result = "tea"
	value = 150

/obj/item/plant/herb/commol
	name = "commol root"
	crop_suffix	= " root"
	desc = "A tough and waxy root. It is well-regarded as an ingredient in burn salve."
	icon_state = "commol"

/obj/item/plant/herb/ipecacuanha
	name = "ipecacuanha root"
	crop_suffix	= " root"
	desc = "This thick root is covered in abnormal ammounts of bark. A powerful emetic can be extracted from it."
	icon_state = "ipecacuanha"
	value = 50

/obj/item/plant/herb/ipecacuanha/invigorating
	name = "ipecacuanha root"
	crop_suffix	= " root"
	desc = "This thick root is covered in abnormal ammounts of bark. A powerful emetic can be extracted from it. This one is strangely veinous"
	icon_state = "ipecacuanhainvigorating"

/obj/item/plant/herb/ipecacuanha/bilious
	name = "ipecacuanha root"
	crop_suffix = " root"
	desc = "This thick root is covered in abnormal ammounts of bark. A powerful emetic can be extracted from it. This one looks particularly revolting"
	icon_state = "ipecacuanhabilious"
	brewable = 1
	brew_result = "gvomit"
	value = -25 //gross

/obj/item/plant/herb/sassafras
	name = "sassafras root"
	crop_suffix	= " root"
	desc = "Roots from a Sassafras tree. Can be fermented into delicious sarsaparilla."
	icon_state = "sassafras"
	brewable = 1
	brew_result = "sarsaparilla"
	value = 20

/obj/item/plant/herb/venne
	name = "venne fibers"
	crop_suffix	= " fibers"
	desc = "Fibers from the stem of a Venne vine. Though tasting foul, it has remarkable anti-toxic properties."
	icon_state = "venne"

/obj/item/plant/herb/venne/toxic
	name = "black venne fibers"
	crop_prefix	= "black "
	desc = "It's black and greasy. Kinda gross."
	icon_state = "venneT"
	value = -20

/obj/item/plant/herb/venne/curative
	name = "dawning venne fibers"
	crop_prefix	= "dawning "
	desc = "It has a lovely sunrise coloration to it."
	icon_state = "venneC"
	value = 150

/obj/item/plant/herb/mint
	name = "mint leaves"
	crop_suffix	= " leaves"
	desc = "Aromatic leaves with a clean flavor."
	icon_state = "mint"
	brewable = 1
	brew_result = "menthol"
	value = 20

/obj/item/plant/herb/catnip
	name = "nepeta cataria"
	crop_suffix	= ""
	desc = "Otherwise known as catnip or catswort.  Cat drugs."
	icon_state = "catnip"
	brewable = 1
	brew_result = "catdrugs"
	value = 20

/obj/item/plant/herb/poppy
	name = "poppy"
	crop_suffix	= ""
	desc = "A distinctive red flower."
	icon_state = "poppy"
	value = -50
	alt_value = 350

/obj/item/plant/herb/aconite
	name = "aconite"
	crop_suffix	= ""
	desc = "Also known as wolfsbane. You know, just in case you have any wolves that need baning."
	icon_state = "aconite"
	value = 5 //not particularly useful (however a werewolf outbreak market event might send this skyrocketing!!)
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER

	// module_research_type = /obj/item/plant/herb/cannabis
	attack_hand(var/mob/user as mob)
		if (iswerewolf(user))
			user.changeStatus("weakened", 8 SECONDS)
			user.take_toxin_damage(-10)
			boutput(user, "<span class='alert'>You try to pick up [src], but it hurts and you fall over!</span>")
			return
		else ..()
	//stolen from glass shard
	HasEntered(AM as mob|obj)
		var/mob/M = AM
		if(iswerewolf(M))
			M.changeStatus("weakened", 3 SECONDS)
			M.force_laydown_standup()
			M.take_toxin_damage(-10)
			M.visible_message("<span class='alert'>The [M] steps too close to [src] and falls down!</span>")
			return
		..()
	attack(mob/M as mob, mob/user as mob)
		//if a wolf attacks with this, which they shouldn't be able to, they'll just drop it
		if (iswerewolf(user))
			user.u_equip(src)
			user.drop_item()
			boutput(user, "<span class='alert'>You drop the aconite, you don't think it's a good idea to hold it!</span>")
			return
		if (iswerewolf(M))
			M.take_toxin_damage(rand(5,10))
			user.visible_message("[user] attacks [M] with [src]! It's super effective!")
			if (prob(50))
				//Wraith does stamina damage this way, there is probably a better way, but I can't find it
				M:stamina -= 40
			return
		..()
		return
	//stolen from dagger, not much too it
	throw_impact(atom/A, datum/thrown_thing/thr)
		if(iswerewolf(A))
			if (istype(usr, /mob))
				A:lastattacker = usr
				A:lastattackertime = world.time
			A:weakened += 15

	pull(var/mob/user)
		if (!istype(user))
			return
		if (!iswerewolf(user))
			return ..()
		else
			boutput(user, "<span class='alert'>You can't drag that aconite! It burns!</span>")
			user.take_toxin_damage(-10)
			return

// FLOWERS //

/obj/item/plant/flower
	// PLACEHOLDER FOR FLOURISH'S PLANT PLOT STUFF

/obj/item/plant/flower/rose
	name = "rose"
	desc = "By any other name, would smell just as sweet. This one likes to be called "
	icon_state = "rose"
	var/thorned = 1
	var/list/names = list("Emma", "Olivia", "Ava", "Isabella", "Sophia", "Charlotte", "Mia", "Amelia",
	"Harper", "Evelyn", "Abigail", "Emily", "Elizabeth", "Mila", "Dakota", "Avery",
	"Sofia", "Camila", "Aria", "Scarlett", "Liam", "Noah", "William", "James",
	"Oliver", "Benjamin", "Elijah", "Lucas", "Mason", "Logan", "Alexander", "Ethan",
	"Jacob", "Michael", "Daniel", "Henry", "Jackson", "Sebastian", "Aiden", "Matthew")
	value = 5 //just a flower

	New()
		..()
		desc = desc + pick(names) + "."

	attack_hand(mob/user as mob)
		var/mob/living/carbon/human/H = user
		if(src.thorned)
			if (H.hand)//gets active arm - left arm is 1, right arm is 0
				if (istype(H.limbs.l_arm,/obj/item/parts/robot_parts))
					..()
					return
			else
				if (istype(H.limbs.r_arm,/obj/item/parts/robot_parts))
					..()
					return
			if(istype(H))
				if(H.gloves)
					..()
					return
			boutput(user, "<span class='alert'>You prick yourself on [src]'s thorns trying to pick it up!</span>")
			random_brute_damage(user, 3)
			take_bleeding_damage(user,null,3,DAMAGE_STAB)
		else
			..()

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/wirecutters/) && src.thorned)
			boutput(user, "<span class='notice'>You snip off [src]'s thorns.</span>")
			src.thorned = 0
			src.desc += " Its thorns have been snipped off."
			return
		..()
		return

/obj/item/plant/herb/hcordata
	name = "houttuynia cordata"
	desc = "Also known as fish mint or heart leaf, used in cuisine for its distinct fishy flavor."
	icon_state = "hcordata"
	value = 20
