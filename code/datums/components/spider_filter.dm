var/global/list/image/spider_filter_images

/datum/component/spider_filter_item
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/image/filter_image

/datum/component/spider_filter_item/Initialize()
	SHOULD_CALL_PARENT(1)
	..()

	src.filter_image = image('icons/effects/spider_filter.dmi', null, "pider")
	src.filter_image.override = 1

	if(isnull(global.spider_filter_images))
		global.spider_filter_images = list()

	global.spider_filter_images += src.filter_image
	for(var/thing as anything in by_cat[TR_CAT_SPIDER_FILTER_MOBS])
		if(ismob(thing))
			var/mob/M = thing
			M?.client?.images += src.filter_image
		if(isclient(thing))
			var/client/C = thing
			C?.images += src.filter_image

	src.filter_image.loc = parent

/datum/component/spider_filter_item/disposing()
	global.spider_filter_images -= src.filter_image
	for(var/thing as anything in by_cat[TR_CAT_SPIDER_FILTER_MOBS])
		if(ismob(thing))
			var/mob/M = thing
			M.client?.images -= src.filter_image
		if(isclient(thing))
			var/client/C = thing
			C?.images -= src.filter_image
	qdel(src.filter_image)
	. = ..()

// todo: persist this pref? arachnophobia etc
/mob/verb/hide_spiders()
	set desc = "Replace spiders with a text 'SPIDER' icon"
	set name = "Toggle Spiders (arachnophobe mode)"

	var/client/client = src.client

	if(!client || !client.preferences)
		return

	if(!client.preferences.hidden_spiders)
		client.preferences.hidden_spiders = TRUE
		OTHER_START_TRACKING_CAT(client, TR_CAT_SPIDER_FILTER_MOBS)
		for(var/image/I as anything in global.spider_filter_images)
			src.client.images += I
		boutput(src, "<span class='notice'>Spiders <b>Hidden</b>. They can still hurt you.</span>")
	else
		client.preferences.hidden_spiders = FALSE
		OTHER_STOP_TRACKING_CAT(client, TR_CAT_SPIDER_FILTER_MOBS)
		for(var/image/I as anything in global.spider_filter_images)
			src.client.images -= I
		boutput(src, "<span class='notice'>Spiders <b>Unhidden</b>.</span>")
