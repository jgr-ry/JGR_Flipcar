Config = {}

Config.enableUpdates = true 				-- Check GitHub version.
Config.UseESX = false						-- Use ESX Framework
Config.UseQBX = true       					-- Use QBX Framework (qbx_core + ox_inventory). Set to true to enable QBX branches.
Config.UseCustomNotify = true				-- Use a custom notification script, must complete event below.

-- Only complete this event if Config.UseCustomNotify is true; mythic_notification provided as an example
RegisterNetEvent('flipcar-Ryder:CustomNotify')
AddEventHandler('flipcar-Ryder:CustomNotify', function(message, type)
    --exports.mythic_notify:SendAlert(type, message, 4000)
end)

Config.TimetoFlip = 3 						-- How long, in seconds, to flip the car.

Config.Jobs = {								-- List of permitted jobs; leave empty table for to allow all.
	--["police"] = 0,
	--["mechanic"] = 0,
}
Config.AndOr = false -- Don`t change		--  Logic to determine item requirement, change this to true to use an item
Config.RequiredItem = 'Workingtofix'		-- Replace 'itemnamehere' with item to be used for flipping vehicles, it is NOT removed on use, it only needs to be in the inventory (can be ignored if Config.AndOr = or and no item is wanted). 


-- Visual Preference
Config.UseThirdEye = true 					-- Enables using a third eye (depending on version will need to update export to target all vehicles)
Config.ThirdEyeName = 'qtarget' 			-- Name of third eye aplication
Config.UseChatCommand = true                -- Enables using chat command
Config.ChatCommand = 'flipcar'              -- When Config.UseChatCommand = true, is the phrase used to flip vehicle.

-- Language Configuration
Config.LangType = {
	['error'] = 'error',
	['success'] = 'success',
	['info'] = 'inform'
}

Config.Lang = {
	['flipped'] = 'You have flipped the vehicle!',
	['allset'] = 'Vehicle is already upright', 
    ['in_vehicle'] = 'You can not flip the vehicle from inside!',
    ['far_away'] = 'You are not close enough flip the vehicle!',
    ['not_allowed'] = 'You don\'t have the training or tools to flip a vehicle!',
	['flip'] = 'Flip Vehicle',
}
