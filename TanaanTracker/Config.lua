-- TanaanTracker: Config.lua
TanaanTracker = TanaanTracker or {}

-- UI behavior
TanaanTracker.SHOW_BARS = true
TanaanTracker.UI_UPDATE_INTERVAL = 1 -- seconds

-- Rares config (coords in 0–100 style; mapID is HereBeDragons ID, use /way list in-zone to verify)
TanaanTracker.rares = {
    -- spawnYell: substring of the NPC yell that fires when the rare spawns.
    -- Note: yells come from escort/herald NPCs, not the rare itself, so we match message text only.
    ["Doomroller"] = { id = 95056, respawn = 60 * 60, aliases = {"doom","dr"}, coords = {47, 52.5}, mapID = 945,
                       spawnYell = "Trample their corpses" },
    ["Vengeance"]  = { id = 95054, respawn = 60 * 60, aliases = {"veng","ven"}, coords = {32.5, 74},  mapID = 945,
                       spawnYell = "Insects deserve to be crushed" },
    ["Terrorfist"] = { id = 95044, respawn = 60 * 60, aliases = {"terror","tf"}, coords = {13.5, 60}, mapID = 945,
                       spawnYell = "massive gronnling is heading for Rangari Refuge" },
    ["Deathtalon"] = { id = 95053, respawn = 60 * 60,  aliases = {"talon","dt"}, coords = {23, 40.21},  mapID = 945,
                       spawnYell = "Behind the veil, all you find is death" },
}
TanaanTracker.raresOrder = {"Doomroller", "Vengeance", "Terrorfist", "Deathtalon"}
