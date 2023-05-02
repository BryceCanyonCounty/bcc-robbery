--Pulling Essentials
VORPcore = {} --Pulls vorp core
TriggerEvent("getCore", function(core)
  VORPcore = core
end)
VORPutils = {}
TriggerEvent("getUtils", function(utils)
  VORPutils = utils
end)

--Function for Draw 3D Text
function DrawText3D(x, y, z, text)
  local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
  local px,py,pz=table.unpack(GetGameplayCamCoord())
  local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
  local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
  if onScreen then
    SetTextScale(0.30, 0.30)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 255, 255, 215)
    SetTextCentre(1)
    DisplayText(str,_x,_y)
    local factor = (string.len(text)) / 225
    DrawSprite("feeds", "hud_menu_4a", _x, _y+0.0125,0.015+ factor, 0.03, 0.1, 35, 35, 35, 190, 0)
  end
end

--Function to load model
function modelload(model) --recieves the models hash from whereever this function is called
  RequestModel(model) -- requests the model to load into the game
  if not HasModelLoaded(model) then --checks if its loaded
    RequestModel(model) --if it hasnt loaded then request it to load again
  end
  while not HasModelLoaded(model) do
    Wait(100)
  end
end

--Deadcheck event to run async with robbery
PlayerDead = nil
AddEventHandler('bcc-robbery:DeadCheck', function(coords)
  local pl = PlayerPedId()
  while Inmission do
    Citizen.Wait(200)
    if IsEntityDead(pl) then
      PlayerDead = true break
    end
    local plc = GetEntityCoords(pl)
    if GetDistanceBetweenCoords(coords.x, coords.y, coords.z, plc.x, plc.y, plc.z, true) > 30 then
      PlayerDead = true break
    end
  end
end)

--Handles spawning the enemy npcs
AddEventHandler('bcc-robbery:EnemyPeds', function(table)
  local model = 'a_m_m_huntertravelers_cool_01' --sets variable to the string the peds hash
  modelload(model) --triggers the function to load the model
  local roboilwagonpeds = {} --this creates a table used too store the wagon defenders
  for k, v in pairs(table) do --creates a for loop which runs once per table
    roboilwagonpeds[k] = CreatePed(model, v.x, v.y, v.z, true, true, true, true) --creates the peds and stores them in the table as the [k] key
    Citizen.InvokeNative(0x283978A15512B2FE, roboilwagonpeds[k], true) --creates a blip on each of the npcs
    TaskCombatPed(roboilwagonpeds[k], PlayerPedId()) --makes each npc fight the player
    Citizen.InvokeNative(0x23f74c2fda6e7c61, 953018525, roboilwagonpeds[k]) --sets the blip that tracks the ped
  end
  while true do
    Citizen.Wait(200)
    if PlayerDead then
      for k, v in pairs(roboilwagonpeds) do
        DeletePed(v)
      end break
    end
  end
end)