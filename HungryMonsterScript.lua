
local monster = script.Parent.Handle.SpecialMesh  --몬스터의 모션을 구현하기 위해 몬스터의 매쉬를 담은 변수

local clickDetector = script.Parent.ClickDetector  --몬스터의 클릭디텍터를 담은 변수

local statusScript = require(workspace.Level33.Level33StatusScript) --전반적인 게임의 상태를 확인할 수 있는 모듈스크립트를 담은 변수

local changeYSize = -0.002
local changeXSize = -0.002 --사이즈가 한번 변하는 양을 담은 변수

local eatTime = 2  --먹는 시간을 담은 변수
local eatSound = script["EatSound"] --먹는소리를 담은 변수

local eatEffect = workspace.Level33.HungryMonster.EatEffect:FindFirstChild("Effect"):FindFirstChild("ParticleEmitter")
local eatEffect2 = workspace.Level33.HungryMonster.EatEffect:FindFirstChild("Effect"):FindFirstChild("ParticleEmitter2")
local eatEffect3 = workspace.Level33.HungryMonster.EatEffect:FindFirstChild("Effect"):FindFirstChild("Part"):FindFirstChild("ParticleEmitter3") --먹는 이펙트를 담은 변수들

local eatingBear = workspace.Level33.EatingItems:FindFirstChild("EatingBear")
local eatingCan = workspace.Level33.EatingItems:FindFirstChild("EatingCan")
local eatingLaptop = workspace.Level33.EatingItems:FindFirstChild("EatingLaptop")
local eatingCoffe = workspace.Level33.EatingItems:FindFirstChild("EatingCoffe")
local eatingCheese = workspace.Level33.EatingItems:FindFirstChild("EatingCheese") --먹을 때 입에 등장할 아이템들을 담은 변수들

local buttonBlocker = workspace.ButtonBlocker --엘리베이터 버튼을 막는 장애물을 담은 변수

local Players = game:GetService("Players") --플레이어를 담은 변수

local ReplicatedStorage = game:GetService("ReplicatedStorage") --ReplicatedStorage를 담은 변수

local remote = ReplicatedStorage:WaitForChild("UpdateMissionLabel") --UI를 변경하는 이벤트를 담은 변수

eatEffect.Enabled = false
eatEffect2.Enabled = false
eatEffect3.Enabled = false --시작할때 이펙트를 false로 설정

eatingBear:ScaleTo(0.001)
eatingCan:ScaleTo(0.001)
eatingLaptop:ScaleTo(0.001)
eatingCoffe:ScaleTo(0.001)
eatingCheese:ScaleTo(0.001) --시작할때 입에 있는 아이템들의 크기를 0.001로 설정하여 플레이어 눈에 보이지 않도록 설정




--UI를 적용하는 함수--
function setText(text)
 for _, player in ipairs(Players:GetPlayers()) do
  remote:FireClient(player, text)
 end
end

--몬스터에게 아이템을 먹였을 때의 모션과 아이템을 먹은 후 다음목표를 갱신하는 함수--
function EatMotion()
 changeYSize = 0.03       --먹는 모션시 크기 변형도 설정
 
 eatEffect.Enabled = true 
 eatEffect2.Enabled = true
 eatEffect3.Enabled = true  --먹는 이펙트가 보이도록 설정
 
 eatSound:Play() --먹는 소리 재생
 
 if statusScript.itemRound == 1 then         --모듈스크립트의 아이템순서를 확인하는 변수값에 맞게 아이템의 크기를 키워 해당 아이템이 입에서 보이도록 설정
  eatingBear:ScaleTo(4)
 elseif statusScript.itemRound == 2 then
  eatingCan:ScaleTo(1)
 elseif statusScript.itemRound == 3 then
  eatingLaptop:ScaleTo(2)
 elseif statusScript.itemRound == 4 then
  eatingCoffe:ScaleTo(2)
 elseif statusScript.itemRound == 5 then
  eatingCheese:ScaleTo(2)
 end

 while statusScript.monsterEat == true do  --몬스터가 먹는 모션을 보여주는 반복문
  
  task.wait(0.02)                       --0.02초를 주기로 반복
  
  if monster.Scale.Y >= 0.41 then       --제한한 Y축으로 사이즈가 커짐
   changeYSize *= -1
  end
  if monster.Scale.Y <= 0.25 then       --제한한 Y축으로 사이즈가 작아짐
   changeYSize *= -1
  end
  monster.Scale = Vector3.new(monster.Scale.X, monster.Scale.Y + changeYSize, monster.Scale.Z) --설정한 크기로 Y축을 변경
  
  eatTime -= 0.022           --먹는 시간변수값을 감소시키기
  
  if eatTime <= 0 then       --먹는 시간이 0이하가 되면 먹는 모션을 멈추고 가만이 있을 때의 모션으로 넘어가도록 모듈스크립트 변수 설정 및 먹는 시간 초기화
   statusScript.monsterEat = false
   statusScript.monsterIdle = true
   eatTime = 2
  end
 end
 
 if statusScript.itemRound == 1 then    --모듈스크립트의 아이템순서를 확인하는 변수값에 맞게 UI에 다음 목표 갱신
  setText("땅콩캔 찾기")
 elseif statusScript.itemRound == 2 then
  setText("노트북 찾기")
 elseif statusScript.itemRound == 3 then
  setText("커피 찾기")
 elseif statusScript.itemRound == 4 then
  setText("치즈 찾기")
 elseif statusScript.itemRound == 5 then  --마지막 아이템을 먹으면 엘리베이터로 이동하라고 지시하고 엘리베이터 버튼을 막고 있는 나무 판자를 치움
  buttonBlocker.Position = Vector3.new(buttonBlocker.Position.X - 1, buttonBlocker.Position.Y, buttonBlocker.Position.Z)
  buttonBlocker.Anchored = false
  print("done")
  setText("엘리베이터로 이동하기")
 end
 
 eatingBear:ScaleTo(0.001)          
 eatingCan:ScaleTo(0.001)
 eatingLaptop:ScaleTo(0.001)
 eatingCoffe:ScaleTo(0.001)
 eatingCheese:ScaleTo(0.001)     --먹는 모션이 끝났으므로 아이템이 보이지 않도록 다시 크기를 0.001로 설정
 
 eatSound:Stop()   --먹는 소리도 중지
 
 eatEffect.Enabled = false
 eatEffect2.Enabled = false
 eatEffect3.Enabled = false  --먹는 이펙트도 중지
 
 
 statusScript.itemRound += 1 --모듈스크립트의 아이템서를 확인하는 변수값을 더해 다음 아이템을 먹을 수 있도록 설정
 
 IdleMotion() --가만히 있을때의 모션 함수 실행
end



--몬스터가 가만히 있을때의 모션 함수--
function IdleMotion()
 changeXSize = -0.002
 changeYSize = -0.002  --가만히 있는 모션시 크기 변형도 설정

 monster.Scale = Vector3.new(0.287, 0.266, 0.279) --모션 시작시의 사이즈 초기화
 
 while statusScript.monsterIdle == true do     --모듈스크립트의 몬스터가 가만히 있는 상태를 담은 변수가 True일 동안 실행
  
  task.wait(0.03)      --0.03초 주기로 반복
  
  if monster.Scale.Y >= 0.31 then       --제한한 Y축으로 사이즈가 커짐
   changeYSize *= -1
  end
  if monster.Scale.Y <= 0.25 then       --제한한 Y축으로 사이즈가 작아짐 
   changeYSize *= -1
  end
  if monster.Scale.X >= 0.321 then      --제한한 X축으로 사이즈가 커짐
   changeXSize *= -1
  end
  if monster.Scale.X <= 0.261 then      --제한한 X축으로 사이즈가 작아짐
   changeXSize *= -1
  end
  monster.Scale = Vector3.new(monster.Scale.X + changeXSize, monster.Scale.Y + changeYSize, monster.Scale.Z)  --설정한 크기로 X축, Y축 사이즈 설정
 end
 EatMotion() --모듈스크립트의 몬스터가 가만히 있는 상태를 담은 변수가 False가 되면 먹는 함수 실행
end

IdleMotion() -- 게임 시작시 가만히 있을때의 모션 함수 실행
