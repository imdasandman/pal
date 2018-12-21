-- Retribution Paladin for 8.1 by Laksmackt - 12/2018
-- Holding Shift = Hammer of Justice



local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.paladin

local race = UnitRace("player")

local function combat()
    if not target.alive or not target.enemy then
        return
    end

    if target.enemy and target.distance <= 8 then
        auto_attack()
    end

    -- Interupts
    if toggle('interrupts', false) and target.interrupt() and target.distance < 8 and -spell(SB.Rebuke) == 0 then
        return cast(SB.Rebuke, 'target')
    end
    if toggle('interrupts', false) and target.interrupt() and target.distance < 8 and -spell(SB.Rebuke) > 0 and -spell(SB.BlindingLight) == 0 then
        return cast(SB.BlindingLight, 'target')
    end
    if toggle('interrupts', false) and target.interrupt() and target.distance < 8 and -spell(SB.Rebuke) > 0 and -spell(SB.BlindingLight) > 0 and -spell(SB.HammerofJustice) == 0 then
        return cast(SB.HammerofJustice, 'target')
    end



    --doomsfury trinket whenever using wings
    if player.buff(SB.AvengingWrath).up and GetItemCooldown(161463) == 0 then
        macro('/use 14')
    end

    if target.enemy and target.distance < 8 and target.health.percent > 50 and GetItemCooldown(159627) == 0 and -spell(SB.AvengingWrath) > 10 and player.buff(SB.AvengingWrath).down then
        macro('/use 13')
    end

    --use healthstone at 40% health and we are in combat
    if GetItemCooldown(5512) == 0 and player.health.percent < 40 then
        macro('/use Healthstone')
    end

    if modifier.shift and -spell(SB.HammerofJustice) == 0 then
        return cast(SB.HammerofJustice, 'target')
    end

    -- Lets use our blessings/LoH
    -- BoP bad players

    if lowest.castable(SB.BlessingofProtection) and lowest.health.percent <= 20 and lowest.debuff(SB.Forbearance).down and lowest ~= tank and lowest ~= player then
        return cast(SB.BlessingofProtection, lowest)
    end

    --BlessingofSacrifice	on semi bad players

    if not talent(4, 3) and lowest.castable(SB.BlessingofSacrifice) and lowest.health.percent <= 40 and lowest ~= tank and lowest ~= player then
        return cast(SB.BlessingofSacrifice, lowest)
    end


    -- LoH on dying players
    if lowest.castable(SB.LayonHands) and lowest.debuff(SB.Forbearance).down and lowest.health.percent <= 15 then
        return cast(SB.LayonHands, lowest)
    end

    if -spell(SB.LayonHands) == 0 and player.debuff(SB.Forbearance).down and player.health.percent <= 15 then
        return cast(SB.LayonHands, player)
    end

    -- self-cleanse
    local dispellable_unit = player.removable('poison', 'disease')
    if dispellable_unit then
        return cast(SB.CleanseToxins, dispellable_unit)
    end


    ---
    ---combat
    ---

    if not talent(4, 3) and race == "Blood Elf" and -spell(SB.ArcaneTorrent) == 0 then
        return cast(SB.ArcaneTorrent)
    end

    if castable(SB.ShieldofVengeance) then
        return cast(SB.ShieldofVengeance)
    end




end

local function resting()
    -- self-cleanse
    local dispellable_unit = player.removable('poison', 'disease')
    if dispellable_unit then
        return cast(SB.CleanseToxins, dispellable_unit)
    end


end

local function interface()
end

dark_addon.rotation.register({
    spec = dark_addon.rotation.classes.paladin.retribution,
    name = 'rettpal',
    label = 'Pal  - RETRIBUTION',
    combat = combat,
    resting = resting,
    interface = interface,
})