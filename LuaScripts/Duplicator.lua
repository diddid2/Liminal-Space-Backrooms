
-- 전체 모두 직접 개발한 코드입니다.
-- 복도를 x11 길이만큼 늘리는 코드.
local model = workspace["Level!"]["Backroom Level !"]
local count = 10
local offset = Vector3.new(-150, 0, 0) --x 축으로 150길이의 segments(모델)를 10번 이어붙임. 

if not model.PrimaryPart then
 return
end

local endPlatform = workspace["Level!"]["Backroom Level ! End"]

local baseCFrame = model:GetPivot()

for i = 1, count do
 local clone = model:Clone()
 clone.Parent = model.Parent
 local newCFrame = baseCFrame * CFrame.new(offset * i)
 clone:PivotTo(newCFrame)
end

local endDelta = CFrame.new(offset * count)
endPlatform:PivotTo(endPlatform:GetPivot() * endDelta)