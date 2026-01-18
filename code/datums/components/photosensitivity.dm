/mob/verb/set_photosensitivity()
	set desc = "Disable SOME eyestrain-inducing effects. May not adequately protect all users."
	set name = "Toggle Photosensitivity (best effort)"

	var/client/client = src.client

	if(!client || !client.preferences)
		return

	if(!client.preferences.photosensitive)
		client.preferences.photosensitive = TRUE
		OTHER_START_TRACKING_CAT(client, TR_CAT_PHOTOSENSITIVE_MOBS)

		boutput(src, "<span class='notice'>Eyestrain effects reduced. Please remember to take breaks.</span>")
	else
		client.preferences.photosensitive = FALSE
		OTHER_STOP_TRACKING_CAT(client, TR_CAT_PHOTOSENSITIVE_MOBS)

		boutput(src, "<span class='notice'>Eyestrain effects restored.</span>")
