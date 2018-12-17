local addon, dark_addon = ...
local SB = dark_addon.rotation.spellbooks.shaman

local function combat()
  if modifier.shift then
    return cast(SB.TotemMastery)
  end
  if target.alive and target.enemy then
    if player.totem(SB.TotemMastery) <= 9 or not -buff(SB.StormTotem) then
      return cast(SB.TotemMastery)
    end
    if -spell(SB.FlameShock) == 0 and not -target.debuff(SB.FlameShock) or target.debuff(SB.FlameShock).remains <= 6 then
      return cast(SB.FlameShock)
    end
    if toggle('cooldowns') and -spell(SB.FireElemental) == 0 then
      return cast(SB.FireElemental)
    end
    if -spell(SB.LiquidMagmaTotem) == 0 then
      return cast(SB.LiquidMagmaTotem, 'ground')
    end
    if -power.maelstrom >= 90 then
      return cast(SB.EarthShock)
    end
    if toggle('cooldowns') and -spell(SB.Ascendance) == 0 then
      return cast(SB.Ascendance)
    end
    if -spell(SB.LavaBurst) == 0 then
      return cast(SB.LavaBurst)
    end
    if player.totem(SB.TotemMastery) <= 9 then
      return cast(SB.TotemMastery)
    end
    if -spell(SB.EarthShock) == 0 and -power.maelstrom >= 60 and not -buff(SB.LavaSurge) then
      return cast(SB.EarthShock)
    end
    if player.moving then
      return cast(SB.FrostShock)
    else
      return cast(SB.LightningBolt)
    end
  end
end

local function resting()
  if modifier.shift then
    return cast(SB.TotemMastery)
  end
end

dark_addon.rotation.register({
  spec = dark_addon.rotation.classes.shaman.elemental,
  name = 'elemental',
  label = 'Bundled Elemental',
  combat = combat,
  resting = resting,
  interface = interface
})
