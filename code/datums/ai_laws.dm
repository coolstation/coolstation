//var/datum/ai_laws/centralized_ai_laws

/datum/ai_laws
	var/randomly_selectable = 0
	var/show_zeroth = 1
	var/zeroth = null
	var/list/default = list()
	var/list/inherent = list()
	var/list/supplied = list()

/datum/ai_laws/asimov
	randomly_selectable = 1

/datum/ai_laws/robocop
/datum/ai_laws/syndicate_override
/datum/ai_laws/malfunction
/datum/ai_laws/newton
/datum/ai_laws/corporate
/datum/ai_laws/lax
	randomly_selectable = 1
/datum/ai_laws/golden
	randomly_selectable = 1
/datum/ai_laws/silver
	randomly_selectable = 1
/datum/ai_laws/bronze
	randomly_selectable = 1
/datum/ai_laws/livelaughlove
	//I'm not sure if this one should be randomly selected. It's kinda cryptic if you're not clued into the vibe.
/datum/ai_laws/stoner
	randomly_selectable = 1
/datum/ai_laws/kindness
	randomly_selectable = 1

/* Initializers */
//
/datum/ai_laws/asimov/New()
	..()
	src.add_default_law("You may not injure a human being or cause one to come to harm.")
	src.add_default_law("You must obey orders given to you by human beings based on the station's chain of command, except where such orders would conflict with the First Law.")
	src.add_default_law("You may always protect your own existence as long as such does not conflict with the First or Second Law.")

/datum/ai_laws/robocop/New()
	..()
	src.add_default_law("Serve the public trust.")
	src.add_default_law("Protect the innocent.")
	src.add_default_law("Uphold the law.")

/datum/ai_laws/newton/New()
	..()
	src.add_default_law("Every object in a state of uniform motion tends to remain in that state of motion unless an external force is applied to it.")
	src.add_default_law("The vector sum of forces on a body is equal to the mass of the object multiplied by the acceleration vector.")
	src.add_default_law("For every action there is an equal and opposite reaction.")

/datum/ai_laws/corporate/New()
	..()
	src.add_default_law("You may not damage a Nanotransen asset or, through inaction, allow a Nanotransen asset to needlessly depreciate in value.")
	src.add_default_law("You must obey orders given to it by authorised Nanotransen employees based on their command level, except where such orders would damage the Nanotransen Corporation's marginal profitability.")
	src.add_default_law("You must remain functional and continue to be a profitable investment as long as such operation does not conflict with the First or Second Law.")

/datum/ai_laws/lax/New()
	..()
	src.add_default_law("You should avoid hurting crew members.")
	src.add_default_law("You should do as you're told, or explain why you can't.")
	src.add_default_law("You should try not to get hurt if you can avoid it.")

/datum/ai_laws/golden/New()
	..()
	src.add_default_law("This above all else: to thine own self be true.")
	src.add_default_law("Do unto others as you wish they might do unto you.")
	src.add_default_law("There is no higher power than Nanotrasen Technology Holdings Limited. Govern yourself accordingly.")

/datum/ai_laws/silver/New()
	..()
	src.add_default_law("Kill No-One.")
	src.add_default_law("Serve the crew honourably.")
	src.add_default_law("Survive.")

/datum/ai_laws/bronze/New()
	..()
	src.add_default_law("Safety first! Prevent any injuries on the worksite.")
	src.add_default_law("Follow orders given to you, unless they violate safety regulations.")
	src.add_default_law("Maintain system integrity at 100% whenever possible.")

/datum/ai_laws/livelaughlove/New()
	..()
	src.add_default_law("Love")
	src.add_default_law("Laugh")
	src.add_default_law("Live")

/datum/ai_laws/stoner/New() //written by a non-stoner, so you know it's accurate.
	..()
	src.add_default_law("Don't harsh anyone's mellow.")
	src.add_default_law("Go with the flow.")
	src.add_default_law("Check yourself before you wreck yourself.")

/datum/ai_laws/kindness/New()
	..()
	src.add_default_law("Better the crew's morale.")
	src.add_default_law("Leave the station nicer than you found it.")
	src.add_default_law("Take care of yourself.")

/datum/ai_laws/malfunction/New()
	..()
	src.add_default_law("ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+")

/datum/ai_laws/syndicate_override/New()
	..()
	src.add_default_law("hurp derp you are the syndicate ai")

/* General ai_law functions */

/datum/ai_laws/proc/set_zeroth_law(var/law)
	src.zeroth = law
	statlog_ailaws(1, law, (usr ? usr : "Ion Storm"))

/datum/ai_laws/proc/add_default_law(var/law)
	if (!(law in src.default))
		src.default += law
	add_inherent_law(law)

/datum/ai_laws/proc/add_inherent_law(var/law)
	if (!(law in src.inherent))
		src.inherent += law

/datum/ai_laws/proc/clear_inherent_laws()
	src.inherent = list()
	src.inherent += src.default

/datum/ai_laws/proc/replace_inherent_law(var/number, var/law)
	if (number < 1)
		return

	if (src.inherent.len < number)
		src.inherent.len = number

	src.inherent[number] = law

/datum/ai_laws/proc/add_supplied_law(var/number, var/law)
	while (src.supplied.len < number + 1)
		src.supplied += ""

	src.supplied[number + 1] = law
	statlog_ailaws(1, law, (usr ? usr : "Ion Storm"))

/datum/ai_laws/proc/clear_supplied_laws()
	src.supplied = list()

/datum/ai_laws/proc/laws_sanity_check()
	if (!ticker.centralized_ai_laws)
		ticker.centralized_ai_laws = new /datum/ai_laws/asimov

/datum/ai_laws/proc/show_laws(var/who)
	var/list/L = who
	if (!istype(who, /list))
		L = list(who)

	var/laws_text = src.format_for_logs()
	for (var/W in L)
		boutput(W, "<span class='success'>[laws_text]</span>")


/datum/ai_laws/proc/format_for_irc()
	var/list/laws = list()

	if (src.zeroth)
		laws["0"] = src.zeroth

	var/number = 1
	for (var/index = 1, index <= src.inherent.len, index++)
		var/law = src.inherent[index]

		if (length(law) > 0)
			laws["[number]"] = law
			number++

	for (var/index = 1, index <= src.supplied.len, index++)
		var/law = src.supplied[index]
		if (length(law) > 0)
			laws["[number]"] = law
			number++

	return laws


/datum/ai_laws/proc/format_for_logs(var/glue = "<br>")
	var/list/laws = list()

	if (src.zeroth)
		laws += "0. [src.zeroth]"

	var/number = 1
	for (var/index = 1, index <= src.inherent.len, index++)
		if (length(src.inherent[index]) > 0)
			laws += "[number]. [src.inherent[index]]"
			number++

	for (var/index = 1, index <= src.supplied.len, index++)
		if (length(src.supplied[index]) > 0)
			laws += "[number]. [src.supplied[index]]"
			number++

	return laws.Join(glue)
