
--교과서, 강의 수업내용 참조하여 텔레포트 UI만 따로 도구상자에서 가져와 구현
local sp = script.Parent

local debounce = true

sp.Touched:Connect(function(hitpart)
 local character = hitpart.Parent
 local humanoid = character:FindFirstChild("Humanoid")
 if humanoid and debounce then
  local player = game.Players:GetPlayerFromCharacter(character)
  if player then
   debounce = false
   player.PlayerGui.LoadingScreen.Frame.Visible = true
   wait(1.1)
   sp.CanTouch = false
   character:FindFirstChild("HumanoidRootPart").CFrame = workspace["Level32"].SpawnPoint.CFrame
   
   wait(20)
   debounce = true
   sp.CanTouch = true
   player.PlayerGui.LoadingScreen.Frame.Visible = false
  end
 end
end)