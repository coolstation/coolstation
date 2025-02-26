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
