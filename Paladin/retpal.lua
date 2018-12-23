-- Retribution Paladin for 8.1 by Laksmackt - 12/2018
-- Holding Shift = Hammer of Justice



local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.paladin

--spells
SB.EmpyreanPower = 286393

local race = UnitRace("player")

local function combat()
    if not target.alive or not target.enemy then
        return
    end

    if target.enemy and target.distance <= 8 then
        auto_attack()
    end

    if toggle('multitarget', false) then
        enemyCount = enemies.around(8)
    elseif toggle('multitarget', true) then
        enemyCount = 1
    end

-- defensive
-- defensive

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
    --cool downs
    if not talent(4, 3) and race == "Blood Elf" and -spell(SB.ArcaneTorrent) == 0 then
        return cast(SB.ArcaneTorrent)
    elseif -power.holypower <= 4 and race == "Blood Elf" and -spell(SB.ArcaneTorrent) == 0 then
        return cast(SB.ArcaneTorrent)
    end

    if castable(SB.ShieldofVengeance) then
        return cast(SB.ShieldofVengeance)
    end

    if talent(7, 3) and player.buff(SB.Inquisition).up and castable(SB.AvengingWrath) then
        return cast(SB.AvengingWrath)
    elseif talent(7, 1) and castable(SB.AvengingWrath) then
        return cast(SB.AvengingWrath)
    end

    --crusade talent
    if talent(7, 2) and -power.holypower >= 4 and castable(SB.Crusade) then
        return cast(SB.Crusade)
    end
    --end cool downs

    --Inquisition talent

    if talent(7, 3) and castable(SB.Inquisition) then
        if player.buff(SB.Inquisition).down or (player.buff(SB.Inquisition).remains < 5 and -power.holypower >= 3) then
            return cast(SB.Inquisition)
        elseif talent(1, 3) and -spell(SB.ExecutionSentence) < 10 and player.buff(SB.Inquisition).remains < 15 then
            return cast(SB.Inquisition)
        elseif -spell(SB.AvengingWrath) < 15 and player.buff(SB.Inquisition).remains < 20 and -power.holypower >= 3 then
            return cast(SB.Inquisition)
        end
    end

    if talent(1, 3) and castable(SB.ExecutionSentence, 'target') then
        if enemyCount <= 2 and not talent(7, 2) or (enemyCount <= 2 and talent(7, 2) and player.buff(SB.Crusade).down and -spell(SB.Crusade) > ((1.5 / ((UnitSpellHaste("player") / 100) + 1)) * 2)) then
            return cast(SB.ExecutionSentence, 'target')
        end
    end

    -- Divine Storm



    if castable(SB.DivineStorm) and player.buff(SB.EmpyreanPower).up then
        return cast(SB.DivineStorm)
    end

    if castable(SB.DivineStorm) and -power.holypower >= 3 and enemyCount >= 2 then
        if talent(7, 1) and player.buff(SB.DivinePurpose).up then
            return cast(SB.DivineStorm)
        elseif talent(7, 2) and player.buff(SB.Crusade).down and -spell(SB.Crusade) > ((1.5 / ((UnitSpellHaste("player") / 100) + 1)) * 2) then
            return cast(SB.DivineStorm)
        elseif -power.holypower == 5 then
            return cast(SB.DivineStorm)
        end
    end


    -- templars_verdict

    if castable(SB.TemplarsVerdict, 'target') then
        if player.buff(SB.DivinePurpose).up then
            return cast(SB.TemplarsVerdict, 'target')
        elseif talent(7, 2) and player.buff(SB.Crusade).down and -spell(SB.Crusade) > ((1.5 / ((UnitSpellHaste("player") / 100) + 1)) * 3) and player.buff(SB.ExecutionSentence).down then
            return cast(SB.TemplarsVerdict, 'target')
        elseif player.buff(SB.Crusade).up and player.buff(SB.Crusade).count < 10 then
            return cast(SB.TemplarsVerdict, 'target')
        elseif talent(1, 3) and -spell(SB.ExecutionSentence) > ((1.5 / ((UnitSpellHaste("player") / 100) + 1)) * 2) then
            return cast(SB.TemplarsVerdict, 'target')
        elseif -power.holypower == 5 then
            return cast(SB.TemplarsVerdict, 'target')
        end
    end

    local HoW = 'foo'
    if not talent(2, 3) and target.health.percent >= 20 and (player.buff(SB.AvengingWrath).down or player.buff(SB.Crusade).down) then
        local HoW = 'true'
    end

    -- call_action_list,name=finishers,if=holy_power>=5

    if castable(SB.WakeofAshes) and -power.holypower == 0 and enemyCount >= 2 then
        return cast(SB.WakeofAshes)
    elseif castable(SB.WakeofAshes) and -power.holypower == 1 and -spell(SB.BladeOfJustice) > ((1.5 / ((UnitSpellHaste("player") / 100) + 1)) * 1) then
        return cast(SB.WakeofAshes)
    end

    if castable(SB.BladeOfJustice, 'target') and -power.holypower <= 2 then
        return cast(SB.BladeOfJustice, 'target')
    elseif castable(SB.BladeOfJustice, 'target') and -power.holypower == 3 and (-spell(SB.HammerofWrath) > ((1.5 / ((UnitSpellHaste("player") / 100) + 1)) * 2) or HoW == 'true') then
        return cast(SB.BladeOfJustice, 'target')
    end

    if castable(SB.Judgment, 'target') and -power.holypower <= 2 then
        return cast(SB.Judgment)
    elseif castable(SB.Judgment, 'target') and -power.holypower <= 4 and (-spell(SB.BladeOfJustice) > ((1.5 / ((UnitSpellHaste("player") / 100) + 1)) * 2) or HoW == 'true') then
        return cast(SB.Judgment)
    end

    if target.enemy and -power.holypower <= 4 and target.castable(SB.HammerofWrath) and (target.health.percent <= 20 or (player.buff(SB.AvengingWrath).up or player.buff(SB.Crusade).up)) then
        return cast(SB.HammerofWrath, target)
    end

    --consecration
    if talent(4, 2) and castable(SB.ConsecrationRet) then
        if -power.holypower <= 2 or (-power.holypower <= 3 and -spell(SB.BladeOfJustice) > ((1.5 / ((UnitSpellHaste("player") / 100) + 1)) * 2)) then
            return cast(SB.ConsecrationRet)
        elseif -power.holypower == 4 and -spell(SB.BladeOfJustice) > ((1.5 / ((UnitSpellHaste("player") / 100) + 1)) * 2) and -spell(SB.Judgment) > ((1.5 / ((UnitSpellHaste("player") / 100) + 1)) * 2) then
            return cast(SB.ConsecrationRet)
        end
    end

    --crusader strike
    if castable(SB.CrusaderStrike, 'target') then
        if -power.holypower <= 3 and -spell(SB.BladeOfJustice) > ((1.5 / ((UnitSpellHaste("player") / 100) + 1)) * 2) then
            return cast(SB.CrusaderStrike)
        elseif -spell(SB.BladeOfJustice) > ((1.5 / ((UnitSpellHaste("player") / 100) + 1)) * 2) and -spell(SB.ConsecrationRet) > ((1.5 / ((UnitSpellHaste("player") / 100) + 1)) * 2) and -spell(SB.Judgment) > ((1.5 / ((UnitSpellHaste("player") / 100) + 1)) * 2) then
            return cast(SB.CrusaderStrike)
        elseif -power.holypower <= 4 then
            return cast(SB.CrusaderStrike)
        end
    end

    --[[

    P	43.78	crusader_strike,if=holy_power<=4
    Q	2.20	arcane_torrent,if=holy_power<=4

            ]]
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