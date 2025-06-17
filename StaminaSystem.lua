
--스태미나 시스템

local UIS = game:GetService('UserInputService')
local Player = game.Players.LocalPlayer
local Character = Player.Character

local maxstamina = 500
local function setupCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")
	local stamina = maxstamina
	local sprinting = false

	local ui = Player:WaitForChild("PlayerGui"):WaitForChild("StaminaGUI")
	local staminaBar = ui:WaitForChild("StaminaBackground"):WaitForChild("StaminaBar")

	local function startSprint()
		if stamina > 10 * maxstamina / 100 then
			humanoid.WalkSpeed = 25
			sprinting = true
		end
	end

	local function stopSprint()
		humanoid.WalkSpeed = 7
		sprinting = false
	end

	local RunService = game:GetService("RunService")
	
	local inputBeganConn, inputEndedConn, renderSteppedConn
	
	inputBeganConn = UIS.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.LeftShift then
			startSprint()
		end
	end)

	inputEndedConn = UIS.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.LeftShift then
			stopSprint()
		end
	end)
	
	renderSteppedConn = RunService.RenderStepped:Connect(function(deltaTime)
		if sprinting and stamina > 0 then
			stamina = stamina - (20 * deltaTime)
		elseif not sprinting and stamina < maxstamina then
			stamina = stamina + (maxstamina / 100 * 10 * deltaTime)
		end

		if stamina <= 0 then
			stamina = 0
			stopSprint()
		end

		staminaBar:TweenSize(UDim2.new(stamina / maxstamina, 0, 1, 0), "Out", "Quad", 0.2, true)
	end)
	
	character.AncestryChanged:Connect(function(_, parent)
		if not parent then
			inputBeganConn:Disconnect()
			inputEndedConn:Disconnect()
			renderSteppedConn:Disconnect()
		end
	end)
end

--if Player.Character then
--	setupCharacter(Player.Character)
--end
Player.CharacterAdded:Connect(setupCharacter)
if Player.Character then
	setupCharacter(Player.Character)
end
