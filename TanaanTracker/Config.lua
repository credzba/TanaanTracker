-- TanaanTracker: Config.lua
TanaanTracker = TanaanTracker or {}

-- UI behavior
TanaanTracker.SHOW_BARS = true
TanaanTracker.UI_UPDATE_INTERVAL = 1 -- seconds

-- Rares config (coords in 0–100 style; mapID is HereBeDragons ID, use /way list in-zone to verify)
TanaanTracker.rares = {
    ["Doomroller"] = { id = 95056, respawn = 60 * 60, aliases = {"doom","dr"}, coords = {47, 52.5}, mapID = 945 },
    ["Vengeance"]  = { id = 95054, respawn = 60 * 60, aliases = {"veng","ven"}, coords = {32.5, 74},  mapID = 945 },
    ["Terrorfist"] = { id = 95044, respawn = 60 * 60, aliases = {"terror","tf"}, coords = {13.5, 60}, mapID = 945 },
    ["Deathtalon"] = { id = 95053, respawn = 60 * 60,  aliases = {"talon","dt"}, coords = {23, 40.21},  mapID = 945 },
}
TanaanTracker.raresOrder = {"Doomroller", "Vengeance", "Terrorfist", "Deathtalon"}
