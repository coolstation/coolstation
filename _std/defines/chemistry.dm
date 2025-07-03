//states of matter!
#define SOLID 1
#define LIQUID 2
#define GAS 3

//chem transfer methods
#define TOUCH 1
#define INGEST 2
#define INJECT 3

//some holder stuff i dont understand
#define MAX_TEMP_REACTION_VARIANCE 8
#define CHEM_EPSILON 0.0001

//makes sure we cant have too many critters
#define CRITTER_REACTION_LIMIT 50
#define CRITTER_REACTION_CHECK(x) if (x++ > CRITTER_REACTION_LIMIT) return

//uncomment to enable sorting of reactions by priority (which is currently slow and bad)
//#define CHEM_REACTION_PRIORITIES

//reagent_container bit flags
#define RC_SCALE 	1		// has a graduated scale, so total reagent volume can be read directly (e.g. beaker)
#define RC_VISIBLE	2		// reagent is visible inside, so color can be described
#define RC_FULLNESS 4		// can estimate fullness of container - RC_SCALE takes precedence
#define RC_SPECTRO	8		// spectroscopic glasses can analyse contents
//You can do custom inventory counter stuff (like hyposprays) so long as you avoid these flags.
#define RC_INV_COUNT_AMT 16	// with RC_SCALE, display N/total in inventory counter. With RC_FULLNESS, give shorthand for fullness. Does nothing otherwise
//#define RC_INV_COUNT_USE 32 // update inventory with "pour XXu" - can't implement "pour all" cause that's a feature of the glass subtype RIP

//macro for lag-compensated probability - assumes lag-compensation multiplier is always called mult
#define probmult(x) (prob(percentmult((x), mult)))

//chemical reaction result amounts can be negative and it's not useful, it's free real estate!

///When instantiating the recipe, make the output volume consistent with combined input volume (e.g. 5u of reagents go in, 5u of reagent come out)
#define RECIPE_AUTO_PRESERVE_VOLUME -1
