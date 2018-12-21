local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.hunter

-- Tailored to the following build: 1 1 2 3 2 3 2

--Globals
SB.CarefulAim = 260228

local function GroupType()
    return IsInRaid() and 'raid' or IsInGroup() and 'party' or 'solo'
end

local function UseMD()
    if misdirect and group_type == 'raid' and tank.alive and target.enemy and targetoftarget == tank and castable(SB.Misdirection) and -spell(SB.Misdirection) == 0 then
        return cast(SB.Misdirection, 'tank')
    elseif misdirect and group_type == 'party' and tank.alive and target.enemy and targetoftarget == tank and castable(SB.Misdirection) and -spell(SB.Misdirection) == 0 then
        return cast(SB.Misdirection, 'tank')
    elseif misdirect and pet.alive and target.enemy and castable(SB.Misdirection) and -spell(SB.Misdirection) == 0 then
        return cast(SB.Misdirection, 'pet')
    end
end

local function gcd()
    -- no pet spells here for now
end


local function combat()

    if target.alive and target.enemy and not player.channeling() then
        auto_shot()

        -- Auto use MD in combat
        UseMD()

        -------------
        -- Trap Usage
        -------------
        -- Freezing Trap
        if usetraps and modifier.shift and not modifier.alt and -spell(SB.FreezingTrap) == 0 then
            return cast(SB.FreezingTrap, 'ground')
        end
        -- TarTrap
        if usetraps and modifier.alt and not modifier.shift and -spell(SB.TarTrap) == 0 then
            return cast(SB.TarTrap, 'ground')
        end

        -------------
        -- Interrupts
        -------------
        if toggle('interrupts') and castable(SB.CounterShot) and target.interrupt(50) then
            return cast(SB.CounterShot)
        end

        -------------
        -- Auto Racial
        --------------
        -- if toggle('racial', false) and race then
        --     print (spicy_utils.getracial(race))
        --     --cast(spicy_utils.getracial(race))
        -- end

        -------------
        -- Cooldowns
        -------------
        -- Double Tap
        if castable(SB.DoubleTap) and spell(SB.AimedShot).chargeds >= 1 then
            return cast(SB.DoubleTap)
        end
        -- Trueshot
        if castable(SB.Trueshot) and -buff(SB.CarefulAim) and -spell(SB.Trueshot) == 0 then
            return cast(SB.Trueshot)
        end

        ---------------------
        -- Standard Abilities
        ---------------------
        -- Aimed Shot
        if spell(SB.AimedShot).chargeds >= 1 and not -buff(SB.PreciseShots) then
            return cast(SB.AimedShot)
        end
        -- Arcane Shot
        if -buff(SB.PreciseShots) then
            return cast(SB.ArcaneShot, 'target')
        end
        -- Rapid Fire
        if castable(SB.RapidFire) and -spell(SB.RapidFire) == 0 then
            return cast(SB.RapidFire, 'target')
        end
        -- Steady Shot - filler
        if castable(SB.SteadyShot) then
            return cast(SB.SteadyShot, 'target')
        end

    end
end

local function resting()
    -- resting
    local group_type = GroupType()
    -- handle Misdirection outside of combat
    UseMD()
end


dark_addon.rotation.register({
    spec = dark_addon.rotation.classes.hunter.marksmanship,
    name = 'spicy_rotations_marksman',
    label = 'The Spiciest Marksman',
    combat = combat,
    gcd = gcd,
    resting = resting,
    interface = interface,
})
