-- Survival Hunter for 8.1 by Pixels 12/2018
-- Talents: In Progress
-- Alt = Tar Trap
-- Shift = Freezing Trap

local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.hunter 

--Local Spells not in default spellbook
SB.Bite = 17253
SB.Smack = 49962
SB.WildfireBomb = 259495

local function GroupType()
    return IsInRaid() and 'raid' or IsInGroup() and 'party' or 'solo'
end

local function combat()
    local usetraps = dark_addon.settings.fetch('spicysv_settings_traps')
    local usemisdirect = dark_addon.settings.fetch('spicysv_settings_misdirect')
    local race = UnitRace('player')
    local group_type = GroupType()
    
    if target.alive and target.enemy and not player.channeling() then

        -- Traps
        if usetraps and modifier.shift and not modifier.alt and -spell(SB.FreezingTrap) == 0 then
            return cast(SB.FreezingTrap, 'ground')
        end
        if usetraps and modifier.alt and not modifier.shift and -spell(SB.TarTrap) == 0 then
            return cast(SB.TarTrap, 'ground')
        end

        -- Interrupts
        if toggle('interrupts') and castable(SB.CounterShot) and target.interrupt(50) then
            return cast(SB.CounterShot)
        end

        -- Cooldowns
        if toggle('cooldowns', false) and castable(SB.CoordinatedAssault) and -spell(SB.CoordinatedAssault) == 0 then
            return cast(SB.CoordinatedAssault)
        end
        
        -- Standard Abilities
        if castable(SB.SerpentSting) and (not target.debuff(SB.SerpentSting).exists or target.debuff(SB.SerpentSting).remains < 2) then
            return cast(SB.SerpentSting, 'target')
        end
        if -power.focus >= 30 and castable(SB.KillCommand) and -spell(SB.KillCommand) == 0 then
            return cast(SB.KillCommand, 'target')
        end
        if spell(SB.WildfireBomb).charges >= 1 and castable(SB.WildfireBomb) then
            return cast(SB.WildfireBomb, 'target')
        end
        if not player.buff(SB.MongooseFury).exists or buff(SB.MongooseFury).count == 5 and castable(SB.MongooseBite) then
            return cast(SB.MongooseBite, 'target')
        end

        -- Pet Management
        if pet.exists and not pet.alive then
            return cast (SB.RevivePet)
        end
        if pet.alive and pet.health.percent <= 70 and -spell(SB.MendPet) == 0 then
            return cast(SB.MendPet)
        end
        if player.health.percent <= 50 or pet.health.percent <= 20 and castable(SB.Exhilaration) and -spell(SB.Exhilaration) == 0 then
            return cast(SB.Exhilaration)
        end
        if player.health.percent < 50 and not castable(SB.Exhilaration) then
            return cast(SB.AspectOfTheTurtle)
        end
    end        
end

local function resting()
    --resting
    local petselection = dark_addon.settings.fetch('spicysv_settings_petselector')
    local group_type = GroupType()

    if not pet.exists then
        if petselection == 'key_1' then
            return cast(SB.CallPet1)
        elseif petselection == 'key_2' then
            return cast(SB.CallPet2)
        elseif petselection == 'key_3' then
            return cast(SB.CallPet3)
        elseif petselection == 'key_4' then
            return cast(SB.CallPet4)
        elseif petselection == 'key_5' then
            return cast(SB.CallPet5)
        end
    end
end

function interface()

    local settings = {
        key = 'svpal_settings',
        title = 'Survival Hunter',
        width = 250,
        height = 380,
        resize = true,
        show = false,
        template = {
            { type = 'header', text = 'SV Pal Settings'},
            { type = 'rule'},
            { type = 'text', text = 'General Settings'},
            { key = 'traps', type = 'checkbox',
            text = 'Traps',
            desc = 'Auto use Traps',
            default = false
            },
            { type = 'rule'},
            { type = 'text', text = 'Talents'},
            { type = 'rule'},
            { type = 'text', text = 'Pet Management'},
            { key = 'petselector', type = 'dropdown',
                text = 'Pet Selector',
                desc = 'select your active pet',
                default = 'key_3',
                list = {
                    { key = 'key_1', text = 'Pet 1'},
                    { key = 'key_2', text = 'Pet 2'},
                    { key = 'key_3', text = 'Pet 3'},
                    { key = 'key_4', text = 'Pet 4'},
                    { key = 'key_5', text = 'Pet 5'}
                },
            }
        }
    }

    configWindow = dark_addon.interface.builder.buildGUI(settings)

    dark_addon.interface.buttons.add_toggle({
        name = 'racial',
        label = 'Use Racial',
        on = {
            label = 'Racial',
            color = dark_addon.interface.color.orange,
            color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
        },
        off = {
            label = 'Racial',
            color = dark_addon.interface.color.grey,
            color2 = dark_addon.interface.color.dark_grey
        }
    })
    
    dark_addon.interface.buttons.add_toggle({
        name = 'settings',
        label = 'Rotation Settings',
        font = 'dark_addon_icon',
        on = {
            label = dark_addon.interface.icon('cog'),
            color = dark_addon.interface.color.cyan,
            color2 = dark_addon.interface.color.dark_cyan
        },
        off = {
            label = dark_addon.interface.icon('cog'),
            color = dark_addon.interface.color.grey,
            color2 = dark_addon.interface.color.dark_grey
        },
        callback = function(self)
            if configWindow.parent:IsShown() then
                configWindow.parent:Hide()
            else
                configWindow.parent:Show()
            end
        end
    })
end

dark_addon.rotation.register({
    spec = dark_addon.rotation.classes.hunter.survival,
    name = 'svpal',
    label = 'PAL: Survival Hunter',
    combat = combat,
    resting = resting,
    interface = interface,
})