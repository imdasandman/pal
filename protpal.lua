local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.paladin

local function combat()
    if not target.alive or not target.enemy or player.channeling then
        return
    end
    print "oh no"
end

local function resting()
    print "oh yeah"
end

dark_addon.rotation.register({
    spec = dark_addon.rotation.classes.paladin.protection,
    name = 'protpal',
    label = 'PallyPal - PROT',
    combat = combat,
    resting = resting,
    interface = interface,
})