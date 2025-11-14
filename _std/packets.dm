
#define RADIO_JAMMER_RANGE 6

proc/check_for_radio_jammers(atom/source)
	. = FALSE
	for (var/atom/A as anything in by_cat[TR_CAT_RADIO_JAMMERS])
		if (IN_RANGE(source, A, RADIO_JAMMER_RANGE))
			return TRUE

#define MAKE_DEFAULT_RADIO_PACKET_COMPONENT(conn_id, freq) src._AddComponent(list( \
		/datum/component/packet_connected/radio, \
		conn_id, \
		freq, \
		("net_id" in src.vars) ? src.vars["net_id"] : null, \
		hascall(src, "receive_signal") ? "receive_signal" : null, \
		FALSE, \
		null, /*("id_tag" in src.vars) ? "[src.vars["id_tag"]]" : null, */\
		FALSE \
	))

#define MAKE_SENDER_RADIO_PACKET_COMPONENT(conn_id, freq) src._AddComponent(list( \
		/datum/component/packet_connected/radio, \
		conn_id, \
		freq, \
		("net_id" in src.vars) ? src.vars["net_id"] : null, \
		null, \
		TRUE, \
		null, /*("id_tag" in src.vars) ? "[src.vars["id_tag"]]" : null, */\
		FALSE \
	))

proc/get_packet_connection_by_id(atom/movable/AM, id)
	RETURN_TYPE(/datum/component/packet_connected)
	for(var/datum/component/packet_connected/comp as anything in AM.GetComponents(/datum/component/packet_connected))
		if(comp.connection_id == id)
			return comp
	return null

proc/get_radio_connection_by_id(atom/movable/AM, id)
	RETURN_TYPE(/datum/component/packet_connected/radio)
	for(var/datum/component/packet_connected/radio/comp as anything in AM.GetComponents(/datum/component/packet_connected/radio))
		if(comp.connection_id == id)
			return comp
	return null

/// packet transmission types
#define TRANSMISSION_INVALID -1
#define TRANSMISSION_WIRE	0
#define TRANSMISSION_RADIO	1
