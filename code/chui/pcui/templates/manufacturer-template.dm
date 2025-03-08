//Main screen for the manuacturer
/datum/pcui_template/manufacturer

	setup(var/mob/user as mob)
		name = "mainscreen"
		window = "manufact"
		size = "870x700"
		header = {"
		[PC_USER_PREF_CSS("css/chui/manufacturer/manufacturer")]
		"}

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
			[PC_IFDEF("rockbox")]
				<HR><B>Ores Available for Purchase:</B><br><small>
				[PC_TAG("ore-list")]
			[PC_ENDIF("rockbox")]
			</small><HR>

			[PC_TAG("control-panel")]
			</div>
			"}
