
local TeddyAI = script.Parent

local chasing = false
local followingTarget = nil
local SimplePath = require(game.ServerStorage.SimplePath)
local path = nil
local reached = false
local reached2 = false
local hipHeight = script.Parent.Humanoid.HipHeight

local partName
local partNameNumber = 0
local lastPath = 83
local statusScript = require(workspace.Level33.Level33StatusScript)


local pathParams = {
 ["AgentHeight"] = ((hipHeight > 0 and hipHeight) or 4),
 ["AgentRadius"] = script.Parent.HumanoidRootPart.Size.X,
 ["AgentCanJump"] = true
}

script.Parent.HumanoidRootPart:SetNetworkOwner(nil)

local function getHumPos()
 return (TeddyAI.HumanoidRootPart.Position - Vector3.new(0,hipHeight,0))
end

local function displayPath(waypoints)
 local color = BrickColor.Random()
 for index, waypoint in pairs(waypoints) do
  local part = Instance.new("Part")
  part.BrickColor = color
  part.Anchored = true
  part.CanCollide = false
  part.Size = Vector3.new(1,1,1)
  part.Position = waypoint.Position
  part.Parent = workspace
  local Debris = game:GetService("Debris")
  Debris:AddItem(part, 6)
 end
end

local function findPotentialTarget()
 local players = game.Players:GetPlayers()
 local maxDistance = 150
 local nearestTarget

 for index, player in pairs(players) do
  if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
   if player.Character.Humanoid.Health > 0 then
    local target = player.Character
    local distance = (TeddyAI.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude

    if distance < maxDistance then
     nearestTarget = player
     maxDistance = distance
    end
   end
  end
 end
 return nearestTarget
end

local function canSeeTarget(target)
 if target and target:FindFirstChild("HumanoidRootPart") then
  local origin = TeddyAI.HumanoidRootPart.Position
  local direction = (target.HumanoidRootPart.Position - TeddyAI.HumanoidRootPart.Position).unit * 500
  local ray = Ray.new(origin, direction)
  local ignoreList = {TeddyAI}

  local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)

  -- check if it exists
  if hit then
   -- check if it hit
   if hit:IsDescendantOf(target) then
    -- check health
    if target.Humanoid.Health > 0 then
     -- check if target is safe or not
     if not game.Players:GetPlayerFromCharacter(target).Safe.Value then
      -- check if monster can see
      local unit = (target.HumanoidRootPart.Position - getHumPos()).Unit
      local lv = TeddyAI.HumanoidRootPart.CFrame.LookVector
      local dp = unit:Dot(lv)
      if dp > 0 then
       game.Players:GetPlayerFromCharacter(target).PlayerGui.KuraTex.Enabled = true
       return true
      end  
     end   
    end
   end
  else
   game.Players:GetPlayerFromCharacter(target).PlayerGui.KuraTex.Enabled = false
   return false
  end 
 end
end

local function getPath(destination)
 local PathfindingService = game:GetService("PathfindingService")

 local path = PathfindingService:CreatePath(pathParams)

 path:ComputeAsync(getHumPos(), destination.Position)

 return path
end


--맵에 배치한 블록으로 이동하는 함수--
local function blockToBlock()
 if path and not reached then
  coroutine.wrap(function()
   path.Reached:Wait()
   reached2 = true
   print("Set")
  end)()
  repeat wait() if path == nil then break end until reached2 == true
 end
 reached = false
 reached2 = false
 path = nil
 coroutine.wrap(function()
  wait(1)
  if followingTarget and chasing == false then
   -- disable stuff for all targets
   print("disable things for all targets")
   for i, v in pairs(game.Players:GetPlayers()) do
    if v.GettingChasedBy.Value == script.Parent then
     v.GettingChased.Value = false
     v.GettingChasedBy.Value = nil
    end
   end
   TeddyAI.Chasing.Value = false
   followingTarget = nil
  end
 end)()
 
 
 print("now going to path")
 
 if statusScript.enemyStuck == true then
  statusScript.enemyStuck = false
  partNameNumber = 0
  print("reset")
 end 
 
 --블록의 이름순서대로 움직이도록 설정
 partNameNumber += 1
 partName = "Path" .. partNameNumber
 print(partName)
 
 if partNameNumber == lastPath then
  partNameNumber = 0
 end
 
 local goal = workspace.WaypointsHowler_2:FindFirstChild(partName)
 local path = getPath(goal)
 
 if path.Status == Enum.PathStatus.Success then
  for i, v in pairs(path:GetWaypoints()) do
   if findPotentialTarget() then
    if canSeeTarget(findPotentialTarget().Character) then
     break
    end
   end
   TeddyAI.Humanoid:MoveTo(v.Position)
   TeddyAI.Humanoid.MoveToFinished:Wait()
  end
 else
  print("nope")
 end
end

TeddyAI.Chasing.Changed:Connect(function()
 print(TeddyAI.Chasing.Value)
end)

script.Parent.Teleport.Event:Connect(function()
 path = nil
end)

while true do
 local target = findPotentialTarget()
 --플레이어를 감지했을 때 플레이어를 추격하는 함수--
 if target and canSeeTarget(target.Character) and target.Character.Humanoid.Health > 0  and statusScript.playerInSafeZone == false then
  workspace["Siren Head_Chase (OLD)"]:Play()
  print("found player")
  path = SimplePath.new(script.Parent,pathParams)
  local connection = path.Reached:Connect(function()
   reached = true
   script.Parent.Reached:Fire(target)
  end)
  repeat
   chasing = true
   followingTarget = target
   target.GettingChased.Value = true
   target.GettingChasedBy.Value = script.Parent
   TeddyAI.Chasing.Value = true
   path:Run(target.Character.HumanoidRootPart.Position)
   print("chasing!!!")
  until target.Character.Humanoid.Health < 1 or reached or statusScript.playerInSafeZone == true or statusScript.enemyStuck == true or statusScript.playerDeath == true
  --플레이어가 세이프 존에 들어올 경우 추격 중지
  
  
  workspace["Siren Head_Chase (OLD)"]:Stop()
  game.Players:GetPlayerFromCharacter(target.Character).PlayerGui.KuraTex.Enabled = false
  
  
  if connection then
   connection:Disconnect()
  end
  if findPotentialTarget() ~= target then
   if path and path._moveConnection then
    path:Stop()
   end
  end
  
  --플레이어가 세이프 존에 들어올 경우 세이프 존에 가까운 블록으로 움직이도록 구현
  if statusScript.playerInSafeZone == true then
   print("InSafeZone")
   partNameNumber = 69
   chasing = false
   blockToBlock()
  end
  
  print("stopped")
  chasing = false
  
 else
  print("block to block")
  blockToBlock()
 end
 game:GetService("RunService").Heartbeat:Wait()
end

