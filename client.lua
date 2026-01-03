ESX = nil
PlayerData = nil
PlayerJob = nil
PlayerGrade = nil

local VehicleData = nil

-- Framework detection
local UsingQBX = false
local UsingESX = false

if GetResourceState and GetResourceState('qbx_core') == 'started' then
    UsingQBX = true
end
if GetResourceState and GetResourceState('es_extended') == 'started' then
    UsingESX = true
end

RegisterNetEvent('flipcar-Ryder:Notify', function(message, type)
    if Config.UseCustomNotify then
        TriggerEvent('flipcar-Ryder:CustomNotify', message, type)
    elseif Config.UseESX and ESX then
        ESX.ShowNotification(message, false, false, type)
    elseif UsingQBX and exports.qbx_core and exports.qbx_core.Notify then
        exports.qbx_core:Notify(message, type)
    end
end)

CreateThread(function()
    -- ESX initialization (tal cual estaba en tu original)
    if UsingESX then
        CreateThread(function()
            while ESX == nil do
                TriggerEvent('getSharedObject', function(obj) ESX = obj end)
                Wait(0)
            end
            while ESX.GetPlayerData().job == nil do
                Wait(100)
            end
            PlayerData = ESX.GetPlayerData()
            PlayerJob = PlayerData.job.name
            PlayerGrade = PlayerData.job.grade
            RegisterNetEvent('esx:setJob', function(job)
                PlayerJob = job.name
                PlayerGrade = job.grade
            end)
        end)
    end

    -- QBX initialization (tal cual estaba en tu original)
    if UsingQBX then
        CreateThread(function()
            while (not PlayerData) and (_G.QBX == nil or _G.QBX.PlayerData == nil) do
                if _G.QBX and _G.QBX.PlayerData then
                    PlayerData = _G.QBX.PlayerData
                    break
                end
                Wait(100)
            end
            if exports.qbx_core and exports.qbx_core.GetGroups then
                local groups = exports.qbx_core:GetGroups()
                PlayerJob = nil
                PlayerGrade = nil
                if groups then
                    for k, v in pairs(groups) do
                        PlayerJob = k
                        PlayerGrade = v
                        break
                    end
                end
            end
            RegisterNetEvent('qbx_core:client:onGroupUpdate', function()
                if exports.qbx_core and exports.qbx_core.GetGroups then
                    local groups = exports.qbx_core:GetGroups()
                    PlayerJob = nil
                    PlayerGrade = nil
                    if groups then
                        for k, v in pairs(groups) do
                            PlayerJob = k
                            PlayerGrade = v
                            break
                        end
                    end
                end
            end)
        end)
    end

    if Config.UseChatCommand then
        RegisterCommand(Config.ChatCommand, function()
            TriggerEvent('flipcar-Ryder:flipcar')
        end)
    end
end)

function hasRequiredJob()
    local jobs = Config.Jobs == nil or next(Config.Jobs)
    if jobs then
        if Config.UseESX and PlayerJob then
            for jobName, gradeLevel in pairs(Config.Jobs) do
                if PlayerJob == jobName and PlayerGrade >= gradeLevel then
                    return true
                end
            end
            return false
        end

        if UsingQBX and exports.qbx_core and exports.qbx_core.GetGroups then
            local groups = exports.qbx_core:GetGroups() or {}
            for jobName, gradeLevel in pairs(Config.Jobs) do
                if groups[jobName] and groups[jobName] >= gradeLevel then
                    return true
                end
            end
            return false
        end
        return true
    else
        return true
    end
end

RegisterNetEvent('flipcar-Ryder:flipcar')
AddEventHandler('flipcar-Ryder:flipcar', function()
    local ped = PlayerPedId()
    local inside = IsPedInAnyVehicle(ped, false)
    local hasJob = hasRequiredJob()
    local hasItem = RequiredItem()
    if inside then
        TriggerEvent('flipcar-Ryder:Notify', Config.Lang['in_vehicle'], Config.LangType['error'])
    elseif Config.AndOr then
        if hasJob and hasItem then
            FlipCarOver()
        else
            TriggerEvent('flipcar-Ryder:Notify', Config.Lang['not_allowed'], Config.LangType['error'])
        end
    elseif hasJob or hasItem then
        FlipCarOver()
    else
        TriggerEvent('flipcar-Ryder:Notify', Config.Lang['not_allowed'], Config.LangType['error'])
    end
end)

CreateThread(function()
    if Config.UseThirdEye then
        local thirdEye = Config.ThirdEyeName or ''
        local hasOxTarget = GetResourceState('ox_target') == 'started'
        local hasQTarget = GetResourceState('qtarget') == 'started'

        if (thirdEye == 'ox_target') or hasOxTarget then
            if exports.ox_target and exports.ox_target.addGlobalVehicle then
                exports.ox_target:addGlobalVehicle({
                    {
                        event = 'flipcar-Ryder:flipcar',
                        icon = 'fas fa-arrow-up',
                        label = Config.Lang['flip'],
                        distance = 2.0
                    }
                })
            end
        else
            if exports[thirdEye] and exports[thirdEye].Vehicle then
                exports[thirdEye]:Vehicle({
                    options = {
                        {
                            event = 'flipcar-Ryder:flipcar',
                            icon = 'fas fa-arrow-up',
                            label = Config.Lang['flip'],
                            distance = 2
                        },
                    },
                })
            elseif hasQTarget and exports.qtarget and exports.qtarget.AddGlobalVehicle then
                exports.qtarget:AddGlobalVehicle({
                    {
                        event = 'flipcar-Ryder:flipcar',
                        icon = 'fas fa-arrow-up',
                        label = Config.Lang['flip'],
                        distance = 2.0
                    }
                })
            end
        end
    end
end)

function RequiredItem()
    local hasItem = false
    if Config.UseESX and ESX and ESX.GetPlayerData then
        PlayerData = ESX.GetPlayerData()
        if PlayerData and PlayerData.inventory then
            for k, v in ipairs(PlayerData.inventory) do
                if v.name == Config.RequiredItem and v.count > 0 then
                    hasItem = true
                    break
                end
            end
        end
        return hasItem
    end

    if UsingQBX then
        if exports.ox_inventory and exports.ox_inventory.GetItemCount then
            local count = exports.ox_inventory:GetItemCount(Config.RequiredItem) or 0
            return count > 0
        end
        if PlayerData and PlayerData.items then
            for k, v in pairs(PlayerData.items) do
                if (v.name == Config.RequiredItem or v.item == Config.RequiredItem) and (v.amount and v.amount > 0 or v.count and v.count > 0) then
                    return true
                end
            end
        end
    end
    return false
end

-- FUNCIÓN CORREGIDA: Se añadió pedCoords para evitar el error de nil
function FlipCarOver()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    
    -- Intento de obtener el vehículo con soporte para múltiples métodos
    if ESX and ESX.Game and ESX.Game.GetClosestVehicle then
        VehicleData = ESX.Game.GetClosestVehicle(pedCoords)
    elseif lib and lib.getClosestVehicle then
        -- Aquí es donde estaba el error: ahora pasamos pedCoords explícitamente
        VehicleData = lib.getClosestVehicle(pedCoords, 3.0, false)
    else
        -- Fallback nativo
        VehicleData = GetClosestVehicle(pedCoords.x, pedCoords.y, pedCoords.z, 3.0, 0, 71)
    end

    if not VehicleData or VehicleData == 0 then return end

    local dist = #(pedCoords - GetEntityCoords(VehicleData))
    
    if dist <= 3 and not IsVehicleOnAllWheels(VehicleData) then
        RequestAnimDict('missfinale_c2ig_11')
        while not HasAnimDictLoaded('missfinale_c2ig_11') do
            Wait(10)
        end
        TaskPlayAnim(ped, 'missfinale_c2ig_11', 'pushcar_offcliff_m', 2.0, -8.0, -1, 35, 0, 0, 0, 0)
        Wait(Config.TimetoFlip * 1000)
        local carRot = GetEntityRotation(VehicleData, 2)
        SetEntityRotation(VehicleData, carRot[1], 0, carRot[3], 2, true)
        SetVehicleOnGroundProperly(VehicleData)
        TriggerEvent('flipcar-Ryder:Notify', Config.Lang['flipped'], Config.LangType['success'])
        ClearPedTasks(ped)
    elseif IsVehicleOnAllWheels(VehicleData) then
        TriggerEvent('flipcar-Ryder:Notify', Config.Lang['allset'], Config.LangType['error'])
    end
end