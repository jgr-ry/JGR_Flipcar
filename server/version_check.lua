--[[
    JGR Version Checker (v2)
    ------------------------------------------------------------------------
    Archivo común a todos los scripts JGR. NO lo edites dentro del recurso:
    si hay que cambiarlo, se cambia aquí y se copia igual en todos.

    Cómo funciona
      1. Lee la versión local de `version` en el fxmanifest.lua.
      2. Descarga el versions.json central:
         https://raw.githubusercontent.com/jgr-ry/Check_Versions_scripts/main/versions.json
      3. Busca la clave del recurso (metadato `jgr_version_key` del fxmanifest;
         si no existe, usa el nombre de la carpeta) y compara versiones semver.

    Metadatos opcionales en fxmanifest.lua
      jgr_version_key 'JGR_Ejemplo'                         -- clave en versions.json
      repository      'https://github.com/jgr-ry/JGR_Ejemplo' -- enlace de descarga

    Desactivar el aviso (server.cfg)
      set jgr_versioncheck 0
]]

local VERSIONS_URL = 'https://raw.githubusercontent.com/jgr-ry/Check_Versions_scripts/main/versions.json'
local resourceName = GetCurrentResourceName()

local function trim(value)
    if value == nil then return nil end
    value = tostring(value):gsub('^%s+', ''):gsub('%s+$', ''):gsub('^[vV]', '')
    return value ~= '' and value or nil
end

local function parseVersion(value)
    local parts = {}
    for piece in (trim(value) or '0'):gmatch('[^%.%-%+]+') do
        parts[#parts + 1] = tonumber(piece) or 0
    end
    return parts
end

--- @return integer -1 si a < b, 0 si son iguales, 1 si a > b
local function compareVersions(a, b)
    local pa, pb = parseVersion(a), parseVersion(b)
    for i = 1, math.max(#pa, #pb) do
        local va, vb = pa[i] or 0, pb[i] or 0
        if va ~= vb then return va < vb and -1 or 1 end
    end
    return 0
end

local function printLines(color, lines)
    local bar = ('^%s%s^7'):format(color, ('-'):rep(64))
    print(bar)
    for i = 1, #lines do print(lines[i]) end
    print(bar)
end

local function checkVersion()
    local key = GetResourceMetadata(resourceName, 'jgr_version_key', 0) or resourceName
    local localVersion = trim(GetResourceMetadata(resourceName, 'version', 0)) or '0.0.0'
    local repoUrl = GetResourceMetadata(resourceName, 'repository', 0)

    PerformHttpRequest(VERSIONS_URL, function(status, body)
        if status ~= 200 or type(body) ~= 'string' then
            print(('^3[%s]^7 No se pudo comprobar si hay actualizaciones (HTTP %s).'):format(resourceName, tostring(status)))
            return
        end

        local ok, data = pcall(json.decode, body)
        if not ok or type(data) ~= 'table' then
            print(('^3[%s]^7 versions.json no es válido; se omite la comprobación.'):format(resourceName))
            return
        end

        local entry = data[key]
        if entry == nil then return end

        local remoteVersion = trim(type(entry) == 'table' and (entry.version or entry.ver or entry.v) or entry)
        if not remoteVersion then return end

        local cmp = compareVersions(localVersion, remoteVersion)
        if cmp < 0 then
            local lines = {
                ('^3[%s]^7 ^1Hay una nueva versión disponible.^7'):format(resourceName),
                ('^3[%s]^7 Tu versión: ^1%s^7  ->  Última: ^2%s^7'):format(resourceName, localVersion, remoteVersion),
            }
            local url = type(entry) == 'table' and entry.url or repoUrl
            if url then lines[#lines + 1] = ('^3[%s]^7 Descarga: ^5%s^7'):format(resourceName, url) end
            if type(entry) == 'table' and entry.changelog then
                lines[#lines + 1] = ('^3[%s]^7 Cambios: %s'):format(resourceName, tostring(entry.changelog))
            end
            printLines('1', lines)
        elseif cmp > 0 then
            print(('^3[%s]^7 Versión de desarrollo ^5%s^7 (publicada: %s).'):format(resourceName, localVersion, remoteVersion))
        else
            print(('^3[%s]^7 ^2Actualizado^7 (v%s).'):format(resourceName, localVersion))
        end
    end, 'GET', '', { ['User-Agent'] = ('%s-VersionCheck'):format(resourceName) })
end

CreateThread(function()
    if GetConvarInt('jgr_versioncheck', 1) == 0 then return end
    Wait(3000)
    checkVersion()
end)
