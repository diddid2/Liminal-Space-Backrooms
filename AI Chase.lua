-- 좀비가 플레이어를 인식할 최대 거리 및 공격 시 입힐 피해량
local SearchDistance = 100
local ZombieDamage = 100

local zombie = script.Parent
local human = zombie:FindFirstChildOfClass("Humanoid")
local hroot = zombie:WaitForChild("HumanoidRootPart")

local pfs = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- 배회 범위
local WanderX, WanderZ = 30, 30
local isWandering = false

-- 좀비가 원래 있던 위치 저장
local zombieOriginCFrame = zombie:GetPivot()

function GetNearestPlayerTorso(position)
 local closestTorso = nil
 local shortestDistance = SearchDistance

 for _, player in pairs(Players:GetPlayers()) do
 if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
 local root = player.Character.HumanoidRootPart
 local dist = (root.Position - position).Magnitude
 if dist < shortestDistance then
  shortestDistance = dist
  closestTorso = root
end
end
end
return closestTorso
end

-- 좀비가 무작위로 주변을 배회함
function WanderRandomly()
 if isWandering then return end -- 이미 배회 중이면 중복 실행 방지
 isWandering = true

 task.spawn(function()
 while isWandering do
 local randX = math.random(-WanderX, WanderX)
 local randZ = math.random(-WanderZ, WanderZ)
 local target = Vector3.new(hroot.Position.X + randX, hroot.Position.Y, hroot.Position.Z + randZ)
 human:MoveTo(target)
 human.MoveToFinished:Wait(2)
 wait(math.random(2, 4)) -- 다음 배회까지 대기
end
end)
end

-- 좀비 몸체가 플레이어를 닿으면 피해 입힘
for _, part in pairs(zombie:GetChildren()) do
 if part:IsA("BasePart") then
 part.Touched:Connect(function(hit)
 local character = hit:FindFirstAncestorOfClass("Model")
 local humanoid = character and character:FindFirstChild("Humanoid")
 if humanoid and character.Name ~= zombie.Name then
 humanoid:TakeDamage(ZombieDamage)
end
end)
end
end

-- 플레이어가 게임에 입장하면 캐릭터 죽음을 감지
Players.PlayerAdded:Connect(function(player)
 player.CharacterAdded:Connect(function(character)
 local humanoid = character:WaitForChild("Humanoid")

 humanoid.Died:Connect(function()
 -- 플레이어가 죽으면 좀비를 원래 위치로 되돌림
 task.delay(0.1, function()
 if zombie and zombie:FindFirstChild("HumanoidRootPart") then
 zombie:PivotTo(zombieOriginCFrame)
end
end)
end)
end)
end)

-- 플레이어 추적 및 배회 반복
task.spawn(function()
 local lastTargetPos = nil
 local recalcCooldown = 0.2
 local timeSinceLastRecalc = 0

 RunService.Heartbeat:Connect(function(dt)
 timeSinceLastRecalc += dt

 if timeSinceLastRecalc < recalcCooldown then return end

 local targetTorso = GetNearestPlayerTorso(hroot.Position)
 if targetTorso then
 isWandering = false -- 추적 중이므로 배회 중지

 local targetPos = targetTorso.Position
 if not lastTargetPos or (targetPos - lastTargetPos).Magnitude > 4 then
 lastTargetPos = targetPos
 timeSinceLastRecalc = 0

 local path = pfs:CreatePath({
 AgentRadius = 2,
 AgentHeight = 5,
 AgentCanJump = true,
 AgentCanClimb = true,
})

 path:ComputeAsync(hroot.Position, targetPos)

 if path.Status == Enum.PathStatus.Success then
 local waypoints = path:GetWaypoints()
 task.spawn(function()
 for _, waypoint in ipairs(waypoints) do
       human:MoveTo(waypoint.Position)
 local success = human.MoveToFinished:Wait(1)
 if not success then break end -- 경로 상 장애물이 있으면 멈춤
end
end)
end
end
else
-- 타겟이 없으면 무작위 배회 시작
 WanderRandomly()
end
end)
end)
