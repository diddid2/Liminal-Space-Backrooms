
local CollectionService = game:GetService("CollectionService")   --CollectionService를 담은 변수

local Items = CollectionService:GetTagged("InteractiveItem")  --InteractiveItem 테그를 가지고 있는 아이템들 담은 변수

local globalRange = 1000     --아이템을 클릭할 수 있는 최대거리를 담은 변수

local Players = game:GetService("Players") --플레이어를 담은 변수

local needItemGet = false    --필요한 아이템을 얻었는지 확인하는 변수

local monsterClickDetector = workspace.Level33:FindFirstChild("HungryMonster").ClickDetector  --아이템을 먹여야할 몬스터의 클릭딕텍터를 받은 변수

local statusScript = require(workspace.Level33.Level33StatusScript)    --전반적인 게임의 상태를 확인할 수 있는 모듈스크립트를 담은 변수

local safeZone = workspace.Level33.SafeZone         --세이프존 모델을 담은 변수

local ReplicatedStorage = game:GetService("ReplicatedStorage") --ReplicatedStorage를 담은 변수

local remote = ReplicatedStorage:WaitForChild("UpdateMissionLabel") --UI를 변경하는 이벤트를 담은 변수

function setText(text)  --왼쪽위 UI를 설정하는 함수--
 for _, player in ipairs(Players:GetPlayers()) do
  remote:FireClient(player, text)
 end
end

setText("곰인형 찾기") --게임 시작시 먹어야할 첫번째 아이템이 곰인형이므로 곰인형을 찾기로 UI설정

--시작할때 아이템들을 각 아이템들에게 필요한 컴포넌트들을 설정하는 반복문--
for i = 1,#Items,1 do
 
 if Items[i].Name ~= "BearItem" then --시작할때 먹어야할 아이템은 곰인형이므로 곰인형을 제외한 나머지 아이템들의 반짝이는 힌트표시는 꺼두는것으로 설정
  Items[i].SparklesEffect.Sparkles:FindFirstChild("Sparkle").Enabled = false
 end
 
 local Highlight = Instance.new("Highlight")  --각각 먹여야할 아이템들에게 표시할수 있도록 하이라이트 추가
 
 Highlight.FillTransparency = 1  --하이라트가 테두리만 표시할 수 있도록 설정
 
 Highlight.Parent = Items[i]     --각각 아이템의 하이라이트의 부모를 설정
 
 Highlight.Enabled = false       --각각 아이템의 하이라이트를 시작시 비활성화 되도록 설정
 
 local ClickDetector = Instance.new("ClickDetector") --각각 먹여야할 아이템들에게 클릭딕텍터를 추가
 
 ClickDetector.MaxActivationDistance = globalRange  --클릭딕텍터의 감지 거리 설정
 
 ClickDetector.Parent = Items[i] --각각 아이템의 클릭딕텍터 부모설정                     
 
 ClickDetector.MouseHoverEnter:Connect(function(player) --얻어야할 아이템쪽에 마우스를 대면 아이템테두리에 표시가 생기도록 설정
  Highlight.Enabled = true
 end)
 
 ClickDetector.MouseHoverLeave:Connect(function(player) --얻어야할 아이템에서 마우스를 때면 아이템테두리에 표시가 없어지도록 설정
  Highlight.Enabled = false
 end)
 
 ClickDetector.MouseClick:Connect(function(other) --얻어야할 아이템에 마우스를 대고 클릭하면 mouseClicke 함수 호출
  mouseClicked(Items[i].Name)
 end)
 print("item detect")
end

--아이템을 얻고 몬스터를 클릭했을 작동하는 함수--
monsterClickDetector.MouseClick:Connect(function(player)
 if needItemGet == true then
  needItemGet = false
  statusScript.monsterEat = true
  statusScript.monsterIdle = false
  print("ItemEat!!!!")
  print(statusScript.itemRound)
  
  --다음 얻어야할 아이템의 힌트 표시를 활성화 하는 부분
  if statusScript.itemRound == 1 then
   workspace.Level33.Items.CanItem.SparklesEffect.Sparkles:FindFirstChild("Sparkle").Enabled = true
  elseif statusScript.itemRound == 2 then
   workspace.Level33.Items.LaptopItem.SparklesEffect.Sparkles:FindFirstChild("Sparkle").Enabled = true
  elseif statusScript.itemRound == 3 then
   workspace.Level33.Items.CoffeItem.SparklesEffect.Sparkles:FindFirstChild("Sparkle").Enabled = true
  elseif statusScript.itemRound == 4 then
   workspace.Level33.Items.CheeseItem.SparklesEffect.Sparkles:FindFirstChild("Sparkle").Enabled = true 
  end
 end
end)


local items_sort = {"BearItem", "CanItem", "LaptopItem", "CoffeItem", "CheeseItem"} --아이템 획득순서.
--얻어야할 아이템에 마우스를 대고 클릭했을 시 아이템을 얻는 함수--
function mouseClicked(name)
 
 local clickObject = workspace.Level33.Items:FindFirstChild(name) --클릭한 아이템을 담은 변수
 
 for i=1,#items_sort do
  if name == items_sort[i] and statusScript.itemRound == i then --클릭한 아이템이 지금 얻어야하는 아이템이 맞을 경우
   setText("몬스터에게 먹이기")
   needItemGet = true
   print(items_sort[i].." Click")
   clickObject:Destroy() --클릭한 아이템을 삭제하고 needItemGet을 true로 만들어 필요한 아이템을 얻었다는 조건을 만족시키고 몬스터에게 먹이라고 UI를 설정
  end
 end
end

--세이프존에 들어왔을시 작동하는 함수--
safeZone.Touched:Connect(function(other)
 local character = other:FindFirstAncestorWhichIsA("Model") --플레이어 캐릭터 모델을 담은 변수
 
 local player = game.Players:GetPlayerFromCharacter(character) -- 전체 플레이어 중 위에서 가져온 캐릭터를 포함하는 플레이어를 검색
 
 if game.Players:GetPlayerFromCharacter(character) and statusScript.playerInSafeZone == false then --세이프존에 들어온 모델이 플레이어인 경우
  statusScript.playerInSafeZone = true    --모듈 스크립트의 playerInSafeZone을 true로 만들어 플레이어가 세이프존에 들어왔다는 조건을 만족시킴
  print(statusScript.playerInSafeZone)
 end
end)

--세이프존에서 나왔을시 작동하는 함수--
safeZone.TouchEnded:Connect(function(other)
 local character = other:FindFirstAncestorWhichIsA("Model") 
 
 local player = game.Players:GetPlayerFromCharacter(character)
 
 if game.Players:GetPlayerFromCharacter(character) and statusScript.playerInSafeZone == true then --세이프존에서 나온 모델이 플레이어인 경우
  statusScript.playerInSafeZone = false   --모듈 스크립트의 playerInSafeZone을 false로 만들어 플레이어가 세이프존에서 나왔다는 조건을 만족시킴
  print(statusScript.playerInSafeZone)
 end
end)