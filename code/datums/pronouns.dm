/proc/pronouns_filter_is_choosable(var/P)
	var/datum/pronouns/pronouns = get_singleton(P)
	return pronouns.choosable

/proc/choose_pronouns(mob/user, message, title, default="None")
	RETURN_TYPE(/datum/pronouns)
	var/list/types = filtered_concrete_typesof(/datum/pronouns, /proc/pronouns_filter_is_choosable)
	var/list/choices = list()
	for(var/t in types)
		var/datum/pronouns/pronouns = get_singleton(t)
		choices[pronouns.name] = pronouns
	choices["None"] = null
	var/choice = input(user, message, title, default) as null|anything in choices
	if(isnull(choice))
		return choice
	return choices[choice]


#define STRING_CHECK(STRING) \
	STRING = trim(STRING); \
	for(var/x in bad_name_characters) { \
		STRING = replacetext(STRING, x, ""); \
	} \
	STRING = copytext(STRING, 1, NAME_CHAR_MAX);

/// create an instance of a custom pronoun datum
/// optional current arg to autofill fields with current values
/proc/create_pronouns(datum/pronouns/current = null)
	RETURN_TYPE(/datum/pronouns)
	var/preferredGender = input(usr, "Enter preferred gender e.g. man, woman, person", "Miraculous Pronoun-o-matic", current?.preferredGender) as null|text
	STRING_CHECK(preferredGender)
	if(!preferredGender) return FALSE
	var/subjective = input(usr, "Enter subjective pronoun e.g. BLANK robusted the clown", "Miraculous Pronoun-o-matic", current?.subjective) as null|text
	STRING_CHECK(subjective)
	if(!subjective) return FALSE
	var/objective = input(usr, "Enter objective pronoun e.g. I've heard about BLANK", "Miraculous Pronoun-o-matic", current?.objective) as null|text
	STRING_CHECK(objective)
	if(!objective) return FALSE
	var/possessive = input(usr, "Enter possessive pronoun e.g. That is BLANK toolbox", "Miraculous Pronoun-o-matic", current?.possessive) as null|text
	STRING_CHECK(possessive)
	if(!possessive) return FALSE
	var/posessivePronoun = input(usr, "Enter posessive pronoun e.g. That is BLANK", "Miraculous Pronoun-o-matic", current?.posessivePronoun) as null|text
	STRING_CHECK(posessivePronoun)
	if(!posessivePronoun) return FALSE
	var/reflexive = input(usr, "Enter reflexive pronoun e.g. Describe BLANK", "Miraculous Pronoun-o-matic", current?.reflexive) as null|text
	STRING_CHECK(reflexive)
	if(!reflexive) return FALSE
	var/plural = alert(usr, "Are these pronouns plural?", "Miraculous Pronoun-o-matic", "Yes", "No")
	if(!plural) return FALSE
	var/datum/pronouns/custom/newPronouns = new
	newPronouns.preferredGender = preferredGender
	newPronouns.name = "custom ([subjective]/[objective])"
	newPronouns.subjective = subjective
	newPronouns.objective = objective
	newPronouns.possessive = possessive
	newPronouns.posessivePronoun = posessivePronoun
	newPronouns.reflexive = reflexive
	newPronouns.pluralize = plural == "Yes" ? TRUE : FALSE
	return newPronouns
#undef STRING_CHECK
ABSTRACT_TYPE(/datum/pronouns)
/datum/pronouns
	var/name
	var/preferredGender
	var/subjective
	var/objective
	var/possessive
	var/posessivePronoun
	var/reflexive
	var/pluralize = FALSE
	var/choosable = TRUE

	proc/next_pronouns()
		RETURN_TYPE(/datum/pronouns)
		var/list/types = filtered_concrete_typesof(/datum/pronouns, /proc/pronouns_filter_is_choosable)
		var/selected
		for (var/i = 1, i <= length(types), i++)
			var/datum/pronouns/pronouns = get_singleton(types[i])
			if (src == pronouns)
				selected = i
				break
		return get_singleton(types[selected < length(types) ? selected + 1 : 1])

/datum/pronouns/theyThem
	name = "they/them"
	preferredGender = "person"
	subjective = "they"
	objective = "them"
	possessive = "their"
	posessivePronoun = "theirs"
	reflexive = "themself"
	pluralize = TRUE

/datum/pronouns/heHim
	name = "he/him"
	preferredGender = "man"
	subjective = "he"
	objective = "him"
	possessive = "his"
	posessivePronoun = "his"
	reflexive = "himself"

/datum/pronouns/sheHer
	name = "she/her"
	preferredGender = "woman"
	subjective = "she"
	objective = "her"
	possessive = "her"
	posessivePronoun = "hers"
	reflexive = "herself"

/datum/pronouns/abomination
	name = "abomination"
	preferredGender = "abomination"
	subjective = "we"
	objective = "us"
	possessive = "our"
	posessivePronoun = "ours"
	reflexive = "ourself"
	pluralize = TRUE
	choosable = FALSE

/datum/pronouns/itIts
	name = "it/its"
	preferredGender = "neuter"
	subjective = "it"
	objective = "it"
	possessive = "its"
	posessivePronoun = "its"
	reflexive = "itself"
	choosable = TRUE

/datum/pronouns/custom
	choosable = FALSE
	name = "custom"
