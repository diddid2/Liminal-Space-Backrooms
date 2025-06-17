
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer


-- RemoteEvent 가져오기
local event = ReplicatedStorage:WaitForChild("LookAtBelle")

-- 이미 실행된 적 있는지 체크
local hasLookedAtBelle = false

event.OnClientEvent:Connect(function(targetPart)
 if hasLookedAtBelle then return end
 hasLookedAtBelle = true

 if not targetPart or not targetPart:IsA("BasePart") then return end

 -- 캐릭터 조작 불가능하게 제어
 local character = player.Character or player.CharacterAdded:Wait()
 local humanoid = character:FindFirstChildOfClass("Humanoid")
 local hrp = character:FindFirstChild("HumanoidRootPart")
 if not humanoid or not hrp then return end

 -- 기존 속도 저장 후 비활성화
 local oldWalkSpeed = humanoid.WalkSpeed
 local oldJumpPower = humanoid.JumpPower
 humanoid.WalkSpeed = 0
 humanoid.JumpPower = 0

 -- 카메라를 Scriptable 모드로 전환
 local originalType = Camera.CameraType
 Camera.CameraType = Enum.CameraType.Scriptable

 local startCFrame = Camera.CFrame

 -- 카메라의 위치에서 대상 바라보는 방향 계산
 local direction = (Camera.CFrame.Position - targetPart.Position).Unit
 local endPos = targetPart.Position + direction * 5
 local endCFrame = CFrame.new(endPos, targetPart.Position)

 -- Tween 코드를 이용해 부드럽게 플레이어 시점 이동
 local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
 local camTween = TweenService:Create(Camera, tweenInfo, {CFrame = endCFrame})

 camTween:Play()
 -- 1.5초 후 고정된 카메라 갱신
 local conn
 task.delay(1.5, function()
 conn = RunService.RenderStepped:Connect(function()
 Camera.CFrame = CFrame.new(endPos, targetPart.Position)
end)
end)

 -- 3초 후 원상복구
 task.delay(3, function()
 if conn then conn:Disconnect() end

 local currentChar = player.Character
 local currentHumanoid = currentChar and currentChar:FindFirstChildOfClass("Humanoid")

 if currentHumanoid then
 Camera.CameraType = Enum.CameraType.Custom
 Camera.CameraSubject = currentHumanoid

   -- 플레이어 조작 불가능 해제
 currentHumanoid.WalkSpeed = oldWalkSpeed
 currentHumanoid.JumpPower = oldJumpPower

end
end)
end)
