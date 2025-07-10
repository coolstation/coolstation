//Contains wacky space drugs

ABSTRACT_TYPE(/datum/reagent/drug)

datum
	reagent
		drug/
			name = "some drug"

		drug/bathsalts
			name = "bath salts"
			id = "bathsalts"
			description = "Sometimes packaged as a refreshing bathwater additive, these crystals are definitely not for human consumption."
			reagent_state = SOLID
			fluid_r = 250
			fluid_g = 250
			fluid_b = 250
			transparency = 100
			addiction_prob = 15//80
			addiction_min = 5
			overdose = 20
			depletion_rate = 0.6
			energy_value = 1
			hunger_value = -0.1
			bladder_value = -0.1
			thirst_value = -0.05
			contraband = 8
			var/static/list/halluc_attackers = list(
				new /image('icons/mob/critter.dmi',"death") = list("death","the bell guy","GO METS!"),
				new /image('icons/mob/critter.dmi', "cluwnespider_queen") = list("your mother","fat fuck","horrible green crab"),
				new /image('icons/mob/genetics.dmi', "psyche") = list("stranger","why why why"),
				new /image('icons/mob/human.dmi', "husk") = list("mom","dad","burn please burn"),
				new /image('icons/mob/human.dmi', "fire3") = list("no no NO","????","best friends!!!"),
				new /image('icons/mob/human.dmi', "eaten") = list("grampa","the thing you refuse to remember you did"),
				new /image('icons/mob/human.dmi', "decomp3") = list("yourself","me","us","mom","dad"),
			)
			var/static/list/halluc_overrides = list(
				new /image('icons/mob/critter.dmi',"death"),
				new /image('icons/mob/human.dmi', "husk"),
				new /image('icons/mob/human.dmi', "fire3"),
				new /image('icons/mob/human.dmi', "eaten"),
				new /image('icons/mob/critter.dmi',"brullbar"),
			)
			var/static/list/halluc_sounds = list(
				'sound/vox/poo-vox.ogg',
				new /datum/hallucinated_sound("clownstep", min_count = 10, max_count = 20, delay = 0.1 SECONDS),
				new /datum/hallucinated_sound('sound/machines/airlock_bolted.ogg', volume = 50, min_count = 2, max_count = 5, delay = 0.2 SECONDS),
				'sound/voice/creepyshriek.ogg',
				new /datum/hallucinated_sound('sound/musical_instruments/Bell_Huge_1.ogg', min_count = 2, max_count = 4, delay = 1.2 SECONDS),
				'sound/machines/airlock_deny.ogg',
				'sound/machines/airlock_pry.ogg',
				'sound/musical_instruments/Bikehorn_1.ogg',
				'sound/misc/talk/radio.ogg',
				'sound/misc/talk/radio_ai.ogg',
				'sound/weapons/DSRXPLOD.ogg',
				'sound/weapons/flintlock.ogg',
				new /datum/hallucinated_sound('sound/machines/airlock_bolted.ogg', pitch = 0.4),
				'sound/items/hypo.ogg',
				'sound/voice/cluwnelaugh1.ogg',
				'sound/voice/cluwnelaugh2.ogg',
				'sound/voice/cluwnelaugh3.ogg',
				'sound/items/geiger/geiger-3-2.ogg',
				'sound/items/geiger/geiger-5-3.ogg',
				'sound/machines/ArtifactEld1.ogg',
				'sound/machines/ArtifactEld2.ogg',
				'sound/effects/heartbeat.ogg',
			)

			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_bathsalts", 3)
				return

			on_remove()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_bathsalts")
				return

			on_mob_life(var/mob/M, var/mult = 1) // commence bad times
				if(!M) M = holder.my_atom

				var/check = rand(0,100)
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					if (check < 8 && H.bioHolder.mobAppearance.customization_second.id != "tramp") // M.is_hobo = very yes
						H.bioHolder.mobAppearance.customization_second = new /datum/customization_style/beard/tramp
						H.set_face_icon_dirty()
						boutput(M, "<span class='alert'><b>You feel gruff!</b></span>")
						SPAWN_DBG(0.3 SECONDS)
							M.visible_message("<span class='alert'><b>[M.name]</b> has a wild look in their eyes!</span>")
					if(check < 60)
						if(H.getStatusDuration("paralysis")) H.delStatus("paralysis")
						H.delStatus("stunned")
						H.delStatus("weakened")
					if(check < 30)
						H.emote(pick("twitch", "twitch_s", "scream", "drool", "grumble", "mumble"))

				M.druggy = max(M.druggy, 15)
				if(check < 20)
					M.change_misstep_chance(10 * mult)

					var/image/imagekey = pick(halluc_attackers)
					M.AddComponent(/datum/component/hallucination/fake_attack, timeout=15, image_list=list(imagekey), name_list=halluc_attackers[imagekey], attacker_prob=rand(30,50), max_attackers=rand(1,2))
				// a really shitty form of traitor stimulants - you'll be tough to take down but nearly uncontrollable anyways and you won't heal the way stims do

				M.AddComponent(/datum/component/hallucination/random_sound, timeout=10, sound_list=src.halluc_sounds, sound_prob=25)
				M.AddComponent(/datum/component/hallucination/random_image_override, timeout=10, image_list=halluc_overrides, target_list=list(/mob/living/carbon/human), range=7, image_prob=30, image_time=20, override=TRUE)

				if(check < 8)
					M.reagents.add_reagent(pick("methamphetamine", "crank", "neurotoxin"), rand(1,5))
					M.visible_message("<span class='alert'><b>[M.name]</b> scratches at something under their skin!</span>")
					random_brute_damage(M, 5 * mult)
				else if (check < 16)
					if(prob(20))
						boutput(M, "<span class='alert'><b>OH GOD LOOK OUT!!!</b>!</span>")
						M.emote("scream")
					else if(prob(50))
						boutput(M, "<span class='alert'><b>The smiling thing</b> laughs!</span>")
					else
						boutput(M, "<span class='alert'><b>You hear something strange behind you...</b></span>")
				else if(check < 24)
					boutput(M, "<span class='alert'><b>They're coming for you!</b></span>")
				else if(check < 28)
					boutput(M, "<span class='alert'><b>THEY'RE GONNA GET YOU!</b></span>")
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == INGEST)
					boutput(M, "<span class='alert'><font face='[pick("Curlz MT", "Comic Sans MS")]' size='[rand(4,6)]'>You feel FUCKED UP!!!!!!</font></span>")
					M.playsound_local(M.loc, 'sound/effects/heartbeat.ogg', 50, 1)
					M.emote("faint")
					//var/mob/living/carbon/human/H = M
					//if (istype(H))
					M.changeStatus("radiation", 3 SECONDS, 2)
					M.take_toxin_damage(5)
					M.take_brain_damage(10)
				else
					boutput(M, "<span class='notice'>You feel a bit more salty than usual.</span>")
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> flails around like a lunatic!</span>")
						M.change_misstep_chance(25 * mult)
						M.make_jittery(10)
						M.emote("scream")
						M.reagents.add_reagent("salts1", 5 * mult)
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]'s</b> eyes dilate!</span>")
						M.emote("twitch_s")
						M.take_toxin_damage(2 * mult)
						M.take_brain_damage(1 * mult)
						M.setStatus("stunned", max(M.getStatusDuration("stunned"), 4 SECONDS))
						M.change_eye_blurry(7, 7)
						M.reagents.add_reagent("salts1", 5 * mult)
					else if (effect <= 7)
						M.emote("faint")
						M.reagents.add_reagent("salts1", 5 * mult)
				else if (severity == 2)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]'s</b> eyes dilate!</span>")
						M.take_toxin_damage(2 * mult)
						M.take_brain_damage(1 * mult)
						M.setStatus("stunned", max(M.getStatusDuration("stunned"), 4 SECONDS))
						M.change_eye_blurry(7, 7)
						M.reagents.add_reagent("salts1", 5 * mult)
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]</b> convulses violently and falls to the floor!</span>")
						M.make_jittery(50)
						M.take_toxin_damage(2 * mult)
						M.take_brain_damage(1 * mult)
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 9 SECONDS))
						M.emote("gasp")
						M.reagents.add_reagent("salts1", 5 * mult)
					else if (effect <= 7)
						M.emote("scream")
						M.visible_message("<span class='alert'><b>[M.name]</b> tears at their own skin!</span>")
						random_brute_damage(M, 5 * mult)
						M.reagents.add_reagent("salts1", 5 * mult)
						M.emote("twitch")


		drug/jenkem
			name = "jenkem"
			id = "jenkem"
			description = "Jenkem is a prison drug made from fermenting feces in a solution of urine. Extremely disgusting."
			reagent_state = LIQUID
			fluid_r = 100
			fluid_g = 70
			fluid_b = 0
			transparency = 255
			addiction_prob = 5//30
			addiction_min = 5
			value = 2 // 1 1  :I
			viscosity = 0.4
			bladder_value = -0.03
			hunger_value = -0.04
			hygiene_value = -0.5
			thirst_value = -0.04
			energy_value = -0.04
			contraband = 2

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.make_dizzy(5 * mult)
				if(prob(10))
					M.emote(pick("twitch","drool","moan"))
					M.take_toxin_damage(1 * mult)
				..()
				return

		drug/crank
			name = "crank" // sort of a shitty version of methamphetamine that can be made by assistants
			id = "crank"
			description = "A cheap and dirty stimulant drug, commonly used by space biker gangs."
			reagent_state = SOLID
			fluid_r = 250
			fluid_b = 0
			fluid_g = 200
			transparency = 40
			addiction_prob = 10//50
			addiction_min = 5
			overdose = 20
			value = 20 // 10 2 1 3 1 heat explosion :v
			energy_value = 1.5
			bladder_value = -0.1
			hunger_value = -0.05
			thirst_value = -0.05
			stun_resist = 60
			contraband = 6

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(probmult(15)) M.emote(pick("twitch", "twitch_s", "grumble", "laugh"))
				if(prob(8))
					boutput(M, "<span class='notice'><b>You feel great!</b></span>")
					M.reagents.add_reagent("methamphetamine", rand(1,2) * mult)
					M.emote(pick("laugh", "giggle"))
				if(prob(6))
					boutput(M, "<span class='notice'><b>You feel warm.</b></span>")
					M.bodytemperature += rand(1,10) * mult
				if(prob(4))
					boutput(M, "<span class='alert'><b>You feel kinda awful!</b></span>")
					M.take_toxin_damage(1 * mult)
					M.make_jittery(30 * mult)
					M.emote(pick("groan", "moan"))
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> looks confused!</span>")
						M.change_misstep_chance(20 * mult)
						M.make_jittery(20)
						M.emote("scream")
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]</b> is all sweaty!</span>")
						M.bodytemperature += rand(5,30) * mult
						M.take_brain_damage(1 * mult)
						M.take_toxin_damage(1 * mult)
						M.setStatus("stunned", max(M.getStatusDuration("stunned"), 3 SECONDS))
					else if (effect <= 7)
						M.make_jittery(30)
						M.emote("grumble")
				else if (severity == 2)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> is sweating like a pig!</span>")
						M.bodytemperature += rand(20,100) * mult
						M.take_toxin_damage(5 * mult)
						M.setStatus("stunned", max(M.getStatusDuration("stunned"), 4 SECONDS))
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]</b> starts tweaking the hell out!</span>")
						M.make_jittery(100)
						M.take_toxin_damage(2 * mult)
						M.take_brain_damage(8 * mult)
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 4 SECONDS))
						M.change_misstep_chance(25 * mult)
						M.emote("scream")
						M.reagents.add_reagent("salts1", 5 * mult)
					else if (effect <= 7)
						M.emote("scream")
						M.visible_message("<span class='alert'><b>[M.name]</b> nervously scratches at their skin!</span>")
						M.make_jittery(10)
						random_brute_damage(M, 5 * mult)
						M.emote("twitch")

		drug/LSD
			name = "lysergic acid diethylamide"
			id = "LSD"
			description = "A highly potent hallucinogenic substance. Far out, maaaan."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 0
			fluid_b = 255
			transparency = 20
			value = 6 // 4 2
			thirst_value = -0.03
			contraband = 4
			var/static/list/halluc_sounds = list(
				"punch",
				'sound/vox/poo-vox.ogg',
				new /datum/hallucinated_sound("clownstep", min_count = 1, max_count = 6, delay = 0.4 SECONDS),
				'sound/weapons/armbomb.ogg',
				new /datum/hallucinated_sound('sound/weapons/Gunshot.ogg', min_count = 1, max_count = 3, delay = 0.4 SECONDS),
				new /datum/hallucinated_sound('sound/impact_sounds/Energy_Hit_3.ogg', min_count = 2, max_count = 4, delay = COMBAT_CLICK_DELAY),
				new /datum/hallucinated_sound('sound/machines/airlock_bolted.ogg', volume = 50, min_count = 2, max_count = 5, delay = 0.2 SECONDS),
				new /datum/hallucinated_sound('sound/machines/airlock_bolted.ogg', volume = 20),
				new /datum/hallucinated_sound('sound/impact_sounds/Metal_Hit_1.ogg', min_count = 1, max_count = 3, delay = COMBAT_CLICK_DELAY),
				'sound/machines/airlock_swoosh_temp.ogg',
				'sound/machines/airlock_deny.ogg',
				'sound/machines/airlock_pry.ogg',
				new /datum/hallucinated_sound('sound/weapons/flash.ogg', min_count = 1, max_count = 3, delay = COMBAT_CLICK_DELAY),
				'sound/musical_instruments/Bikehorn_1.ogg',
				'sound/misc/talk/radio.ogg',
				'sound/misc/talk/radio2.ogg',
				'sound/misc/talk/radio_ai.ogg',
				'sound/weapons/laser_f.ogg',
				new /datum/hallucinated_sound('sound/machines/click.ogg', min_count = 1, max_count = 4, delay = 0.4 SECONDS), //silenced pistol sound
				new /datum/hallucinated_sound('sound/effects/glare.ogg', pitch = 0.8), //vamp glare is pitched down for... reasons
				'sound/effects/poff.ogg',
				'sound/items/hypo.ogg',
				'sound/items/sticker.ogg',
			)
			var/static/list/speech_sounds = list(
				'sound/misc/talk/speak_1.ogg',
				'sound/misc/talk/speak_3.ogg',
				'sound/misc/talk/cow.ogg',
				'sound/misc/talk/roach.ogg',
				'sound/misc/talk/lizard.ogg',
				'sound/misc/talk/skelly.ogg',
			)
			var/static/list/voice_names = list(
				"The voice in your head",
				"Someone right behind you",
				"???",
				"A whisper in the vents",
				"The universe itself",
			)
			var/static/list/monkey_images = list(
				new /image('icons/mob/monkey.dmi', "monkey_hallucination"),
				new /image('icons/mob/monkey.dmi', "fire3"),
				new /image('icons/mob/monkey.dmi', "skeleton"),
				new /image('icons/mob/monkey.dmi', "seamonkey"),
			)
			var/static/list/critter_image_list = list(
				//new /image('icons/mob/hallucinations.dmi', "spider"),
				new /image('icons/mob/hallucinations.dmi', "dragon"),
				new /image('icons/mob/hallucinations.dmi', "pig"),
				new /image('icons/mob/hallucinations.dmi', "slime"),
				new /image('icons/mob/monkey.dmi', "monkey_hallucination"),
				new /image('icons/mob/monkey.dmi', "fire3"),
				new /image('icons/mob/monkey.dmi', "skeleton"),
				new /image('icons/mob/monkey.dmi', "seamonkey"),
				new /image('icons/mob/critter.dmi', "spacebee"),
				new /image('icons/mob/critter.dmi', "eyespider"),
				new /image('icons/mob/critter.dmi', "skeleton"),
				new /image('icons/mob/critter.dmi', "fly"),
			)
			var/static/list/monkey_names = strings("names/monkey.txt")
			var/static/list/halluc_images = list(
				new /image(icon = 'icons/obj/scrap.dmi', icon_state = "Crusher_1"),
				new /image(icon = 'icons/misc/mechanicsExpansion.dmi', icon_state = "comp_flush"),
				new /image(icon = 'icons/obj/foodNdrink/food_produce.dmi', icon_state = "banana-peel"),
				new /image(icon = 'icons/obj/items/weapons.dmi', icon_state = "mine_radiation_armed"),
				new /image(icon = 'icons/obj/decals/urine.dmi', icon_state = "floor1"),
				new /image(icon = 'icons/obj/decals/cleanables.dmi', icon_state = "messnoodle2meatball"),
				new /image(icon = 'icons/obj/foodNdrink/kitchen.dmi', icon_state = "cleaver")
			)

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				//pretty colors
				//M.AddComponent(/datum/component/hallucination/trippy_colors, timeout=10)
				M.druggy = max(M.druggy, 15)

				if(probmult(25)) //get attacked
					if(prob(50)) //monkey mode
						M.AddComponent(/datum/component/hallucination/fake_attack, timeout=10, image_list=monkey_images, name_list=monkey_names, attacker_prob=15, max_attackers=3)
					else
						M.AddComponent(/datum/component/hallucination/fake_attack, timeout=10, image_list=null, name_list=null, attacker_prob=80, max_attackers=1)

				//THE VOICES GET LOUDER
				M.AddComponent(/datum/component/hallucination/random_sound, timeout=10, sound_list=src.halluc_sounds, sound_prob=10)

				//TRUST NOTHING
				M.AddComponent(/datum/component/hallucination/random_image_override,\
					timeout=15,\
					image_list=halluc_images,\
					target_list=list(/turf/floor),\
					range=7,\
					image_prob=20,\
					image_time=30,\
					override=FALSE,\
					visible_creation = FALSE,\
					pixel_variance = 6\
				)

				if(probmult(8)) //display a random chat message
					M.playsound_local(M.loc, pick(src.speech_sounds, 100, 1))
					boutput(M, "<b>[pick(src.voice_names)]</b> says, \"[phrase_log.random_phrase("say")]\"")

				//turn someone into a critter
				M.AddComponent(/datum/component/hallucination/random_image_override, timeout=10, image_list=critter_image_list, target_list=list(/mob/living/carbon/human), range=6, image_prob=25, image_time=20, override=TRUE)
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == INGEST)
					boutput(M, "<span class='alert'><font face='[pick("Arial", "Georgia", "Impact", "Mucida Console", "Symbol", "Tahoma", "Times New Roman", "Verdana")]' size='[rand(3,6)]'>Holy shit, you start tripping balls!</font></span>")
				return

			on_remove()
				. = ..()
				if (ismob(holder.my_atom))
					var/mob/M = holder.my_atom
					if (M.client)
						animate(M.client, color = null, time = 2 SECONDS, easing = SINE_EASING) // gotta come down sometime

		drug/lsd_bee
			name = "lsbee"
			id = "lsd_bee"
			description = "A highly potent hallucinogenic substance. It smells like honey."
			taste = "sweet"
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 235
			fluid_b = 0
			transparency = 100
			value = 5
			thirst_value = -0.03
			contraband = 4.2
			var/static/list/bee_halluc = list(
				new /image('icons/mob/bee.dmi',"zombee-wings") = list("zombee", "undead bee", "BZZZZZZZZ"),
				new /image('icons/mob/bee.dmi',"syndiebee-wings") = list("syndiebee", "evil bee", "syndicate assassin bee", "IT HAS A GUN"),
				new /image('icons/mob/bee.dmi',"bigbee-angry") = list("very angry bee", "extremely angry bee", "GIANT FRICKEN BEE"),
				new /image('icons/mob/bee.dmi',"lichbee-wings") = list("evil bee", "demon bee", "YOU CAN'T BZZZZ FOREVER"),
				new /image('icons/mob/bee.dmi',"voorbees-wings") = list("killer bee", "murder bee", "bad news bee", "RUN"),
			)

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 5)
				var/image/imagekey = pick(bee_halluc)
				if(probmult(33))
					var/list/attackers = M.GetComponents(/datum/component/hallucination/fake_attack)
					if(length(attackers) < 5)
						M.AddComponent(/datum/component/hallucination/fake_attack, timeout=5, image_list=list(imagekey), name_list=bee_halluc[imagekey], attacker_prob=10)
				if (probmult(12))
					M.visible_message(pick("<b>[M]</b> makes a buzzing sound.", "<b>[M]</b> buzzes."),pick("BZZZZZZZZZZZZZZZ", "<span class='alert'><b>THE BUZZING GETS LOUDER</b></span>", "<span class='alert'><b>THE BUZZING WON'T STOP</b></span>"))
				if (probmult(15))
					switch(rand(1,2))
						if(1)
							M.emote("twitch")
						if(2)
							M.emote("scream")
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == INGEST)
					boutput(M, "Your ears start buzzing.")

		drug/space_drugs
			name = "space drugs"
			id = "space_drugs"
			description = "An illegal chemical compound used as a cheap drug."
			reagent_state = LIQUID
			fluid_r = 200
			fluid_g = 185
			fluid_b = 230
			addiction_prob = 15//65
			addiction_min = 10
			depletion_rate = 0.2
			value = 3 // 1c + 1c + 1c
			viscosity = 0.2
			thirst_value = -0.03
			minimum_reaction_temperature = T0C+400

			reaction_temperature(exposed_temperature, exposed_volume)
				var/myvol = volume
				holder.del_reagent(id)
				holder.add_reagent("neurotoxin", myvol, null)

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 15)
				// if(M.canmove && isturf(M.loc))
				// 	step(M, pick(cardinal))
				if (M.canmove && prob(40))
					M.change_misstep_chance(5 * mult)

				if(probmult(7)) M.emote(pick("twitch","drool","moan","giggle"))
				..()
				return

		drug/THC
			name = "tetrahydrocannabinol"
			id = "THC"
			description = "A mild psychoactive chemical extracted from the cannabis plant."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 225
			fluid_b = 0
			transparency = 200
			value = 3
			viscosity = 0.4
			hunger_value = -0.04
			thirst_value = -0.04
			contraband = 1

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.stuttering += rand(0,2)
				if(M.client && probmult(5))
					for (var/obj/critter/domestic_bee/bee in view(7,M))
						var/chat_text = null
						var/text = pick_smart_string("shit_bees_say_when_youre_high.txt", "strings", list("M"="[M]", "beeMom"=bee.beeMom ? bee.beeMom : "Mom", "other_bee"=istype(bee, /obj/critter/domestic_bee/sea) ? "Seabee" : "Spacebee"), bee)
						if(!M.client.preferences.flying_chat_hidden)
							var/speechpopupstyle = "font-family: 'Comic Sans MS'; font-size: 8px;"
							chat_text = make_chat_maptext(bee, text, "color: [rgb(194,190,190)];" + speechpopupstyle, alpha = 140)
						M.show_message("[bee] buzzes \"[text]\"",2, assoc_maptext = chat_text)
						break

				if(probmult(5))
					M.emote(pick("laugh","giggle","smile"))
				if(probmult(5))
					boutput(M, "[pick("You feel hungry.","Your stomach rumbles.","You feel cold.","You feel warm.")]")
				if(prob(4))
					M.change_misstep_chance(10 * mult)
				if (holder.get_reagent_amount(src.id) >= 50 && probmult(25))
					if(prob(10))
						M.drowsyness = 10
				..()
				return

		drug/CBD
			name = "cannabidiol"
			id = "CBD"
			description = "A non-psychoactive phytocannabinoid extracted from the cannabis plant."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 225
			fluid_b = 0
			transparency = 200
			value = 3
			viscosity = 0.4
			hunger_value = -0.04
			thirst_value = 0.03

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(probmult(5))
					M.emote(pick("sigh","yawn","hiccup","cough"))
				if(probmult(5))
					boutput(M, "[pick("You feel peaceful.","You breathe softly.","You feel chill.","You vibe.")]")
				if(probmult(10))
					M.change_misstep_chance(-5)
					M.delStatus("weakened")
				if (holder.get_reagent_amount(src.id) >= 70 && probmult(25))
					if (holder.get_reagent_amount("THC") <= 20)
						M.drowsyness = 10
				if(prob(25))
					M.HealDamage("All", 2 * mult, 0)
				..()
				return

		drug/nicotine
			name = "nicotine"
			id = "nicotine"
			description = "A highly addictive stimulant extracted from the tobacco plant."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 0
			fluid_b = 0
			viscosity = 0.2
			transparency = 190
			addiction_prob = 15//70
			addiction_min = 10
			max_addiction_severity = "LOW"
			overdose = 35 // raise if too low - trying to aim for one sleepypen load being problematic, two being deadlyish
			//var/counter = 1
			//note that nicotine is also horribly poisonous in concentrated form IRM - could be used as a poor-man's toxin?
			//just comment that out if you don't think it's any good.
			// Gonna try this out. Not good for you but won't horribly maim you from taking a quick puff of a cigarette - ISN
			value = 3
			thirst_value = -0.07
			stun_resist = 8

			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_nicotine", 1)
				..()

			on_remove()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_nicotine")
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(probmult(50))
					M.make_jittery(5)

				if(src.volume > src.overdose)
					M.take_toxin_damage(1 * mult)
				..()

			//cogwerks - improved nicotine poisoning?
			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> looks nervous!</span>")
						M.change_misstep_chance(15 * mult)
						M.take_toxin_damage(2 * mult)
						M.make_jittery(10)
						M.emote("twitch")
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]</b> is all sweaty!</span>")
						M.bodytemperature += rand(15,30) * mult
						M.take_toxin_damage(3 * mult)
					else if (effect <= 7)
						M.take_toxin_damage(4 * mult)
						M.emote("twitch_v")
						M.make_jittery(10)
				else if (severity == 2)
					if (effect <= 2)
						M.emote("gasp")
						boutput(M, "<span class='alert'><b>You can't breathe!</b></span>")
						M.take_oxygen_deprivation(15 * mult)
						M.take_toxin_damage(3 * mult)
						M.setStatus("stunned", max(M.getStatusDuration("stunned"), 1 SECOND * mult))
					else if (effect <= 4)
						boutput(M, "<span class='alert'><b>You feel terrible!</b></span>")
						M.emote("drool")
						M.make_jittery(10)
						M.take_toxin_damage(5 * mult)
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 1 SECOND * mult))
						M.change_misstep_chance(33 * mult)
					else if (effect <= 7)
						M.emote("collapse")
						boutput(M, "<span class='alert'><b>Your heart is pounding!</b></span>")
						M << sound('sound/effects/heartbeat.ogg')
						M.setStatus("paralysis", max(M.getStatusDuration("paralysis"), 5 SECONDS * mult))
						M.make_jittery(30)
						M.take_toxin_damage(6 * mult)
						M.take_oxygen_deprivation(20 * mult)

		drug/nicotine/nicotine2
			name = "nicotwaine"
			id = "nicotine2"
			description = "A highly addictive stimulant derived from the twobacco plant."
			addiction_prob = 100
			overdose = 70
			stun_resist = 11
			contraband = 2

			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_nicotine2", 3)
				..()

			on_remove()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_nicotine2")
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					if (H.sims)
						H.sims.affectMotive("fun", 2)
				if(probmult(75))
					M.make_jittery(10)
				if(probmult(25))
					M.emote(pick("drool","shudder","groan","moan","shiver"))
					boutput(M, "<span class='success'><b>You feel... pretty good... and calm... weird.</b></span>")
				if(probmult(10))
					M.make_jittery(20)
					M.emote(pick("twitch","twitch_v","shiver","shudder","flinch","blink_r"))
					boutput(M, "<span class='alert'><b>You can feel your heartbeat in your throat!</b></span>")
					M.playsound_local(M.loc, 'sound/effects/heartbeat.ogg', 50, 1)
					M.take_toxin_damage(2)
				if(probmult(5))
					M.delStatus("paralysis")
					M.delStatus("stunned")
					M.delStatus("weakened")
					M.delStatus("paralysis")
					M.sleeping = 0
					M.make_jittery(30)
					M.emote(pick("twitch","twitch_v","shiver","shudder","flinch","blink_r"))
					boutput(M, "<span class='alert'><b>Your heart's beating really really fast!</b></span>")
					M.playsound_local(M.loc, 'sound/effects/heartbeat.ogg', 50, 1)
					M.take_toxin_damage(4)
				if(src.volume > src.overdose)
					M.take_toxin_damage(2)
				..(M)

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				..()
				..()
				/*var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> looks really nervous!</span>")
						boutput(M, "<span class='alert'><b>You feel really nervous!</b></span>")
						M.change_misstep_chance(30)
						M.take_toxin_damage(3)
						M.make_jittery(20)
						M.emote("twitch")
						M.emote("twitch")
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]</b> is super sweaty!</span>")
						boutput(M, "<span class='alert'><b>You feel hot! Is it hot in here?!</b></span>")
						M.bodytemperature += rand(30,60)
						M.take_toxin_damage(4)
					else if (effect <= 7)
						M.take_toxin_damage(5)
						M.emote("twitch_v")
						M.emote("twitch_v")
						M.make_jittery(20)
				else if (severity == 2)
					if (effect <= 2)
						M.emote("gasp")
						M.emote("gasp")
						boutput(M, "<span class='alert'><b>You really can't breathe!</b></span>")
						M.take_oxygen_deprivation(15)
						M.take_toxin_damage(4)
						M.changeStatus("stunned", 10 * mult)
					else if (effect <= 4)
						boutput(M, "<span class='alert'><b>You feel really terrible!</b></span>")
						M.emote("drool")
						M.emote("drool")
						M.make_jittery(20)
						M.take_toxin_damage(5)
						M.changeStatus("weakened", 10 * mult)
						M.change_misstep_chance(66)
					else if (effect <= 7)
						M.emote("collapse")
						boutput(M, "<span class='alert'><b>Your heart is pounding! You need help!</b></span>")
						M << sound('sound/effects/heartbeat.ogg')
						M.changeStatus("weakened", 50 * mult)
						M.make_jittery(60)
						M.take_toxin_damage(5)
						M.take_oxygen_deprivation(20)*/

		drug/psilocybin
			name = "psilocybin"
			id = "psilocybin"
			description = "A powerful hallucinogenic chemical produced by certain mushrooms."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 230
			fluid_b = 200
			transparency = 200
			value = 3
			viscosity = 0.1
			thirst_value = -0.3
			contraband = 4

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 15)
				if(probmult(8))
					boutput(M, "<b>You hear a voice in your head... <i>[phrase_log.random_phrase("say")]</i></b>")
				if(probmult(8))
					M.emote(pick("scream","cry","laugh","moan","shiver"))
				if(probmult(3))
					switch (rand(1,3))
						if(1)
							boutput(M, "<B>The Emergency Shuttle has docked with the station! You have 3 minutes to board the Emergency Shuttle.</B>")
						if(2)
							boutput(M, "<span class='alert'><b>Restarting world!</b> </span><span class='notice'>Initiated by Administrator!</span>")
							SPAWN_DBG(2 SECONDS) M.playsound_local(M.loc, pick('sound/misc/NewRound.ogg', 'sound/misc/NewRound2.ogg', 'sound/misc/NewRound3.ogg', 'sound/misc/NewRound4.ogg', 'sound/misc/TimeForANewRound.ogg'), 50, 1)
						if(3)
							switch (rand(1,4))
								if(1)
									boutput(M, "<span class='alert'><b>Unknown fires the revolver at [M]!</b></span>")
									M.playsound_local(M.loc, 'sound/weapons/Gunshot.ogg', 50, 1)
								if(2)
									boutput(M, "<span class='alert'><b>[M] has been attacked with the fire extinguisher by Unknown</b></span>")
									M.playsound_local(M.loc, 'sound/impact_sounds/Metal_Hit_1.ogg', 50, 1)
								if(3)
									boutput(M, "<span class='alert'><b>Unknown has punched [M]</b></span>")
									boutput(M, "<span class='alert'><b>Unknown has weakened [M]</b></span>")
									M.setStatus("weakened", max(M.getStatusDuration("weakened"), 1 SECOND))
									M.playsound_local(M.loc, pick(sounds_punch), 50, 1)
								if(4)
									boutput(M, "<span class='alert'><b>[M] has been attacked with the taser gun by Unknown</b></span>")
									boutput(M, "<i>You can almost hear someone talking...</i>")
									M.setStatus("paralysis", max(M.getStatusDuration("paralysis"), 3 SECONDS))
				..()


		drug/krokodil
			name = "krokodil"
			id = "krokodil"
			description = "A sketchy homemade opiate, often used by disgruntled Cosmonauts."
			reagent_state = SOLID
			fluid_r = 0
			fluid_g = 100
			fluid_b = 180
			transparency = 250
			addiction_prob = 10//50
			addiction_min = 10
			overdose = 20
			hunger_value = -0.1
			thirst_value = -0.09
			contraband = 7
			var/fake_health = 40

			on_remove()
				src.fake_health = 40
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_MOB_PROPERTY(M, PROP_FAKEHEALTH_MAX, "krokodil")
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.jitteriness -= 40
				src.fake_health += mult
				if(prob(25))
					M.take_brain_damage(1 * mult)
					src.fake_health += 3 * mult
				if(probmult(15))
					M.emote(pick("smile", "grin", "yawn", "laugh", "drool"))
				if(prob(10))
					boutput(M, "<span class='notice'><b>You feel pretty chill.</b></span>")
					M.bodytemperature -= 1 * mult
					M.emote("smile")
					src.fake_health += 3 * mult
				if(prob(5))
					boutput(M, "<span class='alert'><b>You feel too chill!</b></span>")
					M.emote(pick("yawn", "drool"))
					M.setStatus("stunned", max(M.getStatusDuration("stunned"), 2 SECONDS * mult))
					M.take_toxin_damage(1 * mult)
					M.take_brain_damage(1 * mult)
					M.bodytemperature -= 20 * mult
				if(prob(2))
					boutput(M, "<span class='alert'><b>Your skin feels all rough and dry.</b></span>")
					random_brute_damage(M, 2 * mult)
				APPLY_MOB_PROPERTY(M, PROP_FAKEHEALTH_MAX, "krokodil", src.fake_health)
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				src.fake_health += severity * 4
				if (severity == 1)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> looks dazed!</span>")
						M.setStatus("stunned", max(M.getStatusDuration("stunned"), 4 SECONDS))
						M.emote("drool")
					else if (effect <= 4)
						M.emote("shiver")
						M.bodytemperature -= 40 * mult
					else if (effect <= 7)
						boutput(M, "<span class='alert'><b>Your skin is cracking and bleeding!</b></span>")
						random_brute_damage(M, 5 * mult)
						M.take_toxin_damage(2 * mult)
						M.take_brain_damage(1 * mult)
						M.emote("cry")
				else if (severity == 2)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> sways and falls over!</span>")
						M.take_toxin_damage(3 * mult)
						M.take_brain_damage(3 * mult)
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 9 SECONDS * mult))
						M.emote("faint")
					else if (effect <= 4)
						if(ishuman(M))
							M.visible_message("<span class='alert'><b>[M.name]'s</b> skin is rotting away!</span>")
							random_brute_damage(M, 25 * mult)
							M.emote("scream")
							M.bioHolder.AddEffect("eaten") //grody. changed line in human.dm to use decomp1 now
							M.emote("faint")
					else if (effect <= 7)
						M.emote("shiver")
						M.bodytemperature -= 70 * mult

		drug/catdrugs
			name = "cat drugs"
			id = "catdrugs"
			description = "Uhhh..."
			reagent_state = LIQUID
			fluid_r = 200
			fluid_g = 200
			fluid_b = 0
			transparency = 20
			viscosity = 0.14
			thirst_value = -0.1
			contraband = 2
			var/static/list/cat_halluc = list(
				new /image('icons/mob/critter.dmi',"cat-ghost") = list("ghost cat"),
				new /image('icons/mob/critter.dmi', "cat1-wild") = list("wild cat"),
			)
			var/static/list/cat_sounds = list('sound/voice/animal/cat.ogg', 'sound/voice/animal/cat_hiss.ogg')

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 15)
				if(probmult(11))
					M.visible_message("<span class='notice'><b>[M.name]</b> hisses!</span>")
					playsound(M.loc, "sound/voice/animal/cat_hiss.ogg", 50, 1)
				if(probmult(9))
					M.visible_message("<span class='notice'><b>[M.name]</b> meows! What the fuck?</span>")
					playsound(M.loc, 'sound/voice/animal/cat.ogg', 50, 1)

				var/image/imagekey = pick(cat_halluc)
				if(probmult(40)) //get attacked
					var/list/attackers = M.GetComponents(/datum/component/hallucination/fake_attack)
					if(length(attackers) < 2)
						M.AddComponent(/datum/component/hallucination/fake_attack, timeout=10, image_list=list(imagekey), name_list=cat_halluc[imagekey], attacker_prob=7, max_attackers=1)
				M.AddComponent(/datum/component/hallucination/random_sound, timeout=10, sound_list=src.cat_sounds, sound_prob=20)
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == INGEST)
					M.playsound_local(M.loc, pick('sound/voice/animal/cat.ogg', 'sound/voice/animal/cat_hiss.ogg'), 50, 1)
					boutput(M, "<span class='alert'><font face='[pick("Arial", "Georgia", "Impact", "Mucida Console", "Symbol", "Tahoma", "Times New Roman", "Verdana")]' size='[rand(3,6)]'>Holy shit, you start tripping balls!</font></span>")
				return

		drug/batdrugs
			name = "bat drugs"
			id = "batdrugs"
			description = "Uhhh..."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 0
			fluid_b = 0
			transparency = 20
			viscosity = 0.14
			thirst_value = -0.1
			contraband = 2
			var/static/list/bat_halluc = list(
				new /image('icons/mob/critter.dmi',"bat-dance") = list("ghost bat"),
				new /image('icons/mob/critter.dmi', "scarybat-dance") = list("wild bat"),
			)
			var/static/list/bat_sounds = list('sound/voice/animal/batsqueak.ogg')

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 15)
				if(probmult(11))
					M.visible_message("<span class='notice'><b>[M.name]</b> screeches!</span>")
					playsound(M.loc, 'sound/voice/animal/batsqueak.ogg', 40, 1, 2)
				if(probmult(9))
					M.visible_message("<span class='notice'><b>[M.name]</b> squeaks! What the fuck?</span>")
					playsound(M.loc, "sound/voice/animal/batsqueak.ogg", 40, 1, 2)

				var/image/imagekey = pick(bat_halluc)
				if(probmult(40)) //get attacked
					var/list/attackers = M.GetComponents(/datum/component/hallucination/fake_attack)
					if(length(attackers) < 2)
						M.AddComponent(/datum/component/hallucination/fake_attack, timeout=10, image_list=list(imagekey), name_list=bat_halluc[imagekey], attacker_prob=7, max_attackers=1)
				M.AddComponent(/datum/component/hallucination/random_sound, timeout=10, sound_list=src.bat_sounds, sound_prob=20)
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == INGEST)
					M.playsound_local(M.loc, 'sound/voice/animal/batsqueak.ogg', 50, 1)
					boutput(M, "<span class='alert'><font face='[pick("Arial", "Georgia", "Impact", "Mucida Console", "Symbol", "Tahoma", "Times New Roman", "Verdana")]' size='[rand(3,6)]'>Holy shit, you start tripping balls!</font></span>")
				return

		drug/triplemeth
			name = "triple meth"
			id = "triplemeth"
			description = "Hot damn ... i don't even ..."
			reagent_state = SOLID
			fluid_r = 250
			fluid_g = 250
			fluid_b = 250
			transparency = 220
			addiction_prob = 100
			addiction_min = 0
			overdose = 20
			depletion_rate = 0.2
			value = 39 // 13c * 3  :v
			energy_value = 3
			bladder_value = -0.1
			hunger_value = -0.3
			thirst_value = -0.2
			contraband = 18

			on_remove()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "triplemeth")
					M.remove_stun_resist_mod("triplemeth")

				if(hascall(holder.my_atom,"removeOverlayComposition"))
					holder.my_atom:removeOverlayComposition(/datum/overlayComposition/triplemeth)
				..()


			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom

				if(holder.has_reagent("methamphetamine")) return ..() //Since is created by a meth overdose, dont react while meth is in their system.
				M.add_stun_resist_mod("triplemeth", 98)
				APPLY_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "triplemeth", 100)

				if(hascall(holder.my_atom,"addOverlayComposition"))
					holder.my_atom:addOverlayComposition(/datum/overlayComposition/triplemeth)

				if(probmult(50)) M.emote(pick("twitch","blink_r","shiver"))
				M.make_jittery(5)
				M.make_dizzy(5 * mult)
				M.change_misstep_chance(15 * mult)
				M.take_brain_damage(1 * mult)
				M.delStatus("disorient")
				if(M.sleeping) M.sleeping = 0
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if(holder.has_reagent("methamphetamine")) return ..() //Since is created by a meth overdose, dont react while meth is in their system.
				if (severity == 1)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> can't seem to control their legs!</span>")
						M.change_misstep_chance(12 * mult)
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 5 SECONDS * mult))
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]'s</b> hands flip out and flail everywhere!</span>")
						M.drop_item()
						M.hand = !M.hand
						M.drop_item()
						M.hand = !M.hand
					else if (effect <= 7)
						M.emote("laugh")
				else if (severity == 2)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]'s</b> hands flip out and flail everywhere!</span>")
						M.drop_item()
						M.hand = !M.hand
						M.drop_item()
						M.hand = !M.hand
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]</b> falls to the floor and flails uncontrollably!</span>")
						M.make_jittery(10)
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 10 SECONDS * mult))
					else if (effect <= 7)
						M.emote("laugh")

		drug/methamphetamine // // COGWERKS CHEM REVISION PROJECT. marked for revision
			name = "methamphetamine"
			id = "methamphetamine"
			description = "Methamphetamine is a highly effective and dangerous stimulant drug."
			reagent_state = SOLID
			fluid_r = 250
			fluid_g = 250
			fluid_b = 250
			transparency = 220
			addiction_prob = 10//60
			addiction_min = 5
			overdose = 20
			depletion_rate = 0.6
			value = 13 // 9c + 1c + 1c + 1c + heat
			energy_value = 1.5
			bladder_value = -0.09
			hunger_value = -0.09
			thirst_value = -0.09
			stun_resist = 50
			contraband = 6

			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_methamphetamine", 3)
				if (ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_MOVEMENT_MODIFIER(M, /datum/movement_modifier/reagent/energydrink, src.type)
				..()

			on_remove()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "r_methamphetamine")
				if(holder && ismob(holder.my_atom))
					holder.del_reagent("triplemeth")
				if (ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_MOVEMENT_MODIFIER(M, /datum/movement_modifier/reagent/energydrink, src.type)
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(probmult(5)) M.emote(pick("twitch","blink_r","shiver"))
				M.make_jittery(5)
				M.drowsyness = max(M.drowsyness-10, 0)
				if(M.sleeping) M.sleeping = 0
				if(prob(50))
					M.take_brain_damage(1 * mult)
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> can't seem to control their legs!</span>")
						M.change_misstep_chance(20 * mult)
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 5 SECONDS * mult))
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]'s</b> hands flip out and flail everywhere!</span>")
						M.drop_item()
						M.hand = !M.hand
						M.drop_item()
						M.hand = !M.hand
					else if (effect <= 7)
						M.emote("laugh")
				else if (severity == 2)

					if(!holder.has_reagent("triplemeth", 10 * mult))
						holder.add_reagent("triplemeth", 10 * mult, null)
						M.add_karma(10)

					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]'s</b> hands flip out and flail everywhere!</span>")
						M.drop_item()
						M.hand = !M.hand
						M.drop_item()
						M.hand = !M.hand
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]</b> falls to the floor and flails uncontrollably!</span>")
						M.make_jittery(10)
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 2 SECONDS * mult))
					else if (effect <= 7)
						M.emote("laugh")

		drug/hellshroom_extract
			name = "Hellshroom extract"
			id = "hellshroom_extract"
			description = "TEMP"
			reagent_state = SOLID
			fluid_r = 163
			fluid_g = 17
			fluid_b = 63
			transparency = 100
			depletion_rate = 0.3
			contraband = 13

			on_mob_life(var/mob/M, var/mult = 1) // commence bad times
				if(!M) M = holder.my_atom
				if(ishuman(M))
					var/mob/living/carbon/human/K = M
					if (K.sims)
						K.sims.affectMotive("Energy", 2)
						K.sims.affectMotive("fun", 1)
						K.sims.affectMotive("Bladder", -0.5)
						K.sims.affectMotive("Hunger", -1)
						K.sims.affectMotive("Thirst", -2)
				var/mob/living/H = M
				var/check = rand(0,100)
				if (istype(H))
					if (M.reagents.has_reagent("milk"))
						boutput(M, "<span class='notice'>The milk stops the burning. Ahhh.</span>")
						M.reagents.del_reagent("milk")
						M.reagents.del_reagent("hellshroom_extract")
					if (check < 20)
						src.breathefire(M)
					if(check < 5)
						var/bats = rand(2,3)
						M.AddComponent(/datum/component/hallucination/fake_attack, timeout=10, image_list=list(new /image('icons/misc/AzungarAdventure.dmi', "hellbat")), name_list=list("hellbat"), attacker_prob=100, max_attackers=bats)
						boutput(M, "<span class='alert'><b>A hellbat begins to chase you</b>!</span>")
						M.emote("scream")
					if(check < 20)
						boutput(M, "<span class='alert'><b>Oh god! Oh GODD!!</b></span>")
					if(check < 20)
						boutput(M, "<span class='alert'><b>You feel like you are melting from the inside!</b></span>")
					if(check < 20)
						boutput(M, "<span class='alert'>Your throat feels like it's on fire!</span>")
						M.emote(pick("scream","cry","twitch_s","choke","gasp","grumble"))
						M.changeStatus("paralysis", 2 SECONDS)
					if(check < 20)
						boutput(M, "<span class='notice'><b>You feel A LOT warmer.</b></span>")
						M.bodytemperature += rand(30,60)
				..()
				return

datum/reagent/drug/hellshroom_extract/proc/breathefire(var/mob/M)
	var/temp = 3000
	var/range = 1

	var/turf/T = get_step(M,M.dir)
	T = get_step(T,M.dir)
	var/list/affected_turfs = getline(M, T)

	M.visible_message("<span class='alert'><b>[M] burps a stream of fire!</b></span>")
	playsound(M.loc, "sound/effects/mag_fireballlaunch.ogg", 30, 0)

	var/turf/currentturf
	var/turf/previousturf
	for(var/turf/F in affected_turfs)
		previousturf = currentturf
		currentturf = F
		if(currentturf.density || istype(currentturf, /turf/space))
			break
		if(previousturf && LinkBlocked(previousturf, currentturf))
			break
		if (F == get_turf(M))
			continue
		if (get_dist(M,F) > range)
			continue
		tfireflash(F,1,temp)
