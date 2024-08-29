/*
/obj/machinery/pipedispenser
	name = "Pipe Dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "autolathe"
	density = 1
	anchored = 1.0

/obj/machinery/pipedispenser/attack_hand(user as mob)
	if(..())
		return

	var/dat = {"
<A href='byond://?src=\ref[src];make=0'>Pipe<BR>
<A href='byond://?src=\ref[src];make=1'>Bent Pipe<BR>
<A href='byond://?src=\ref[src];make=2'>Heat Exchange Pipe<BR>
<A href='byond://?src=\ref[src];make=3'>Heat Exchange Bent Pipe<BR>
<A href='byond://?src=\ref[src];make=4'>Connector<BR>
<A href='byond://?src=\ref[src];make=5'>Manifold<BR>
<A href='byond://?src=\ref[src];make=6'>Junction<BR>
<A href='byond://?src=\ref[src];make=7'>Vent<BR>
<A href='byond://?src=\ref[src];make=8'>Valve<BR>
<A href='byond://?src=\ref[src];make=9'>Pipe-Pump<BR>"}
//<A href='byond://?src=\ref[src];make=10'>Filter Inlet<BR>


	user.Browse("<HEAD><TITLE>Pipe Dispenser</TITLE></HEAD><TT>[dat]</TT>", "window=pipedispenser")
	onclose(user, "pipedispenser")
	return

/obj/machinery/pipedispenser/Topic(href, href_list)
	if(..())
		return
	src.add_dialog(usr)
	src.add_fingerprint(usr)
	if(href_list["make"])
		var/p_type = text2num(href_list["make"])
		var/obj/item/pipe/P = new /obj/item/pipe(src.loc)
		P.pipe_type = p_type
		P.update()

	for(var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			src.Attackhand(M)
	return

/obj/machinery/pipedispenser/New()
	..()
*/

