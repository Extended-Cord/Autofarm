--// FOBFarm v3
--// Written by Amiriki
--// Features Discord webhook logging + Auto :mapvote

getgenv().Options = {
	['Weapon'] = 'Venomancer', -- Name of weapon you want to use to kill NPCs
	['KillGenWeapon'] = 'Heavens Edge', -- Name of weapon you want to use when killing general.
	['WebhookURL'] = '', -- Optional | Enter Discord webhook URL to log information.
	['onFinishCommand'] = ':mapvote savannah'
}

--// Internals
--// Variables

local HTTPService = game:service('HttpService') 
local Players = game:service('Players')
local localPlayer = Players.LocalPlayer
local leaderStats = localPlayer:WaitForChild('leaderstats')
local targetsPath = workspace['Unbreakable']['Characters']
local Teams = game:service('Teams')
local coreGui = game:service('CoreGui')
local targetTeam

--// Functions

function sendToWebhook(webhook, halal)
	if hala == false then
	local data = {
			["embeds"] = {{
				["title"] = "FOBFarm 3.0",
				["description"] = "A round has just ended!",
				["type"] = "rich",
				["color"] = tonumber(0x0096FF),
				["fields"] = {
					{
						["name"] = "Gold",
						["value"] = tostring(leaderStats.Gold.Value),
						["inline"] = true
					},
					{
						["name"] = "Experience",
						["value"] = tostring(leaderStats.XP.Value),
						["inline"] = true
					},
					{
						["name"] = "Level",
						["value"] = tostring(leaderStats.Level.Value),
						["inline"] = true
					},
				},
				["footer"] = {
					["text"] = 'Current Account: '..localPlayer.Name
				}
			}}
		}
	else
		local data = {
			["embeds"] = {{
				["title"] = "FOBFarm 3.0",
				["description"] = "Player has joined the game / You have been disconnected",
				["type"] = "rich",
				["color"] = tonumber(0xFFFFFF),
				["footer"] = {
					["text"] = 'Current Account: '..localPlayer.Name
				}
			}}
		}
	end
	
	
	
	
	response = syn.request(
	{
		Url = webhook,
		Method = 'POST',
		Headers = {
			['Content-Type'] = 'application/json'
		},
		Body = HTTPService:JSONEncode(data)
	}
);
end

function getTarget()
	warn('// Obtaining Targets //')
	local targetsList

	if localPlayer.Team == Teams:FindFirstChild('Neutral') then return {} end
	if localPlayer.Team == Teams:FindFirstChild('Orc') then targetTeam = 'Human' end
	if localPlayer.Team == Teams:FindFirstChild('Human') then targetTeam = 'Orc' end

	targetsList = targetsPath[targetTeam]:GetChildren()
	local gen
	local ind 
	for i,v in pairs(targetsList) do
		if v.Name == 'Human General' or v.Name == 'Orc General'  then
		ind = i
		gen = v
		end
	end
	
	targetsList[ind] = nil
	table.insert(targetsList, #targetsList, gen)

	return targetsList
end

function attack(target)
local currentWeapon

if target.Name == 'Orc General' or target.Name == 'Human General' then currentWeapon = Options.KillGenWeapon else currentWeapon = Options.Weapon end 
if Teams:FindFirstChild('Neutral') and localPlayer.Team == Teams:FindFirstChild('Neutral') then return end

repeat wait() until localPlayer.Backpack:FindFirstChild(currentWeapon) or localPlayer.Character:FindFirstChild(currentWeapon)
if localPlayer.Backpack:FindFirstChild(currentWeapon) then localPlayer.Character.Humanoid:EquipTool(localPlayer.Backpack:FindFirstChild(currentWeapon)) end

warn('// Teleporting to next target //')

repeat
localPlayer.Character:FindFirstChild(currentWeapon):Activate()
localPlayer.Character.HumanoidRootPart.CFrame = target.Torso.CFrame * CFrame.new(0,0,3)
wait(0.25)
until not target or target:FindFirstChild('Humanoid').Health == 0
end


localPlayer.CharacterAdded:Connect(function()
for index, npc in pairs(getTarget()) do
attack(npc)
getTarget()[index] = nil
end

warn('// Round over //')
	Players:Chat(Options.onFinishCommand)
	sendToWebhook(Options.WebhookURL,false)
end)

Players.PlayerAdded:Connect(function(plr)
	sendToWebhook(Options.WebhookURL,true)
	game:Shutdown()
end)

coreGui.RobloxPromptGui.promptOverlay.DescendantAdded:Connect(function()
    local GUI = coreGui.RobloxPromptGui.promptOverlay:FindFirstChild("ErrorPrompt")
    if GUI then
        if GUI.TitleFrame.ErrorTitle.Text == "Disconnected" then
            sendToWebhook(Options.WebhookURL,true)
			game:Shutdown()
        end
    end
end)
