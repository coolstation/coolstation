//Signal frequencies
//BIG NOTE: this used to be a string and only PDA was stored in here
//if passing this to the radio controller for adding, removing, or returning:
//you *must* pass it as a string, like "[FREQ_PDA]", when before it was passed as FREQ_PDA
//luckily since it was only FREQ_PDA before this was an easy fix

//standards, familiar to us all
#define FREQ_DEFAULT 1457 //Default door signal, frequency that signallers start on
#define FREQ_PDA 1149 //The number to make someone's PDA go BEEP BEEP
#define FREQ_WLNET 1419 //Wireless networking
#define FREQ_COMM_DISH 1113
//door shit
#define FREQ_POD 1143 //Pod bay door control
#define FREQ_AIRLOCK_REMOTE 1411 //remote door access i guess
#define FREQ_AIRLOCK 1449 //Complicated airlock interactions
#define FREQ_ARMORY 1461 //Armory door unlock auth signal
#define FREQ_SECURE_STORAGE 1463
//atmos shit
#define FREQ_ATMOS 1225 //Atmos Control
#define FREQ_ENGINE 1227 //Engineering Equipment (TEG)
#define FREQ_TOX_MIX 1229 //Toxins Mixing Equipment
#define FREQ_ATMOS_SEC 1274 //security or secure atmos control maybe
#define FREQ_ATMOS2 1439 //Atmos pumps and sensors control (atmos 2 until I can either cleanly split and define them, or unify with 1225)
//bot shit
#define FREQ_ROBADDY_CONTROL 1089 //evil robuddy freq control who knows, same as fukken wizard radio frequencies
#define FREQ_ROBUDDY 1219 //robuddy control
#define FREQ_ROBADDY 1431 //evil robuddy freq
#define FREQ_BOT_HOSPITAL 1440 //Hospital tour(???) beacon i guess
#define FREQ_BOT_TOUR_LUNA 1441 //Luna tour beacon, overlaps with engineering intercom, jfc
#define FREQ_BOT_TOUR 1443 //Tour beacons, overlaps with research intercom
#define FREQ_BOT_NAV 1445 //Nav beacons and communication, but overlaps with medical intercom
#define FREQ_BOT_CONTROL 1447 //MULE bots, sec bot summon, etc. Overlaps with AI intercom
#define FREQ_SOVBOT 1917 //oh i get it
//notif shit
#define FREQ_HYDRO 1433 //Plant status, used by plant pots
#define FREQ_STATUS 1435 //Status Display
#define FREQ_ALARM 1437 //Fire and atmos alarms, received by alert computer and fire doors
#define FREQ_TRACKING 1451 //Tracker implants (and electropacks???)
#define FREQ_GPS 1453 //GPS, for reporting in and sending distress signals
#define FREQ_RUCK 1467 //For communicating scans from handheld scanners/pda to ruckingenur kits, and between kits, apparently
#define FREQ_MAIL 1475 //Mail delivery notices for PDA
#define FREQ_NUMBERS 1487 //Numbers Station
