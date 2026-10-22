Config = {}

-- Framework: 'auto' | 'qbx' | 'qb' | 'esx' | 'standalone'
-- En 'auto' se detecta en este orden: qbx_core -> qb-core -> es_extended -> ox_core/standalone.
-- (Las antiguas opciones Config.UseESX / Config.UseQBX ya no hacen falta; si borras
-- Config.Framework y dejas Config.UseESX = true, se fuerza ESX como antes.)
Config.Framework = 'auto'

-- Notificaciones cuando Config.UseCustomNotify = false:
-- 'auto' (la del framework y, si no hay, ox_lib) | 'ox_lib' | 'native'
Config.Notify = 'auto'

Config.UseCustomNotify = false				-- true = usa tu propio sistema de notificaciones (completa el evento de abajo).

-- Solo se usa si Config.UseCustomNotify = true; mythic_notify como ejemplo.
if not IsDuplicityVersion() then
	AddEventHandler('flipcar-Ryder:CustomNotify', function(message, type)
		--exports.mythic_notify:SendAlert(type, message, 4000)
	end)
end

Config.TimetoFlip = 3 						-- Segundos que tarda en dar la vuelta al vehículo.
Config.FlipDistance = 3.0					-- Distancia máxima (metros) al vehículo.

Config.Jobs = {								-- Trabajos permitidos y grado mínimo; tabla vacía = cualquiera.
	--["police"] = 0,
	--["mechanic"] = 0,
}
Config.AndOr = false						-- false = trabajo O ítem; true = trabajo Y ítem (pon true para exigir el ítem).
Config.RequiredItem = 'Workingtofix'		-- Ítem necesario. NO se gasta, solo hay que llevarlo encima.


-- Interacción
Config.UseThirdEye = true 					-- Añade la opción al target (ojo) en todos los vehículos.
Config.ThirdEyeName = 'auto' 				-- 'auto' | 'ox_target' | 'qb-target' | 'qtarget'
Config.UseChatCommand = true                -- Activa el comando de chat.
Config.ChatCommand = 'flipcar'              -- Nombre del comando si Config.UseChatCommand = true.

-- Tipos de notificación
Config.LangType = {
	['error'] = 'error',
	['success'] = 'success',
	['info'] = 'inform'
}

-- Textos
Config.Lang = {
	['flipped'] = 'You have flipped the vehicle!',
	['allset'] = 'Vehicle is already upright',
	['in_vehicle'] = 'You can not flip the vehicle from inside!',
	['far_away'] = 'You are not close enough flip the vehicle!',
	['not_allowed'] = 'You don\'t have the training or tools to flip a vehicle!',
	['flip'] = 'Flip Vehicle',
}
