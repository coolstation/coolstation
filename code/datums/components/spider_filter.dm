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
	for(var/mob/M as anything in by_cat[TR_CAT_SPIDER_FILTER_MOBS])
		M.client?.images += src.filter_image

	src.filter_image.loc = parent

/datum/component/spider_filter_item/disposing()
	global.spider_filter_images -= src.filter_image
	for(var/mob/M as anything in by_cat[TR_CAT_SPIDER_FILTER_MOBS])
		M.client?.images -= src.filter_image
	qdel(src.filter_image)
	. = ..()
