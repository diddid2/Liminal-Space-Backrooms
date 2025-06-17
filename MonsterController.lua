
-- 전체 모두 직접 개발한 코드입니다.
-- 뒤에서 
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local smiler = workspace["Level!"]:WaitForChild("Smiler")
local speed = 14

-- 초기 위치 저장
local smilerInitialCFrame = smiler:GetPivot()

-- 이동 제어 변수
local moving = false

-- smiler를 초기 위치로 돌려보내는 함수
local function ResetSmiler()
	if smiler and smiler:IsDescendantOf(workspace) then
		smiler:PivotTo(smilerInitialCFrame)
	end
end

-- smiler 이동 함수
local function StartMoving()
	moving = true
end

local function StopMoving()
	moving = false
end

RunService.Heartbeat:Connect(function(dt)
	if not moving then return end
	if not smiler or not smiler:IsDescendantOf(workspace) then return end

	local currentPos = smiler:GetPivot().Position
	local moveAmount = -speed * dt
	local newPos = currentPos + Vector3.new(moveAmount, 0, 0)

	smiler:PivotTo(CFrame.new(newPos))
end)

-- 캐릭터 세팅 함수
local function setupCharacter(char)
	local humanoid = char:WaitForChild("Humanoid")
	-- humanoid 사망 시 처리
	humanoid.Died:Connect(function()
		StopMoving()
		ResetSmiler()
	end)
end

local function setupPlayer(player)
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

-- 게임 시작 신호를 받으면 이동 시작
local event = ReplicatedStorage:WaitForChild("Level!Start")
event.Event:Connect(function()
	ResetSmiler()
	StartMoving()
end)

--local RunService = game:GetService("RunService")

--local smiler = workspace["Level!"]:WaitForChild("Smiler")
--local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local event = ReplicatedStorage:WaitForChild("Level!Start")
--local speed = 17
--local moving = false

--event.Event:Wait()

--RunService.Heartbeat:Connect(function(dt)
--	if not smiler or not smiler:IsDescendantOf(workspace) then return end

--	local currentPos = smiler:GetPivot().Position
--	local moveAmount = -speed * dt
--	local newPos = currentPos + Vector3.new(moveAmount, 0, 0)

--	smiler:PivotTo(CFrame.new(newPos))
--end)