//hi so far this is literally a copy paste of savefile.dm
//this is for persistence stuff and is coder only for now.

/datum/preferences/proc

	savefile2_path(client/user)
		return "data/player_saves2/[copytext(user.ckey, 1, 2)]/[user.ckey]_2.sav" //saving to /player_saves2, all save files will end with a _2 to diff

	//JSON is not currently playing a role in this system, but will eventually work a as a type of 'mid-round' save that gets encoded to the actual save file
	//if conditons are met
	// returnSaveFile returns the file rather than writing it
	// used for cloud saves
	body_save(client/user, var/id, returnSavefile = 0) //profilenum not needed yet
	//TODO: LIMB SAVES
		if (IsGuestKey(user.key))
			return 0

		var/savefile/F
		var/mob/living/carbon/human/H
		var/datum/bioHolder/BH
		if (returnSavefile)
			F = new /savefile
		else
			F = new /savefile(src.savefile_path(user), -1)
		if (user.mob && user.mob.bioHolder)
			if(ishuman(user.mob))
				H = user.mob
			else
				boutput(user, "<B><I>you aren't a human!</I></B>")
				return 0 //humans only for now, borgs are a whole other can of worms
			BH = user.mob.bioHolder
		else
			boutput(user, "<B><I>your client has no mob and or no bioholder!</I></B>")
			return 0

		F.Lock(-1)

		// Character details
		F["[id]_real_name"] << H.real_name
		F["[id]_name_first"] << src.name_first
		F["[id]_name_middle"] << src.name_middle
		F["[id]_name_last"] << src.name_last
		F["[id]_gender"] << BH.mobAppearance.gender
		F["[id]_age"] << BH.age
		F["[id]_fartsound"] << BH.mobAppearance.fartsound
		F["[id]_screamsound"] << BH.mobAppearance.screamsound
		F["[id]_voicetype"] << BH.mobAppearance.voicetype
		F["[id]_PDAcolor"] << src.PDAcolor
		F["[id]_pda_ringtone_index"] << src.pda_ringtone_index
		F["[id]_blood_type"] << BH.bloodType

		// Records
		F["[id]_pin"] << H.pin
		F["[id]_flavor_text"] << BH.mobAppearance.flavor_text
		F["[id]_medical_note"] << src.medical_note
		F["[id]_security_note"] << src.security_note

		// AppearanceHolder details
		F["[id]_pronouns"] << BH.mobAppearance.pronouns.name
		F["[id]_pronouns_preferred_gender"] << BH.mobAppearance.pronouns.preferredGender
		F["[id]_pronouns_subjective"] << BH.mobAppearance.pronouns.subjective
		F["[id]_pronouns_objective"] << BH.mobAppearance.pronouns.objective
		F["[id]_pronouns_possessive"] << BH.mobAppearance.pronouns.possessive
		F["[id]_pronouns_posessive_pronoun"] << BH.mobAppearance.pronouns.posessivePronoun
		F["[id]_pronouns_reflexive"] << BH.mobAppearance.pronouns.reflexive
		F["[id]_pronouns_plural"] << BH.mobAppearance.pronouns.pluralize
		F["[id]_eye_color"] << BH.mobAppearance.e_color
		F["[id]_hair_color"] << BH.mobAppearance.customization_first_color
		F["[id]_facial_color"] << BH.mobAppearance.customization_second_color
		F["[id]_detail_color"] << BH.mobAppearance.customization_third_color
		F["[id]_skin_tone"] << BH.mobAppearance.s_tone
		F["[id]_hair_style_name"] << BH.mobAppearance.customization_first
		F["[id]_facial_style_name"] << BH.mobAppearance.customization_second
		F["[id]_detail_style_name"] << BH.mobAppearance.customization_third
		F["[id]_underwear_style_name"] << BH.mobAppearance.underwear
		F["[id]_underwear_color"] << BH.mobAppearance.u_color

		//organHolder details *eventually we'll want to have a proc that determines what organs to revert to normal,
		//which missing organs to replace, etc. For now, all gets saved and replaced if missing.
		F["[id]_brain_type"] << H.organHolder.brain.organ_name
		F["[id]_left_eye_type"] << H.organHolder.left_eye.organ_name
		F["[id]_right_eye_type"] << H.organHolder.right_eye.organ_name
		F["[id]_heart_type"] << H.organHolder.heart.organ_name
		F["[id]_left_lung_type"] << H.organHolder.left_lung.organ_name
		F["[id]_right_lung_type"] << H.organHolder.right_lung.organ_name
		F["[id]_left_kidney_type"] << H.organHolder.left_kidney.organ_name
		F["[id]_right_kidney_type"] << H.organHolder.right_kidney.organ_name
		F["[id]_liver_type"] << H.organHolder.liver.organ_name
		F["[id]_spleen_type"] << H.organHolder.spleen.organ_name
		F["[id]_pancreas_type"] << H.organHolder.pancreas.organ_name
		F["[id]_stomach_type"] << H.organHolder.stomach.organ_name
		F["[id]_intestines_type"] << H.organHolder.intestines.organ_name
		F["[id]_appendix_type"] << H.organHolder.appendix.organ_name
		F["[id]_tail_type"] << H.organHolder.tail.organ_name

		// Job prefs
		F["[id]_job_prefs_1"] << src.job_favorite
		F["[id]_job_prefs_2"] << src.jobs_med_priority
		F["[id]_job_prefs_3"] << src.jobs_low_priority
		F["[id]_job_prefs_4"] << src.jobs_unwanted
		F["[id]_be_traitor"] << src.be_traitor
		F["[id]_be_syndicate"] << src.be_syndicate
		F["[id]_be_spy"] << src.be_spy
		F["[id]_be_gangleader"] << src.be_gangleader
		F["[id]_be_revhead"] << src.be_revhead
		F["[id]_be_changeling"] << src.be_changeling
		F["[id]_be_wizard"] << src.be_wizard
		F["[id]_be_werewolf"] << src.be_werewolf
		F["[id]_be_vampire"] << src.be_vampire
		F["[id]_be_wraith"] << src.be_wraith
		F["[id]_be_blob"] << src.be_blob
		F["[id]_be_conspirator"] << src.be_conspirator
		F["[id]_be_flock"] << src.be_flock
		F["[id]_be_misc"] << src.be_misc

		// UI settings. Ehhhhh.
		F["[id]_hud_style"] << src.hud_style
		F["[id]_tcursor"] << src.target_cursor

		if(src.traitPreferences.isValid()) //we'll save trates as preferences and use a copy_to to set them on load
			F["[id]_traits"] << src.traitPreferences.traits_selected



		// Global options
		F["tooltip"] << (src.tooltip_option ? src.tooltip_option : TOOLTIP_ALWAYS)
		F["changelog"] << src.view_changelog
		F["score"] << src.view_score
		F["tickets"] << src.view_tickets
		F["sounds"] << src.admin_music_volume
		F["radio_sounds"] << src.radio_music_volume
		F["clickbuffer"] << src.use_click_buffer
		F["font_size"] << src.font_size

		F["see_mentor_pms"] << src.see_mentor_pms
		F["listen_ooc"] << src.listen_ooc
		F["listen_looc"] << src.listen_looc
		F["default_wasd"] << src.use_wasd
		F["use_azerty"] << src.use_azerty
		F["preferred_map"] << src.preferred_map
		F["flying_chat_hidden"] << src.flying_chat_hidden
		F["auto_capitalization"] << src.auto_capitalization
		F["local_deachat"] << src.local_deadchat
		F["hidden_spiders"] << src.hidden_spiders

		if (returnSavefile)
			return F
		return 1

	body_load(client/user,var/id,var/savefile/loadFrom = null) //for now this just loads to prefs, use respawn as self to load the character in
	//TODO: LOAD ORGAN SAVE STUFF
		if (ismob(user))
			CRASH("[user] isnt a client. please give me a client. please. i beg you.")

		if (IsGuestKey(user.key))
			return "Guests cannot load saves."

		var/savefile/F
		var/path
		if (loadFrom)
			F = loadFrom
		else
			path = savefile2_path(user)
			if (!fexists(path))
				return "Save path does not exist."
			F = new /savefile(path, -1)

		var/version = null
		F["version"] >> version

		if (isnull(version) || version < SAVEFILE_VERSION_MIN || version > SAVEFILE_VERSION_MAX)
			if (!loadFrom)
				fdel(path)
			return "Save version unvalid. > [version],[id],[path],[loadFrom] <"

		/*
		// Check if any saved profiles are present
		var/sanity_check = null
		F["[profileNum]_saved"] >> sanity_check
		if (isnull(sanity_check))
			for (var/i=1, i <= SAVEFILE_PROFILES_MAX, i++)
				F["[i]_saved"] >> sanity_check
				if (!isnull(sanity_check))
					break
			if (isnull(sanity_check) && !loadFrom)
				fdel(path)
			return "Failed sanity check."
		*/

		// Character details
		F["[id]_real_name"] >> src.real_name
		F["[id]_name_first"] >> src.name_first
		F["[id]_name_middle"] >> src.name_middle
		F["[id]_name_last"] >> src.name_last
		F["[id]_gender"] >> src.gender
		F["[id]_age"] >> src.age
		F["[id]_fartsound"] >> AH.fartsound
		F["[id]_screamsound"] >> AH.screamsound
		F["[id]_voicetype"] >> AH.voicetype
		F["[id]_PDAcolor"] >> src.PDAcolor
		F["[id]_pda_ringtone_index"] >> src.pda_ringtone_index
		F["[id]_random_blood"] >> src.random_blood
		F["[id]_blood_type"] >> src.blType

		// Records
		F["[id]_pin"] >> src.pin
		F["[id]_flavor_text"] >> src.flavor_text
		F["[id]_medical_note"] >> src.medical_note
		F["[id]_security_note"] >> src.security_note

		// Randomization options
		F["[id]_name_is_always_random"] >> src.be_random_name
		F["[id]_look_is_always_random"] >> src.be_random_look

		// AppearanceHolder details
		if (src.AH)
			var/saved_pronouns
			F["[id]_pronouns"] >> saved_pronouns
			// we only store the name and i don't feel like breaking all saves so stupid string searching
			if(findtext(saved_pronouns, "custom"))
				AH.pronouns = new
				AH.pronouns.name = saved_pronouns
				F["[id]_pronouns_preferred_gender"] >> AH.pronouns.preferredGender
				F["[id]_pronouns_subjective"] >> AH.pronouns.subjective
				F["[id]_pronouns_objective"] >> AH.pronouns.objective
				F["[id]_pronouns_possessive"] >> AH.pronouns.possessive
				F["[id]_pronouns_posessive_pronoun"] >> AH.pronouns.posessivePronoun
				F["[id]_pronouns_reflexive"] >> AH.pronouns.reflexive
				F["[id]_pronouns_plural"] >> AH.pronouns.pluralize
			else
				for (var/P as anything in filtered_concrete_typesof(/datum/pronouns, /proc/pronouns_filter_is_choosable))
					var/datum/pronouns/pronouns = get_singleton(P)
					if (saved_pronouns == pronouns.name)
						AH.pronouns = pronouns
						break
			F["[id]_eye_color"] >> AH.e_color
			F["[id]_hair_color"] >> AH.customization_first_color
			F["[id]_hair_color"] >> AH.customization_first_color_original
			F["[id]_facial_color"] >> AH.customization_second_color
			F["[id]_facial_color"] >> AH.customization_second_color_original
			F["[id]_detail_color"] >> AH.customization_third_color
			F["[id]_detail_color"] >> AH.customization_third_color_original
			F["[id]_skin_tone"] >> AH.s_tone
			F["[id]_skin_tone"] >> AH.s_tone_original
			F["[id]_hair_style_name"] >> AH.customization_first
			F["[id]_hair_style_name"] >> AH.customization_first_original
			F["[id]_facial_style_name"] >> AH.customization_second
			F["[id]_facial_style_name"] >> AH.customization_second_original
			F["[id]_detail_style_name"] >> AH.customization_third
			F["[id]_detail_style_name"] >> AH.customization_third_original
			F["[id]_underwear_style_name"] >> AH.underwear
			F["[id]_underwear_color"] >> AH.u_color

		// Job prefs
		F["[id]_job_prefs_1"] >> src.job_favorite
		F["[id]_job_prefs_2"] >> src.jobs_med_priority
		F["[id]_job_prefs_3"] >> src.jobs_low_priority
		F["[id]_job_prefs_4"] >> src.jobs_unwanted
		F["[id]_be_traitor"] >> src.be_traitor
		F["[id]_be_syndicate"] >> src.be_syndicate
		F["[id]_be_spy"] >> src.be_spy
		F["[id]_be_gangleader"] >> src.be_gangleader
		F["[id]_be_revhead"] >> src.be_revhead
		F["[id]_be_changeling"] >> src.be_changeling
		F["[id]_be_wizard"] >> src.be_wizard
		F["[id]_be_werewolf"] >> src.be_werewolf
		F["[id]_be_vampire"] >> src.be_vampire
		F["[id]_be_wraith"] >> src.be_wraith
		F["[id]_be_blob"] >> src.be_blob
		F["[id]_be_conspirator"] >> src.be_conspirator
		F["[id]_be_flock"] >> src.be_flock
		F["[id]_be_misc"] >> src.be_misc

		// UI settings...
		F["[id]_hud_style"] >> src.hud_style
		F["[id]_tcursor"] >> src.target_cursor

		F["[id]_traits"] >> src.traitPreferences.traits_selected

		/*
		// Game setting options, not per-profile
		F["tooltip"] >> src.tooltip_option
		F["changelog"] >> src.view_changelog
		F["score"] >> src.view_score
		F["tickets"] >> src.view_tickets
		F["sounds"] >> src.admin_music_volume
		F["radio_sounds"] >> src.radio_music_volume
		F["clickbuffer"] >> src.use_click_buffer
		F["font_size"] >> src.font_size

		F["see_mentor_pms"] >> src.see_mentor_pms
		F["listen_ooc"] >> src.listen_ooc
		F["listen_looc"] >> src.listen_looc
		F["default_wasd"] >> src.use_wasd
		F["use_azerty"] >> src.use_azerty
		F["preferred_map"] >> src.preferred_map
		F["flying_chat_hidden"] >> src.flying_chat_hidden
		F["auto_capitalization"] >> src.auto_capitalization
		F["local_deachat"] >> src.local_deadchat
		F["hidden_spiders"] >> src.hidden_spiders
		*/

		if (isnull(src.name_first) || !length(src.name_first) || isnull(src.name_last) || !length(src.name_last))
			// Welp, you get a random name then.
			src.randomize_name()

		// Clean up invalid / default preferences
		if (isnull(AH.fartsound))
			AH.fartsound = "default"
		if (isnull(AH.screamsound) || AH.screamsound == "default")
			AH.screamsound = "male"
		if (!AH.voicetype)
			AH.voicetype = RANDOM_HUMAN_VOICE

		if(!is_valid_color_string(src.PDAcolor)) //how?
			src.PDAcolor = "#6F7961"

		get_all_character_setup_ringtones()
		if(!(src.pda_ringtone_index in selectable_ringtones))
			src.pda_ringtone_index = "Two-Beep"

		if (!istext(src.hud_style))
			src.hud_style = "New"
		if (!istext(src.target_cursor))
			src.target_cursor = "Default"


		// Validate trait choices
		if (src.traitPreferences.traits_selected == null)
			src.traitPreferences.traits_selected = list()

		for (var/T as anything in src.traitPreferences.traits_selected)
			if (!(T in traitList)) src.traitPreferences.traits_selected.Remove(T)

		if (!src.traitPreferences.isValid())
			src.traitPreferences.traits_selected.Cut()
			src.traitPreferences.calcTotal()
			alert(usr, "Your traits couldn't be loaded. Please reselect your traits.")


		if(!src.radio_music_volume) // We can take this out some time, when we're decently sure that most people will have this var set to something
			F["[id]_sounds"] >> src.radio_music_volume
			F["[id]_radio_sounds"] << src.radio_music_volume

		// Global pref validation
		if (user?.is_mentor())
			if (isnull(src.see_mentor_pms))
				src.see_mentor_pms = 1
			if (src.see_mentor_pms == 0)
				user.set_mentorhelp_visibility(0)

		if (isnull(src.listen_looc))
			src.listen_looc = 1
		if (isnull(src.use_wasd))
			src.use_wasd = 1
		if (isnull(src.use_azerty))
			src.use_azerty = 0


		src.tooltip_option = (src.tooltip_option ? src.tooltip_option : TOOLTIP_ALWAYS) //For fucks sake.
		src.keybind_prefs_updated(user)


		return 1


