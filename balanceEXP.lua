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

local function GroupType()
    return IsInRaid() and 'raid' or IsInGroup() and 'party' or 'solo'
end

local function findHealer()
    local members = GetNumGroupMembers()
    local group_type = GroupType()
    if group_type ~= 'solo' then
        for i = 1, (members - 1) do
            local unit = group_type .. i
            if (UnitGroupRolesAssigned(unit) == 'HEALER') and not UnitCanAttack('player', unit) and not UnitIsDeadOrGhost(unit) then
                return unit
            end
        end
    end
    return 'player'
end

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

    print("enemies around: " .. enemyCount)
    print("Time to die: " .. target.time_to_die)
    print(target.time_to_die * enemyCount / (1.5 / ((UnitSpellHaste("player") / 100) + 1)))


    -----------------------------
    --- Modifiers
    -----------------------------
    --battle rez
    if modifier.control and not mouseover.alive and -spell(SB.Rebirth) == 0 then
        return cast(SB.Rebirth, 'mouseover')
    end

    --Starfall
    if modifier.lshift and talent(5, 1) and enemyCount >= aoeTarget and -spell(SB.Starfall) == 0 and power.astral.actual > 40 then
        return cast(SB.Starfall, 'ground')
    elseif modifier.lshift and enemyCount >= aoeTarget and -spell(SB.Starfall) == 0 and power.astral.actual > 50 then
        return cast(SB.Starfall, 'ground')
    end

    if modifier.lalt then
        if castable(SB.BearForm) and not -buff(SB.BearForm) then
            return cast(SB.BearForm)
        end
        if castable(SB.Barkskin) and not -buff(SB.Barkskin) then
            return cast(SB.Barkskin)
        end
        --  if -buff(SB.Bearform) and talent(3, 2) and castable(SB.FrenziedRegeneration) then
        --    return cast(SB.FrenziedRegeneration)
        --  end
        if -buff(SB.Barkskin) and -buff(SB.BearForm) then
            return
        end
    end

    --potions

    if autoPotion == "pot_b" and (player.buff(SB.IncarnationBalance).up or player.buff(ca_inc).up) and GetItemCount(163222) >= 1 and GetItemCooldown(163222) == 0 then
        macro('/use Battle Potion of Intellect')
        print("glug - battle potion of intellect - glug")
    end
    if autoPotion == "pot_c" and (player.buff(SB.IncarnationBalance).up or player.buff(ca_inc).up) and GetItemCount(109218) >= 1 and GetItemCooldown(109218) == 0 then
        print("glug - Draenic int - glug")
        macro('/use Draenic Intellect Potion')
    end

    if autoPotion == "pot_d" and (player.buff(SB.IncarnationBalance).up or player.buff(ca_inc).up) and GetItemCount(152559) >= 1 and GetItemCooldown(152559) == 0 then
        macro('/use Potion of rising death')
        print("glug - deadly grace - glug")
    end

    -- Interupts
    if toggle('interrupts', false) and target.interrupt(intpercent) and target.distance <= 45 and -spell(SB.SolarBeam) == 0 then
        return cast(SB.SolarBeam, 'target')
    end

    -- Barkskin
    if player.health.percent < 65 and -spell(SB.Barkskin) == 0 then
        cast(SB.Barkskin, 'player')
    end



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
    ---     Innervate
    -----------------------------
    if toggle('Innervate', false) and IsInGroup() and -spell(SB.Innervate) == 0 then
        if innervateTarget == '' then
            innervateTarget = (findHealer())
        end
        if UnitInRange(innervateTarget) and UnitExists(innervateTarget) and tank.health.percent < 80 then
            print("Innervate on " .. innervateTarget)
            return cast(SB.Innervate, innervateTarget)
        end
    end
    -----------------------------
    --- CoolDowns
    -----------------------------
    badguy = UnitClassification("target")
    -- and badguy ~= "normal" and badguy ~= "minus"
    if toggle('cooldowns', false) then
        if talent(5, 3) and power.astral.actual > 40 and -spell(SB.IncarnationBalance) == 0 then
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
       0.00	force_of_nature,if=(buff.ca_inc.up|cooldown.ca_inc.remains>30)&ap_check
    0.00	cancel_buff,name=starlord,if=buff.starlord.remains<8&!solar_wrath.ap_check
    Spenders
    0.00	starfall,if=(buff.starlord.stack<3|buff.starlord.remains>=8)&spell_targets>=variable.sf_targets&(target.time_to_die+1)*spell_targets>cost%2.5
]]--
    -----------------------------
    --- StarSurge / Starlord
    -----------------------------

    --|!talent.starlord.enabled&(buff.arcanic_pulsar.stack<8|buff.ca_inc.up))&spell_targets.starfall<variable.sf_targets&buff.lunar_empowerment.stack+buff.solar_empowerment.stack<4&buff.solar_empowerment.stack<3&buff.lunar_empowerment.stack<3&(!variable.az_ss|!buff.ca_inc.up|!prev.starsurge)|target.time_to_die<=execute_time*astral_power%40|!solar_wrath.ap_check

    if not modifier.shift and talent(5, 2) and enemyCount <= aoeTarget and target.castable(SB.Starsurge) then
        if player.buff(SB.Starlord).down then
            return cast(SB.Starsurge, target)
        elseif player.buff(SB.Starlord).count < 3 and player.buff(SB.Starlord).remains >= 8 and player.buff(SB.ArcanicPulsar).counts < 8 then
            return cast(SB.Starsurge, 'target')
        elseif power.astral.actual >= 87 and player.buff(SB.Starlord).remains <= 7 then
            macro('/cancelaura Starlord')
            return cast(SB.Starsurge, 'target')
        end
    elseif not modifier.shift and not talent(5, 2) and enemyCount < aoeTarget and target.castable(SB.Starsurge) and player.buff(SB.LunarEmpowerment).count <= 2 and player.buff(SB.SolarEmpowerment).count <= 2 then
        return cast(SB.Starsurge, 'target')
    end

    if not modifier.shift and not talent(5, 2) and castable(SB.Starsurge) then
        if player.buff(SB.ArcanicPulsar).count < 8 or (player.buff(SB.IncarnationBalance).up or player.buff(SB.CelestialAlignment).up) then
            return cast(SB.Starsurge, 'target')
        end
    end
    --dots
    if target.castable(SB.Sunfire) and ((target.time_to_die * (enemyCount / (1.5 / ((UnitSpellHaste("player") / 100) + 1)))) >= (4 + enemies.around(40))) and (not target.debuff(SB.SunfireDebuff).exists or target.debuff(SB.SunfireDebuff).remains < 3.6) then
        return cast(SB.Sunfire, 'target')
    end
    if target.castable(SB.Moonfire) and ((target.time_to_die / (1.5 / ((UnitSpellHaste("player") / 100) + 1))) * enemyCount) >= 6 and (not target.debuff(SB.MoonfireDebuff).exists or target.debuff(SB.MoonfireDebuff).remains < 4.8) then
        return cast(SB.Moonfire, 'target')
    end
    if talent(6, 3) and target.castable(SB.StellarFlare) and ((target.time_to_die / (1.5 / ((UnitSpellHaste("player") / 100) + 1))) * enemyCount) >= 5 and (not target.debuff(SB.StellarFlare).exists or target.debuff(SB.StellarFlare).remains < 7.2) then
        return cast(SB.StellarFlare, 'target')
    end

    --[[need to add code here for the moon talent
    0.00	new_moon,if=ap_check
    0.00	half_moon,if=ap_check
    0.00	full_moon,if=ap_check
]]

    if target.castable(SB.LunarStrike) and player.buff(SB.SolarEmpowerment).count < 3 and player.buff(SB.LunarEmpowerment).count == 3 then
        return cast(SB.LunarStrike, 'target')
    elseif target.castable(SB.LunarStrike) and player.buff(SB.WarriorOfElune).up and player.buff(SB.LunarEmpowerment).up then
        return cast(SB.LunarStrike, 'target')
    elseif target.castable(SB.LunarStrike) and enemyCount >= 2 and player.buff(SB.SolarEmpowerment).down then
        return cast(SB.LunarStrike, 'target')
    end
    --need to add code for that azerite trait ....if I ever get it
    --(!variable.az_ss|!buff.ca_inc.up|(!prev.lunar_strike&!talent.incarnation.enabled|prev.solar_wrath))|variable.az_ss&buff.ca_inc.up&prev.solar_wrath)


    if target.castable(SB.SolarWrath) and not lastcast(SB.SolarWrath) then
        return cast(SB.SolarWrath, 'target')
    end

    --[[	93.17	solar_wrath,if=variable.az_ss<3|!buff.ca_inc.up|!prev.solar_wrath
    0.00	sunfire
    Fallthru for movement
    ]]--
    if target.castable(SB.Sunfire) then
        return cast(SB.Sunfire)
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