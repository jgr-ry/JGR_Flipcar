if Config.enableUpdates then
    local function GitHubUpdate()
        -- URL actualizada al repositorio correcto proporcionado
        local updateUrl = 'https://raw.githubusercontent.com/jgr-ry/JGR_Flipcar/main/fxmanifest.lua'
        
        PerformHttpRequest(updateUrl, function(error, result, headers)
            if error ~= 200 or not result then
                print("^6JGR Flip-car^7 - ^1Error:^7 No se pudo verificar la versión (Código: "..(error or "N/A")..")")
                return
            end

            -- Obtener versión local desde el manifest
            local actual = GetResourceMetadata(GetCurrentResourceName(), 'version')
            
            -- Buscar la versión en el texto del manifest de GitHub
            local versionMatch = result:match("version ['\"](%d+%.%d+%.%d+)['\"]")

            if versionMatch then
                -- Limpiar puntos para comparar números (ej: 1.1.5 -> 115)
                local versionNum = tonumber((versionMatch:gsub("%.", "")))
                local actualNum = tonumber((actual:gsub("%.", "")))

                if versionNum > actualNum then
                    print('^6--------------------------------------------------------------------------^7')
                    print('^6JGR Flip-car^7 - ¡Hay una nueva versión disponible! [^2' .. versionMatch .. '^7]')
                    print('^6JGR Flip-car^7 - Tu versión actual: ^1' .. actual .. '^7')
                    print('^6JGR Flip-car^7 - Descarga la actualización en: ^5https://github.com/jgr-ry/JGR_Flipcar^7')
                    print('^6--------------------------------------------------------------------------^7')
                else
                    print('^6JGR Flip-car^7 - Estás utilizando la última versión del script (^2v' .. actual .. '^7).')
                end
            else
                print("^6JGR Flip-car^7 - ^3Advertencia:^7 No se pudo leer el formato de versión en GitHub.")
            end
        end, 'GET')
    end

    -- Esperar un poco al iniciar para no saturar la consola
    CreateThread(function()
        Wait(5000)
        GitHubUpdate()
    end)
end