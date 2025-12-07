// replacement for world.timeofday that shouldn't break around midnight, please use this
#define TIME ((world.timeofday - server_start_time + 24 HOURS) % (24 HOURS))

/// gets the hour (1-24) of the day it is
#define TimeOfHour world.timeofday % 36000

//This doesn't have to live in the construction gamemode code anymore
/// Formats a raw ticker timestamp into a (hh:)mm:ss format
/proc/dstohms(var/ds)
	var/hours = floor(ds / (10 * 60 * 60))
	var/minutes = floor((ds - (hours * 10 * 60 * 60)) / (10 * 60))
	var/seconds = floor((ds - (hours * 10 * 60 * 60) - (minutes * 10 * 60)) / 10)
	if (hours < 0)
		hours = 0
	if (minutes < 0)
		minutes = 0
	if (seconds < 0)
		seconds = 0
	if (hours < 10 && hours)
		hours = "0[hours]"
	if (minutes < 10)
		minutes = "0[minutes]"
	if (seconds < 10)
		seconds = "0[seconds]"
	if (hours)
		return "[hours]:[minutes]:[seconds]"
	return "[minutes]:[seconds]"
