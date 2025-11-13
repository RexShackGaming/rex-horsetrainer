local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

-------------------------------------
-- upate horse xp
-------------------------------------
RegisterNetEvent('rex-horsetrainer:server:updatexp', function(amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
    if not Player then
        print(('^1[rex-horsetrainer] ERROR: Player object not found for source %s^7'):format(src))
        return
    end
    
    if not Player.PlayerData.citizenid then
        print(('^1[rex-horsetrainer] ERROR: CitizenID not found for source %s^7'):format(src))
        return
    end

    local citizenid = Player.PlayerData.citizenid
    if Config.Debug then
        print(('^3[rex-horsetrainer] DEBUG: XP update received - Player: %s, Amount: %s^7'):format(citizenid, tostring(amount)))
    end

    -- check valid amount
    if type(amount) ~= 'number' or amount <= 0 or amount > 10 then
        print(('^1[rex-horsetrainer] WARNING: Invalid XP amount (%s) from player %s^7'):format(tostring(amount), src))
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Horse Training',
            description = 'Invalid XP amount',
            type = 'error',
            duration = 5000
        })
        return
    end

    -- check if player has any horses at all
    local playerHorses = MySQL.query.await('SELECT id, active FROM player_horses WHERE citizenid = ?', { citizenid })
    if not playerHorses or #playerHorses == 0 then
        print(('^1[rex-horsetrainer] ERROR: No horses found for citizen %s^7'):format(citizenid))
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Horse Training',
            description = 'No horses found!',
            type = 'error',
            duration = 5000
        })
        return
    end

    -- check if an active horse exists
    local activeHorse = MySQL.query.await('SELECT id, horsexp FROM player_horses WHERE citizenid = ? AND active = 1 LIMIT 1', { citizenid })
    if not activeHorse or not activeHorse[1] then
        print(('^3[rex-horsetrainer] WARNING: No active horse for citizen %s. Available horses: %d^7'):format(citizenid, #playerHorses))
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Horse Training',
            description = 'No active horse!',
            type = 'error',
            duration = 5000
        })
        return
    end

    if Config.Debug then
        print(('^3[rex-horsetrainer] DEBUG: Active horse found - Current XP: %d^7'):format(activeHorse[1].horsexp))
    end

    -- atomic update: add XP, cap at 5000, only for citizen's active horse
    local affected = MySQL.update.await('UPDATE player_horses SET horsexp = LEAST(horsexp + ?, 5000) WHERE citizenid = ? AND active = 1', { amount, citizenid })

    if affected == 0 then
        print(('^1[rex-horsetrainer] ERROR: XP update failed - no rows affected for citizen %s^7'):format(citizenid))
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Horse Training',
            description = 'Failed to update XP',
            type = 'error',
            duration = 5000
        })
        return
    end

    if Config.Debug then
        print(('^2[rex-horsetrainer] SUCCESS: XP updated successfully for citizen %s (+%d)^7'):format(citizenid, amount))
    end

    -- fetch new XP for notification
    local result = MySQL.query.await('SELECT horsexp FROM player_horses WHERE citizenid = ? AND active = 1 LIMIT 1', { citizenid })
    if not result or not result[1] then
        print(('^1[rex-horsetrainer] ERROR: Failed to fetch updated XP for citizen %s^7'):format(citizenid))
        return
    end

    local newXP = result[1].horsexp
    if Config.Debug then
        print(('^3[rex-horsetrainer] DEBUG: New XP value: %d/5000^7'):format(newXP))
    end
    
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Horse Training',
        description = ('XP increased! Current: %d/5000'):format(newXP),
        type = 'success',
        duration = 5000
    })
end)
