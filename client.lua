local CAYO_LOADED = false
local CAYO_COORDS = vec(4782.1, -5128.2)
local CAYO_RADIUS = 2000.0

function LoadCayo()
	print("Loading Cayo Perico")
	Citizen.InvokeNative(0x9A9D1BA639675CF1, 'HeistIsland', true)
	Citizen.InvokeNative(0x5E1460624D194A38, true) --minimap
	Citizen.InvokeNative(0xF74B1FFA4A15FBEA, true) --aipath
	Citizen.InvokeNative(0x53797676AD34A9AA, false) --unknown
	SetScenarioGroupEnabled('Heist_Island_Peds', true)
	SetAudioFlag('PlayerOnDLCHeist4Island', true)
	SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Zones', true, true)
	SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Disabled_Zones', false, true)
end

function UnloadCayo()
	print("Unloading Cayo Perico")
	Citizen.InvokeNative(0x9A9D1BA639675CF1, 'HeistIsland', false)
	Citizen.InvokeNative(0x5E1460624D194A38, false)
	Citizen.InvokeNative(0xF74B1FFA4A15FBEA, false)
	Citizen.InvokeNative(0x53797676AD34A9AA, true)
	SetScenarioGroupEnabled('Heist_Island_Peds', false)
	SetAudioFlag('PlayerOnDLCHeist4Island', false)
	SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Zones', false, false)
	SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Disabled_Zones', true, false)
end

function CheckCayo()
	local ped = PlayerPedId()
	local coords = GetEntityCoords(ped)

	if not CAYO_LOADED and #(CAYO_COORDS - coords.xy) < CAYO_RADIUS then
		LoadCayo()
		CAYO_LOADED = true
	elseif CAYO_LOADED and #(CAYO_COORDS - coords.xy) >= CAYO_RADIUS  then
		UnloadCayo()
		CAYO_LOADED = false
	end
end

Citizen.CreateThread(function()
	UnloadCayo()

	while true do
		Wait(0)
		CheckCayo()
	end
end)

Citizen.CreateThread(function()
	local islandMap = GetHashKey('h4_fake_islandx')
	local contextHash = GetHashKey('MAP_CanZoom')
	while true do
		local paused = IsPauseMenuActive()
		local isFullMap = false
		if paused then
			isFullMap = PauseMenuIsContextActive(contextHash)
			if isFullMap and not IsControlPressed(2, 217) then
				SetRadarAsExteriorThisFrame()
				SetRadarAsInteriorThisFrame(islandMap, vec(4700.0, -5145.0), 0, 0)
			end
		end
		Wait((paused and isFullMap) and 0 or 1000)
	end
end)