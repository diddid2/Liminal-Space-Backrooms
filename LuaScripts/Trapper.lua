
-- 전체 모두 직접 개발한 코드입니다.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local modelsFolder = ReplicatedStorage:WaitForChild("Trap Models")
local spawnCenter = workspace:WaitForChild("RunwayCenter")
local event = ReplicatedStorage:WaitForChild("Level!Start")

local sideOffset = 18
local moveDuration = 0.5
local lifespan = 600
local stepDistance = 15
local sides = {-1, 1}
local rng = Random.new(1234567)

local spawnedTraps = {}
local trapConnection = nil -- Heartbeat 연결 추적

local function lerp(a: Vector3, b: Vector3, t: number)
 return a + (b - a) * t
end

--ReplicatedStorage에 있는 두 모델을 가져와서 이벤트가 트리거 된 시점 이후로 플레이어가 x축으로 15씩 움직일때마다 양옆 랜덤(시드값) 장애물 생성

local function moveModelOverTime(model: Model, startPos: Vector3, endPos: Vector3, duration: number)
 local startTime = tick()
 local conn
 conn = RunService.Heartbeat:Connect(function()
  local elapsed = tick() - startTime
  local alpha = math.clamp(elapsed / duration, 0, 1)
  local newPos = lerp(startPos, endPos, alpha)
  model:PivotTo(CFrame.new(newPos))
  if alpha >= 1 then
   conn:Disconnect()
  end
 end)
end

local function spawnTrapModel(forwardX: number)
 local props = modelsFolder:GetChildren()
 if #props == 0 then return end

 local original = props[rng:NextInteger(1, #props)]
 local selected = original:Clone()
 local side = sides[rng:NextInteger(1, #sides)]

 local offsetZ = original:GetAttribute("OffsetZ") or 4
 local baseZ = spawnCenter.Position.Z
 local spawnZ = baseZ + side * (sideOffset + offsetZ)
 local endZ   = baseZ + side * (offsetZ + 0.1)

 local spawnPos = Vector3.new(forwardX, spawnCenter.Position.Y, spawnZ)
 local endPos   = Vector3.new(forwardX, spawnCenter.Position.Y, endZ)

 selected:PivotTo(CFrame.new(spawnPos))
 selected.Parent = workspace

 moveModelOverTime(selected, spawnPos, endPos, moveDuration)
 Debris:AddItem(selected, lifespan)

 table.insert(spawnedTraps, selected)
end

local function clearTraps()
 for _, trap in ipairs(spawnedTraps) do
  if trap and trap.Parent then
   trap:Destroy()
  end
 end
 table.clear(spawnedTraps)
 if trapConnection then
  trapConnection:Disconnect()
  trapConnection = nil
 end
end

local function startTrapLoop(hrp: Part)
 local lastX = hrp.Position.X
 local trapCounter = 0
 local spawnBaseX = spawnCenter.Position.X

 trapConnection = RunService.Heartbeat:Connect(function()
  if not hrp or not hrp.Parent then return end

  local currentX = hrp.Position.X
  local distanceMoved = currentX - lastX

  if distanceMoved <= -stepDistance then
   trapCounter += 1
   lastX -= stepDistance
   local trapX = spawnBaseX - (trapCounter * stepDistance) - 15
   spawnTrapModel(trapX)
  end
 end)
end

local latestHRP = nil

event.Event:Connect(function()
 if latestHRP then
  clearTraps()
  startTrapLoop(latestHRP)
 end
end)

local function setupCharacter(char)
 local hrp = char:WaitForChild("HumanoidRootPart")
 local humanoid = char:WaitForChild("Humanoid")

 latestHRP = hrp

 humanoid.Died:Connect(function()
  clearTraps()
  latestHRP = nil
 end)
end

local function setupPlayer(player: Player)
 if player.Character then
  setupCharacter(player.Character)
 end
 player.CharacterAdded:Connect(setupCharacter)
end

local player = Players:GetPlayers()[1]
if not player then
 player = Players.PlayerAdded:Wait()
end
setupPlayer(player)
