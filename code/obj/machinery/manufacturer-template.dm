/datum/pcui_template

	var/name = ""
	var/template = ""
	var/header = ""
	var/window = ""
	var/size = "800x600"

/datum/pcui_template/proc/setup(var/src, var/mob/user as mob)
	return

/datum/pcui_template/proc/getTemplate()
	return template

/datum/pcui_template/manufacturer

	setup(var/src, var/mob/user as mob)
		name = "mainscreen"
		header = "[PC_USER_PREF_CSS("css/chui/manufacturer/manufacturer")]"
		size = "1111x600"
		window = "manufact"
		template = {"

			<title>[PC_TAG("title")]</title>

			<script type="text/javascript">
				function product(ref) {
					window.location = "?src=[PC_REFTAG];disp=" + ref;
				}

				function delete_product(ref) {
					window.location = "?src=[PC_REFTAG];delete=1;disp=" + ref;
				}
			</script>

			<div id='products'>
			[PC_TAG("products")]
			</div><div id='info'>
			[PC_TAG("mat-list")]
			<A href='byond://?src=[PC_REFTAG];search=1'>(Search: \"[PC_TAG("search")]\")</A><BR>
			<A href='byond://?src=[PC_REFTAG];category=1'>(Filter: \"[PC_TAG("search-category")]\")</A>
			<!-- This is not re-formatted yet just b/c i don't wanna mess with it*/ -->
			<HR><B>Scanned Card:</B> <A href='byond://?src=[PC_REFTAG];card=1'>([PC_TAG("scan")])</A><BR>
			[PC_IFDEF("account")]
				<B>Current Funds</B>: [PC_TAG("account")] Credits<br>
			[PC_ENDIF("account")]
			<HR><B>Ores Available for Purchase:</B><br><small>
			[PC_TAG("ore-list")]
			</small><HR>

			[PC_TAG("control-panel")]
			</div>
			"}
