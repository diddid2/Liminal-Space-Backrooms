local belle = workspace.Level32:WaitForChild("belle") -- Level32 폴더 안에 있는  belle 모델 가져오기 
local event = game:GetService("ReplicatedStorage"):WaitForChild("LookAtBelle")

script.Parent.Touched:Connect(function(hitpart) -- 파트가 터치되었을 때 실행
local character = hitpart.Parent
local humanoid = character and character:FindFirstChild("Humanoid")
 if humanoid then
 local player = game.Players:GetPlayerFromCharacter(character)
 if player then
 -- 플레이어 위치와 belle 위치 가져오기
 local hrp = player.Character:FindFirstChild("HumanoidRootPart")
 local belleRoot = belle.PrimaryPart
 local bellePos = belleRoot.Position
 -- belle가 플레이어 방향으로만 "Y축 회전"하도록 위치 계산
 local targetPos = Vector3.new(hrp.Position.X, bellePos.Y, hrp.Position.Z)
 -- belle가 targetPos를 바라보도록 회전
 local lookAt = CFrame.new(bellePos, targetPos)
 belle:PivotTo(lookAt)

 event:FireClient(player, belleRoot)
end
end
end)
