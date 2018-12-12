-- Holy Paladin for 8.1 by Laksmackt - 9/2018

-- Talents supported: everything EXCEPT Light's Hammer.

--Holding Shift = Hammer of Justice in combat / CC out of combat (if repentance talent is selected)
--Holding CTRL = decurse (at mouseover target - works with raidframes)
--Holding LEFT ALT = Dawn of Light

-- Interrupts - Holy Pally does not have a traditional 'kick' - but if interrupts are selected it will use Blinding Light (if talent is selected)
-- and hammer of justice to stun if it can - if you want to preserve your stuns for manual use - do not select interrupt



local dark_addon = dark_interface
local SB = dark_addon.rotation.spellbooks.paladin
local TB = dark_addon.rotation.spellbooks.paladin
local DB = dark_addon.rotation.spellbooks.paladin
local race = UnitRace("player")


-- enable to treat tank like everyone else - all 'tank' statements will be ignored
--dark_addon.environment.virtual.exclude_tanks = false


local function combat()
    if not player.alive or player.buff(SB.Refreshment).up or player.buff(SB.Drink).up then
        return
    end

    -----------------------------
    --- Reading from settings
    -----------------------------

    local autoStun = dark_addon.settings.fetch('holypal_settings_autoStun')
    local intpercent = dark_addon.settings.fetch('holypal_settings_intpercent')
    local usehealthstone = dark_addon.settings.fetch('holypal_settings_healthstone.check')
    local healthstonepercent = dark_addon.settings.fetch('holypal_settings_healthstone.spin')
    local autoRacial = dark_addon.settings.fetch('holypal_settings_autoRacial')
    local autoAura = dark_addon.settings.fetch('holypal_settings_autoAura')
    local AutoAvengingCrusader = dark_addon.settings.fetch('holypal_settings_autoAvengingCrusader')
    local autoHolyAvenger = dark_addon.settings.fetch('holypal_settings_autoHolyAvenger')
    local autoWrath = dark_addon.settings.fetch('holypal_settings_autoWrath')
    local autoDivineProtection = dark_addon.settings.fetch('holypal_settings_autoDivineProtection')
    local autoDivineShield = dark_addon.settings.fetch('holypal_settings_autoDivineShield')
    local autoBeaconofVirtue = dark_addon.settings.fetch('holypal_settings_autoBeaconofVirtue')

    -----------------------------
    --- Reticulate Splines
    -----------------------------
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

    -----------------------------
    --- Determine mobs in range (not 100% right)
    -----------------------------
    local inRange = 0

    if toggle('multitarget', false) then
        for i = 1, 40 do
            if UnitExists('nameplate' .. i) and IsSpellInRange('Consecration', 'nameplate' .. i) == 1 and UnitAffectingCombat('nameplate' .. i) then
                inRange = inRange + 1
            end
        end
    else
        inRange = 1
    end




    --[[
     if tank.name == nil then
        print ('SET TANK AS FOCUS')
    end

  ]]
    --Trinket/item use
    if GetItemCooldown(160649) == 0 and tank.health.percent < 95 then
        macro('/use [help] 14; [@targettarget] 14')
    end


    --healthstone
    if GetItemCooldown(5512) == 0 and player.health.percent < 30 then
        macro('/use Healthstone')
    end



    -- Modifiers
    if modifier.lshift and target.enemy and -spell(SB.HammerofJustice) == 0 then
        return cast(SB.HammerofJustice, 'target')
    end

    if modifier.lalt and -spell(SB.LightofDawn) == 0 then
        return cast(SB.LightofDawn)
    end

    if modifier.control and -spell(SB.Cleanse) == 0 then
        return cast(SB.Cleanse, 'mouseover')
    end

    if target.enemy and target.distance <= 8 then
        auto_attack()
    end

    -- Interupts
    if toggle('interrupts', false) and talent(3, 3) and target.interrupt() and target.distance <= 10 and -spell(SB.BlindingLight) == 0 then
        return cast(SB.BlindingLight, 'target')
    end

    if toggle('interrupts', false) and autoStun == true and target.interrupt(intpercent, false) and target.distance < 8 and -spell(SB.HammerofJustice) == 0 then
        return cast(SB.HammerofJustice, 'target')
    end

    --if toggle('interrupts', false) and target.interrupt(80) and target.distance < 5 and -spell(SB.WarStomp) == 0 then
    --		return cast(SB.WarStomp)
    --end
    -- Done with Interupts

    --healthstone
    --if hasItem(5512) and GetItemCooldown(5512) == 0 and player.health.percent < 30 then
    --   macro('/use Healthstone')
    --end



    --LightoftheMartyr if moving and other instant is on cd - we all love to hate it!
    if player.moving and lowest.health.percent < 40 and player.health.percent > 50 and -spell(SB.HolyShock) > 0 then
        return cast(SB.LightoftheMartyr, lowest)
    end
    if player.moving and tank.health.percent < 40 and player.health.percent > 50 and -spell(SB.HolyShock) > 0 then
        return cast(SB.LightoftheMartyr, tank)
    end


    -- Beacons
    -- if talent(7, 1) and tank.buff(SB.BeaconofLight).down  then
    --  return cast(SB.BeaconofLight, tank)
    --end
    --if talent(7, 2) and IsInRaid() then
    --  if tank.buff(SB.BeaconofLight).down then
    --   return cast(SB.BeaconofLight, tank)
    -- end
    -- if offtank.buff(SB.BeaconofFaith).down then
    --   return cast(SB.BeaconofFaith, offtank)
    -- end
    --end
    --]



    -- Lets use our blessings/LoH

    -- LoH on dying players
    if tank.castable(SB.LayonHands) and tank.debuff(SB.Forbearance).down and tank.health.percent <= 20 then
        return cast(SB.LayonHands, tank)
    end

    if lowest.castable(SB.LayonHands) and lowest.debuff(SB.Forbearance).down and lowest.health.percent <= 15 then
        return cast(SB.LayonHands, lowest)
    end

    -- BoP bad players
    if toggle('BoP', false) and lowest.castable(SB.BlessingofProtection) and lowest.debuff(SB.Forbearance).down and lowest ~= tank and lowest ~= player and lowest.health.percent <= 20 then
        return cast(SB.BlessingofProtection, lowest)
    end

    --BlessingofSacrifice	on semi bad players
    if tank.castable(SB.BlessingofSacrifice) and tank ~= player and tank.health.percent <= 40 then
        return cast(SB.BlessingofSacrifice, tank)
    end

    if lowest.castable(SB.BlessingofSacrifice) and lowest ~= player and lowest.health.percent <= 20 then
        return cast(SB.BlessingofSacrifice, lowest)
    end



    -- done with blessings


    -- - Decurse

    local dispellable_unit = group.removable('disease', 'magic', 'poison')
    if toggle('DISPELL', false) and dispellable_unit and spell(SB.Cleanse).cooldown == 0 then
        return cast(SB.Cleanse, dispellable_unit)
    end

    -- self-cleanse
    local dispellable_unit = player.removable('disease', 'magic', 'poison')
    if toggle('DISPELL', false) and dispellable_unit then
        return cast(SB.Cleanse, dispellable_unit)
    end


    -- Ok Lets do some cooldowns
    if talent(6, 2) and toggle('cooldowns', false) and AutoAvengingCrusader == true and -spell(SB.AvengingCrusader) == 0 and player.buff(SB.BeaconofVirtue).down and target.distance < 8 and (lowest.health.percent <= 60 or tank.health.percent <= 75 or group_health_percent < 60) and player.buff(SB.HolyAvenger).down then
        --print 'CD - Avenging Crusader'
        return cast(SB.AvengingCrusader, 'player')
    elseif autoWrath == true and (talent(6, 1) or talent(6, 3)) and toggle('cooldowns', false) and -spell(SB.AvengingWrath) == 0 and player.buff(SB.BeaconofVirtue).down and (lowest.health.percent <= 60 or tank.health.percent <= 75 or group_health_percent < 60) and player.buff(SB.HolyAvenger).down then
        --print 'CD - Avenging Crusader'
        return cast(SB.AvengingWrath, 'player')
    end


    -- while Avenging Crusader is active, Crusader Strike is a super heal - so has much higher priority
    if player.buff(SB.AvengingCrusader).up and -spell(SB.CrusaderStrike) == 0 and target.enemy and target.distance < 8 then
        return cast(SB.CrusaderStrike, 'target')
    end

    --Talent row 5  (1 is passive - supports 2+3)
    if autoHolyAvenger == true and talent(5, 3) and toggle('cooldowns', false) and -spell(SB.HolyAvenger) == 0 and lowest.health.percent <= 80 and player.buff(SB.AvengingCrusader).down then
        --print 'CD - HolyAvenger'
        cast(SB.HolyAvenger, 'player')
    elseif talent(5, 2) and toggle('Cooldowns, false') and tank.castable(SB.HolyPrism) and tank.health.percent <= 60 then
        --print 'CD - HolyPrism - tank'
        return cast(SB.HolyPrism, tank)
    elseif talent(5, 2) and toggle('DPS', false) and -spell(SB.HolyPrism) == 0 and target.distance < 40 then
        --print 'CD - HolyPrism - DPS'
        return cast(SB.HolyPrism, target)
    end

    -- defensive cooldowns
    if autoDivineProtection == true and toggle('cooldowns', false) and -spell(SB.DivineProtection) == 0 and player.health.percent < 60 and -spell(SB.DivineProtection) == 0 then
        --print 'CD - Divine Protection'
        cast(SB.DivineProtection, 'player')
    end
    if autoDivineShield == true and toggle('cooldowns', false) and -spell(SB.DivineShield) == 0 and player.health.percent < 20 then
        --print 'CD - Divine Shield'
        return cast(SB.DivineShield, 'player')
    end
    if toggle('cooldowns', false) and autoAura == true and group_health_percent < 55 and -spell(SB.AuraMastery) == 0 then
        --print 'CD - Aura Mastery'
        return cast(SB.AuraMastery)
    end
    -- Talent row 7

    if autoBeaconofVirtue == true and toggle('cooldowns', false) and talent(7, 3) and -spell(SB.BeaconofVirtue) == 0 and player.buff(SB.AvengingCrusader).down and lowest.health.percent < 65 and tank.health.percent < 65 and lowest.distance <= 40 then
        --print 'CD - Beacon of Virtue - lowest'
        return cast(SB.BeaconofVirtue, lowest)
    elseif autoBeaconofVirtue == true and toggle('cooldowns', false) and talent(7, 3) and -spell(SB.BeaconofVirtue) == 0 and player.buff(SB.AvengingCrusader).down and lowest.health.percent < 70 and tank.health.percent < 65 and tank.distance <= 40 then
        --print 'CD - Beacon of Virtue - tank'
        return cast(SB.BeaconofVirtue, tank)
    elseif autoBeaconofVirtue == true and toggle('cooldowns', false) and talent(7, 3) and -spell(SB.BeaconofVirtue) == 0 and player.buff(SB.AvengingCrusader).down and group_health_percent < 70 and lowest.distance <= 40 then
        --print 'CD - Beacon - group low'
        return cast(SB.BeaconofVirtue, lowest)
    elseif autoBeaconofVirtue == true and toggle('cooldowns', false) and talent(7, 3) and -spell(SB.BeaconofVirtue) == 0 and player.buff(SB.AvengingCrusader).down and group_health_percent < 75 and lowest.distance > 40 then
        --print 'CD - Beacon - group low - self'
        return cast(SB.BeaconofVirtue, player)
    end

    -- judgement is high priority due to overall dps but also influences 2 talents and goto azerite trait
    if -spell(SB.Judgment) == 0 and target.enemy and target.distance < 30 then
        --print(tank.name)
        return cast(SB.Judgment, 'target')
    end



    -- holy shock on CD

    if lowest.castable(SB.HolyShock) and lowest.health.percent <= 70 and lowest.distance < 40 then
        return cast(SB.HolyShock, lowest)
    end

    if tank.castable(SB.HolyShock) and tank.health.percent < 80 and tank.distance <= 40 then
        return cast(SB.HolyShock, tank)
    end

    if -spell(SB.HolyShock) == 0 and toggle('DPS', false) and lowest.health.percent > 80 and target.distance < 40 then
        return cast(SB.HolyShock, target)
    end

    -- check range and use RuleofLaw if needed
    if talent(2, 3) and -spell(SB.RuleofLaw) == 0 and lowest.distance > 10 and lowest.distance < 20 and player.buff(SB.RuleofLaw).down then
        return cast(SB.RuleofLaw)
    end

    --Bestow Faith on cooldown
    if talent(1, 2) and -spell(SB.BestowFaith) == 0 and tank.health.percent < 80 and tank.health.percent > 40 and tank.distance < 40 then
        --print 'bestow faith tank'
        return cast(SB.BestowFaith, tank)
    end
    if talent(1, 2) and -spell(SB.BestowFaith) == 0 and lowest.distance < 40 and lowest.health.percent < 85 then
        --print 'bestow faith low'
        return cast(SB.BestowFaith, lowest)
    end

    --LightoftheMartyr if people dying and we can afford the health - we all love to hate it! - this will only trigger if shock is on cd
    if lowest.health.percent < 20 and player.health.percent > 60 and -spell(SB.HolyShock) > 0 then
        return cast(SB.LightoftheMartyr, lowest)
    end
    if tank.health.percent < 20 and player.health.percent > 60 and -spell(SB.HolyShock) > 0 then
        return cast(SB.LightoftheMartyr, tank)
    end





    -- Light of dawn are best used manually, but you can have it done for you should you so desire ... expect to miss a lot
    if toggle('LoD', false) and group_health_percent < 90 and -spell(SB.LightofDawn) == 0 then
        return cast(SB.LightofDawn)
    end

    -- Use any Infusion of Light procs on Flash of Light on low health targets.
    --InfusionofLight

    if player.buff(SB.InfusionofLight) and -spell(SB.FlashofLight) == 0 and tank.health.percent < 70 and tank.distance < 40 then
        return cast(SB.FlashofLight, tank)
    end

    if player.buff(SB.InfusionofLight) and -spell(SB.FlashofLight) == 0 and lowest.health.percent < 80 and lowest.distance < 40 then
        return cast(SB.FlashofLight, lowest)
    end

    if lowest.castable(SB.FlashofLight) and lowest.health.percent < 50 then
        return cast(SB.FlashofLight, lowest)
    end

    if tank.castable(SB.FlashofLight) and tank.health.percent < 50 then
        return cast(SB.FlashofLight, tank)
    end



    --Use Holy Light for low or moderate damage, prioritizing low health targets,

    if lowest.castable(SB.HolyLight) and lowest.health.percent < 80 then
        return cast(SB.HolyLight, lowest)
    end

    if tank.castable(SB.HolyLight) and tank.health.percent < 80 then
        return cast(SB.HolyLight, tank)
    end



    --martyr - we all love to hate it!
    if lowest.health.percent < 40 and lowest ~= player and player.health.percent > 60 and -spell(SB.HolyShock) > 0 then
        return cast(SB.LightoftheMartyr, lowest)
    end

    if tank.health.percent < 40 and player.health.percent > 50 and -spell(SB.HolyShock) > 0 then
        return cast(SB.LightoftheMartyr, tank)
    end

    --dps
    if -spell(SB.CrusaderStrike) == 0 and lowest.health.percent > 50 and tank.health.percent > 50 and target.enemy and target.distance < 8 then
        return cast(SB.CrusaderStrike, 'target')
    end
    --Consecration
    if toggle('DPS', false) and -spell(SB.ConsecrationProt) == 0 and inRange >= 3 and target.debuff(SB.ConsecrationProt).down and lowest.health.percent > 50 and target.distance < 4 then
        return cast(SB.ConsecrationProt, 'player')
    end

    -- uncomment if not blood elf - using racial trait on CD for mana ... make sure to turn this off in Kings Rest if group depend on you for dispell
    if autoRacial == true and race == "Blood Elf" and player.power.mana.percent < 90 and -spell(SB.ArcaneTorrent) == 0 then
        return cast(SB.ArcaneTorrent)
    end

end

local function resting()
    if player.alive and player.buff(SB.Refreshment).down and player.buff(SB.Drink).down then


        --Beacons
        if talent(7, 1) and tank.buff(SB.BeaconofLight).down then
            return cast(SB.BeaconofLight, tank)
        end
        if talent(7, 2) and IsInRaid() then
            if tank.buff(SB.BeaconofLight).down then
                return cast(SB.BeaconofLight, tank)
            end
            if offtank.buff(SB.BeaconofFaith).down then
                return cast(SB.BeaconofFaith, offtank)
            end
            --elseif talent(7, 2) and IsInGroup() then
            --  if tank.buff(SB.BeaconofLight).down then
            --    return cast(SB.BeaconofLight, tank)
            --  end
            --  if player.buff(SB.BeaconofFaith).down then
            --    return cast(SB.BeaconofFaith, player)
            --  end
        end

        -- - Decurse
        local dispellable_unit = group.removable('disease', 'magic', 'poison')
        if toggle('DISPELL', false) and dispellable_unit and spell(SB.Cleanse).cooldown == 0 then
            return cast(SB.Cleanse, dispellable_unit)
        end

        -- self-cleanse
        local dispellable_unit = player.removable('disease', 'magic', 'poison')
        if toggle('DISPELL', false) and dispellable_unit and spell(SB.Cleanse).cooldown == 0 then
            return cast(SB.Cleanse, dispellable_unit)
        end

        if lowest.castable(SB.HolyShock) and lowest.health.percent <= 80 then
            return cast(SB.HolyShock, lowest)
        end

        if lowest.castable(SB.HolyLight) and lowest.health.percent < 85 then
            return cast(SB.HolyLight, lowest)
        end

        if tank.castable(SB.HolyShock) and tank.health.percent <= 80 then
            return cast(SB.HolyShock, tank)
        end

        if tank.castable(SB.HolyLight) and tank.health.percent < 85 then
            return cast(SB.HolyLight, tank)
        end
    end
    if modifier.lshift and talent(3, 2) and target.enemy and -spell(SB.Repentance) == 0 then
        return cast(SB.Repentance, 'target')
    end

    if modifier.lalt and -spell(SB.LightofDawn) == 0 then
        return cast(SB.LightofDawn)
    end

    if modifier.control then
        if mouseover.alive and -spell(SB.Cleanse) == 0 then
            return cast(SB.Cleanse, 'mouseover')

        elseif mouseover.isDead and -spell(SB.Absolution) == 0 then
            return cast(SB.Absolution)
        end
    end


end

function interface()
    local settings = {
        key = 'holypal_settings',
        title = 'Holy Paladin',
        width = 250,
        height = 380,
        resize = true,
        show = false,
        template = {
            { type = 'header', text = '               Holy Paladin Settings' },
            { type = 'text', text = 'Everything on the screen is LIVE.  As you make changes, they are being fed to the engine.' },
            { type = 'rule' },
            { type = 'text', text = 'General Settings' },
            { key = 'healthstone', type = 'checkspin', text = 'Healthstone', desc = 'Auto use Healthstone at health %', min = 5, max = 100, step = 5 },
            -- { key = 'input', type = 'input', text = 'TextBox', desc = 'Description of Textbox' },
            { key = 'intpercent', type = 'spinner', text = 'Interrupt %', desc = '% cast time to interrupt at', min = 5, max = 100, step = 5 },
            { type = 'rule' },
            { type = 'text', text = 'Utility' },
            { key = 'autoStun', type = 'checkbox', text = 'Stun', desc = 'Use stun as an interrupt' },
            { key = 'autoRacial', type = 'checkbox', text = 'Racial', desc = 'Use Racial on CD (Blood Elf only)' },
            { type = 'rule' },
            { type = 'text', text = 'Automated CoolDowns' },
            { key = 'autoAura', type = 'checkbox', text = 'Aura Mastery', desc = '' },
            { key = 'autoAvengingCrusader', type = 'checkbox', text = 'AvengingCrusader', desc = '' },
            { key = 'autoHolyAvenger', type = 'checkbox', text = 'Holy Avenger', desc = '' },
            { key = 'autoWrath', type = 'checkbox', text = 'Avenging Wrath', desc = '' },
            { key = 'autoDivineProtection', type = 'checkbox', text = 'Divine Protection', desc = '' },
            { key = 'autoDivineShield', type = 'checkbox', text = 'Divine Shield', desc = '' },
            { key = 'autoBeaconofVirtue', type = 'checkbox', text = 'Beacon of Virtue', desc = '' },
            { type = 'rule' },
        }
    }

    configWindow = dark_addon.interface.builder.buildGUI(settings)

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
    dark_addon.interface.buttons.add_toggle({
        name = 'settings',
        label = 'Rotation Settings',
        font = 'dark_addon_icon',
        on = {
            label = dark_addon.interface.icon('cog'),
            color = dark_addon.interface.color.cyan,
            color2 = dark_addon.interface.color.dark_cyan
        },
        off = {
            label = dark_addon.interface.icon('cog'),
            color = dark_addon.interface.color.grey,
            color2 = dark_addon.interface.color.dark_grey
        },
        callback = function(self)
            if configWindow.parent:IsShown() then
                configWindow.parent:Hide()
            else
                configWindow.parent:Show()
            end
        end
    })
end

dark_addon.rotation.register({
    spec = dark_addon.rotation.classes.paladin.holy,
    name = 'holypal',
    label = 'PAL: Holy Paladin',
    combat = combat,
    resting = resting,
    interface = interface,
})
