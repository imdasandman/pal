-- Marksmanship Hunter for 8.1 by Pixels 12/2018
-- Talents: In Progress
-- Alt = Tar Trap
-- Shift = Freezing Trap

local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.hunter

--Local Spells not in default spellbook
SB.CarefulAim = 260228

local function GroupType()
    return IsInRaid() and 'raid' or IsInGroup() and 'party' or 'solo'
end

local function combat()

    if target.alive and target.enemy and not player.channeling() then
        auto_shot()

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
        if castable(SB.DoubleTap) and spell(SB.AimedShot).chargeds >= 1 then
            return cast(SB.DoubleTap)
        end
        if castable(SB.Trueshot) and -buff(SB.CarefulAim) and -spell(SB.Trueshot) == 0 then
            return cast(SB.Trueshot)
        end

        -- Standard Abilities
        if spell(SB.AimedShot).chargeds >= 1 and not -buff(SB.PreciseShots) then
            return cast(SB.AimedShot)
        end
        if -buff(SB.PreciseShots) then
            return cast(SB.ArcaneShot, 'target')
        end
        if castable(SB.RapidFire) and -spell(SB.RapidFire) == 0 then
            return cast(SB.RapidFire, 'target')
        end
        if castable(SB.SteadyShot) then
            return cast(SB.SteadyShot, 'target')
        end

    end
end

local function resting()
    -- resting
    local group_type = GroupType()

end


dark_addon.rotation.register({
    spec = dark_addon.rotation.classes.hunter.marksmanship,
    name = 'mmpal',
    label = 'PAL: Marksmanship Hunter',
    combat = combat,
    resting = resting,
    interface = interface,
})
