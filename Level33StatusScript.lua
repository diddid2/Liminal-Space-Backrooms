
local module = {}

--다른 스크립트들이 참조할 수 있는 전반적인 게임의 상태를 나타내는 변수들

module.monsterIdle = true   --몬스터가 가만히 있는 상태인지를 확인하는 변수
module.monsterEat = false   --몬스터가 먹고있는 상태인지를 확인하는 변수
module.itemRound = 1        --먹어야할 아이템의 순서를 정하는 변수
module.playerInSafeZone = false   --플레이어가 세이프존에 들어왔는지를 확인하는 변수
module.enemyStuck = false         --적 몬스터가 어딘가에 끼어서 움직이 못하는 지를 확인하는 변수
module.currentMission = "곰인형을 찾기" --UI에 띄울 현재 목표를 저장하는 변수


return module