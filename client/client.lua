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
    local playerPed = cache.ped

    while true do
        Wait(Config.RidingWait)

        if not LocalPlayer.state['isLoggedIn'] then goto continue end

        local PlayerData = RSGCore.Functions.GetPlayerData()
        local jobtype = PlayerData.job.type

        horse = GetLastMount(playerPed)
        horsePed = exports['rsg-horses']:CheckActiveHorse()

        if not horsePed or not IsEntityAPed(horsePed) then goto continue end

        horseSpeed = GetEntitySpeed(horsePed)
        horsespeedcheck = horseSpeed > 5

        if horse ~= horsePed or not IsPedOnMount(playerPed) or IsPedStopped(horsePed) or not horsespeedcheck then
            goto continue
        end

        RSGCore.Functions.TriggerCallback('rsg-horses:server:GetActiveHorse', function(data)
            horseEXP = data.horsexp or 0
            if horseEXP >= 5000 then return end

            local xp = jobtype == 'horsetrainer' and Config.TrainerRidingXP or Config.PlayerRidingXP
            TriggerServerEvent('rex-horsetrainer:server:updatexp', xp)
        end)

        ::continue::
    end
end)

--------------------------------------------------------------------
-- Leading horse XP loop
--------------------------------------------------------------------
CreateThread(function()
    local playerPed = cache.ped

    while true do
        Wait(Config.LeadingWait)

        if not LocalPlayer.state['isLoggedIn'] then goto continue end

        local PlayerData = RSGCore.Functions.GetPlayerData()
        local jobtype = PlayerData.job.type

        horse = GetLastMount(playerPed)
        horsePed = exports['rsg-horses']:CheckActiveHorse()

        if not horsePed or horsePed == 0 or horse == 0 then goto continue end
        if horse ~= horsePed or IsPedOnMount(playerPed) or IsPedStopped(horsePed) then goto continue end
        if not IsPedLeadingHorse(horsePed) then goto continue end

        RSGCore.Functions.TriggerCallback('rsg-horses:server:GetActiveHorse', function(data)
            horseEXP = data.horsexp or 0
            if horseEXP >= 5000 then return end

            local xp = jobtype == 'horsetrainer' and Config.TrainerLeadingXP or Config.PlayerLeadingXP
            TriggerServerEvent('rex-horsetrainer:server:updatexp', xp)
        end)

        ::continue::
    end
end)
