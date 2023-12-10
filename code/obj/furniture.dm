//holy fuck maybe we should put some stuff in here instead of everything being a stool
//might be easier than trying to fit a stool rework into a rough framework to begin with

ABSTRACT_TYPE(/obj/furniture)

/obj/furniture
	var/deconstructable = 0
	var/foldable = 0
	var/securable = 1
	var/parts_type = null

//set up some basic common procs like construction and deconstruction
//that's a later thing because for now i just want to get an abstract out there
