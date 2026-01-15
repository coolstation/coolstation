#define VIEW_HEIGHT 480

/datum/hud/funimage
	click_check = 0

	New(var/icon/I)
		var/imheught = I.Height()
		if(imheught > VIEW_HEIGHT)
			var/newscale = (VIEW_HEIGHT)/(imheught)
			var/newwidth = round(I.Width()*newscale)
			I.Scale(newwidth,VIEW_HEIGHT)

		create_screen("image", "Fun Image (click to remove)", I, "", "1, 1", HUD_LAYER_3)
		..()

	relay_click(id, mob/user)
		if (id == "image")
			remove_client(user.client)


#undef VIEW_HEIGHT
