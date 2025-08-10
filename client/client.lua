local RSGCore = exports['rsg-core']:GetCoreObject()
local cleancooldownSecondsRemaining = 0
local horsePed = nil
local horse = nil
local horseSpeed = 0
local horsespeedcheck = false
local horseEXP = 0
lib.locale()

-----------------------------
-- trainer brush cooldown timer
-----------------------------
local function CleaningCooldown()
    cleancooldownSecondsRemaining = (Config.BrushCooldown * 60)
    CreateThread(function()
        while cleancooldownSecondsRemaining > 0 do
            Wait(1000)
            cleancooldownSecondsRemaining = cleancooldownSecondsRemaining - 1
        end
    end)
end

-----------------------------
-- riding horse xp
-----------------------------
CreateThread(function()
    while true do
        if LocalPlayer.state['isLoggedIn'] then
            local PlayerData = RSGCore.Functions.GetPlayerData()
            local jobtype = PlayerData.job.type
            horse = GetLastMount(cache.ped)
            horsePed = exports['rsg-horses']:CheckActiveHorse()
            horseSpeed = GetEntitySpeed(horsePed)
            if horseSpeed > 5 then
                horsespeedcheck = true
            else
                horsespeedcheck = false
            end
            if not IsPedStopped(horsePed) and horse == horsePed and IsPedOnMount(cache.ped) and horsespeedcheck == true then
                RSGCore.Functions.TriggerCallback('rsg-horses:server:GetActiveHorse', function(data)
                    horseEXP = data.horsexp
                    if horseEXP >= 5000 then
                        return
                    end
                    if jobtype == 'horsetrainer' then
                        TriggerServerEvent('rex-horsetrainer:server:updatexp', Config.TrainerRidingXP)
                    else
                        TriggerServerEvent('rex-horsetrainer:server:updatexp', Config.PlayerRidingXP)
                    end
                end)
            end
        end
        Wait(Config.RidingWait)
    end
end)

-----------------------------
-- leading horse xp
-----------------------------
CreateThread(function()
    while true do
        if LocalPlayer.state['isLoggedIn'] then
            local PlayerData = RSGCore.Functions.GetPlayerData()
            local jobtype = PlayerData.job.type
            horse = GetLastMount(cache.ped)
            horsePed = exports['rsg-horses']:CheckActiveHorse()
            if horsePed ~= 0 and horse ~= 0 then
                if IsPedLeadingHorse(horsePed) and horse == horsePed and not IsPedOnMount(cache.ped) and not IsPedStopped(horsePed) then
                    RSGCore.Functions.TriggerCallback('rsg-horses:server:GetActiveHorse', function(data)
                        horseEXP = data.horsexp
                        if horseEXP >= 5000 then
                            return
                        end
                        if jobtype == 'horsetrainer' then
                            TriggerServerEvent('rex-horsetrainer:server:updatexp', Config.TrainerLeadingXP)
                        else
                            TriggerServerEvent('rex-horsetrainer:server:updatexp', Config.PlayerLeadingXP)
                        end
                    end)
                end
            end
        end
        Wait(Config.LeadingWait)
    end
end)

-----------------------------
-- trainer brush horse
-----------------------------
RegisterNetEvent('rex-horsetrainer:client:brushhorse', function()
    local PlayerData = RSGCore.Functions.GetPlayerData()
    local jobtype = PlayerData.job.type
    if jobtype ~= 'horsetrainer' then return end
    if cleancooldownSecondsRemaining ~= 0 then
        lib.notify({ title = 'Already Clean!', type = 'error', duration = 7000 })
        return
    end
    horse = GetLastMount(cache.ped)
    horsePed = exports['rsg-horses']:CheckActiveHorse()
    local hasItem = RSGCore.Functions.HasItem('trainer_brush', 1)
    if hasItem and horse == horsePed and IsPedOnMount(cache.ped) then
        Citizen.InvokeNative(0xCD181A959CFDD7F4, cache.ped, horsePed, `INTERACTION_BRUSH`, 0, 0)
        Wait(8000)
        Citizen.InvokeNative(0xE3144B932DFDFF65, horsePed, 0.0, -1, 1, 1)
        ClearPedEnvDirt(horsePed)
        ClearPedDamageDecalByZone(horsePed, 10, 'ALL')
        ClearPedBloodDamage(horsePed)
        PlaySoundFrontend('Core_Fill_Up', 'Consumption_Sounds', true, 0)
        CleaningCooldown()
        TriggerServerEvent('rex-horsetrainer:server:updatexp', Config.TrainerBrushXP)
    end
end)
