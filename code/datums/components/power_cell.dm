/datum/component/power_cell
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/charge
	var/max_charge
	var/recharge_rate
	var/cycle = 0
	var/can_be_recharged

TYPEINFO(/datum/component/power_cell)
	initialization_args = list(
		ARG_INFO("max", "num", "Maximum cell charge", 200),
		ARG_INFO("start_charge", "num", "Initial cell charge", 200),
		ARG_INFO("recharge_rate", "num", "Recharge rate of cell (approx per 5.8 seconds)", 0),
		ARG_INFO("rechargable", "num", "If the cell can recharged in a recharger", TRUE)
	)

/datum/component/power_cell/Initialize(max = 200, start_charge = 200, recharge = 0, rechargable = TRUE)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	. = ..()
	src.max_charge = max
	src.charge = start_charge
	src.recharge_rate = recharge
	if(charge < max_charge && recharge_rate)
		processing_items |= parent
	RegisterSignal(parent, COMSIG_ATTACKBY, PROC_REF(attackby))
	RegisterSignal(parent, COMSIG_CELL_CHARGE, PROC_REF(charge))
	RegisterSignal(parent, COMSIG_CELL_CAN_CHARGE, PROC_REF(can_charge))
	RegisterSignal(parent, COMSIG_CELL_USE, PROC_REF(use))
	RegisterSignal(parent, COMSIG_CELL_CHECK_CHARGE, PROC_REF(check_charge))
	RegisterSignal(parent, COMSIG_CELL_IS_CELL, PROC_REF(is_cell))
	RegisterSignal(parent, COMSIG_ITEM_PROCESS, PROC_REF(process))


/datum/component/power_cell/InheritComponent(datum/component/power_cell/C, i_am_original, max, start_charge, recharge)
	if(C)
		src.max_charge = C.max_charge
		src.charge = C.charge
		src.recharge_rate = C.recharge_rate
		if(charge < max_charge && recharge_rate)
			processing_items |= parent
	else
		if(isnum_safe(max))
			src.max_charge = max
		if(isnum_safe(start_charge))
			src.charge = start_charge
		if(isnum_safe(recharge))
			src.recharge_rate = recharge


/datum/component/power_cell/proc/attackby(source, obj/item/I, mob/user)
	SEND_SIGNAL(I, COMSIG_CELL_TRY_SWAP, parent, user)

/datum/component/power_cell/proc/can_charge()
	. = CELL_CHARGEABLE

/datum/component/power_cell/proc/charge(source, amount)
	if (amount > 0)
		src.charge = min(src.charge + amount, src.max_charge)

	if (src.charge >= src.max_charge)
		processing_items -= parent
		src.charge = src.max_charge
		. = CELL_FULL
	SEND_SIGNAL(parent, COMSIG_UPDATE_ICON)

/datum/component/power_cell/proc/use(source, amount)
	src.charge = max(src.charge - amount, 0)
	if(src.recharge_rate && amount > 0)
		processing_items |= parent


	if(src.charge > 0) //return sufficient charge if cell is non-empty after drain, insufficient if cell was emptied by the drain
		. = CELL_SUFFICIENT_CHARGE
	else
		. = CELL_INSUFFICIENT_CHARGE

	SEND_SIGNAL(parent, COMSIG_UPDATE_ICON)

/datum/component/power_cell/proc/check_charge(source, list/amount)
	if(islist(amount))
		amount["charge"] = charge
		amount["max_charge"] = max_charge
		. = CELL_RETURNED_LIST
	else if(isnum_safe(amount))
		. = (charge >= amount) ? CELL_SUFFICIENT_CHARGE : CELL_INSUFFICIENT_CHARGE
	else
		. = charge > 0 ? CELL_SUFFICIENT_CHARGE : CELL_INSUFFICIENT_CHARGE

/datum/component/power_cell/proc/is_cell()
	return TRUE

/datum/component/power_cell/proc/process()
	cycle = !cycle
	if(cycle)
		src.charge(null, recharge_rate)
	SEND_SIGNAL(parent, COMSIG_UPDATE_ICON)
	return
