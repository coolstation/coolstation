/var/create_object_html = null
/datum/pcui_template/selector

	setup(var/mob/user as mob)
		name = "selection panel"
		window = "create-object"
		size = "530x480"
		force_chui = TRUE
		//Injected into the existing head element
		header = {"
		 <style type="text/css">
		* { box-sizing: border-box; }
        #dir { border: none; border-collapse: collapse; }
        #dir td { border: none; text-align: center; }

        #dir input { display: none; }
        #dir input + label { background: #eed; color: black; border: 1px solid #dda; width: 1.4em; text-align: center; vertical-align: middle; display: block; font-size: 130%; }
        #dir input:checked + label { background: #fe7; border: 1px solid #a94; }
		#createobj .leftfloater {
			float: left;
			margin: .25em .5em;
		}
		input\[type=number\] { width: 4em; text-align: right; }
		input\[type=radio\] { vertical-align: middle; }
    	</style>
		"}

		template = {"
		<title>[PC_TAG("title")]</title>
		<div id="createobj">
		<form name="spawner" action="byond://?src=[PC_REFTAG]" method="get">
		<input type="hidden" name="src" value="[PC_REFTAG]">
		<input type="hidden" name="action" value="[PC_TAG("action")]">

		[PC_TAG("filter-text")]
        <br>
        <input type="text" name="filter" id="filter" value="" onkeyup="[PC_TAG("searchfunc")]" onchange="[PC_TAG("searchfunc")]" onkeydown="submitFirst(event)" placeholder="[PC_TAG("placeholder")]" style="display: block; width: 100%;">

		<div id="selector_hs">
			<select name="type" id="[PC_TAG("action")]" multiple size="20" style="width: 100%; display: block;">
			</select>
		</div>
		[PC_IFDEF("spawner")]
        <div class="leftfloater">
            <table id="dir">
                <tr>
          	    <td>
                        <input type="radio" name="one_direction" id="dir-9" value="9"><label for="dir-9">&nwarr;</label>
                    </td>
                    <td>
                        <input type="radio" name="one_direction" id="dir-1" value="1"><label for="dir-1">&uarr;</label>
                    </td>
                    <td>
                        <input type="radio" name="one_direction" id="dir-5" value="5"><label for="dir-5">&nearr;</label>
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="radio" name="one_direction" id="dir-8" value="8"><label for="dir-8">&larr;</label>
                    </td>
                    <td>
                        &nbsp;
                    </td>
                    <td>
                        <input type="radio" name="one_direction" id="dir-4" value="4"><label for="dir-4">&rarr;</label>
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="radio" name="one_direction" id="dir-10" value="10"><label for="dir-10">&swarr;</label>
                    </td>
                    <td>
                        <input type="radio" name="one_direction" id="dir-2" value="2" checked="checked"><label for="dir-2">&darr;</label>
                    </td>
                    <td>
                        <input type="radio" name="one_direction" id="dir-6" value="6"><label for="dir-6">&searr;</label>
                    </td>
                </tr>
            </table>
        </div>

        <div class="leftfloater" style="font-family: Consolas, monospace;">
			X <input type="number" value="0" id="coords-x" onchange="updateCoords()">
			<br>Y <input type="number" value="0" id="coords-y" onchange="updateCoords()">
			<br>Z <input type="number" value="0" id="coords-z" onchange="updateCoords()">
		</div>

        <div class="leftfloater">
			Coordinates are:<br>
	        <label><input type="radio" name="offset_type" value="absolute"> Absolute</label><br>
			<label><input type="radio" name="offset_type" value="relative" checked="checked"> Relative</label>
		</div>

        <div style="float: right; margin: 0.5em 1em; text-align: right;">
            Number to spawn: <input type="number" name="object_count" min="1" step="1" value="1"><br>
            <input type="submit" value="Spawn">
        </div>
		<input type="hidden" id="offset" name="offset" value="0,0,0">
		[PC_ENDIF("spawner")]
		[PC_IFDEF("inputstyle")]
			<div style="float: right; margin: 0.5em 1em; text-align: right;">
				<input type="submit" value="Submit">
			</div>
			<div style="float: left; margin: 0.5em 1em; text-align: right;">
				<input type="button" value="Cancel" [PC_CLOSE_ONCLICK]>
			</div>
		[PC_ENDIF("inputstyle")]

	</form>

	<script>

    var old_search = "";
    var [PC_TAG("action")] = document.spawner.[PC_TAG("action")];
    var [PC_TAG("action")]_container = document.getElementById('[PC_TAG("action")]');
    var object_paths = "[PC_TAG("object-paths")]";

    var objects = object_paths == null ? \[\] : object_paths.split(";");

    document.spawner.filter.focus();
    populateList(objects);

    function populateList(from_list) {
        var newOpts = '';
        for (var i = 0; i < from_list.length; i++) {
            newOpts += '<option value="' + from_list\[i\] + '">' + from_list\[i\] + '</option>';
        }
        [PC_TAG("action")]_container.innerHTML = newOpts;
    }

	function updateSearch()
		{
			if (old_search == document.spawner.filter.value)
			{
				return false;
			}

			old_search = document.spawner.filter.value;


			var filtered = new Array();
			var i;
			for (i in objects)
			{
				if(objects\[i\].search(old_search) < 0)
				{
					continue;
				}

				filtered.push(objects\[i\]);
			}

			populateList(filtered);

			if ([PC_TAG("action")].options.length)
				[PC_TAG("action")].options\[0\].selected = 'true';

			return true;
		}

function updateSearchSubstring() {
    var searchInput = document.spawner.filter.value.toLowerCase();

    if (old_search === searchInput) {
        return;
    }

    old_search = searchInput;

    var filtered = \[\];
    for (var i = 0; i < objects.length; i++) {
        var item = objects\[i\];
        if (typeof item === 'string' && item.toLowerCase().indexOf(searchInput) !== -1) {
            filtered.push(item);
        }
    }

    populateList(filtered);

    if ([PC_TAG("action")].options && [PC_TAG("action")].options.length) {
        [PC_TAG("action")].options\[0\].selected = true;
    }
}
    function updateSearchSubstringOld() {
        var searchInput = document.spawner.filter.value.toLowerCase();

        if (old_search === searchInput) {
            return false;
        }

        old_search = searchInput;

        var filtered = \[\];
        for (var i = 0; i < objects.length; i++) {
            var item = objects\[i\];
            if (typeof item === 'string' && item.toLowerCase().indexOf(searchInput) !== -1) {
                filtered.push(item);
            }
        }

        populateList(filtered);

        if ([PC_TAG("action")].options && [PC_TAG("action")].options.length) {
            [PC_TAG("action")].options\[0].selected = true;
        }

        return true;
    }

    function submitFirst(event) {
        if (event.keyCode === 13 || event.which === 13) {
            if ([PC_TAG("searchfunc")]()) {
                if (event.stopPropagation) event.stopPropagation();
                else event.cancelBubble = true;

                if (event.preventDefault) event.preventDefault();
                else event.returnValue = false;
            }
        }
    }

    document.spawner.filter.addEventListener("input", [PC_TAG("searchfunc")], false);

	window.addEventListener('focus', focusShift, false)

	function focusShift() {
	    document.spawner.filter.focus();
	}

	document.getElementById('[PC_TAG("action")]').addEventListener('dblclick', function(event) {
            document.spawner.submit(); // Submit the form
            event.preventDefault(); // Prevent default behavior (e.g., newline)
    });

	document.getElementById('[PC_TAG("action")]').addEventListener('keydown', function(event) {
        if (event.keyCode === 13 || event.which === 13) {
            document.spawner.submit(); // Submit the form
            event.preventDefault(); // Prevent default behavior (e.g., newline)
        }
    });

    function updateCoords() {
        var x = document.getElementById("coords-x").value;
        var y = document.getElementById("coords-y").value;
        var z = document.getElementById("coords-z").value;
        document.getElementById("offset").value = x + "," + y + "," + z;
    }

	</script>
	</div>
		"}

/datum/pcui_template/selector/inputstyle
	setup(var/mob/user as mob)
		..()
		tags = list("title" = "Jump to Area",\
			"action" = "jump_list",\
			"filter-text" = "Select a location",\
			"placeholder" = "Bar",\
			"searchfunc" = "updateSearchSubstring"
		)
		window = "inputselection"
		size = "365x320"
		header = {"
		 <style type="text/css">
		* { box-sizing: border-box; }
        #dir { border: none; border-collapse: collapse; }
        #dir td { border: none; text-align: center; }

        #dir input { display: none; }
        #dir input + label { background: #eed; color: black; border: 1px solid #dda; width: 1.4em; text-align: center; vertical-align: middle; display: block; font-size: 130%; }
        #dir input:checked + label { background: #fe7; border: 1px solid #a94; }
		#createobj .leftfloater {
			float: left;
			margin: .25em .5em;
		}
		input\[type=number\] { width: 4em; text-align: right; }
		input\[type=radio\] { vertical-align: middle; }

		#createobj {
			height: 80vh;
		}

		#jump_list {
			height: 60vh;
		}

    	</style>
		"}

		PC_ENABLE_IFDEF(src, "inputstyle")


/datum/pcui_template/selector/object_spawner

	setup()
		..()
		tags = list("searchfunc" = "updateSearch",\
		"title" = "Create Object",\
		"filter-text" = "Filter object types:",\
		"action" = "object_list",\
		"placeholder" = "arm/left")

		PC_ENABLE_IFDEF(src, "spawner")


/datum/pcui_template/selector/object_spawner/mobspawn

	setup()
		..()
		tags["title"] = "Spawn Mob"
		tags["placeholder"] = "pig"
		tags["filter-text"] = "Filter mob types:"
		window = "create-mob"

/datum/pcui_template/selector/object_spawner/turfspawn

	setup()
		..()
		tags["title"] = "Spawn Turf"
		tags["placeholder"] = "steel"
		tags["filter-text"] = "Filter turf types:"
		window = "create-turf"
