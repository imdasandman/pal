local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.hunter

SB.Bite = 17253
SB.Smack = 49962
SB.PetFrenzy = 272790
--[[ local function GroupType()
   return IsInRaid() and 'raid' or IsInGroup() and 'party' or 'solo'
end ]]

--[[ local function UseMD(group)
    if group == 'raid' and target.enemy and targetoftarget == tank and castable(SB.Misdirection) then
        return cast(SB.Misdirection, 'tank')
    elseif group == 'party' and target.enemy and targetoftarget == tank and castable(SB.Misdirection) then
        return cast(SB.Misdirection, 'tank')
    elseif group == 'solo' and target.enemy and castable(SB.Misdirection) then
        return cast(SB.Misdirection, 'pet')
    end
end ]]

local function combat()
    local usetraps = dark_addon.settings.fetch('spicybm_settings_traps')
    local usemisdirect = dark_addon.settings.fetch('spicybm_settings_misdirect')
    local race = UnitRace('player')
    --local group_type = GroupType()
    
    if target.alive and target.enemy and not player.channeling() then
        auto_shot()

        -- Traps
        if usetraps and modifier.shift and not modifier.alt and castable(SB>FreezingTrap) then
            return cast(SB.FreezingTrap, 'ground')
        end
        if usetraps and modifier.alt and not modifier.shift and castable(SB.TarTrap) then
            return cast(SB.TarTrap, 'ground')
        end
        -- Interrupts
        if toggle('interrupts') and castable(SB.CounterShot) and target.interrupt(50) then
            return cast(SB.CounterShot)
        end
        -- AOE
        if toggle('multitarget', false) and modifier.rshift and -power.focus >= 70 then
            return cast(SB.MultiShot, 'target')
        end
        -- Auto Racial
        -- if toggle('racial', false) and race then
        --     print (spicy_utils.getracial(race))
        --     --cast(spicy_utils.getracial(race))
        -- end
        -- Cooldowns
        if toggle('cooldowns', false) and castable(SB.BeastialWrath) then
            return cast(SB.BeastialWrath)
        end
        if toggle('cooldowns', false) and castable(SB.AspectOfTheWild) then
            return cast(SB.AspectOfTheWild)
        end
        -- Standard Abilities
        if spell(SB.BarbedShot).charges >= 1 and pet.buff(SB.PetFrenzy).remains <= 1.75 then
            return cast(SB.BarbedShot, 'target')
        end
        if -power.focus >= 30 and castable(SB.KillCommand) then
            return cast(SB.KillCommand, 'target')
        end
        if talent(1,3) and castable(SB.DireBeast) then
            return cast(SB.DireBeast, 'target')
        end
        if talent(2,3) and -power.focus < 90 and castable(SB.ChimaeraShot) then
            return cast(SB.ChimaeraShot, 'target')
        end
        if talent(4,3) and castable(SB.AMurderOfCrows) then
            return cast(SB.AMurderOfCrows, 'target')
        end
        if -power.focus >=80 and castable(SB.CobraShot) and -spell(SB.KillCommand) >= 2.5 then
            return cast(SB.CobraShot, 'target')
        end
        -- Pet Management
        if pet.exists and not pet.alive then
            return cast (SB.RevivePet)
        end
        if pet.alive and pet.health.percent <= 70 and castable(SB.MendPet) then
            return cast(SB.MendPet)
        end
        -- Defensives
        if (player.health.percent <= 50 or pet.health.percent <= 20) and castable(SB.Exhilaration) then
            return cast(SB.Exhilaration)
        end
        if player.health.percent < 50 and not castable(SB.Exhilaration) then
            return cast(SB.AspectOfTheTurtle)
        end
    end        
end

local function resting()
    local usemisdirect = dark_addon.settings.fetch('spicybm_settings_misdirect')
    local petselection = dark_addon.settings.fetch('spicybm_settings_petselector')
    --local group_type = GroupType()

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
    if pet.exists and not pet.alive then
        return cast (SB.RevivePet)
    end
    -- Mend Pet
    if pet.alive and pet.health.percent <= 70 and -spell(SB.MendPet) == 0 then
        return cast(SB.MendPet)
    end

end

function interface()

    local settings = {
        key = 'spicybm_settings',
        title = 'Beastmaster Hunter',
        width = 250,
        height = 380,
        fontheight = 10,
        resize = true,
        show = false,
        template = {
            { type = 'header', text = 'Spicy BM Settings'},
            { type = 'text', text = 'the suggested talent build:'},
            { type = 'text', text = '1 3 2 3 2 1 1'},
            { type = 'rule'},
            { type = 'text', text = 'General Settings'},
            { key = 'misdirect', type = 'checkbox',
            text = 'Misdirection',
            desc = 'Auto Misdirect',
            default = false
            },
            { key = 'traps', type = 'checkbox',
            text = 'Traps',
            desc = 'Auto use Traps',
            default = false
            },
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
    spec = dark_addon.rotation.classes.hunter.beastmastery,
    name = 'spicybm',
    label = 'The Spiciest BM',
    combat = combat,
    resting = resting,
    interface = interface,
})