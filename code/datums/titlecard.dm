//new titlecard, which uses a fancy HTML overlay kinda deal
//this is shown to the client as a browser window instead of an in-world object or turf overlay like the classic way

/datum/titlecard
	var/global/list/maptext_areas = list()
	var/global/last_pregame_html = ""

	var/is_game_mode = FALSE //tied to a game mode modifier?
	//var/notice = "" //anything a map or situation should announce?
	var/add_html = "" //any little bonus stuff you need to stick in the middle (like credits)

	var/overlay_image_url = null

	/*/should make a static fallback for videos....
	#if defined(MAP_OVERRIDE_BOBMAP)
	var/image_url = "images/titlecards/console.gif"
	var/video_url = "images/titlecards/console.mp4"
	var/is_video = FALSE
	#elif defined(MAP_OVERRIDE_GEHENNA) //quick and easy signifier to see if your secrets submodule is active and working
	//var/image_url = "images/titlecards/coolstation.gif"
	var/image_url = "images/titlecards/console.gif"
	var/video_url = "images/titlecards/coolstation.mp4"
	var/is_video = FALSE
	#else*/
	var/image_url = "images/titlecards/console.gif"
	var/video_url = "images/titlecards/console.mp4"
	var/is_video = FALSE
	//#endif

	#if defined(SECRETS_ENABLED) //quick and easy signifier to see if your secrets submodule is active and working
	add_html = "<span style=\"position:fixed;bottom:3px;right:3px;color:white;opacity:0.5;font-size:75%;\">Secrets enabled!</span>"
	#endif

	//add a permanent disclaimer to the top
	var/disclaimer_text = {"<span style="font-size:120%;"><b>PHOTOSENSITIVITY WARNING</b>: <br>
							This game has sudden flashing lights and rapidly cycling colors which cannot be disabled.</span><br>"}

	//basic ground rules for new players
	var/agreement_text = {"
							<span style="font-size:bigger"><b>PHOTOSENSITIVITY WARNING</b>: This game has sudden flashing lights and rapidly cycling colors that cannot be disabled.
							If you are sensitive to motion graphics or certain patterns, please use discretion or do not play this game.</span>
							<br>
							<font color="#4F5FFF">content warning:</font><br>
							This game contains violence, suicide, gun's, drugs, alcohol and spiders,<br>
							all depicted in a non-serious or (relatively) non-graphic way.<br>
							This game also contains farting, screaming, gibs, <font color="#7B3F00">poo</font>,<br>
							explosions, gas station boner pills, and <font color="red">It</font>ali<font color="green">ans</font>, in a super serious way.<br>
							Also this is an 18+ server. You must be at least 18 years old to play here. Not for erotic themes, but because this is a space station for adults.<br>

							To play on this server you must abide by the <a href=\"byond://winset?command=Rules\">Rules</a>.<br>"}

	//novelty items
	var/agreement_background_url = "images/titlecards/agreement/bg-combo.png" //background
	var/agreement_headerleft_url = "images/titlecards/agreement/toot.gif" //thing what floats on the left side of the header
	var/agreement_headerright_url = "images/titlecards/agreement/bwomp.gif" //thing what floats on the right side of the header
	var/agreement_overlay_url = "images/titlecards/agreement/handshake.png" //overlay to the whole thing (use an alpha-transparent png)
	var/agreement_yesbutton_url = "images/titlecards/agreement/comicsans-yes.png" //agree button
	var/agreement_nobutton_url = "images/titlecards/agreement/comicsans-no.png" //disagree button
	var/agreement_buttonspacer_url = "images/titlecards/agreement/honk.gif" //button spacer


	//a few assorted titlescreens (TODO: expand and make selectable)
	dev //starfield

		video_url = "images/titlecards/coolstation_dev_alt.mp4"
		is_video = TRUE

	classic //signpost
		image_url = "images/titlecards/classic.gif"

	disaster
		overlay_image_url = "images/titlecards/disaster.gif"
		is_game_mode = TRUE

	heisenbee //cute illustration of sleeping heisenbee with carnage in the background
		image_url = "images/titlecards/heisenbee.png"
		//clickable credit line
		add_html = {"<a href="https://www.deviantart.com/alexbluebird" target="_blank" style="position:absolute;bottom:3px;right:3px;color:white;opacity:0.7;">by AlexBlueBird</a>"}

	battleroyale //overlays a battle royal edition thing in addition to the standard titlecard
		overlay_image_url = "images/titlecards/battleroyale_overlay.png"
		is_game_mode = TRUE

	thebadgif //the really bad stock gifs one bob made
		image_url = "images/titlecards/bob.gif"

/datum/titlecard/proc/set_pregame_html()
	//fuck u i'm breaking this out so you can actually read it
	//Set styles + fill page with image as background
	//The actual overlay image you see isn't called as an explicit item, but visible due to the absence of items
	//What a concept, huh?
	last_pregame_html =	{"
		<html>
			<head>
				<meta http-equiv='X-UA-Compatible' content='IE=edge'>
				<style>@font-face{
					font-family:'PxPlus IBM VGA9';
					src:url([resource("misc/ibmvga9.ttf")]);
					}
					body,#overlay{
						margin:0;
						padding:0;
						background:url([resource(src.image_url)]) black;
						background-size:contain;
						background-repeat:no-repeat;
						overflow:hidden;
						background-position:center center;
						background-attachment:fixed;
						image-rendering:pixelated;
					}
		"}
	//Add an overlay by defining an image for the otherwise empty and ever-present overlay-ID'd div
	//(or not, in this case, because null is first)
	if (isnull(src.overlay_image_url))
		last_pregame_html += {"
					#overlay{
						display:none;
					}
		"}
	else
		last_pregame_html += {"
					#overlay{
						background-image:url(src.overlay_image_url)]);
						background-color:transparent;
						left:0;
						top:0;
						right:0;
						bottom:0;
						position:fixed;
					}
		"}
	//add content and photosensitivity warnings
	if (isnull(src.disclaimer_text))
		last_pregame_html += {"
					#disclaimer{
						display:none;
					}
		"}
	else
		last_pregame_html += {"
					#disclaimer{
						text-align:center;
						color:#fff;
						text-shadow: -1px -1px 0 #777, 1px -1px 0 #777, -1px 1px 0 #777, 1px 1px 0 #777;
						font:1.2em 'PxPlus IBM VGA9';
						font-size:75%;
						margin-top:10px;
						top:0;
						height:12%;
						width:100%;
						z-index:10;
					}
		"}
	if (src.is_video)
		last_pregame_html += {"
					.pregamevideo{
						position: absolute;
						right: 0;
						bottom: 0;
						min-width: 100%;
						min-height: 100%;
						width: auto;
						height: auto;
						z-index: -100;
						background-size: cover;
						overflow: hidden;
					}
		"}
	else
		last_pregame_html += {"
					#video{
						display:none;
					}
		"}
	//The rest of the structure of the browser overlay including content spaces
	last_pregame_html += {"
					.area{
						white-space:pre;
						color:#fff;
						text-shadow: -2px -2px 0 #000, 2px -2px 0 #000, -2px 2px 0 #000, 2px 2px 0 #000;
						font:1.2em 'PxPlus IBM VGA9';
						-webkit-text-stroke:0.3px black;
					}
					a{
						text-decoration:none;
					}
					#leftside{
						position:fixed;
						left:2%;
						bottom:2%;
						text-align:center;
					}
					#status,#timer{
						right:5%;
						position:fixed;
						right:5%;

						width:auto;
						text-align:center;
					}
					#status{
						bottom:2%;
					}
					#timer{
						text-align:center;
						bottom: 8%;
					}
				</style>
			</head>
			<body>
				<script>
					document.onclick=function(){location="byond://winset?id=mapwindow.map&focus=true";};
					function set_area(id,text){document.getElementById(id).innerHTML=text||"";};
					onresize=function(){document.body.style.fontSize=Math.min(innerWidth/672,innerHeight/480)*16+"px";};
					onload=function(){onresize();location="byond://winset?command=.send-lobby-text";};
				</script>
				<div id="video">
		"}

	if (src.is_video)
		last_pregame_html += {"
					<video autoplay loop class="pregamevideo">
						<source src="[resource(src.video_url)]" type="video/mp4">
					</video>
		"}

	if (src.disclaimer_text)
		last_pregame_html += {"
					</div>
					<div id="disclaimer">
					[src.disclaimer_text]
					<div id="overlay">
					</div>
			"}

	last_pregame_html += {"
				[src.add_html]
				<div id="status" class="area">
				</div>
				<div id="timer" class="area">
				</div>
				<div id="leftside" class="area">
				</div>
			</body>
		</html>
		"}
	pregameHTML = last_pregame_html

	//now that it's ready, let's show it to everybody
	for(var/client/C)
		if(istype(C.mob, /mob/new_player))
			//if(C.player.rounds_participated > 5 || C.holder)
			//	C << browse(pregameHTML, "window=pregameBrowser")
			//else
			//	C << browse(newplayerHTML, "window=pregameBrowser")
			C << browse(pregameHTML, "window=pregameBrowser")
			if(C)
				winshow(C, "pregameBrowser", 1)

/datum/titlecard/proc/set_agreement_html()
	//basically one big "hey are you 18+ and will you follow the rules + yes no buttons"
	//not contextual or overlaid or anything and will not display game info until clicked through
	//but i will probably move this to its own separate file and load from that later
	//keeps but hides the status/countdown divs so maptext doesn't barf errors
	//overlay is set up but hidden because we need either CSS4 or some Javascript to do clickthrough (add it back with a named div at the top of the divs)
	newplayerHTML =	{"
		<html>
			<head>
				<meta http-equiv='X-UA-Compatible' content='IE=edge'>
				<style>
					body{
						margin:0;
						padding:0;
						background:url([resource(src.agreement_background_url)]) black;
						background-size:100% auto;
						background-repeat:no-repeat;
						background-attachment:fixed;
						image-rendering:pixelated;
						color:#fff;
						font-family: "Comic Sans", "Comic Sans MS", "Chalkboard", "ChalkboardSE-Regular", "Marker Felt", "Purisa", "URW Chancery L", cursive, sans-serif;
						font-size:small;
						text-align:center;
					}
					#overlay{
						background:url([resource(src.agreement_overlay_url)]);
						background-color:transparent;
						background-size:100% auto;
						background-repeat:no-repeat;
						background-attachment:fixed;
						margin:0;
						padding:0;
						left:0;
						top:0;
						right:0;
						bottom:0;
						position:fixed;
						overflow:hidden;
						image-rendering:pixelated;
						z-index:1;
					}
					.area{
						white-space:pre;
						color:#fff;
						text-shadow: -2px -2px 0 #000, 2px -2px 0 #000, -2px 2px 0 #000, 2px 2px 0 #000;
						font:1em 'PxPlus IBM VGA9';
						-webkit-text-stroke:0.3px black;
					}
					a{
						text-decoration:none;
					}
					h1{
						color:red;
						text-shadow: -2px -2px 0 #700, 2px -2px 0 #700, -2px 2px 0 #700, 2px 2px 0 #700;
					}
					#disclaimer{
						text-shadow: -1px -1px 0 #777, 1px -1px 0 #777, -1px 1px 0 #777, 1px 1px 0 #777;
						margin-top:10px;
						height:12%;
						width:100%;
						font-size:60%;
						z-index:10;
					}
					#agreement{
						text-shadow: -1px -1px 0 #777, 1px -1px 0 #777, -1px 1px 0 #777, 1px 1px 0 #777;
						z-index:9;
						width:80%;
						margin:auto;
					}
					#leftside{
						display:none;
					}
					#status,#timer{
						display:none;
					}
					#timer{
						display:none;
					}
				</style>
			</head>
			<body>
				<script>
					document.onclick=function(){location="byond://winset?id=mapwindow.map&focus=true";};
					function set_area(id,text){document.getElementById(id).innerHTML=text||"";};
					onresize=function(){document.body.style.fontSize=Math.min(innerWidth/672,innerHeight/480)*16+"px";};
					onload=function(){onresize();location="byond://winset?command=.send-lobby-text";};
				</script>

				<h1><img src="[resource(src.agreement_headerleft_url)]">HEY LISTEN UP<img src="[resource(src.agreement_headerright_url)]"></h1>
				<div id="agreement">
					[src.agreement_text]
					<br>
				</div>
				<a href=\"byond://?action=pregameHTML\"><img src="[resource(src.agreement_yesbutton_url)]"></a>&nbsp;&nbsp;<img src="[resource(src.agreement_buttonspacer_url)]">&nbsp;&nbsp;<a href=\"byond://winset?command=.quit\"><img src="[resource(src.agreement_nobutton_url)]"></a>
				<div id="status" class="area">
				</div>
				<div id="timer" class="area">
				</div>
				<div id="leftside" class="area">
				</div>
			</body>
		</html>
		"}

//update the timers and notices within the HTML and such
/datum/titlecard/proc/set_maptext(id, text)
	maptext_areas[id] = text
	if(isnull(pregameHTML))
		return
	if (last_pregame_html == pregameHTML)
		for(var/client/C)
			if(istype(C.mob, /mob/new_player))
				C << output(list2params(list(id, text)), "pregameBrowser:set_area")

/client/verb/send_lobby_text()
	set name = ".send-lobby-text"
	set hidden = 1

	if (!istype(src?.mob, /mob/new_player))
		return

	lobby_titlecard.send_lobby_text(src)

/datum/titlecard/proc/send_lobby_text(client/C)
	if (last_pregame_html != pregameHTML)
		return
	if(isnull(pregameHTML))
		return

	for (var/id in maptext_areas)
		C << output(list2params(list(id, maptext_areas[id])), "pregameBrowser:set_area")

//old title card turf
/obj/titlecard
	appearance_flags = TILE_BOUND
	icon = null //set in New()
	icon_state = "title_main"
	layer = 60
	name = "Space Station 13"
	desc = "The title card for it, at least."
	plane = PLANE_OVERLAY_EFFECTS
	pixel_x = -96
	anchored = ANCHORED_TECHNICAL

	ex_act(severity)
		return

	meteorhit(obj/meteor)
		return

	New()
		..()
		icon = file("assets/icons/widescreen.dmi")
	#if defined(MAP_OVERRIDE_OSHAN) //we might do an underwater station later but for now i'm leaving this as an example even if we basically won't go back to these
		icon_state = "title_oshan"
		name = "Oshan Laboratory"
		desc = "An underwater laboratory on the planet Abzu."
	#endif
	#if defined(REVERSED_MAP)
		transform = list(-1, 0, 0, 0, 1, 0)
	#endif
