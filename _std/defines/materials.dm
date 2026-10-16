#define VALUE_CURRENT 1
#define VALUE_MAX 2
#define VALUE_MIN 4

//materials

/// Crystals, Minerals
#define MATERIAL_CRYSTAL 1
/// Metals
#define MATERIAL_METAL 2
/// Cloth or cloth-like
#define MATERIAL_CLOTH 4
/// Coal, meat and whatnot.
#define MATERIAL_ORGANIC 8
/// Is energy or outputs energy.
#define MATERIAL_ENERGY 16
/// Rubber , latex etc
#define MATERIAL_RUBBER 32

// Gonna leave a bit of space between the categories and this one in case we want more categories, organisation!
/// This material is altered from (infusion) or interpolated from other materials (nanocrucible)
#define MATERIAL_NONSTANDARD 256 // unused atm but

/// Global static list of rarity color associations
var/global/static/list/RARITY_COLOR = list("#9d9d9d", "#ffffff", "#1eff00", "#0070dd", "#a335ee", "#ff8000", "#ff0000")

/// Material category names as displayed in fabricators
/// see determine_material_patterns() for exact definitions
var/global/list/material_category_names = list(
	"ALL"   = "Any Material",
	//is metal or crystal, sorted by electrical (higher better)
	"CON-1" = "Conductive Material", //50, pharosium
	"CON-2" = "High Energy Conductor", //75, claretine
	//is crystal
	"CRY-1" = "Crystal", //molitz
	//is crystal and sorted by density
	//going by this it sure seems like a lot of the old stuff i remember that used to be gated by uqill was just straight up reduced to molitz
	"DEN-1" = "High Density Crystalline Matter", //40, molitz
	"DEN-2" = "Very High Density Crystalline Matter", //60, wizard crystal? some gemstones.
	"DEN-3" = "Extraordinarily Dense Crystalline Matter", //75, uqill
	//is cloth or rubber or organic
	"FAB-1" = "Fabric",
	//is cloth or rubber, sorted by electrical (lower better)
	"INS-1" = "Insulative Material", //47, latex
	"INS-2" = "Highly Insulative Material", //20, synthrubber
	//is metal, sorted by hardness (higher better)
	"MET-1" = "Metal", //mauxite
	"MET-2" = "Sturdy Metal", //also mauxite (maybe this should be a refined form of mauxite? mauxsteel?)
	"MET-3" = "Dense Metal", //bohrum
	//is energy material, sorted by radioactivity
	"POW-1" = "Power Source", //no radcheck, plasmastone, etc. but also basically any of them, including goast stuff, and telecrystals.
	"POW-2" = "Significant Power Source", //10, cerenkite
	"POW-3" = "Extreme Power Source", //55, erebite and soulsteel (or it would be if i didn't mess with the rad count)
	//...but that's why i put specific mats back in for most recipes. we're basically killing matsci as it exists from forkdate. so there.
	//anyway: reflective at all
	"REF-1" = "Reflective Material"
)
