--[[
Elemental Shaman Rotation by Laksmact - PRE 8.1
]]


local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.shaman
local race = UnitRace("player")
local x = 0
local function combat()


  --Spells not in spellbook
SB.Berserking = 26297
SB.StormKeeper = 191634
  -----
  --- how many in range
  -----
  local inRange = 0
  for i = 1, 40 do
    if UnitExists('nameplate' .. i) and IsSpellInRange('Wind Shear', 'nameplate' .. i) == 1 and UnitAffectingCombat('nameplate' .. i) then
      inRange = inRange + 1
    end
  end
  --print(inRange)



  if talent(2, 3) and modifier.alt then
    return cast(SB.TotemMastery)
  end

  if modifier.shift and -power.maelstrom >= 60 then
    return cast(SB.Earthquake, 'ground')
  end

  if modifier.control and -spell(SB.CapacitorTotem) == 0 then
    return cast(SB.CapacitorTotem, 'ground')
  end

  if target.alive and target.enemy then

    if talent(2, 3) and player.buff(SB.StormTotem).down then
      return cast(SB.TotemMastery)
    end

    --------------------
    --- racial
    --------------------
    if race == 'Troll' then
      if talent(7, 3) and player.buff(SB.Ascendance).up and player.castable(SB.Berserking) then
        cast(SB.Berserking)
      elseif not talent(7, 3) and -spell(SB.Berserking) == 0 then
        cast(SB.Berserking)
      end
    end
    -- Interupts
    if toggle('interrupts', false) and target.interrupt(50) and target.distance <= 30 and castable(SB.WindShear) then
      return cast(SB.WindShear, 'target')
    end

    --Cool Downs

    if toggle('cooldowns') and castable(SB.FireElemental) then
      return cast(SB.FireElemental)
    end
    -- if toggle('cooldowns') and -spell(SB.EarthElemental) == 0 and -spell(SB.FireElemental) > 60 and -spell(SB.FireElemental) < 120 then
    --   return cast(SB.EarthElemental)
    -- end

    if talent(4, 3) and toggle('cooldowns') and -spell(SB.LiquidMagmaTotem) == 0 then
      return cast(SB.LiquidMagmaTotem, 'ground')
    end
    if talent(7, 3) and toggle('cooldowns') and -spell(SB.Ascendance) == 0 then
      return cast(SB.Ascendance)
    end

    if talent(7, 2) and toggle('cooldowns') and -spell(SB.StormKeeper) == 0 and (inRange >= 3 or (UnitClassification("target") == "worldboss" or UnitClassification("target") == "rareelite")) then
      return cast(SB.StormKeeper)
    end
    --print(UnitClassification("target"))
    -- defensive cooldowns
    if toggle('DEF', false) then
      if castable(SB.AstralShift) and player.health.percent <= 80 then
        return cast(SB.AstralShift, player)
      end
      if player.health.percent <= 30 and castable(SB.HealingSurgeEle, player) then
        return cast(SB.HealingSurgeEle, player)
      end
      if player.health.percent <= 50 and castable(SB.EarthElemental) == 0 then
        return cast(SB.EarthElemental, player)
      end
    end

    if talent(1, 3) and -spell(SB.ElementalBlast) == 0 then
      return cast(SB.ElementalBlast, target)
    end

    if not modifier.shift and inRange <= 3 and -power.maelstrom >= 90 and -spell(SB.EarthShock) == 0 then
      return cast(SB.EarthShock)
    end

    if -spell(SB.FlameShock) == 0 and (not target.debuff(SB.FlameShock) or target.debuff(SB.FlameShock).remains <= 6) then
      return cast(SB.FlameShock)
    end

    if player.buff(SB.LavaSurge).up and target.debuff(SB.FlameShock).up then
      return cast(SB.LavaBurst, target)
    end

    if not modifier.shift and -spell(SB.EarthShock) == 0 and -power.maelstrom >= 60 and inRange <= 3 then
      return cast(SB.EarthShock)
    end

    if player.moving and -spell(SB.FrostShock) == 0 then
      return cast(SB.FrostShock)
    end

    if toggle('multitarget', false) and inRange <= 2 and target.castable(SB.LavaBurst) and target.debuff(SB.FlameShock).up then
      return cast(SB.LavaBurst, target)
    end

    if toggle('multitarget', false) and inRange >= 2 then
      if castable(SB.ChainLightning) then return cast(SB.ChainLightning, target) end
    elseif toggle('multitarget', false) and inRange == 1 or toggle('multitarget', true) then
      if castable(SB.LightningBolt)then return cast(SB.LightningBolt, target) end
    end

  end
end

local function resting()
  if talent(2, 3) and modifier.alt then
    return cast(SB.TotemMastery)
  end

  if modifier.shift and -power.maelstrom >= 60 then
    return cast(SB.Earthquake, 'ground')
  end

  if modifier.control and -spell(SB.CapacitorTotem) == 0 then
    return cast(SB.CapacitorTotem, 'ground')
  end

  if player.moving and not player.buff(SB.GhostWolf).up then
    x = x + 1
    if x >= 7 then
      x = 0
      return cast(SB.GhostWolf)
    end
  end
end

function interface()
  dark_addon.interface.buttons.add_toggle({
    name = 'DEF',
    label = 'Defensive CD',
    on = {
      label = 'DEF',
      color = dark_addon.interface.color.orange,
      color2 = dark_addon.interface.color.ratio(dark_addon.interface.color.dark_orange, 0.7)
    },
    off = {
      label = 'DEF',
      color = dark_addon.interface.color.grey,
      color2 = dark_addon.interface.color.dark_grey
    }
  })
end

dark_addon.rotation.register({
  spec = dark_addon.rotation.classes.shaman.elemental,
  name = 'ShamPalEle',
  label = 'not optimized for 8.1',
  combat = combat,
  resting = resting,
  interface = interface
})
