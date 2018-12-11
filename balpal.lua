-- Balance Druid for 8.1 by Laksmackt - 10/2018
-- Talents: 3132222  or wahtever ...most works
-- Holding Alt = Treants
-- Holding Shift = Starfall (will halt starsurge)
-- Holding CONTROL = Battle Rez (works w/ raid frames)

local addon, dark_addon = ...
local SB = dark_addon.rotation.spellbooks.druid
local TB = dark_addon.rotation.talentbooks.druid
local DS = dark_addon.rotation.dispellbooks.soothe

local outdoor = IsOutdoors()
local indoor = IsIndoors()
local realmName = GetRealmName()
local race = UnitRace("player")
local x = 0 -- counting seconds in resting
local y = 0 -- counter for opener
local z = 0 -- time in combat


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

--- Combat Rotation
local function combat()

  z = z + 1    --combat timer

  -----------------------------
  --- Modifiers
  -----------------------------
  --battle rez
  if modifier.control and not mouseover.alive and -spell(SB.Rebirth) == 0 then
    return cast(SB.Rebirth, 'mouseover')
  end

  --Starfall
  if modifier.lshift and talent(5, 1) and -spell(SB.Starfall) == 0 and power.astral.actual > 40 then
    return cast(SB.Starfall, 'ground')
  elseif modifier.lshift and -spell(SB.Starfall) == 0 and power.astral.actual > 50 then
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

  -----------------------------
  --- Determine mobs in range (not 100% right)
  -----------------------------
  local inRange = 0

  if toggle('multitarget', false) then
    for i = 1, 40 do
      if UnitExists('nameplate' .. i) and IsSpellInRange('Moonfire', 'nameplate' .. i) == 1 and UnitAffectingCombat('nameplate' .. i) then
        inRange = inRange + 1
      end
    end
  else
    inRange = 1
  end

  --print(inRange)

  if GetShapeshiftForm() == 3 or player.buff(SB.Prowl).up or player.buff(SB.TigerDashBuff).up or player.buff(SB.Dash).up or not player.alive then
    return
  end


  -----------------------------
  --- Health stone / Trinket  /etc
  -----------------------------

  --Health stone
  if player.health.percent < 35 and GetItemCount(5512) >= 1 and GetItemCooldown(5512) then
    macro('/use Healthstone')
  end

  -----------------------------
  ---     Innervate/ Inno
  -----------------------------
  if toggle('Innervate', false) and IsInGroup() and -spell(SB.Innervate) == 0 then
    if healer == nill then
      local healer = (findHealer())
    end
    if healer.castable(SB.Innervate) and tank.health.percent < 80 then
      print("Innervate on " .. healer)
      return cast(SB.Innervate, healer)
    end
  end

  -- print(z)
  if toggle('Innervate', false) and IsInGroup() and -spell(SB.Innervate) == 0 and z > 40 then
    return macro("/cast [target=Djhavok] Innervate")
  end


  -----------------------------
  --- Moving!
  -----------------------------

  if player.moving then
    if talent(1, 2) then
      if player.buff(SB.WarriorOfElune).up and target.castable(SB.LunarStrike) then
        return cast(SB.LunarStrike, 'target')
      end
      if player.buff(SB.WarriorOfElune).down and -spell(SB.WarriorOfElune) == 0 then
        return cast(SB.WarriorOfElune, player)
      end
    end
    if not modifier.shift and -spell(SB.Starsurge) == 0 and power.astral.actual >= 40 then
      return cast(SB.Starsurge, 'target')
    end
    if target.castable(SB.Sunfire) and (not target.debuff(SB.SunfireDebuff).exists or target.debuff(SB.SunfireDebuff).remains < 3.6) then
      return cast(SB.Sunfire, 'target')
    end
    if -spell(SB.Moonfire) == 0 then
      return cast(SB.Moonfire, target)
    end
  end


  -----------------------------
  --- Rotation
  -----------------------------

  -- Moonkin Form
  if not toggle('TANK', false) and not lastcast(SB.MoonkinForm) and player.buff(SB.TigerDashBuff).down and GetShapeshiftForm() ~= 4 then
    return cast(SB.MoonkinForm, player)
  end

  -----------------------------
  --- Opener   it is assumed that you start the fight with a solar wrath
  -----------------------------

  if toggle('opener', false) and y < 5 and power.astral.actual < 40 then
    if target.castable(SB.SolarWrath) and y == 0 then
      y = y + 1
      return cast(SB.SolarWrath, 'target')
    end
    if target.castable(SB.Moonfire) and y == 1 and (not target.debuff(SB.MoonfireDebuff).exists or target.debuff(SB.MoonfireDebuff).remains < 4.8) then
      return cast(SB.Moonfire, 'target')
    end
    if target.castable(SB.Sunfire) and y == 1 and (not target.debuff(SB.SunfireDebuff).exists or target.debuff(SB.SunfireDebuff).remains < 3.6) then
      y = y + 1
      return cast(SB.Sunfire, 'target')
    end
    if target.castable(SB.SolarWrath) then
      --print("pew")
      return cast(SB.SolarWrath, 'target')
    end
  end
  if toggle('opener', false) and power.astral.actual >= 40 and y ~= 99 then
    print("opener stop")
    y = 99
  end

  if toggle('simc', false) then

    if IsInRaid() and (player.buff(SB.IncarnationBalance).up or player.buff(SB.CelestialAlignment).up) and GetItemCount(152559) >= 1 and GetItemCooldown(152559) == 0 then
      macro('/use Potion of Rising Death')
      print("glug glug")
      cast(SB.Berserking)
    end

    if talent(1, 2) and -player.spell(SB.WarriorOfElune) == 0 then
      return cast(SB.WarriorOfElune)
    end

    badguy = UnitClassification("target")
    if toggle('cooldowns', false) and badguy ~= "normal" and badguy ~= "minus" then
      if talent(7, 3) and power.astral.actual > 40 and -spell(SB.IncarnationBalance) == 0 then
        return cast(SB.IncarnationBalance)
      elseif power.astral.actual > 40 and -spell(SB.CelestialAlignment) == 0 then
        return cast(SB.CelestialAlignment)
      end
      if talent(7, 2) and -player.spell(SB.FuryofElune) == 0 and (player.buff(SB.IncarnationBalance).up or -spell(SB.IncarnationBalance) > 30) then
        return cast(SB.FuryofElune, 'target')
      end
    end
    if talent(1, 3) and toggle('FON', false) and -spell(SB.ForceofNature) == 0 and (player.buff(SB.IncarnationBalance).up or -spell(SB.IncarnationBalance) > 30) then
      return cast(SB.ForceofNature, 'ground')
    end
    if talent(1, 3) and toggle('FON', false) and toggle('cooldowns', true) and -spell(SB.ForceofNature) == 0 then
      return cast(SB.ForceofNature, 'ground')
    end

    if target.castable(SB.Sunfire) and power.astral.deficit > 7 and (not target.debuff(SB.SunfireDebuff).exists or target.debuff(SB.SunfireDebuff).remains < 3.6) then
      return cast(SB.Sunfire, 'target')
    end
    if target.castable(SB.Moonfire) and power.astral.deficit > 7 and (not target.debuff(SB.MoonfireDebuff).exists or target.debuff(SB.MoonfireDebuff).remains < 4.8) then
      return cast(SB.Moonfire, 'target')
    end
    if talent(6, 3) and target.castable(SB.StellarFlare) and power.astral.deficit > 12 and (not target.debuff(SB.StellarFlare).exists or target.debuff(SB.StellarFlare).remains < 7.2) then
      return cast(SB.StellarFlare, 'target')
    end
    if target.castable(SB.LunarStrike) and power.astral.deficit >= 16 and player.buff(SB.LunarEmpowerment).count == 3 then
      return cast(SB.LunarStrike, 'target')
    elseif target.castable(SB.LunarStrike) and inRange < 3 and power.astral.actual >= 40 and player.buff(SB.LunarEmpowerment).count == 2 and player.buff(SB.SolarEmpowerment).count == 2 then
      return cast(SB.LunarStrike, 'target')
    end
    if target.castable(SB.SolarWrath) and player.buff(SB.SolarEmpowerment).count == 3 and power.astral.deficit > 12 and inRange < 3 and player.buff(SB.Sunblaze).down then
      return cast(SB.SolarWrath, 'target')
    end

    if target.castable(SB.Starsurge) then
      if inRange < 3 and player.moving then
        return cast(SB.Starsurge, target)
      end
      if ((player.buff(SB.LunarEmpowerment).count * 12) + (player.buff(SB.SolarEmpowerment).count * 8) + power.astral.actual) > 96 then
        return cast(SB.Starsurge, target)
      end
    end

    if target.castable(SB.LunarStrike) then
      if player.buff(SB.WarriorOfElune).up then
        return cast(SB.LunarStrike, 'target')
      elseif inRange >= 3 and player.buff(SB.IncarnationBalance).up and player.buff(SB.LunarEmpowerment).count >= 1 and player.buff(SB.DawningSun).down then
        return cast(SB.LunarStrike, 'target')
      end
    end

    if target.castable(SB.SolarWrath) then
      return cast(SB.SolarWrath, 'target')
    end
    if target.castable(SB.Moonfire) then
      return cast(SB.Moonfire, 'target')
    end
    return
  end

  -- end simc







  --TANK SECTION - EMERGENCY BEAR
  if toggle('TANK', false) and talent(3, 2) then

    if toggle('interrupts', false) and target.interrupt() and player.talent(4, 1) and -spell(SB.MightyBash) == 0 then
      return cast(SB.MightyBash)
    end

    --going bear
    if castable(SB.BearForm, 'player') and not -buff(SB.BearForm) then
      return cast(SB.BearForm, 'player')
    end

    auto_attack()

    --- Frenzied Regeneration
    if castable(SB.FrenziedRegeneration, 'player') and not -buff(SB.FrenziedRegeneration) and player.health.percent < 50 then
      return cast(SB.FrenziedRegeneration, 'player')
    end

    if castable(SB.Ironfur, 'player') and not -buff(SB.Ironfur) then
      return cast(SB.Ironfur, 'player')
    end

    if not target.debuff(SB.MoonfireDebuff) or target.debuff(SB.MoonfireDebuff).remains <= 3 then
      return cast(SB.Moonfire, 'target')
    end

    if -spell(SB.Mangle) == 0 and target.distance <= 10 then
      return cast(SB.Mangle, 'target')
    end

    if castable(SB.Thrash, 'target') and target.distance <= 10 then
      return cast(SB.Thrash, 'target')
    end
    return
  end


  --Manual treants
  if talent(1, 3) and modifier.lalt and -spell(SB.ForceofNature) == 0 then
    return cast(SB.ForceofNature, 'ground')
  end

  -- Interupts
  if toggle('interrupts', false) and target.interrupt() and target.distance <= 45 and -spell(SB.SolarBeam) == 0 then
    return cast(SB.SolarBeam, 'target')
  end

  -- Barkskin
  if player.health.percent < 65 and -spell(SB.Barkskin) == 0 then
    return cast(SB.Barkskin, 'player')
  end

  --- CD /Healing
  if toggle('Heal', false) then

    if talent(3, 3) then
      -- Swiftmend
      if player.castable(SB.Swiftmend) and player.health.percent < 50 and (not player.buff(SB.MoonkinForm).exists or player.health.percent < 30) then
        return cast(SB.Swiftmend, player)
      end
      -- Rejuvenation
      if player.castable(SB.Rejuvenation) and player.health.percent < 75 and not player.buff(SB.MoonkinForm).exists and not (player.buff(SB.Rejuvenation).up or player.buff(SB.RejuvenationGermination).up) then
        return cast(SB.Rejuvenation, player)
      end
    end

    -- Regrowth
    if player.castable(SB.Regrowth) and ((player.health.percent < 48 and not player.buff(SB.Regrowth).up) or player.health.percent < 30) then
      return cast(SB.Regrowth, player)
    end

    if talent(2, 2) and -spell.castable(SB.Renewal) and player.health.percent < 50 then
      return cast(SB.Renewal, player)
    end
  end

  --[[
  if target.castable(SB.Soothe) then
    for i = 1, 40 do
      local name, _, _, count, debuff_type, _, _, _, _, _, spell_id = UnitAura("target", i)
      print(name)
      print(spell_id)
      if name and DS[spell_id] then
        print("Soothing " .. name .. " off the target.")
        return cast(SB.Soothe, target)
      end
    end
  end
]]

  --Cooldowns
  if toggle('cooldowns', false) then
    if talent(5, 3) and -spell(SB.IncarnationBalance) == 0 and power.astral.actual >= 40 and target.health.percent > 80 then
      return cast(SB.IncarnationBalance)
    end

    if not talent(5, 3) and -spell(SB.CelestialAlignment) == 0 and power.astral.actual >= 40 and target.health.percent > 80 then
      return cast(SB.CelestialAlignment)
    end
  end

  if talent(1, 3) and toggle('FON', false) and -spell(SB.ForceofNature) == 0 then
    if (player.buff(SB.CelestialAlignment).up or player.buff(SB.IncarnationBalance).up) then
      return cast(SB.ForceofNature, 'ground')
    end
    if (-spell(SB.IncarnationBalance) > 60 or -spell(SB.CelestialAlignment) > 60) then
      return cast(SB.ForceofNature, 'ground')
    end

  end


  --Racial

  if toggle('racial', false) then
    if race == 'Troll' and -spell(SB.Berserking) == 0 and (player.buff(SB.CelestialAlignment).up or player.buff(SB.IncarnationBalance).up) then
      cast(SB.Berserking, player)
    end
  end


  --maintain dots on target  - sun/moon/astral
  if target.castable(SB.Sunfire) and (not target.debuff(SB.SunfireDebuff).exists or target.debuff(SB.SunfireDebuff).remains < 3.6) then
    return cast(SB.Sunfire, 'target')
  end

  if target.castable(SB.Moonfire) and (not target.debuff(SB.MoonfireDebuff).exists or target.debuff(SB.MoonfireDebuff).remains < 4.8) then
    return cast(SB.Moonfire, 'target')
  end

  if talent(6, 3) and target.castable(SB.StellarFlare) and not target.debuff(SB.StellarFlare).exists then
    return cast(SB.StellarFlare, 'target')
  end
  if talent(7, 2) and target.castable(SB.FuryofElune) then
    return cast(SB.FuryofElune, 'target')
  end




  -- StarSurge for Soul of the forrest and Incarnation
  if not talent(5, 2) and not modifier.shift and inRange <= 2 and target.castable(SB.Starsurge) and player.buff(SB.LunarEmpowerment).count <= 2 and player.buff(SB.SolarEmpowerment).count <= 2 and power.astral.actual > 40 then
    return cast(SB.Starsurge, 'target')
  end

  --Starlord specific - maximizing haste without overcapping
  if talent(5, 2) and not modifier.shift and target.castable(SB.Starsurge) then
    if player.buff(SB.Starlord).down then
      return cast(SB.Starsurge, target)
    elseif player.buff(SB.Starlord).count < 3 and player.buff(SB.Starlord).remains > 6 then
      return cast(SB.Starsurge, 'target')
    elseif player.buff(SB.LunarEmpowerment).count == 1 and player.buff(SB.SolarEmpowerment).count == 0 and power.astral.actual == 100 then
      return cast(SB.Starsurge, 'target')
    elseif power.astral.actual == 100 and player.buff(SB.Starlord).count == 3 and player.buff(SB.Starlord).remains >= 7 then
      return cast(SB.Starsurge, 'target')
    end
  end
  --nukes

  if talent(1, 2) then
    --    if player.buff(SB.WarriorOfElune).up and target.castable(SB.LunarStrike) and player.buff(SB.LunarEmpowerment).up then
    --      return cast(SB.LunarStrike, 'target')
    --    end
    if player.buff(SB.WarriorOfElune).down and -spell(SB.WarriorOfElune) == 0 then
      return cast(SB.WarriorOfElune, player)
    end
  end

  --if toggle('multitarget', true) then
  if inRange <= 1 then
    --print("solo target")
    if target.castable(SB.SolarWrath) and player.buff(SB.SolarEmpowerment).count >= 1 then
      return cast(SB.SolarWrath, 'target')
    end
    if target.castable(SB.LunarStrike) and player.buff(SB.LunarEmpowerment).count >= 1 then
      return cast(SB.LunarStrike, 'target')
    end
    if target.castable(SB.SolarWrath) then
      return cast(SB.SolarWrath, 'target')
    end
    if target.castable(SB.LunarStrike) then
      return cast(SB.LunarStrike, 'target')
    end

  end

  --if toggle('multitarget', false) then
  if inRange > 1 then
    --print("multi target")
    if target.castable(SB.LunarStrike) and player.buff(SB.LunarEmpowerment).count >= 1 then
      return cast(SB.LunarStrike, 'target')
    end
    if target.castable(SB.SolarWrath) and player.buff(SB.SolarEmpowerment).count >= 1 then
      return cast(SB.SolarWrath, 'target')
    end
    if target.castable(SB.LunarStrike) then
      return cast(SB.LunarStrike, 'target')
    end
    if target.castable(SB.SolarWrath) then
      return cast(SB.SolarWrath, 'target')
    end
  end
end

local function resting()

  y = 0
  z = 0
  if GetShapeshiftForm() == 3 and player.moving then
    return
  elseif toggle('Forms', false) and not player.moving and player.buff(SB.Prowl).down and player.buff(SB.MoonkinForm).down and player.buff(SB.TigerDashBuff).down and player.buff(SB.Dash).down and player.alive then
    x = x + 1
    if x >= 14 then
      x = 0
      return cast(SB.MoonkinForm)
    end
  end

  if player.alive then
    if toggle('Heal', false) then
      -- Swiftmend
      if player.castable(SB.Swiftmend) and player.health.percent < 50 and (not player.buff(SB.MoonkinForm).exists or player.health.percent < 30) then
        return cast(SB.Swiftmend, player)
      end
      -- Rejuvenation
      if player.castable(SB.Rejuvenation) and player.health.percent < 75 and not player.buff(SB.MoonkinForm).exists and not (player.buff(SB.Rejuvenation).up or player.buff(SB.RejuvenationGermination).up) then
        return cast(SB.Rejuvenation, player)
      end
      -- Regrowth
      if player.castable(SB.Regrowth) and ((player.health.percent < 48 and not player.buff(SB.Regrowth).up) or player.health.percent < 30) then
        return cast(SB.Regrowth, player)
      end
      -- Barkskin
      if player.health.percent < 20 and -spell(SB.Barkskin) == 0 then
        return cast(SB.Barkskin, 'player')
      end

    end

    if toggle('Forms', false) and player.moving then
      x = x + 1
      local outdoor = IsOutdoors()
      if outdoor and x >= 8 then
        x = 0
        return cast(SB.TravelForm)
      end
    end


  end


end

function interface()
  dark_addon.interface.buttons.add_toggle({
    name = 'opener',
    label = 'Opener',
    font = 'dark_addon_icon',
    on = {
      label = dark_addon.interface.icon('bars'),
      color = dark_addon.interface.color.green,
      color2 = dark_addon.interface.color.dark_green
    },
    off = {
      label = dark_addon.interface.icon('bars'),
      color = dark_addon.interface.color.grey,
      color2 = dark_addon.interface.color.dark_grey
    }
  })

  dark_addon.interface.buttons.add_toggle({
    name = 'Heal',
    label = 'Defensive CD',
    on = {
      label = 'Heal',
      color = dark_addon.interface.color.orange,
      color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
    },
    off = {
      label = 'Heal',
      color = dark_addon.interface.color.grey,
      color2 = dark_addon.interface.color.dark_grey
    }
  })
  dark_addon.interface.buttons.add_toggle({
    name = 'Forms',
    label = 'change forms',
    on = {
      label = 'Forms',
      color = dark_addon.interface.color.orange,
      color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
    },
    off = {
      label = 'Forms',
      color = dark_addon.interface.color.grey,
      color2 = dark_addon.interface.color.dark_grey
    }
  })
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
    name = 'FON',
    label = 'Auto Treants',
    on = {
      label = 'FoN',
      color = dark_addon.interface.color.orange,
      color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
    },
    off = {
      label = 'FoN',
      color = dark_addon.interface.color.grey,
      color2 = dark_addon.interface.color.dark_grey
    }
  })
  dark_addon.interface.buttons.add_toggle({
    name = 'Innervate',
    label = 'Auto Innervate',
    on = {
      label = 'Inno',
      color = dark_addon.interface.color.orange,
      color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
    },
    off = {
      label = 'Inno',
      color = dark_addon.interface.color.grey,
      color2 = dark_addon.interface.color.dark_grey
    }
  })
  dark_addon.interface.buttons.add_toggle({
    name = 'TANK',
    label = 'bear form tank',
    on = {
      label = 'BEAR',
      color = dark_addon.interface.color.orange,
      color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
    },
    off = {
      label = 'OWL',
      color = dark_addon.interface.color.grey,
      color2 = dark_addon.interface.color.dark_grey
    }
  })
  dark_addon.interface.buttons.add_toggle({
    name = 'simc',
    label = 'SimC rotation',
    on = {
      label = 'simc',
      color = dark_addon.interface.color.orange,
      color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
    },
    off = {
      label = 'simc',
      color = dark_addon.interface.color.grey,
      color2 = dark_addon.interface.color.dark_grey
    }
  })
end

dark_addon.rotation.register({
  spec = dark_addon.rotation.classes.druid.balance,
  name = 'balance',
  label = 'Bundled Balance',
  combat = combat,
  resting = resting,
  interface = interface
})
