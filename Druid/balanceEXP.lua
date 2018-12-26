-- Balance Druid for 8.1 by Laksmackt - 10/2018
-- Talents: 3132222  or wahtever ...most works
-- Holding Right Alt = Treants spawn at your mousecursor
-- Holding Left Alt = bear form and defensive (for as long as you hold it down)
-- Holding Shift = Starfall (will halt starsurge)
-- Holding CONTROL = Battle Rez (works w/ raid frames)

local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.druid

--Spells not in spellbook
SB.StellarDrift = 163222
SB.TigerDashBuff = 252216
SB.Starlord = 279709
SB.CelestialAlignment = 194223
SB.Berserking = 26297
SB.DawningSun = 276152
SB.Sunblaze = 274399
SB.IncarnationBalance = 102560
SB.FuryofElune = 202770
---
SB.StellarFlare = 202347
SB.Rebirth = 20484
SB.RejuvenationGermination = 155777
SB.ForceofNature = 205636
SB.ArcanicPulsar = 287790

local x = 0 -- counting seconds in resting
local y = 0 -- counter for opener
local z = 0 -- time in combat
local enemyCount
local autoRacial = true

local function combat()

    local aoeTarget = 4
    if talent(6, 1) then
        aoeTarget = 3
    end
    if arcanicPulsar == true then
        aoeTarget = 5
    end

    if toggle('multitarget', false) then
        enemyCount = enemies.around(40)
    elseif toggle('multitarget', true) then
        enemyCount = 1
    end


    -----------------------------
    -- Moonkin Form
    if not modifier.lalt and not lastcast(SB.MoonkinForm) and player.buff(SB.TigerDashBuff).down and GetShapeshiftForm() ~= 4 then
        return cast(SB.MoonkinForm, player)
    end

    -- rotation
    if not target.castable(SB.Starsurge) and target.castable(SB.SolarWrath) and player.buff(SB.LunarEmpowerment).count == 0 and player.buff(SB.SolarEmpowerment).count == 0 then
        return cast(SB.SolarWrath, 'target')
    end

    -----------------------------
    --- Racial active ability
    -----------------------------
    if not talent(5, 3) and -spell(SB.Berserking) == 0 and (player.buff(SB.CelestialAlignment).up or -spell(SB.CelestialAlignment) > 30) then
        cast(SB.Berserking)
    end
    if talent(5, 3) and -spell(SB.Berserking) == 0 and (player.buff(SB.IncarnationBalance).up or -spell(SB.IncarnationBalance) > 30) then
        cast(SB.Berserking)
    end

    -----------------------------
    --- WarriorOfElune
    -----------------------------
    if talent(1, 2) and -spell(SB.WarriorOfElune) == 0 and player.buff(SB.WarriorOfElune).down then
        return cast(SB.WarriorOfElune)
    end

    -----------------------------
    --- CoolDowns
    -----------------------------
    badguy = UnitClassification("target")
    -- and badguy ~= "normal" and badguy ~= "minus"
    if toggle('cooldowns', false) then
        if talent(5, 3) and power.astral.actual > 40 and target.debuff(SB.StellarFlare).up and -spell(SB.IncarnationBalance) == 0 then
            return cast(SB.IncarnationBalance)
        elseif talent(5, 2) and player.buff(SB.Starlord).count >= 2 and power.astral.actual > 40 and -spell(SB.CelestialAlignment) == 0 then
            return cast(SB.CelestialAlignment)
        elseif talent(5, 1) and power.astral.actual > 40 and -spell(SB.CelestialAlignment) == 0 then
            return cast(SB.CelestialAlignment)
        end

        if talent(7, 2) and talent(5, 3) and -player.spell(SB.FuryofElune) == 0 and (player.buff(SB.IncarnationBalance).up or -spell(SB.IncarnationBalance) > 30) then
            return cast(SB.FuryofElune, 'target')
        end
        if talent(7, 2) and not talent(5, 3) and -player.spell(SB.FuryofElune) == 0 and (player.buff(SB.CelestialAlignment).up or -spell(SB.CelestialAlignment) > 30) then
            return cast(SB.FuryofElune, 'target')
        end
    end



    --[[
        if talent(6, 3) and target.castable(SB.StellarFlare) and not lastcast(SB.StellarFlare) and ((target.time_to_die / (1.5 / ((UnitSpellHaste("player") / 100) + 1))) * enemyCount) >= 5 and (not target.debuff(SB.StellarFlare).exists or target.debuff(SB.StellarFlare).remains < 7.2) then
        return cast(SB.StellarFlare, 'target')
    end

    if target.castable(SB.Sunfire) and ((target.time_to_die * (enemyCount / (1.5 / ((UnitSpellHaste("player") / 100) + 1)))) >= (4 + enemyCount)) and (not target.debuff(SB.SunfireDebuff).exists or target.debuff(SB.SunfireDebuff).remains < 3.6) then
        return cast(SB.Sunfire, 'target')
    end
    if target.castable(SB.Moonfire) and ((target.time_to_die / (1.5 / ((UnitSpellHaste("player") / 100) + 1))) * enemyCount) >= 6 and (not target.debuff(SB.MoonfireDebuff).exists or target.debuff(SB.MoonfireDebuff).remains < 4.8) then
        return cast(SB.Moonfire, 'target')
    end
    ]]

    --feng dots
    if talent(6, 3) and target.castable(SB.StellarFlare) and not lastcast(SB.StellarFlare) and ((target.time_to_die / (1.5 / ((UnitSpellHaste("player") / 100) + 1))) * enemyCount) >= 5 and (not target.debuff(SB.StellarFlare).exists or target.debuff(SB.StellarFlare).remains < 7.2) then
        return cast(SB.StellarFlare, 'target')
    end

    if target.castable(SB.Sunfire) and ((target.time_to_die * (enemyCount / (1.5 / ((UnitSpellHaste("player") / 100) + 1)))) >= (4 + enemyCount)) and (not target.debuff(SB.SunfireDebuff).exists or target.debuff(SB.SunfireDebuff).remains < 3.6) then
        return cast(SB.Sunfire, 'target')
    end
    if target.castable(SB.Moonfire) and ((target.time_to_die / (1.5 / ((UnitSpellHaste("player") / 100) + 1))) * enemyCount) >= 6 and (not target.debuff(SB.MoonfireDebuff).exists or target.debuff(SB.MoonfireDebuff).remains < 4.8) then
        return cast(SB.Moonfire, 'target')
    end

    if target.castable(SB.LunarStrike) and power.astral.deficit >= 16 and player.buff(SB.LunarEmpowerment).count == 3 then
        return cast(SB.LunarStrike, 'target')
    elseif target.castable(SB.LunarStrike) and power.astral.deficit >= 16 and player.buff(SB.LunarEmpowerment).count == 2 and enemyCount < 3 and power.astral.active >= 40 and player.buff(SB.SolarEmpowerment) == 3 then
        return cast(SB.LunarStrike, 'target')
    elseif target.castable(SB.SolarWrath) and power.astral.deficit >= 12 and player.buff(SB.SolarEmpowerment).count == 3 then
        return cast(SB.SolarWrath, 'target')
    end

    if target.castable(SB.Starsurge) then
        return cast(SB.Starsurge)
    end


end

local function resting()


end
local function interface()
end
dark_addon.rotation.register({
    spec = dark_addon.rotation.classes.druid.balance,
    name = 'balanceEXP',
    label = 'Experimental : Balance Druide',
    combat = combat,
    gcd = gcd,
    resting = resting,
    interface = interface
})