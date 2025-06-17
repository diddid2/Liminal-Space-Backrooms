
-- 전체 모두 직접 개발한 코드입니다.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local segmentLength = 85
local loop_times = 0
local loopOrigin = Vector3.new(199.5 + 85*1, 433.976, 959.974)
local loopWidth = Vector3.new(39.5,44.226,31)

local stairOrigin = Vector3.new(23.5-15, 368.976, 963.438-15)
local stairWidth = Vector3.new(30, 250, 30)

local canLoop = true

---------------부활했을때 루프 적용안되는 현상 수정---------------
local function setupCharacter(char)
 character = char
 rootPart = character:WaitForChild("HumanoidRootPart")
end

if player.Character then
 setupCharacter(player.Character)
end

player.CharacterAdded:Connect(function(char)
 setupCharacter(char)
end)
-----------------------------------------------------------

function CharacterOffset(offset)
 canLoop = false
 local newPos = rootPart.CFrame + offset
 character:PivotTo(newPos)
 task.delay(0.1, function()
  canLoop = true
 end)
end

--RenderStepped 대신 BindToRenderStep 사용하여 카메라보다 먼저 함수가 호출되도록 (좀 더 자연스러운 느낌 가미).
RunService:BindToRenderStep("LoopMove", Enum.RenderPriority.Camera.Value - 10, function()
 if not character or not character:FindFirstChild("HumanoidRootPart") then return end
 local pos = rootPart.Position
 if canLoop == true then
  if pos.Y > loopOrigin.Y and pos.Y < loopOrigin.Y + loopWidth.Y and pos.Z > loopOrigin.Z and pos.Z < loopOrigin.Z + loopWidth.Z then --AREA 01
   if loop_times > 0 and pos.X < loopOrigin.X - 85 then --플레이어 위치가 특정 구역을 넘어갔을때 정해진 Offset만큼 다시 뒤로 돌려보내는 소스코드
    print("back again")
    updateWay(-1)
    loop_times = loop_times - 1
   elseif pos.X > loopOrigin.X then
    print("Loop Stack")
    loop_times = loop_times + 1
    updateWay(1)
   end
  elseif pos.X > stairOrigin.X and pos.X < stairOrigin.X + stairWidth.X and pos.Z > stairOrigin.Z and pos.Z < stairOrigin.Z + stairWidth.Z then --STAIR 01
   if pos.Y <= 390.876 then
    print("Stair_Up_Loop")
    CharacterOffset(Vector3.new(0, 17.68, 0))
   elseif pos.Y >= 486.605 then
    print("Stair_Down_Loop")
    CharacterOffset(Vector3.new(0, -17.68, 0))
   end
  end
 end
end)

local props_amount = 3
function updateWay(fadeinout)
 local current_pivot = workspace.LoopWarning:GetPivot()
 local new_pivot = current_pivot * CFrame.new(85*fadeinout,0,0)
 CharacterOffset(Vector3.new(-85 * fadeinout, 0, 0))
 workspace.LoopWarning:PivotTo(new_pivot)
 if loop_times > props_amount then
  local co = coroutine.create(function()
   if (fadeinout == 1) then
    if loop_times == props_amount + 1 then
     for i=255,0,-5 do --우선 for문으로 애니메이션을 구현해놨지만 TweenService로 교체하는게 좋을듯
      game.Lighting.ColorCorrection.TintColor = Color3.fromRGB(255,i,i)
      task.wait(0.017)
     end
    else
     for i=255-(loop_times-props_amount-2)*51,255-(loop_times-props_amount-1)*51,-3 do
      game.Lighting.ColorCorrection.TintColor = Color3.fromRGB(i,0,0)
      task.wait(0.017)
     end
    end
   else
    if loop_times == props_amount + 1 then
     for i=0,255,5 do
      game.Lighting.ColorCorrection.TintColor = Color3.fromRGB(255,i,i)
      task.wait(0.017)
     end
    else
     for i=255-(loop_times-props_amount-1)*51,255-(loop_times-props_amount-2)*51,3 do
      game.Lighting.ColorCorrection.TintColor = Color3.fromRGB(i,0,0)
      task.wait(0.017)
     end
    end
   end
  end)
  coroutine.resume(co)
 elseif game.Lighting.ColorCorrection.TintColor ~= Color3.fromRGB(255,255,255) then
  game.Lighting.ColorCorrection.TintColor = Color3.fromRGB(255,255,255)
 end 
end