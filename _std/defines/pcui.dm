//Patricia's Cool UI defines

#define PC_BROWSER_RESOURCE(x) resource(x, null)
#define PC_CSS_TAGGER(x) ("<link rel=\"stylesheet\" href=\"" + x + "\">")
#define PC_CSS_RESOURCE(x) PC_BROWSER_RESOURCE(x + ".css\">")
#define PC_CHUI_CSS(x) PC_CSS_RESOURCE(x + "-pcui")
#define PC_UNSTYLED_CSS(x) PC_CSS_RESOURCE(x + "-html")

//Create a css tag based on user prefs(or not)
#define PC_USER_PREF_CSS(x) (user.client && !user.client.use_chui) ? PC_CSS_TAGGER(PC_UNSTYLED_CSS(x)) : PC_CSS_TAGGER(PC_CHUI_CSS(x))

#define PC_FORCE_CHUI_CSS(x) PC_CSS_TAGGER(PC_CHUI_CSS(x))

//"non-chui" css styles, whatever that means exactly
#define PC_FORCE_PLAIN_CSS(x) PC_CSS_TAGGER(PC_UNSTYLED_CSS(x))

//Macro-template system
//Docutment tags
#define PC_TAG(x) "<div class=\"template\" id=\"[x]\"></div>"

//Helper for \ref[src] in templates
#define PC_REFTAG "<div class=\"template\" id=\"srcref\"></div>"

//Begin and end ifdef
#define PC_IFDEF(x) "<div class=\"template_ifdef\" id=\"[x]\"></div>"

#define PC_ENDIF(x) "<div class=\"template_endif\" id=\"[x]\"></div>"


//Do not nest ifdefs with the same ID, we're using regex
//Also it doesn't make sense
#define PC_ENABLE_IFDEF(target, tag) while(PC_CHECK_FOR_IFDEF(target, tag)) PC_ENABLE_FIRST_IFDEF(target, tag)


//Internal, make sure you understand what these do if you mess with them

//Ifdefs
#define PC_REMOVE_UNUSED_IFDEF(target) target = regex("<div class=\"template_ifdef\" id=\".*?\">(.|\n)*?<div class=\"template_endif\" id=\".*?\"><\\/div>", "g").Replace(target)

#define PC_ENABLE_FIRST_IFDEF(target, tag) target = splicetext(target, PC_FIND_IFDEF_START(target, tag), PC_FIND_IFDEF_END(target, tag), PC_GET_IFDEF_STRING(target, tag))

#define PC_FIND_IFDEF_START(target, tag) findtext(target, "[PC_IFDEF(tag)]")

#define PC_FIND_IFDEF_END_OF_START(target, tag) (length(PC_IFDEF(tag)) + findtext(target, "[PC_IFDEF(tag)]"))

#define PC_FIND_IFDEF_END(target, tag) (length(PC_ENDIF(tag)) + findtext(target, "[PC_ENDIF(tag)]"))

#define PC_FIND_IFDEF_START_OF_END(target, tag) findtext(target, "[PC_ENDIF(tag)]")

#define PC_CHECK_FOR_IFDEF(target, tag) PC_FIND_IFDEF_START(target, tag) && PC_FIND_IFDEF_START_OF_END(target, tag)

#define PC_GET_IFDEF_STRING(target, tag) copytext(target, PC_FIND_IFDEF_END_OF_START(target, tag), PC_FIND_IFDEF_START_OF_END(target,tag))

//Tag rendering
#define PC_FILL_TAGS(target, tag, replacement)\
	target = (replacetext(target, "<div class=\"template\" id=\"[tag]\"></div>", replacement))


#define PC_FILL_TAG_LIST(target, list)\
	target = replacetext(target, "<div class=\"template\" id=\"srcref\"></div>", "\ref[src]");\
	for(var/p in list)\
		PC_FILL_TAGS(target, p, list[p])
