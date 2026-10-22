local RESOURCE = GetCurrentResourceName()
local ANIM_DICT = 'missfinale_c2ig_11'
local ANIM_NAME = 'pushcar_offcliff_m'
local FLIP_EVENT = 'flipcar-Ryder:flipcar'
local TARGET_NAME = 'jgr_flipcar'
local TARGETS = { 'ox_target', 'qb-target', 'qtarget' }

local flipping = false
local warnedJobs = false
local activeTarget

local function notify(message, ntype)
    if Config.UseCustomNotify then
        TriggerEvent('flipcar-Ryder:CustomNotify', message, ntype)
    else
        Bridge.Notify(message, ntype)
    end
end

-- Evento público: otros recursos (o el servidor) pueden mostrar avisos con el mismo sistema.
RegisterNetEvent('flipcar-Ryder:Notify', notify)

local function notifyLang(key, typeKey)
    notify(Config.Lang[key] or key, Config.LangType[typeKey] or typeKey)
end

---------------------------------------------------------------------------
-- Permisos
---------------------------------------------------------------------------

local function hasRequiredJob()
    if type(Config.Jobs) ~= 'table' or next(Config.Jobs) == nil then
        return true -- sin lista de trabajos: cualquiera
    end

    local allowed = Bridge.HasJob(Config.Jobs)
    if allowed == nil then
        if not warnedJobs then
            warnedJobs = true
            print(('^3[%s]^7 Config.Jobs está configurado pero no hay framework con trabajos (modo %s): la condición de trabajo nunca se cumple.')
                :format(RESOURCE, Bridge.Framework))
        end
        return false
    end
    return allowed
end

local function hasRequiredItem()
    if type(Config.RequiredItem) ~= 'string' or Config.RequiredItem == '' then return false end
    return Bridge.GetItemCount(Config.RequiredItem) > 0
end

local function canFlip()
    local hasJob, hasItem = hasRequiredJob(), hasRequiredItem()
    if Config.AndOr then
        return hasJob and hasItem
    end
    return hasJob or hasItem
end

---------------------------------------------------------------------------
-- Volcar el vehículo
---------------------------------------------------------------------------

local function requestControl(entity, timeout)
    if NetworkHasControlOfEntity(entity) then return true end

    local deadline = GetGameTimer() + (timeout or 1500)
    repeat
        NetworkRequestControlOfEntity(entity)
        Wait(50)
        if NetworkHasControlOfEntity(entity) then return true end
    until GetGameTimer() > deadline

    return false
end

--- Vehículo apuntado con el target o, si no hay, el más cercano.
local function getVehicle(entity, coords)
    if entity and entity ~= 0 and DoesEntityExist(entity) and IsEntityAVehicle(entity) then
        return entity
    end
    return lib.getClosestVehicle(coords, Config.FlipDistance or 3.0, false)
end

local function flipCarOver(entity)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicle = getVehicle(entity, coords)

    if not vehicle or vehicle == 0 or #(coords - GetEntityCoords(vehicle)) > (Config.FlipDistance or 3.0) then
        return notifyLang('far_away', 'error')
    end

    if IsVehicleOnAllWheels(vehicle) then
        return notifyLang('allset', 'error')
    end

    flipping = true
    local ok, err = pcall(function()
        lib.requestAnimDict(ANIM_DICT)
        TaskPlayAnim(ped, ANIM_DICT, ANIM_NAME, 2.0, -8.0, -1, 35, 0, false, false, false)
        Wait((tonumber(Config.TimetoFlip) or 3) * 1000)
        ClearPedTasks(ped)
        RemoveAnimDict(ANIM_DICT)

        if DoesEntityExist(vehicle) then
            -- Sin control de red el giro no se sincroniza con el resto de jugadores.
            requestControl(vehicle)
            local rot = GetEntityRotation(vehicle, 2)
            SetEntityRotation(vehicle, rot.x, 0.0, rot.z, 2, true)
            SetVehicleOnGroundProperly(vehicle)
            notifyLang('flipped', 'success')
        end
    end)
    flipping = false

    if not ok then
        ClearPedTasks(ped)
        print(('^1[%s]^7 Error al volcar el vehículo: %s'):format(RESOURCE, tostring(err)))
    end
end

AddEventHandler(FLIP_EVENT, function(data)
    if flipping then return end

    if IsPedInAnyVehicle(PlayerPedId(), false) then
        return notifyLang('in_vehicle', 'error')
    end

    if not canFlip() then
        return notifyLang('not_allowed', 'error')
    end

    -- Desde el target llega la entidad apuntada en data.entity.
    flipCarOver(type(data) == 'table' and data.entity or nil)
end)
RegisterNetEvent(FLIP_EVENT)

---------------------------------------------------------------------------
-- Comando
---------------------------------------------------------------------------

if Config.UseChatCommand and Config.ChatCommand then
    RegisterCommand(Config.ChatCommand, function()
        TriggerEvent(FLIP_EVENT)
    end, false)
end

---------------------------------------------------------------------------
-- Target (ojo)
---------------------------------------------------------------------------

local function isKnownTarget(name)
    for i = 1, #TARGETS do
        if TARGETS[i] == name then return true end
    end
    return false
end

--- Espera (máx. 10 s) a que arranque un target y devuelve su nombre.
local function resolveTarget()
    local wanted = Config.ThirdEyeName
    local candidates = TARGETS

    if wanted and wanted ~= 'auto' then
        if isKnownTarget(wanted) and GetResourceState(wanted) ~= 'missing' then
            candidates = { wanted }
        else
            print(('^3[%s]^7 Config.ThirdEyeName = "%s" no está disponible; se detecta automáticamente.'):format(RESOURCE, tostring(wanted)))
        end
    end

    local deadline = GetGameTimer() + 10000
    repeat
        for i = 1, #candidates do
            if GetResourceState(candidates[i]) == 'started' then return candidates[i] end
        end
        Wait(500)
    until GetGameTimer() > deadline

    return nil
end

local function addTarget(target)
    local label = Config.Lang['flip']

    if target == 'ox_target' then
        exports.ox_target:addGlobalVehicle({
            {
                name = TARGET_NAME,
                event = FLIP_EVENT,
                icon = 'fas fa-arrow-up',
                label = label,
                distance = 2.0,
            },
        })
    elseif target == 'qb-target' then
        exports['qb-target']:AddGlobalVehicle({
            options = {
                {
                    type = 'client',
                    event = FLIP_EVENT,
                    icon = 'fas fa-arrow-up',
                    label = label,
                },
            },
            distance = 2.0,
        })
    elseif target == 'qtarget' then
        exports.qtarget:Vehicle({
            options = {
                {
                    event = FLIP_EVENT,
                    icon = 'fas fa-arrow-up',
                    label = label,
                },
            },
            distance = 2.0,
        })
    end
end

if Config.UseThirdEye then
    CreateThread(function()
        local target = resolveTarget()
        if not target then
            print(('^3[%s]^7 Config.UseThirdEye = true pero no se encontró ox_target, qb-target ni qtarget.'):format(RESOURCE))
            return
        end

        local ok, err = pcall(addTarget, target)
        if ok then
            activeTarget = target
        else
            print(('^1[%s]^7 No se pudo registrar la opción en %s: %s'):format(RESOURCE, target, tostring(err)))
        end
    end)
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= RESOURCE or not activeTarget then return end

    -- ox_target limpia solo las opciones de recursos parados; qb-target y qtarget no.
    if activeTarget == 'ox_target' then
        pcall(function() exports.ox_target:removeGlobalVehicle(TARGET_NAME) end)
    elseif activeTarget == 'qb-target' then
        pcall(function() exports['qb-target']:RemoveGlobalVehicle(Config.Lang['flip']) end)
    elseif activeTarget == 'qtarget' then
        pcall(function() exports.qtarget:RemoveVehicle({ Config.Lang['flip'] }) end)
    end
end)
