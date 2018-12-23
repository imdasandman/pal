-- Restoration Shaman

--[[ Talents supported:

 15: 1 2
 30: 1 2 3
 45: 1 2 3 (earthgrab totem must be placed manually)
 60: 1 2 3 (Ancestral totem must be placed manually)
 75: 1 2 3 (Windrush Totem must be placed manually)
 90: 1
100: 1  3 (wellspring wont break rotation, but is not automated)


--Holding RIGHT Shift = Healing Rain at cursor
--Holding LEFT Shift = Earth Wall Totem (if talented)
--Holding CTRL = decurse (at mouseover target - works with raidframes) in combat - works as REZ if used on a dead target out of combat
--Holding LEFT ALT = Stun totem at cursor
--Holding RIGHT ALT = Spirit link totem at cursor
]]

local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.shaman
local TB = dark_addon.rotation.spellbooks.shaman
local DB = dark_addon.rotation.spellbooks.shaman
local race = UnitRace("player")

-- enable to treat tank like everyone else - all 'tank' statements will be ignored
--dark_addon.environment.virtual.exclude_tanks = false

SB.EarthShield = 204288
SB.HealingTideTotem = 108280
SB.HealingWave = 77472
SB.CapacitorTotem = 125720
SB.SpiritLink = 98008
SB.LightningBoltRestoration = 403
SB.EarthenWallTotem = 198838
SB.AncestralVision = 212048
SB.HealingTideTotem = 108280
SB.ChainHeal = 1064
SB.AscendanceResto = 114052
SB.HealingWave = 77472
SB.Berserking = 26297

local function GroupType()
    return IsInRaid() and 'raid' or IsInGroup() and 'party' or 'solo'
end


local function combat()
    if not player.alive then
        return
    end

    local inRange = 0
    for i = 1, 40 do
        if UnitExists('nameplate' .. i) and IsSpellInRange('Wind Shear', 'nameplate' .. i) == 1 and UnitAffectingCombat('nameplate' .. i) then
            inRange = inRange + 1
        end
    end

    --- Reticulate Splines
    local group_health_percent = 100 * UnitHealth("player") / UnitHealthMax("player") or 0
    local group_health = group_health_percent
    local group_unit_count = IsInGroup() and GetNumGroupMembers() or 1
    local damaged_units = group_health_percent < 90 and 1 or 0
    local dead_units = 0
    for i = 1, group_unit_count - 1 do
        local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
        local unit = IsInRaid() and "raid" .. i or "party" .. i
        local unit_health = 100 * UnitHealth(unit) / UnitHealthMax(unit) or 0
        if unit_health < 90 then
            damaged_units = damaged_units + 1
        end
        if isDead or not online or not UnitInRange(unit) then
            dead_units = dead_units + 1
        else
            group_health = group_health + unit_health
        end
    end
    group_health_percent = group_health / (group_unit_count - dead_units)


    --------------------
    ---  Trinkets
    --------------------
    --[[
     --Trinket use
     if GetItemCooldown(160649) == 0 and tank.health.percent < 95 then
       macro('/use [help] 14; [@targettarget] 14')
     end
    ]]

    --------------------
    ---  Modifiers
    --------------------
    -- Modifiers
    if modifier.lshift and castable(SB.HealingRain) then
        return cast(SB.HealingRain, 'ground')
    end

    if modifier.rshift and talent(4, 2) and castable(SB.EarthenWallTotem) then
        return cast(SB.EarthenWallTotem, 'ground')
    end

    if modifier.lalt and castable(SB.CapacitorTotem) then
        return cast(SB.CapacitorTotem, 'ground')
    end

    if modifier.ralt and castable(SB.SpiritLink) then
        return cast(SB.SpiritLink, 'ground')
    end

    if modifier.control then
        if mouseover.alive and castable(SB.PurifySpirit) then
            return cast(SB.PurifySpirit, 'mouseover')

        elseif not mouseover.alive and castable(SB.AncestralVision) then
            return cast(SB.AncestralVision)
        end
    end

    --------------------
    ---  Interrupts
    --------------------
    if toggle('interrupts', false) and target.interrupt(50) and target.castable(SB.WindShear) then
        return cast(SB.WindShear, 'target')
    end


    -- SpiritWalk
    if player.moving and lowest.health.percent < 50 and castable(SB.SpiritWalk) then
        return cast(SB.SpiritWalk)
    end
    if player.moving and tank.health.percent < 50 and castable(SB.SpiritWalk) then
        return cast(SB.SpiritWalk)
    end

    --------------------
    ---  Totems / Earth Shield
    --------------------

    if group_health_percent < 80 and castable(SB.HealingStreamTotem) then
        return cast(SB.HealingStreamTotem)
    end

    if tank.buff(SB.EarthShield).down and castable(SB.EarthShield, tank) then
        return cast(SB.EarthShield, tank)
    end


    -- check if they are casting fear - use tremor
    -- spirit link totem automatic



    --------------------
    ---  Decurse
    --------------------

    local dispellable_unit = group.removable('curse', 'magic')
    if toggle('DISPELL', false) and dispellable_unit and spell(SB.PurifySpirit).cooldown == 0 then
        return cast(SB.PurifySpirit, dispellable_unit)
    end

    -- self-cleanse
    local dispellable_unit = player.removable('curse', 'magic')
    if toggle('DISPELL', false) and dispellable_unit then
        return cast(SB.PurifySpirit, dispellable_unit)
    end
    --------------------
    ---  cool Downs
    --------------------

    if toggle('cooldowns', false) and castable(SB.HealingTideTotem) and (lowest.health.percent <= 20 or tank.health.percent <= 35 or group_health_percent < 50) then
        print 'CD - Healing Tide'
        return cast(SB.HealingTideTotem)
    end

    if toggle('cooldowns', false) and (SB.HealingTideTotem) > 0 and castable(SB.Ascendance) and (lowest.health.percent <= 20 or tank.health.percent <= 35 or group_health_percent < 40) then
        print 'CD - Healing Tide'
        return cast(SB.AscendanceResto)
    end

    -- defensive cooldowns


    --- dot
    if target.enemy and castable(SB.FlameShock) and (not target.debuff(SB.FlameShock) or target.debuff(SB.FlameShock).remains <= 6) then
        return cast(SB.FlameShock)
    end


    --- Healing - Riptide

    if lowest.castable(SB.Riptide) and lowest.health.percent <= 70 and lowest.distance < 40 then
        return cast(SB.Riptide, lowest)
    end

    if tank.castable(SB.Riptide) and tank.health.percent < 80 and tank.distance <= 40 then
        return cast(SB.Riptide, tank)
    end

    --- chain heal

    if tank.health.percent > 30 and group_health_percent <= 80 then
        return cast(SB.ChainHeal, lowest)
    end

    --[[
      --- TidalWaves
      if player.buff(SB.TidalWaves).up and -spell(SB.HealingWave) == 0 and tank.health.percent < 70 and tank.distance < 40 then

        return cast(SB.HealingWave, tank)
      end

      if player.buff(SB.TidalWaves).up and -spell(SB.HealingWave) == 0 and lowest.health.percent < 80 and lowest.distance < 40 then
        return cast(SB.HealingWave, lowest)
      end
    ]]

    if lowest.castable(SB.HealingSurge) and lowest.health.percent < 60 then
        return cast(SB.HealingSurge, lowest)
    end

    if tank.castable(SB.HealingSurge) and tank.health.percent < 60 then
        return cast(SB.HealingSurge, tank)
    end


    ---Use HealingWave

    if lowest.castable(SB.HealingWave) and lowest.health.percent < 80 then
        return cast(SB.HealingWave, lowest)
    end

    if tank.castable(SB.HealingWave) and tank.health.percent < 80 then
        return cast(SB.HealingWave, tank)
    end


    --dps
    if castable(SB.LavaBurst, target) and lowest.health.percent > 50 and tank.health.percent > 50 and target.enemy and inRange <= 2 and target.distance < 40 then
        return cast(SB.LavaBurst, 'target')
    end

    if lowest.health.percent > 50 and tank.health.percent > 50 and target.enemy and inRange >= 2 then
        return cast(SB.ChainLightning, target)
    elseif lowest.health.percent > 50 and tank.health.percent > 50 and target.enemy and inRange <= 1 then
        return cast(SB.LightningBoltRestoration, target)
    end


    --[[
        -- uncomment if not blood elf - using racial trait on CD for mana ... make sure to turn this off in Kings Rest if group depend on you for dispell
        if toggle('Racial', false) and race == "Blood Elf" and player.power.mana.percent < 90 and -spell(SB.ArcaneTorrent) == 0 then
            --print (race)
            return cast(SB.ArcaneTorrent)
        end
        ]]
end

local function resting()
    if player.alive then


        if talent(2, 3) and tank.distance < 40 and (tank.buff(SB.EarthShield).down or tank.buff(SB.EarthShield).count <= 2) then
            return cast(SB.EarthShield, tank)
        end
        --------------------
        ---  Modifiers
        --------------------

        -- Modifiers
        if modifier.lshift and -spell(SB.HealingRain) == 0 then
            return cast(SB.HealingRain, 'ground')
        end

        if modifier.rshift and talent(4, 2) and castable(SB.EarthenWallTotem) then
            return cast(SB.EarthenWallTotem, 'ground')
        end

        if modifier.lalt and -spell(SB.CapacitorTotem) == 0 then
            return cast(SB.CapacitorTotem, 'ground')
        end

        if modifier.ralt and -spell(SB.SpiritLink) == 0 then
            return cast(SB.SpiritLink, 'ground')
        end

        if modifier.control then
            if mouseover.alive and -spell(SB.PurifySpirit) == 0 then
                return cast(SB.PurifySpirit, 'mouseover')

            elseif not mouseover.alive and -spell(SB.AncestralVision) == 0 then
                return cast(SB.AncestralVision)
            end
        end


    end
end
local function interface()
    dark_addon.interface.buttons.add_toggle({
        name = 'DPS',
        label = 'DPS',
        on = {
            label = 'DPS',
            color = dark_addon.interface.color.orange,
            color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
        },
        off = {
            label = 'DPS',
            color = dark_addon.interface.color.grey,
            color2 = dark_addon.interface.color.dark_grey
        }
    })
    dark_addon.interface.buttons.add_toggle({
        name = 'DISPELL',
        label = 'DISP',
        on = {
            label = 'DISP',
            color = dark_addon.interface.color.orange,
            color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
        },
        off = {
            label = 'DISP',
            color = dark_addon.interface.color.grey,
            color2 = dark_addon.interface.color.dark_grey
        }
    })
    dark_addon.interface.buttons.add_toggle({
        name = 'BoP',
        label = 'BoP',
        on = {
            label = 'BoP',
            color = dark_addon.interface.color.orange,
            color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
        },
        off = {
            label = 'BoP',
            color = dark_addon.interface.color.grey,
            color2 = dark_addon.interface.color.dark_grey
        }
    })
    dark_addon.interface.buttons.add_toggle({
        name = 'Racial',
        label = 'Racial',
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
        name = 'LoD',
        label = 'LightOfDawn',
        on = {
            label = 'LoD',
            color = dark_addon.interface.color.orange,
            color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
        },
        off = {
            label = 'LoD',
            color = dark_addon.interface.color.grey,
            color2 = dark_addon.interface.color.dark_grey
        }
    })
end

dark_addon.rotation.register({
    spec = dark_addon.rotation.classes.shaman.restoration,
    name = 'ShamPalRest',
    label = 'restoration shaman - not updated for 8.1',
    combat = combat,
    resting = resting,
    interface = interface,
})
