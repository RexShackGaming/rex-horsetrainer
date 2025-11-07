local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

-------------------------------------
-- upate horse xp
-------------------------------------
RegisterNetEvent('rex-horsetrainer:server:updatexp', function(amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player or not Player.PlayerData.citizenid then return end

    local citizenid = Player.PlayerData.citizenid

    -- check valid amount
    if type(amount) ~= 'number' or amount <= 0 or amount > 2 then
        print(('^1[rex-horsetrainer] WARNING: Invalid XP amount (%s) from player %s'):format(tostring(amount), src))
        return
    end

    -- atomic update: add XP, cap at 5000, only for citizen's active horse
    local affected = MySQL.update.await('UPDATE player_horses SET horsexp = LEAST(horsexp + ?, 5000) WHERE citizenid = ? AND active = 1', { amount, citizenid })

    if affected == 0 then
        -- no active horse
        return
    end

    -- fetch new XP for notification
    local result = MySQL.query.await('SELECT horsexp FROM player_horses WHERE citizenid = ? AND active = 1 LIMIT 1', { citizenid })
    if not result or not result[1] then return end

    local newXP = result[1].horsexp
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Horse Training',
        description = ('XP increased! Current: %d/5000'):format(newXP),
        type = 'success',
        duration = 5000
    })
end)
