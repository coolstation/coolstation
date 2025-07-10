
// This file is designed to hold all the core tgui assets we need to possibly send to people.

/// Group for tgui assets
/datum/asset/group/base_tgui
	subassets = list(
		/datum/asset/basic/tgui,
		/datum/asset/basic/fontawesome
	)

/// Normal base window tgui assets
/// Now uses full pathnames separated by dashes
/// Should help improve local/live consistency
/datum/asset/basic/tgui
	local_assets = list(
		"browserassets-tgui-tgui.bundle.js",
		"browserassets-tgui-tgui.bundle.css"
	)

	init()
		. = ..()
		url_map = list(
			"tgui/tgui.bundle.js" = "[resource("tgui/tgui.bundle.js")]",
			"tgui/tgui.bundle.css" = "[resource("tgui/tgui.bundle.css")]"
		)

/// tgui panel specific assets
/datum/asset/basic/tgui_panel
	local_assets = list(
		"browserassets-tgui-tgui-panel.bundle.js",
		"browserassets-tgui-tgui-panel.bundle.css"
	)

	init()
		. = ..()
		url_map = list(
			"tgui/tgui-panel.bundle.js" = "[resource("tgui/tgui-panel.bundle.js")]",
			"tgui/tgui-panel.bundle.css" = "[resource("tgui/tgui-panel.bundle.css")]"
		)

/// Fontawesome assets
/datum/asset/basic/fontawesome
	local_assets = list(
		"browserassets-css-tgui-all.min.css",
		"browserassets-css-fonts-fa-regular-400.eot",
		"browserassets-css-fonts-fa-regular-400.woff",
		"browserassets-css-fonts-fa-solid-900.eot",
		"browserassets-css-fonts-fa-solid-900.woff"
	)

	url_map = list(
		"all.min.css" = "http://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.14.0/css/all.min.css"
	)
