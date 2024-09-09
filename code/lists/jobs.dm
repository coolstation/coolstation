var/list/occupations = list( //determines spawns for jobs and how many slots by default? maybe? who knows
	// Administrative
	// "Captain", implied and handled
	"Head of Personnel",
	// Security
//	"Head of Security", handled elsewhere
	"Security Officer", "Security Officer", "Security Officer",
//	"Vice Officer", //lol
	"Detective",
	// Engineering
	"Chief Engineer", //head
	"Engineer","Engineer","Engineer",
	"Mechanic","Mechanic",
//	"Electrician","Electrician", //not ready yet
//	"Atmospheric Technician","Atmospheric Technician", //not ready yet
//	"Hangar Mechanic", "Hangar Mechanic",
	// Logistics
	"Quartermaster", //dept head
//  "Cargo Technician","Cargo Technician","Cargo Technician" //not ready yet
	"Miner","Miner","Miner",
	"Janitor",
	// Medical
	"Medical Director",
	"Medical Doctor", "Medical Doctor",
	"Geneticist",
	"Roboticist",
	"Pathologist",
	// Research
	"Research Director",
	"Scientist","Scientist", "Scientist",
//	"Chemist","Chemist",
	// Civilian
	"Botanist","Botanist",
	"Bartender",
	"Chef",
	"Chaplain",
//	"Attorney at Space-Law"
	// Silicon
	"AI",
	"Cyborg", "Cyborg",
	// Clown
	"Clown")

var/list/assistant_occupations = list(
	"Staff Assistant")

var/list/job_mailgroup_list = list(
	"Captain" = MGD_COMMAND,
	"Head of Personnel" = MGD_COMMAND,
	"Head of Security" = MGD_COMMAND,
	"Medical Director" = MGD_COMMAND,
	"Research Director" = MGD_COMMAND,
	"Chief Engineer" = MGD_COMMAND,
	"Quartermaster" = MGD_CARGO,
	"Cargo Technician" = MGD_CARGO,
	"Miner" = MGD_CARGO,
	"Engineer" = MGD_STATIONREPAIR,
	"Mechanic" = MGD_STATIONREPAIR,
	"Electrician" = MGD_STATIONREPAIR,
	"Janitor" = MGD_CARGO,
	"Botanist" = MGD_BOTANY,
	"Scientist" = MGD_SCIENCE,
	"Medical Director" = MGD_MEDRESEARCH,
	"Medical Doctor" = MGD_MEDBAY,
	"Surgeon" = MGD_MEDBAY,
	"Pharmacist" = MGD_MEDBAY,
	"Roboticist" = MGD_MEDRESEARCH,
	"Geneticist" = MGD_MEDRESEARCH,
	"Pathologist" = MGD_MEDRESEARCH,
	"Chaplain" = MGD_SPIRITUALAFFAIRS)

//Used for PDA department paging.
var/list/page_departments = list(
	"Command" = MGD_COMMAND,
	"Security" = MGD_SECURITY,
	"Medbay" = MGD_MEDBAY,
	"Med Research" = MGD_MEDRESEARCH,
	"Research" = MGD_SCIENCE,
	"Station Repair" = MGD_STATIONREPAIR,
	"Logistics" = MGD_CARGO,
	"Botany" = MGD_BOTANY,
	"Bar / Kitchen" = MGD_KITCHEN,
	"Spiritual Affairs" = MGD_SPIRITUALAFFAIRS)

/proc/get_all_jobs()
	return list("Assistant", "Detective", "Medical Doctor", "Captain", "Security Officer",
				"Geneticist","Pathologist", "Scientist", "Head of Personnel",
				"Chaplain", "Bartender", "Janitor", "Chef", "Roboticist", "Quartermaster",
				"Cargo Technician","Chief Engineer","Engineer", "Miner", "Mechanic",
				"Research Director", "Medical Director", "Botanist", "Clown")
