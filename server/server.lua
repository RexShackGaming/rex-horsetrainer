local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

------------------------------------
-- use horse brush
------------------------------------
RSGCore.Functions.CreateUseableItem('trainer_brush', function(source, item)
    local src = source
    TriggerClientEvent('rex-horsetrainer:client:brushhorse', src, item.name)
end)

------------------------------------
-- add horse xp
------------------------------------
RegisterNetEvent('rex-horsetrainer:server:updatexp', function(amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local cid = Player.PlayerData.citizenid
    local result = MySQL.query.await('SELECT * FROM player_horses WHERE citizenid = @citizenid AND active = @active', { ['@citizenid'] = cid, ['@active'] = 1 })

    if result[1] then
        horsename = result[1].name
        horseid = result[1].horseid
        horsexp = result[1].horsexp
    end

    newxp = horsexp + amount
    MySQL.update('UPDATE player_horses SET horsexp = ? WHERE horseid = ? AND active = ?', {newxp, horseid, 1})
    TriggerClientEvent('rNotify:ShowAdvancedRightNotification', src, '+'..amount, 'hud_quick_select' , 'horse_stow', 'COLOR_PURE_WHITE', 4000)
end)
