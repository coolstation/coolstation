# Coolstation Mapping Guidelines

{%hackmd @ZeWaka/dark-theme %}

## FUNDAMENTALS

If these features do not work in the current codebase then we will help you find solutions, but expect to be poked violently.

- **Access levels** (mostly for doors) should be correct. Using the `/obj/access_spawn` spawners is required.
- **All areas** on station should have either an APC or be completely wired. APCs should be able to charge if the appropriate SMES unit(s) are set to output.
- **Pipes** (disposals, mail, sewer, brig, and morgue/crematorium, if present) should be present, functional, and error-free.
  - You should almost definitely use a mail packet configurator (`/obj/disposalpipe/segment/configurator`). This sets up the mail system!
- **Networked equipment** should be functional. Especially: communications consoles/dishes, telescience teleporter, and thus mainframe.
- **Working shuttles**, for the escape shuttle, mining and visiting traders. If you use a cargo shuttle, the same applies!
- **Navigation beacons** should be laid under the floor to provide both patrol routes for bots and a network for them to navigate.
- **GPS landmarks** should be in each room, in a decent spot.
- A **functioning engine**. Please provide a screenshot of the engine output (not necessarily at hellburn levels, but enough to meet the station/ship's power needs)
- **Correctly placed spawn points** for all present jobs, late-joiners, observers and so on. Failing to place these will result in players being dropped in to 1,1,1, which is typically uh, space?
- A **correctly linked** up syndicate listening post (i.e. nuclear operatives should be able to teleport there), and the airlocks should absolutely be correctly configured.
- A **MAP NAME** landmark for the Map at 1,1,1. This means an `/obj/landmark/map` renamed to the map ID. Without this, the map settings will fail to identify your map.
- **Windows** should be placed using the `obj/wingrille_spawn` spawners.
  - If you need manually placed thindows (aka the lil segments of a window) to make something work space-wise, remember that they are fairly easily broken through.
- **Firedoors** should be placed using the `obj/firedoor_spawn` spawners, if present.
- **Monkeys** should be spawned via landmarks, in almost all cases.

## HEAVILY RECOMMENDED

We really think these are good ideas, but if you have an idea that doesn't mesh with these, try it out.

### Command

- The bridge should be easy to see into, at least from a few angles.
- The Captain should have a spare ID, which should not initially be locked up, and probably a bonsai.
- The Head of Personnel should have some spare cash, and probably a few pricy knickknacks to steal.
- Quartermasters are command, and should generally have an office like the other command.

### Engineering

- Make sure the station can survive for 30-40 minutes while the engineers mess around with their setup.
- Test to be certain there exists an easy setup that makes enough power for a shift.
- Go weird with it. The Crag TEG breathes atmosphere, Chunk has multiple singularity generators, et cetera. Noone will blame you.

### Logistics

- Crates should arrive either when the cargo shuttle is called or when the cargo folks open some blast doors and let them in from a conveyor. If you implement a different kind of cargo, ensure it works and isn't too automatic.
- Crates should be sellable from cargo, and not too automatically. Again, if you make a new kind of cargo, make sure it works!
- Give cargo plenty of room to move crates around and establish their own way of doing business.

### Civilian

- Botanists should have a good way to pester the chef and bartender, and vice versa. Give all three some shared spaces.
- A small portion of botany should be public access, in case there aren't any.
- Meat4Cash or GrubHub are fun includes.
- Don't give the bartender the world's best chemistry setup.

### Sanitation

- The disposals crusher should have a blast door that is closed at round start (i.e. nothing should get crushed until a player opens the door).
- There should be some spare janitorial supplies in a couple storage closets around the map, not just the janitor's HQ.
- Bathrooms should be scattered around the station.

### Research

- The Research Director should have good access to the mainframe, which should be otherwise fairly protected.
- Chemistry should have at least two chem dispensers, because so many nerds love those things.
- Toxins should be equipped with a burn chamber that does not incinerate other areas, a way to cool gases, and an atmospheric parts dispenser or fabricator.

### Security

- Beepsky! Give this old bastard a shitty little home, and include his crusty ass in the map.
- Include a grenade launcher (the Rivolta) on a table in there somewhere, with fog and/or smoke grenades.
- Armories should escalate conflicts, not shut them down instantly. Breaching charges rule, extra batons not so much.
- On the other side of that, not every map needs a beefy armory.
