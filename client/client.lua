local RSGCore = exports['rsg-core']:GetCoreObject()
local horsePed = nil
local horse = nil
local horseSpeed = 0
local horsespeedcheck = false
local horseEXP = 0
lib.locale()

--------------------------------------------------------------------
-- Riding horse XP loop
--------------------------------------------------------------------
CreateThread(function()
    while true do
        Wait(Config.RidingWait)

        if not LocalPlayer.state['isLoggedIn'] then goto continue end

        local ped = PlayerPedId()
        local PlayerData = RSGCore.Functions.GetPlayerData()
        local jobtype = PlayerData.job.type

        horse = GetLastMount(ped)
        horsePed = exports['rsg-horses']:CheckActiveHorse()

        if not horsePed or not IsEntityAPed(horsePed) then goto continue end

        horseSpeed = GetEntitySpeed(horsePed)
        horsespeedcheck = horseSpeed > 5

        if horse ~= horsePed or not IsPedOnMount(ped) or IsPedStopped(horsePed) or not horsespeedcheck then
            goto continue
        end

        if Config.Debug then
            print(('^3[rex-horsetrainer] DEBUG: Riding XP trigger - horsePed: %s, mounted: %s, speed: %.2f^7'):format(tostring(horsePed), tostring(IsPedOnMount(ped)), horseSpeed))
        end

        RSGCore.Functions.TriggerCallback('rsg-horses:server:GetActiveHorse', function(data)
            if not data then
                print('^1[rex-horsetrainer] ERROR: GetActiveHorse callback returned nil^7')
                return
            end
            
            horseEXP = data.horsexp or 0
            if Config.Debug then
                print(('^3[rex-horsetrainer] DEBUG: Active horse XP: %d/5000^7'):format(horseEXP))
            end
            
            if horseEXP >= 5000 then 
                if Config.Debug then
                    print('^2[rex-horsetrainer] DEBUG: Horse maxed out at 5000 XP^7')
                end
                return 
            end

            local xp = jobtype == 'horsetrainer' and Config.TrainerRidingXP or Config.PlayerRidingXP
            if Config.Debug then
                print(('^3[rex-horsetrainer] DEBUG: Sending riding XP - Amount: %d, JobType: %s^7'):format(xp, jobtype))
            end
            TriggerServerEvent('rex-horsetrainer:server:updatexp', xp)
        end)

        ::continue::
    end
end)

--------------------------------------------------------------------
-- Leading horse XP loop
--------------------------------------------------------------------
CreateThread(function()
    while true do
        Wait(Config.LeadingWait)

        if not LocalPlayer.state['isLoggedIn'] then goto continue end

        local ped = PlayerPedId()
        local PlayerData = RSGCore.Functions.GetPlayerData()
        local jobtype = PlayerData.job.type

        horse = GetLastMount(ped)
        horsePed = exports['rsg-horses']:CheckActiveHorse()

        if not horsePed or horsePed == 0 or horse == 0 then goto continue end
        if horse ~= horsePed or IsPedOnMount(ped) or IsPedStopped(horsePed) then goto continue end
        if not IsPedLeadingHorse(horsePed) then goto continue end

        if Config.Debug then
            print(('^3[rex-horsetrainer] DEBUG: Leading XP trigger - horsePed: %s, leading: %s^7'):format(tostring(horsePed), tostring(IsPedLeadingHorse(horsePed))))
        end

        RSGCore.Functions.TriggerCallback('rsg-horses:server:GetActiveHorse', function(data)
            if not data then
                print('^1[rex-horsetrainer] ERROR: GetActiveHorse callback returned nil^7')
                return
            end
            
            horseEXP = data.horsexp or 0
            if Config.Debug then
                print(('^3[rex-horsetrainer] DEBUG: Active horse XP: %d/5000^7'):format(horseEXP))
            end
            
            if horseEXP >= 5000 then
                if Config.Debug then
                    print('^2[rex-horsetrainer] DEBUG: Horse maxed out at 5000 XP^7')
                end
                return 
            end

            local xp = jobtype == 'horsetrainer' and Config.TrainerLeadingXP or Config.PlayerLeadingXP
            if Config.Debug then
                print(('^3[rex-horsetrainer] DEBUG: Sending leading XP - Amount: %d, JobType: %s^7'):format(xp, jobtype))
            end
            TriggerServerEvent('rex-horsetrainer:server:updatexp', xp)
        end)

        ::continue::
    end
end)
