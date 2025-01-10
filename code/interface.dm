/client
	verb
		changes()
			set category = "Commands"
			set name = "Changelog"
			set desc = "Show or hide the changelog"

			if (winget(src, "changes", "is-visible") == "true")
				src.Browse(null, "window=changes")
			else
				var/changelogHtml = grabResource("html/changelog.html")
				var/data = changelog:html
				changelogHtml = replacetext(changelogHtml, "<!-- HTML GOES HERE -->", "[data]")
				src.Browse(changelogHtml, "window=changes;size=500x650;title=Changelog;", 1)
				src.changes = 1

		bugreport()
			set category = "Commands"
			set name = "bugreport"
			set desc = "Report a bug."
			set hidden = 1
			/*
			switch(alert(src, "Is this an abusable exploit or related to secrets?","Secret report?","Yes","No","Cancel"))
				if("Yes")
					var/details_body = {"**Describe+the+bug**%0AA+clear+and+concise+description+of+what+the+bug+is.%0A%0A**To+Reproduce**%0ASteps+to+reproduce+the+behavior:%0A1.+Buy+a+Pizza+from+a+vending+machine%0A2.+Eat+the+pizza%0A3.+The+pizza+has+not+disappeared%0A4.+See+error%0A%0A**Expected+behavior**%0AA+clear+and+concise+description+of+what+you+expected+to+happen.%0A%0A**Screenshots**%0AIf+applicable,+add+screenshots+to+help+explain+your+problem.%0A%0A**Additional+context**%0AAdd+any+other+context+about+the+problem+here.%0A%0A"}
					var/url = {"https://gitreports.com/issue/coolstation/coolstation-secret?email_public=0&name=[src.ckey]&details=[details_body]%0AReported on: [config.server_name]+[time2text(world.realtime, "YYYY-MM-DD")]+[time2text(world.timeofday, "hh:mm:ss")]"}
					src << link(url)
					return
				if("Cancel")
					return
					*/
			switch(alert(src, "Do you have a GitHub account?",,"Yes","No","Cancel"))
				if("Yes")
					src << link("https://github.com/coolstation/coolstation/issues/new?template=bug_report.md")
				if("No")
					var/details_body = {"**Describe+the+bug**%0AA+clear+and+concise+description+of+what+the+bug+is.%0A%0A**To+Reproduce**%0ASteps+to+reproduce+the+behavior:%0A1.+Buy+a+Pizza+from+a+vending+machine%0A2.+Eat+the+pizza%0A3.+The+pizza+has+not+disappeared%0A4.+See+error%0A%0A**Expected+behavior**%0AA+clear+and+concise+description+of+what+you+expected+to+happen.%0A%0A**Screenshots**%0AIf+applicable,+add+screenshots+to+help+explain+your+problem.%0A%0A**Additional+context**%0AAdd+any+other+context+about+the+problem+here.%0A%0A"}
					var/url = {"https://gitreports.com/issue/coolstation/coolstation?email_public=0&name=[src.ckey]&details=[details_body]%0AReported on: [config.server_name]+[time2text(world.realtime, "YYYY-MM-DD")]+[time2text(world.timeofday, "hh:mm:ss")]"}
					src << link(url)
				if("Cancel")
					return

		github()
			set category = "Commands"
			set name = "github"
			set desc = "Opens the github in your browser"
			set hidden = 1
			src << link("https://github.com/coolstation/coolstation")

		wiki()
			set category = "Commands"
			set name = "Wiki"
			set desc = "Open the Wiki in your browser"
			set hidden = 1
			src << link("https://wiki.coolstation.space/wiki/Main_Page")

		/* map() //currently no map website interface yet
			set category = "Commands"
			set name = "Map"
			set desc = "Open an interactive map in your browser"
			set hidden = 1
			if (map_settings)
				src << link(map_settings.goonhub_map)
			else
				src << link("http://goonhub.com/maps/cogmap")
		*/

		discord() //so why not just replace the missing map button with another more currently useful button
			set category = "Commands"
			set name = "Discord"
			set desc = "Join our Discord!!!!"
			set hidden = 1
			src << link("https://discord.com/invite/Xh3yfs8KGn")

		forum()
			set category = "Commands"
			set name = "Forum"
			set desc = "Open the Forum in your browser"
			set hidden = 1
			src << link("https://forum.coolstation.space")

		savetraits()
			set hidden = 1
			set name = ".savetraits"
			set instant = 1

			if(preferences)
				if(preferences.traitPreferences.isValid())
					preferences.ShowChoices(usr)
				else
					alert(usr, "Invalid trait setup. Please make sure you have 0 or more points available.")
					preferences.traitPreferences.showTraits(usr)

	proc
		set_macro(name)
			winset(src, "mainwindow", "macro=\"[name]\"")
