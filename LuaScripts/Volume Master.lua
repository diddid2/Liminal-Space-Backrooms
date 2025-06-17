
--전체 독자개발, 각 레벨별 범위를 지정해 Part를 생성한 후 닿았을 시
--스폰포인트, 라이팅 세팅값과, UI 구조 변경

local Light = game:GetService('Lighting')
local currentLevel = "Default"
local light_sky = Light.Sky
local light_correction = Light.ColorCorrection
local light_blur = Light.Level37.Blur
local light_blacksky = Light.Level37.SolidBlackSkybox
local light_Atmosphere = Light.Atmosphere
local playerSpawnMap = {}
local level33StatusScript = require(workspace.Level33.Level33StatusScript)


function createVolume(name, positionX, positionY, positionZ, sizeX, sizeY, sizeZ)
 local volume = Instance.new("Part")
 volume.Name = name
 volume.CanCollide = false
 volume.Transparency = 0
 volume.Anchored = true
 volume.Massless = true
 volume.CFrame = CFrame.new(positionX, positionY, positionZ)
 volume.Size = Vector3.new(sizeX, sizeY, sizeZ)
 volume.Parent = game.Workspace
 volume.Touched:Connect(function(other)
  ApplyLighting(other, name)
 end)
 return volume
end

local spawnPositions = {
 ["Level0 Default Volume"] = workspace.Level0.SpawnPoint.CFrame,
 Level32 = workspace.Level32.SpawnPoint.CFrame,
 Level33 = workspace.Level33.SpawnPoint.CFrame,
 Level37 = workspace.Level37.SpawnPoint.CFrame,
 ["Level!"] = workspace["Level!"].SpawnPoint.CFrame,
}

function ApplyLighting(other, level)
 local character = other:FindFirstAncestorWhichIsA("Model")
 local player = game.Players:GetPlayerFromCharacter(character)
 if not game.Players:GetPlayerFromCharacter(character) or currentLevel == level then return end
 currentLevel = level
 playerSpawnMap[player] = spawnPositions[level]
 print(level)
 print("한번 더 트리거됨")
 if workspace["Siren Sound"].IsPlaying then
  workspace["Siren Sound"]:Stop()
  workspace["Toxic Debris"]:Stop()
 end
 player.PlayerGui.Mission.Enabled = false
 game:GetService("StarterGui").Mission.Enabled = false
 game.Lighting.ColorCorrection32.Enabled = false
 light_Atmosphere.Density = 0.3
 if level == "Level0" then
  Light.Brightness = 0
  Light.Ambient = Color3.fromRGB(70,70,70)
  Light.ColorShift_Bottom = Color3.fromRGB(0,0,0)
  Light.ColorShift_Top = Color3.fromRGB(0,0,0)
  Light.OutdoorAmbient = Color3.fromRGB(70,70,70)
  light_correction.Enabled = false
  light_blacksky.Parent = game.Lighting.Level37
  light_blur.Parent = game.Lighting.Level37

 elseif level == "Level32" then
  Light.Brightness = 0
  Light.Ambient = Color3.fromRGB(182,182,182)
  Light.ColorShift_Bottom = Color3.fromRGB(0,0,0)
  Light.ColorShift_Top = Color3.fromRGB(0,0,0)
  Light.OutdoorAmbient = Color3.fromRGB(80,80,80)
  light_correction.Enabled = false
  light_blacksky.Parent = game.Lighting.Level37
  light_blur.Parent = game.Lighting.Level37
  game.Lighting.ColorCorrection32.Enabled = true

 elseif level == "Level33" then
  player.PlayerGui.Mission.Enabled = true
  game:GetService("StarterGui").Mission.Enabled = true
  Light.Brightness = 0
  Light.Ambient = Color3.fromRGB(0,0,0)
  Light.ColorShift_Bottom = Color3.fromRGB(0,0,0)
  Light.ColorShift_Top = Color3.fromRGB(0,0,0)
  Light.OutdoorAmbient = Color3.fromRGB(20,20,20)
  light_correction.Enabled = false
  light_blacksky.Parent = game.Lighting.Level37
  light_blur.Parent = game.Lighting.Level37
  light_Atmosphere.Density = 0.2
  
 elseif level == "Level37" then
  Light.Brightness = 5
  Light.Ambient = Color3.fromRGB(0,0,0)
  Light.ColorShift_Bottom = Color3.fromRGB(255,242,210)
  Light.ColorShift_Top = Color3.fromRGB(255,242,210)
  Light.OutdoorAmbient = Color3.fromRGB(0,0,0)
  Light.EnvironmentDiffuseScale = 1
  light_sky.Parent = game.Lighting.Disabled
  light_correction.Enabled = true
  light_blacksky.Parent = game.Lighting
  light_blur.Parent = game.Lighting
 
 elseif level == "Level!" then
  Light.Brightness = 0
  Light.Ambient = Color3.fromRGB(0,0,0)
  Light.ColorShift_Bottom = Color3.fromRGB(0,0,0)
  Light.ColorShift_Top = Color3.fromRGB(0,0,0)
  Light.OutdoorAmbient = Color3.fromRGB(0,0,0)
  Light.EnvironmentDiffuseScale = 1
  light_sky.Parent = game.Lighting.Disabled
  light_correction.Brightness = 0
  light_correction.Contrast = 0
  light_correction.Saturation = 0
  light_correction.TintColor = Color3.fromRGB(255,255,255)
  light_correction.Enabled = true
  light_blacksky.Parent = game.Lighting
  light_blur.Parent = game.Lighting.Level37
  workspace["Siren Sound"]:Play()
  workspace["Toxic Debris"]:Play()
 end
end

local Players = game:GetService("Players")
Players.PlayerAdded:Connect(function(player)
 playerSpawnMap[player] = spawnPositions["Level0 Default Volume"]
 player.CharacterAdded:Connect(function(character)
  task.wait()
  local hrp = character:WaitForChild("HumanoidRootPart")
  local spawnPos = playerSpawnMap[player]
  if spawnPos then
   hrp.CFrame = spawnPos
  end
  if not workspace:FindFirstChild("Level0 Default Volume") then
--레벨 범위 지정 및 볼륨 생성
   createVolume("Level0 Default Volume", -506, -57.306, 60, 810, 65, 892)
   createVolume("Level32", -1298.75, 1000, -355.5, 1103.5, 1000, 1165)
   createVolume("Level33", 37.75, 96.194, -0.25, 615.5, 242, 581.5)
   createVolume("Level37", 140.5, 106.998, 1550.243, 1000, 2000, 2000)
   createVolume("Level!", -1871.756, 561.464, 976, 2047.5, 301, 208)
  end
  --local playerGui = player:WaitForChild("PlayerGui")
  --playerGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
  local a = coroutine.create(function()
   level33StatusScript.playerInSafeZone = true
   wait(5)
   level33StatusScript.playerInSafeZone = false
  end)
  coroutine.resume(a)
 end)
end)
--wait(5) --Spawn Delay
--local Level0  = createVolume("Level0", -490.5, -52.306, 184, 529, 75, 944)
--local Level32 = createVolume("Level32", -1298.75, 23.007, -355.5, 1103.5, 163.5, 1165)
--local Level33 = createVolume("Level33", 37.75, 96.194, -0.25, 615.5, 242, 581.5)
--local Level37 = createVolume("Level37", 140.5,106.998,1050.243, 1000,2000,1000)
--local LevelRUN  = createVolume("Level!", -1871.756, 561.464, 976, 2047.5, 301, 208)