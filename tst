local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Leywin V1 discord.gg/hwidspoof",
    SubTitle = "Free Version",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local FruitESPEnabled = false
local ChestESPEnabled = false
local PlayerESPEnabled = false
local PlayerESPObjects = {}
local IslandESPEnabled = false
local IslandESPObjects = {}
local InfiniteEnergyEnabled = false
local originalStamina = nil
local WalkOnWaterEnabled = false
local FastAttackEnabled = false
local BringMobEnabled = false
local AutoFarmEnabled = false
local BringMobEnabled = false

_G.FastAttack = true
_G.Grabfruit = false
_G.TweenFruit = false
_G.AutoRaceV3 = false
_G.AutoRaceV4 = false
_G.AutoRengoku = false
_G.TeleportIsland = false
_G.TeleportNPC = false

if _G.FastAttack then
    local _ENV = (getgenv or getrenv or getfenv)()

    local function SafeWaitForChild(parent, childName)
        local success, result = pcall(function()
            return parent:WaitForChild(childName)
        end)
        if not success or not result then
            warn("Failed to find child: " .. childName)
        end
        return result
    end

    local function WaitChilds(path, ...)
        local last = path
        for _, child in {...} do
            last = last:FindFirstChild(child) or SafeWaitForChild(last, child)
            if not last then break end
        end
        return last
    end

    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Player = Players.LocalPlayer

    local Remotes = SafeWaitForChild(ReplicatedStorage, "Remotes")
    local Characters = SafeWaitForChild(workspace, "Characters")
    local Enemies = SafeWaitForChild(workspace, "Enemies")

    local Modules = SafeWaitForChild(ReplicatedStorage, "Modules")
    local Net = SafeWaitForChild(Modules, "Net")

    local Settings = {
        AutoClick = true,
        ClickDelay = 0
    }

    local Module = {}

    Module.FastAttack = (function()
        if _ENV.rz_FastAttack then
            return _ENV.rz_FastAttack
        end

        local FastAttack = {
            Distance = 100,
            attackMobs = true,
            attackPlayers = true,
            Equipped = nil
        }

        local RegisterAttack = SafeWaitForChild(Net, "RE/RegisterAttack")
        local RegisterHit = SafeWaitForChild(Net, "RE/RegisterHit")

        local function IsAlive(character)
            return character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
        end

        local function ProcessEnemies(OthersEnemies, Folder)
            local BasePart = nil
            for _, Enemy in Folder:GetChildren() do
                local Head = Enemy:FindFirstChild("Head")
                if Head and IsAlive(Enemy) and Player:DistanceFromCharacter(Head.Position) < FastAttack.Distance then
                    if Enemy ~= Player.Character then
                        table.insert(OthersEnemies, { Enemy, Head })
                        BasePart = Head
                    end
                end
            end
            return BasePart
        end

        function FastAttack:Attack(BasePart, OthersEnemies)
            if not BasePart or #OthersEnemies == 0 then return end
            RegisterAttack:FireServer(Settings.ClickDelay or 0)
            RegisterHit:FireServer(BasePart, OthersEnemies)
        end

        function FastAttack:AttackNearest()
            local OthersEnemies = {}
            local Part1 = ProcessEnemies(OthersEnemies, Enemies)
            local Part2 = ProcessEnemies(OthersEnemies, Characters)

            local character = Player.Character
            if not character then return end
            local equippedWeapon = character:FindFirstChildOfClass("Tool")

            if equippedWeapon and equippedWeapon:FindFirstChild("LeftClickRemote") then
                for _, enemyData in ipairs(OthersEnemies) do
                    local enemy = enemyData[1]
                    local direction = (enemy.HumanoidRootPart.Position - character:GetPivot().Position).Unit
                    pcall(function()
                        equippedWeapon.LeftClickRemote:FireServer(direction, 1)
                    end)
                end
            elseif #OthersEnemies > 0 then
                self:Attack(Part1 or Part2, OthersEnemies)
            else
                task.wait(0)
            end
        end

        function FastAttack:BladeHits()
            local Equipped = IsAlive(Player.Character) and Player.Character:FindFirstChildOfClass("Tool")
            if Equipped and Equipped.ToolTip ~= "Gun" then
                self:AttackNearest()
            else
                task.wait(0)
            end
        end

        task.spawn(function()
            while task.wait(Settings.ClickDelay) do
                if Settings.AutoClick then
                    FastAttack:BladeHits()
                end
            end
        end)

        _ENV.rz_FastAttack = FastAttack
        return FastAttack
    end)()
end

local sethiddenproperty = sethiddenproperty or function(...) return ... end

function StopTween()
    if _G.StopTween then
        return
    end

    _G.StopTween = true
    wait()

    local player = game.Players.LocalPlayer
    local character = player.Character

    if character and character:IsDescendantOf(workspace) then
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = humanoidRootPart.CFrame
        end
    end

    wait()

    if character:FindFirstChild("BodyClip") then
        character.BodyClip:Destroy()
    end
    if character:FindFirstChild("PartTele") then
        character.PartTele:Destroy()
    end

    _G.StopTween = false
end

function StopTween(target)
    local plyr = game:GetService("Players").LocalPlayer
    local char = plyr.Character

    if not target then
        _G.StopTween = true
        wait(0.2)
        topos(char.HumanoidRootPart.CFrame)
        wait(0.2)
        if char.HumanoidRootPart:FindFirstChild("BodyClip") then
            char.HumanoidRootPart.BodyClip:Destroy()
        end
        if char:FindFirstChild("Block") then
            char.Block:Destroy()
        end
        _G.StopTween = false
        _G.Clip = false
    end

    if char:FindFirstChild("Highlight") then
        char.Highlight:Destroy()
    end
end

function LockTween()
    if _G.LockTween then
        return
    end
    _G.LockTween = true
    wait()
    local plyr = game.Players.LocalPlayer
    local char = plyr.Character
    if char and char:IsDescendantOf(game.Workspace) then
        local hrp = char:WaitForChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = hrp.CFrame
        end
    end
    wait()
    if char:FindFirstChild("BodyClip") then
        char.BodyClip:Destroy()
    end
    if char:FindFirstChild("PartTele") then
        char.Block:Destroy()
    end
    _G.LockTween = false
end

local plr = game:GetService("Players").LocalPlayer
local NoClip = false

function BringMob(huh)
    local WS = game:GetService("Workspace")
    local plr = game.Players.LocalPlayer
    for i, v in pairs(WS.Enemies:GetChildren()) do
        if v.Name == huh and v.Parent and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and (v.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 350 then
            v.HumanoidRootPart.CFrame = BringPos
            v.Humanoid.JumpPower = 0
            v.Humanoid.WalkSpeed = 0
            v.HumanoidRootPart.Transparency = 1
            v.HumanoidRootPart.CanCollide = false
            v.Head.CanCollide = false
            if v.Humanoid:FindFirstChild("Animator") then
                v.Humanoid.Animator:Destroy()
            end
            if not v.HumanoidRootPart:FindFirstChild("Lock") then
                local lock = Instance.new("BodyVelocity")
                lock.Parent = v.HumanoidRootPart
                lock.Name = "Lock"
                lock.MaxForce = Vector3.new(100000, 100000, 100000)
                lock.Velocity = Vector3.new(0, 0, 0)
            end
            sethiddenproperty(plr, "SimulationRadius", math.huge)
            v.Humanoid:ChangeState(11)
        end
    end
end

function CancelTween23()
    if plr.Character.Head:FindFirstChild("BodyVelocity") then
        plr.Character.Head:FindFirstChild("BodyVelocity"):Destroy()
    end
    if plr.Character:FindFirstChild("PartTele") then
        plr.Character:FindFirstChild("PartTele"):Destroy()
    end
    NoClip = false
    return Tween23(plr.Character.HumanoidRootPart.CFrame) -- ensure this is defined elsewhere
end

function KillMob(V1, StopFunction)
    pcall(function()
        local thismob = DetectMob2(V1)
        if thismob and thismob:FindFirstChild("HumanoidRootPart") and thismob.Parent and thismob:FindFirstChild("Humanoid") and thismob.Humanoid.Health > 0 then
            repeat task.wait()
                Buso()
                EquipWeapon()
                Tween23(thismob.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
                BringPos = thismob.HumanoidRootPart.CFrame
                BringMob(V1)
                NoClip = true
            until not thismob.Parent or not thismob:FindFirstChild("Humanoid") or thismob.Humanoid.Health <= 0 or not thismob:FindFirstChild("HumanoidRootPart") or StopFunction()
            NoClip = false
            CancelTween23()
        end
    end)
end

spawn(function()
    while wait() do
        pcall(function()
            if NoClip == true then
                if not plr.Character.Head:FindFirstChild("Nigga") then
                    local vel = Instance.new("BodyVelocity", plr.Character.Head)
                    vel.P = 1500
                    vel.Name = "Nigga"
                    vel.MaxForce = Vector3.new(0, 100000, 0)
                    vel.Velocity = Vector3.new(0, 0, 0)
                end
                for _, v in pairs(plr.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            else
                if plr.Character.Head:FindFirstChild("Nigga") then
                    plr.Character.Head:FindFirstChild("Nigga"):Destroy()
                end
            end
        end)
    end
end)

spawn(function()
    while task.wait() do
        pcall(function()
            local char = plr.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health <= 0 then
                if char:FindFirstChild("Block") then
                    char.Block:Destroy()
                end
            end
        end)
    end
end)

spawn(function()
    while task.wait() do
        pcall(function()
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and char:FindFirstChild("Block") then
                if (hrp.Position - char.Block.Position).Magnitude >= 100 then
                    char.Block:Destroy()
                end
            end
        end)
    end
end)

function enableNoclip()
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if hrp and not hrp:FindFirstChild("BodyClip") then
        local clip = Instance.new("BodyVelocity")
        clip.Name = "BodyClip"
        clip.Parent = hrp
        clip.MaxForce = Vector3.new(100000, 100000, 100000)
        clip.Velocity = Vector3.new(0, 0, 0)
    end
end

function disableNoclip()
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local clip = hrp:FindFirstChild("BodyClip")
        if clip then clip:Destroy() end
    end
end

function disableCollisions()
    for _, v in pairs(plr.Character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end

spawn(function()
    while task.wait(0.2) do
        if getgenv().Module or _G.DefendVolcano or getgenv().AutoFarm then
            enableNoclip()
            disableCollisions()
        else
            disableNoclip()
        end
    end
end)

local isTeleporting = false
local plr = game:GetService("Players").LocalPlayer

function stopTeleport()
    isTeleporting = false
    if plr.Character:FindFirstChild("PartTele") then
        plr.Character.PartTele:Destroy()
    end
end

spawn(function()
    while task.wait() do
        if not isTeleporting then
            stopTeleport()
        end
    end
end)

spawn(function()
    while task.wait() do
        pcall(function()
            if plr.Character:FindFirstChild("PartTele") then
                if (plr.Character.HumanoidRootPart.Position - plr.Character.PartTele.Position).Magnitude >= 100 then
                    stopTeleport()
                end
            end
        end)
    end
end)

plr.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        stopTeleport()
    end)
end)

if plr.Character then
    local humanoid = plr.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Died:Connect(stopTeleport)
    end
end

function WaitHRP(q0)
    if not q0 then return end
    return q0.Character:WaitForChild("HumanoidRootPart", 9)
end

function CheckNearestTeleporter(aI)
    local vcspos = aI.Position
    local minDist = math.huge
    local chosenTeleport = nil
    local y = game.PlaceId

    local TableLocations = {}

    if y == 2753915549 then
        TableLocations = {
            ["Sky3"] = Vector3.new(-7894, 5547, -380),
            ["Sky3Exit"] = Vector3.new(-4607, 874, -1667),
            ["UnderWater"] = Vector3.new(61163, 11, 1819),
            ["Underwater City"] = Vector3.new(61165.19140625, 0.18704631924629211, 1897.379150390625),
            ["Pirate Village"] = Vector3.new(-1242.4625244140625, 4.787059783935547, 3901.282958984375),
            ["UnderwaterExit"] = Vector3.new(4050, -1, -1814)
        }
    elseif y == 4442272183 then
        TableLocations = {
            ["Swan Mansion"] = Vector3.new(-390, 332, 673),
            ["Swan Room"] = Vector3.new(2285, 15, 905),
            ["Cursed Ship"] = Vector3.new(923, 126, 32852),
            ["Zombie Island"] = Vector3.new(-6509, 83, -133)
        }
    elseif y == 7449423635 then
        TableLocations = {
            ["Floating Turtle"] = Vector3.new(-12462, 375, -7552),
            ["Hydra Island"] = Vector3.new(5657.88623046875, 1013.0790405273438, -335.4996337890625),
            ["Mansion"] = Vector3.new(-12462, 375, -7552),
            ["Castle"] = Vector3.new(-5036, 315, -3179),
            ["Dimensional Shift"] = Vector3.new(-2097.3447265625, 4776.24462890625, -15013.4990234375),
            ["Beautiful Pirate"] = Vector3.new(5319, 23, -93),
            ["Beautiful Room"] = Vector3.new(5314.58203, 22.5364361, -125.942276, 1, 2.14762768e-08, -1.99111154e-13, -2.14762768e-08, 1, -3.0510602e-08, 1.98455903e-13, 3.0510602e-08, 1),
            ["Temple of Time"] = Vector3.new(28286, 14897, 103)
        }
    end

    for _, v in pairs(TableLocations) do
        local dist = (v - vcspos).Magnitude
        if dist < minDist then
            minDist = dist
            chosenTeleport = v
        end
    end

    local playerPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    if minDist <= (vcspos - playerPos).Magnitude then
        return chosenTeleport
    end
end

function requestEntrance(teleportPos)
    game.ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", teleportPos)
    local char = game.Players.LocalPlayer.Character.HumanoidRootPart
    char.CFrame = char.CFrame + Vector3.new(0, 50, 0)
    task.wait(0.5)
end

function TelePPlayer(P)
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = P
end

function topos(Pos)
    if not Pos then return end
    if plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 and plr.Character:FindFirstChild("HumanoidRootPart") then
        local Distance = (Pos.Position - plr.Character.HumanoidRootPart.Position).Magnitude

        local nearestTeleport = CheckNearestTeleporter and CheckNearestTeleporter(Pos)
        if nearestTeleport then
            requestEntrance(nearestTeleport)
        end

        if not plr.Character:FindFirstChild("PartTele") then
            local PartTele = Instance.new("Part", plr.Character)
            PartTele.Size = Vector3.new(10, 1, 10)
            PartTele.Name = "PartTele"
            PartTele.Anchored = true
            PartTele.Transparency = 1
            PartTele.CanCollide = true
            PartTele.CFrame = WaitHRP(plr).CFrame
            PartTele:GetPropertyChangedSignal("CFrame"):Connect(function()
                if not isTeleporting then return end
                task.wait()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    WaitHRP(plr).CFrame = PartTele.CFrame
                end
            end)
        end

        isTeleporting = true
        local tween = game:GetService("TweenService"):Create(
            plr.Character.PartTele,
            TweenInfo.new(Distance / 360, Enum.EasingStyle.Linear),
            { CFrame = Pos }
        )
        tween:Play()
        tween.Completed:Connect(function(status)
            if status == Enum.PlaybackState.Completed then
                if plr.Character:FindFirstChild("PartTele") then
                    plr.Character.PartTele:Destroy()
                end
                isTeleporting = false
            end
        end)
    end
end

function TP1(Pos)
    topos(Pos)
end

local PosY = 300
local Pos = CFrame.new(0, PosY, 0)

spawn(function()
    while wait() do
        if _G.SpinPos then
            Pos = CFrame.new(0, PosY, -20)
            wait(0.1)
            Pos = CFrame.new(-20, PosY, 0)
            wait(0.1)
            Pos = CFrame.new(0, PosY, 20)
            wait(0.1)
            Pos = CFrame.new(20, PosY, 0)
        else
            Pos = CFrame.new(0, PosY, 0)
        end
    end
end)

function BTP(p)
    pcall(function()
        if (p.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude >= 1500 and not Auto_Raid and game.Players.LocalPlayer.Character.Humanoid.Health > 0 then
            repeat wait()
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = p
                wait(0.05)
                game.Players.LocalPlayer.Character.Head:Destroy()
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = p
            until (p.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 1500 and game.Players.LocalPlayer.Character.Humanoid.Health > 0
        end
    end)
end

    local function IsAlive(character)
        return character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
    end

    local function ProcessEnemies(OthersEnemies, Folder)
        local BasePart = nil
        for _, Enemy in Folder:GetChildren() do
            local Head = Enemy:FindFirstChild("Head")
            if Head and IsAlive(Enemy) and Player:DistanceFromCharacter(Head.Position) < FastAttackSettings.Distance then
                if Enemy ~= Player.Character then
                    table.insert(OthersEnemies, { Enemy, Head })
                    BasePart = Head
                end
            end
        end
        return BasePart
    end

    local function AttackNearest()
        local OthersEnemies = {}
        local Part1 = ProcessEnemies(OthersEnemies, Enemies)
        local Part2 = ProcessEnemies(OthersEnemies, Characters)

        local character = Player.Character
        if not character then return end

        local equippedWeapon = character:FindFirstChildOfClass("Tool")

        if equippedWeapon and equippedWeapon:FindFirstChild("LeftClickRemote") then
            for _, enemyData in ipairs(OthersEnemies) do
                local enemy = enemyData[1]
                local direction = (enemy.HumanoidRootPart.Position - character:GetPivot().Position).Unit
                pcall(function()
                    equippedWeapon.LeftClickRemote:FireServer(direction, 1)
                end)
            end
        elseif #OthersEnemies > 0 then
            if Part1 or Part2 then
                RegisterAttack:FireServer(FastAttackSettings.ClickDelay)
                RegisterHit:FireServer(Part1 or Part2, OthersEnemies)
            end
        end
    end

    task.spawn(function()
        while task.wait(FastAttackSettings.ClickDelay) do
            if FastAttackEnabled then
                AttackNearest()
            end
        end
    end)

    _G.BringMonster = true

_G.Settings = {
    Main = {
        ["Auto Farm"] = false,
        ["Farm Mode"] = "Normal",
        ["Selected Weapon"] = "Melee",
        ["Selected Mastery Mode"] = "Quest",
        ["Auto Farm Fruit Mastery"] = false,
        ["Auto Farm Gun Mastery"] = false,
        ["Auto Farm Sword Mastery"] = false,
        ["Selected Mob"] = nil,
        ["Selected Boss"] = nil,
        ["Auto Farm All Boss"] = false
    },
    Farm = {
        ["Auto Elite Hunter"] = false,
        ["Auto Farm Bone"] = false,
        ["Auto Farm Chest Tween"] = false,
        ["Auto Farm Chest Instant"] = false,
        ["Auto Farm Observation"] = false,
        ["Auto Observation V2"] = false,
        ["Bring Mob"] = true,
        ["Bring Mob Mode"] = "Normal"
    },
    Setting = {
        ["Farm Distance"] = 35,
        ["Player Tween Speed"] = 250,
        ["Fast Attack"] = true,
        ["Fast Attack Mode"] = "Normal",
        ["Fast Attack Type"] = "New",
        ["Attack Aura"] = true,
        ["Auto Haki"] = true,
        ["Auto Set Spawn Point"] = true,
        ["No Clip"] = true
    }
}

hookfunction(require(game:GetService("ReplicatedStorage").Effect.Container.Death), function()end)
hookfunction(require(game:GetService("ReplicatedStorage").Effect.Container.Respawn), function()end)
local World1, World2, World3 = false, false, false
if game.PlaceId == 2753915549 then
    World1 = true
elseif game.PlaceId == 4442272183 then
    World2 = true
elseif game.PlaceId == 7449423635 then
    World3 = true
end

local StartBring = true
local PosMon = nil

spawn(function()
    while task.wait() do
        pcall(function()
            if not BringMobEnabled or not StartBring or not PosMon then return end

            for _, v in pairs(workspace.Enemies:GetChildren()) do
                local isValid = v.Name == NameMon or v.Name == Mon
                local hasParts = v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Head")
                local isAlive = v.Humanoid and v.Humanoid.Health > 0
                local inRange = (v.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 350

                if isValid and hasParts and isAlive and inRange then
                    local dist = (v.HumanoidRootPart.Position - PosMon.Position).Magnitude
                    if dist <= 350 then
                        v.HumanoidRootPart.CanCollide = false
                        v.Head.CanCollide = false
                        v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                        v.HumanoidRootPart.CFrame = PosMon

                        if v.Humanoid:FindFirstChild("Animator") then
                            v.Humanoid.Animator:Destroy()
                        end
                    end
                end
            end

            sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
        end)
    end
end)

function MaterialMon()
    local placeId = game.PlaceId

    if _G.SelectMaterial == "Radiactive Material" then
        MMon = "Factory Staff"
        MPos = CFrame.new(-105.889565, 72.8076935, -670.247986)
        SP = "Bar"

    elseif _G.SelectMaterial == "Leather + Scrap Metal" then
        if placeId == 2753915549 then
            MMon = "Brute"
            MPos = CFrame.new(-1191.41235, 15.5999985, 4235.50928)
            SP = "Pirate"
        elseif placeId == 4442272183 then
            MMon = "Mercenary"
            MPos = CFrame.new(-986.774475, 72.8755951, 1088.44653)
            SP = "DressTown"
        elseif placeId == 7449423635 then
            MMon = "Pirate Millionaire"
            MPos = CFrame.new(-118.809372, 55.4874573, 5649.17041)
            SP = "Default"
        end

    elseif _G.SelectMaterial == "Magma Ore" then
        if placeId == 2753915549 then
            MMon = "Military Spy"
            MPos = CFrame.new(-5806.70068, 78.5000458, 8904.46973)
            SP = "Magma"
        elseif placeId == 4442272183 then
            MMon = "Lava Pirate"
            MPos = CFrame.new(-5158.77051, 14.4791956, -4654.2627)
            SP = "CircleIslandFire"
        end

    elseif _G.SelectMaterial == "Fish Tail" then
        if placeId == 2753915549 then
            MMon = "Fishman Commando"
            MPos = CFrame.new(61760.8984, 18.0800781, 1460.11133)
            SP = "Underwater City"
        elseif placeId == 7449423635 then
            MMon = "Fishman Captain"
            MPos = CFrame.new(-10828.1064, 331.825989, -9049.14648)
            SP = "PineappleTown"
        end

    elseif _G.SelectMaterial == "Angel Wings" then
        MMon = "Royal Soldier"
        MPos = CFrame.new(-7759.45898, 5606.93652, -1862.70276)
        SP = "SkyArea2"

    elseif _G.SelectMaterial == "Mystic Droplet" then
        MMon = "Water Fighter"
        MPos = CFrame.new(-3331.70459, 239.138336, -10553.3564)
        SP = "ForgottenIsland"

    elseif _G.SelectMaterial == "Vampire Fang" then
        MMon = "Vampire"
        MPos = CFrame.new(-6132.39453, 9.00769424, -1466.16919)
        SP = "Graveyard"

    elseif _G.SelectMaterial == "Gunpowder" then
        MMon = "Pistol Billionaire"
        MPos = CFrame.new(-185.693283, 84.7088699, 6103.62744)
        SP = "Mansion"

    elseif _G.SelectMaterial == "Mini Tusk" then
        MMon = "Mythological Pirate"
        MPos = CFrame.new(-13456.0498, 469.433228, -7039.96436)
        SP = "BigMansion"

    elseif _G.SelectMaterial == "Conjured Cocoa" then
        MMon = "Chocolate Bar Battler"
        MPos = CFrame.new(582.828674, 25.5824986, -12550.7041)
        SP = "Chocolate"
    end
end

function CheckQuest()
	MyLevel = (game:GetService("Players")).LocalPlayer.Data.Level.Value;
	if World1 then
		if MyLevel == 1 or MyLevel <= 9 then
			Mon = "Bandit";
			LevelQuest = 1;
			NameQuest = "BanditQuest1";
			NameMon = "Bandit";
			CFrameQuest = CFrame.new(1059.37195, 15.4495068, 1550.4231, 0.939700544, -0, -0.341998369, 0, 1, -0, 0.341998369, 0, 0.939700544);
			CFrameMon = CFrame.new(1045.962646484375, 27.00250816345215, 1560.8203125);
		elseif MyLevel == 10 or MyLevel <= 14 then
			Mon = "Monkey";
			LevelQuest = 1;
			NameQuest = "JungleQuest";
			NameMon = "Monkey";
			CFrameQuest = CFrame.new(-1598.08911, 35.5501175, 153.377838, 0, 0, 1, 0, 1, -0, -1, 0, 0);
			CFrameMon = CFrame.new(-1448.51806640625, 67.85301208496094, 11.46579647064209);
		elseif MyLevel == 15 or MyLevel <= 29 then
			Mon = "Gorilla";
			LevelQuest = 2;
			NameQuest = "JungleQuest";
			NameMon = "Gorilla";
			CFrameQuest = CFrame.new(-1598.08911, 35.5501175, 153.377838, 0, 0, 1, 0, 1, -0, -1, 0, 0);
			CFrameMon = CFrame.new(-1129.8836669921875, 40.46354675292969, -525.4237060546875);
		elseif MyLevel == 30 or MyLevel <= 39 then
			Mon = "Pirate";
			LevelQuest = 1;
			NameQuest = "BuggyQuest1";
			NameMon = "Pirate";
			CFrameQuest = CFrame.new(-1141.07483, 4.10001802, 3831.5498, 0.965929627, -0, -0.258804798, 0, 1, -0, 0.258804798, 0, 0.965929627);
			CFrameMon = CFrame.new(-1103.513427734375, 13.752052307128906, 3896.091064453125);
		elseif MyLevel == 40 or MyLevel <= 59 then
			Mon = "Brute";
			LevelQuest = 2;
			NameQuest = "BuggyQuest1";
			NameMon = "Brute";
			CFrameQuest = CFrame.new(-1141.07483, 4.10001802, 3831.5498, 0.965929627, -0, -0.258804798, 0, 1, -0, 0.258804798, 0, 0.965929627);
			CFrameMon = CFrame.new(-1140.083740234375, 14.809885025024414, 4322.92138671875);
		elseif MyLevel == 60 or MyLevel <= 74 then
			Mon = "Desert Bandit";
			LevelQuest = 1;
			NameQuest = "DesertQuest";
			NameMon = "Desert Bandit";
			CFrameQuest = CFrame.new(894.488647, 5.14000702, 4392.43359, 0.819155693, -0, -0.573571265, 0, 1, -0, 0.573571265, 0, 0.819155693);
			CFrameMon = CFrame.new(924.7998046875, 6.44867467880249, 4481.5859375);
		elseif MyLevel == 75 or MyLevel <= 89 then
			Mon = "Desert Officer";
			LevelQuest = 2;
			NameQuest = "DesertQuest";
			NameMon = "Desert Officer";
			CFrameQuest = CFrame.new(894.488647, 5.14000702, 4392.43359, 0.819155693, -0, -0.573571265, 0, 1, -0, 0.573571265, 0, 0.819155693);
			CFrameMon = CFrame.new(1608.2822265625, 8.614224433898926, 4371.00732421875);
		elseif MyLevel == 90 or MyLevel <= 99 then
			Mon = "Snow Bandit";
			LevelQuest = 1;
			NameQuest = "SnowQuest";
			NameMon = "Snow Bandit";
			CFrameQuest = CFrame.new(1389.74451, 88.1519318, -1298.90796, -0.342042685, 0, 0.939684391, 0, 1, 0, -0.939684391, 0, -0.342042685);
			CFrameMon = CFrame.new(1354.347900390625, 87.27277374267578, -1393.946533203125);
		elseif MyLevel == 100 or MyLevel <= 119 then
			Mon = "Snowman";
			LevelQuest = 2;
			NameQuest = "SnowQuest";
			NameMon = "Snowman";
			CFrameQuest = CFrame.new(1389.74451, 88.1519318, -1298.90796, -0.342042685, 0, 0.939684391, 0, 1, 0, -0.939684391, 0, -0.342042685);
			CFrameMon = CFrame.new(1201.6412353515625, 144.57958984375, -1550.0670166015625);
		elseif MyLevel == 120 or MyLevel <= 149 then
			Mon = "Chief Petty Officer";
			LevelQuest = 1;
			NameQuest = "MarineQuest2";
			NameMon = "Chief Petty Officer";
			CFrameQuest = CFrame.new(-5039.58643, 27.3500385, 4324.68018, 0, 0, -1, 0, 1, 0, 1, 0, 0);
			CFrameMon = CFrame.new(-4881.23095703125, 22.65204429626465, 4273.75244140625);
		elseif MyLevel == 150 or MyLevel <= 174 then
			Mon = "Sky Bandit";
			LevelQuest = 1;
			NameQuest = "SkyQuest";
			NameMon = "Sky Bandit";
			CFrameQuest = CFrame.new(-4839.53027, 716.368591, -2619.44165, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268);
			CFrameMon = CFrame.new(-4953.20703125, 295.74420166015625, -2899.22900390625);
		elseif MyLevel == 175 or MyLevel <= 189 then
			Mon = "Dark Master";
			LevelQuest = 2;
			NameQuest = "SkyQuest";
			NameMon = "Dark Master";
			CFrameQuest = CFrame.new(-4839.53027, 716.368591, -2619.44165, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268);
			CFrameMon = CFrame.new(-5259.8447265625, 391.3976745605469, -2229.035400390625);
		elseif MyLevel == 190 or MyLevel <= 209 then
			Mon = "Prisoner";
			LevelQuest = 1;
			NameQuest = "PrisonerQuest";
			NameMon = "Prisoner";
			CFrameQuest = CFrame.new(5308.93115, 1.65517521, 475.120514, -0.0894274712, -0.00000000500292918, -0.995993316, 0.00000000160817859, 1, -0.00000000516744869, 0.995993316, -0.00000000206384709, -0.0894274712);
			CFrameMon = CFrame.new(5098.9736328125, -0.3204058110713959, 474.2373352050781);
		elseif MyLevel == 210 or MyLevel <= 249 then
			Mon = "Dangerous Prisoner";
			LevelQuest = 2;
			NameQuest = "PrisonerQuest";
			NameMon = "Dangerous Prisoner";
			CFrameQuest = CFrame.new(5308.93115, 1.65517521, 475.120514, -0.0894274712, -0.00000000500292918, -0.995993316, 0.00000000160817859, 1, -0.00000000516744869, 0.995993316, -0.00000000206384709, -0.0894274712);
			CFrameMon = CFrame.new(5654.5634765625, 15.633401870727539, 866.2991943359375);
		elseif MyLevel == 250 or MyLevel <= 274 then
			Mon = "Toga Warrior";
			LevelQuest = 1;
			NameQuest = "ColosseumQuest";
			NameMon = "Toga Warrior";
			CFrameQuest = CFrame.new(-1580.04663, 6.35000277, -2986.47534, -0.515037298, 0, -0.857167721, 0, 1, 0, 0.857167721, 0, -0.515037298);
			CFrameMon = CFrame.new(-1820.21484375, 51.68385696411133, -2740.6650390625);
		elseif MyLevel == 275 or MyLevel <= 299 then
			Mon = "Gladiator";
			LevelQuest = 2;
			NameQuest = "ColosseumQuest";
			NameMon = "Gladiator";
			CFrameQuest = CFrame.new(-1580.04663, 6.35000277, -2986.47534, -0.515037298, 0, -0.857167721, 0, 1, 0, 0.857167721, 0, -0.515037298);
			CFrameMon = CFrame.new(-1292.838134765625, 56.380882263183594, -3339.031494140625);
		elseif MyLevel == 300 or MyLevel <= 324 then
			Mon = "Military Soldier";
			LevelQuest = 1;
			NameQuest = "MagmaQuest";
			NameMon = "Military Soldier";
			CFrameQuest = CFrame.new(-5313.37012, 10.9500084, 8515.29395, -0.499959469, 0, 0.866048813, 0, 1, 0, -0.866048813, 0, -0.499959469);
			CFrameMon = CFrame.new(-5411.16455078125, 11.081554412841797, 8454.29296875);
		elseif MyLevel == 325 or MyLevel <= 374 then
			Mon = "Military Spy";
			LevelQuest = 2;
			NameQuest = "MagmaQuest";
			NameMon = "Military Spy";
			CFrameQuest = CFrame.new(-5313.37012, 10.9500084, 8515.29395, -0.499959469, 0, 0.866048813, 0, 1, 0, -0.866048813, 0, -0.499959469);
			CFrameMon = CFrame.new(-5802.8681640625, 86.26241302490234, 8828.859375);
		elseif MyLevel == 375 or MyLevel <= 399 then
			Mon = "Fishman Warrior";
			LevelQuest = 1;
			NameQuest = "FishmanQuest";
			NameMon = "Fishman Warrior";
			CFrameQuest = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734);
			CFrameMon = CFrame.new(60878.30078125, 18.482830047607422, 1543.7574462890625);
			if _G.Settings.Main["Auto Farm"] and (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
				(game:GetService("ReplicatedStorage")).Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(61163.8515625, 11.6796875, 1819.7841796875));
			end;
		elseif MyLevel == 400 or MyLevel <= 449 then
			Mon = "Fishman Commando";
			LevelQuest = 2;
			NameQuest = "FishmanQuest";
			NameMon = "Fishman Commando";
			CFrameQuest = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734);
			CFrameMon = CFrame.new(61922.6328125, 18.482830047607422, 1493.934326171875);
			if _G.Settings.Main["Auto Farm"] and (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
				(game:GetService("ReplicatedStorage")).Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(61163.8515625, 11.6796875, 1819.7841796875));
			end;
		elseif MyLevel == 450 or MyLevel <= 474 then
			Mon = "God's Guard";
			LevelQuest = 1;
			NameQuest = "SkyExp1Quest";
			NameMon = "God's Guard";
			CFrameQuest = CFrame.new(-4721.88867, 843.874695, -1949.96643, 0.996191859, -0, -0.0871884301, 0, 1, -0, 0.0871884301, 0, 0.996191859);
			CFrameMon = CFrame.new(-4710.04296875, 845.2769775390625, -1927.3079833984375);
			if _G.Settings.Main["Auto Farm"] and (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
				(game:GetService("ReplicatedStorage")).Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(-4607.82275, 872.54248, -1667.55688));
			end;
		elseif MyLevel == 475 or MyLevel <= 524 then
			Mon = "Shanda";
			LevelQuest = 2;
			NameQuest = "SkyExp1Quest";
			NameMon = "Shanda";
			CFrameQuest = CFrame.new(-7859.09814, 5544.19043, -381.476196, -0.422592998, 0, 0.906319618, 0, 1, 0, -0.906319618, 0, -0.422592998);
			CFrameMon = CFrame.new(-7678.48974609375, 5566.40380859375, -497.2156066894531);
			if _G.Settings.Main["Auto Farm"] and (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
				(game:GetService("ReplicatedStorage")).Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047));
			end;
		elseif MyLevel == 525 or MyLevel <= 549 then
			Mon = "Royal Squad";
			LevelQuest = 1;
			NameQuest = "SkyExp2Quest";
			NameMon = "Royal Squad";
			CFrameQuest = CFrame.new(-7906.81592, 5634.6626, -1411.99194, 0, 0, -1, 0, 1, 0, 1, 0, 0);
			CFrameMon = CFrame.new(-7624.25244140625, 5658.13330078125, -1467.354248046875);
		elseif MyLevel == 550 or MyLevel <= 624 then
			Mon = "Royal Soldier";
			LevelQuest = 2;
			NameQuest = "SkyExp2Quest";
			NameMon = "Royal Soldier";
			CFrameQuest = CFrame.new(-7906.81592, 5634.6626, -1411.99194, 0, 0, -1, 0, 1, 0, 1, 0, 0);
			CFrameMon = CFrame.new(-7836.75341796875, 5645.6640625, -1790.6236572265625);
		elseif MyLevel == 625 or MyLevel <= 649 then
			Mon = "Galley Pirate";
			LevelQuest = 1;
			NameQuest = "FountainQuest";
			NameMon = "Galley Pirate";
			CFrameQuest = CFrame.new(5259.81982, 37.3500175, 4050.0293, 0.087131381, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, 0.087131381);
			CFrameMon = CFrame.new(5551.02197265625, 78.90135192871094, 3930.412841796875);
		elseif MyLevel >= 650 then
			Mon = "Galley Captain";
			LevelQuest = 2;
			NameQuest = "FountainQuest";
			NameMon = "Galley Captain";
			CFrameQuest = CFrame.new(5259.81982, 37.3500175, 4050.0293, 0.087131381, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, 0.087131381);
			CFrameMon = CFrame.new(5441.95166015625, 42.50205993652344, 4950.09375);
		end;
	elseif World2 then
		if MyLevel == 700 or MyLevel <= 724 then
			Mon = "Raider";
			LevelQuest = 1;
			NameQuest = "Area1Quest";
			NameMon = "Raider";
			CFrameQuest = CFrame.new(-429.543518, 71.7699966, 1836.18188, -0.22495985, 0, -0.974368095, 0, 1, 0, 0.974368095, 0, -0.22495985);
			CFrameMon = CFrame.new(-728.3267211914062, 52.779319763183594, 2345.7705078125);
		elseif MyLevel == 725 or MyLevel <= 774 then
			Mon = "Mercenary";
			LevelQuest = 2;
			NameQuest = "Area1Quest";
			NameMon = "Mercenary";
			CFrameQuest = CFrame.new(-429.543518, 71.7699966, 1836.18188, -0.22495985, 0, -0.974368095, 0, 1, 0, 0.974368095, 0, -0.22495985);
			CFrameMon = CFrame.new(-1004.3244018554688, 80.15886688232422, 1424.619384765625);
		elseif MyLevel == 775 or MyLevel <= 799 then
			Mon = "Swan Pirate";
			LevelQuest = 1;
			NameQuest = "Area2Quest";
			NameMon = "Swan Pirate";
			CFrameQuest = CFrame.new(638.43811, 71.769989, 918.282898, 0.139203906, 0, 0.99026376, 0, 1, 0, -0.99026376, 0, 0.139203906);
			CFrameMon = CFrame.new(1068.664306640625, 137.61428833007812, 1322.1060791015625);
		elseif MyLevel == 800 or MyLevel <= 874 then
			Mon = "Factory Staff";
			NameQuest = "Area2Quest";
			LevelQuest = 2;
			NameMon = "Factory Staff";
			CFrameQuest = CFrame.new(632.698608, 73.1055908, 918.666321, -0.0319722369, 0.000000000896074881, -0.999488771, 0.000000000136326533, 1, 0.000000000892172336, 0.999488771, -0.000000000107732087, -0.0319722369);
			CFrameMon = CFrame.new(73.07867431640625, 81.86344146728516, -27.470672607421875);
		elseif MyLevel == 875 or MyLevel <= 899 then
			Mon = "Marine Lieutenant";
			LevelQuest = 1;
			NameQuest = "MarineQuest3";
			NameMon = "Marine Lieutenant";
			CFrameQuest = CFrame.new(-2440.79639, 71.7140732, -3216.06812, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268);
			CFrameMon = CFrame.new(-2821.372314453125, 75.89727783203125, -3070.089111328125);
		elseif MyLevel == 900 or MyLevel <= 949 then
			Mon = "Marine Captain";
			LevelQuest = 2;
			NameQuest = "MarineQuest3";
			NameMon = "Marine Captain";
			CFrameQuest = CFrame.new(-2440.79639, 71.7140732, -3216.06812, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268);
			CFrameMon = CFrame.new(-1861.2310791015625, 80.17658233642578, -3254.697509765625);
		elseif MyLevel == 950 or MyLevel <= 974 then
			Mon = "Zombie";
			LevelQuest = 1;
			NameQuest = "ZombieQuest";
			NameMon = "Zombie";
			CFrameQuest = CFrame.new(-5497.06152, 47.5923004, -795.237061, -0.29242146, 0, -0.95628953, 0, 1, 0, 0.95628953, 0, -0.29242146);
			CFrameMon = CFrame.new(-5657.77685546875, 78.96973419189453, -928.68701171875);
		elseif MyLevel == 975 or MyLevel <= 999 then
			Mon = "Vampire";
			LevelQuest = 2;
			NameQuest = "ZombieQuest";
			NameMon = "Vampire";
			CFrameQuest = CFrame.new(-5497.06152, 47.5923004, -795.237061, -0.29242146, 0, -0.95628953, 0, 1, 0, 0.95628953, 0, -0.29242146);
			CFrameMon = CFrame.new(-6037.66796875, 32.18463897705078, -1340.6597900390625);
		elseif MyLevel == 1000 or MyLevel <= 1049 then
			Mon = "Snow Trooper";
			LevelQuest = 1;
			NameQuest = "SnowMountainQuest";
			NameMon = "Snow Trooper";
			CFrameQuest = CFrame.new(609.858826, 400.119904, -5372.25928, -0.374604106, 0, 0.92718488, 0, 1, 0, -0.92718488, 0, -0.374604106);
			CFrameMon = CFrame.new(549.1473388671875, 427.3870544433594, -5563.69873046875);
		elseif MyLevel == 1050 or MyLevel <= 1099 then
			Mon = "Winter Warrior";
			LevelQuest = 2;
			NameQuest = "SnowMountainQuest";
			NameMon = "Winter Warrior";
			CFrameQuest = CFrame.new(609.858826, 400.119904, -5372.25928, -0.374604106, 0, 0.92718488, 0, 1, 0, -0.92718488, 0, -0.374604106);
			CFrameMon = CFrame.new(1142.7451171875, 475.6398010253906, -5199.41650390625);
		elseif MyLevel == 1100 or MyLevel <= 1124 then
			Mon = "Lab Subordinate";
			LevelQuest = 1;
			NameQuest = "IceSideQuest";
			NameMon = "Lab Subordinate";
			CFrameQuest = CFrame.new(-6064.06885, 15.2422857, -4902.97852, 0.453972578, -0, -0.891015649, 0, 1, -0, 0.891015649, 0, 0.453972578);
			CFrameMon = CFrame.new(-5707.4716796875, 15.951709747314453, -4513.39208984375);
		elseif MyLevel == 1125 or MyLevel <= 1174 then
			Mon = "Horned Warrior";
			LevelQuest = 2;
			NameQuest = "IceSideQuest";
			NameMon = "Horned Warrior";
			CFrameQuest = CFrame.new(-6064.06885, 15.2422857, -4902.97852, 0.453972578, -0, -0.891015649, 0, 1, -0, 0.891015649, 0, 0.453972578);
			CFrameMon = CFrame.new(-6341.36669921875, 15.951770782470703, -5723.162109375);
		elseif MyLevel == 1175 or MyLevel <= 1199 then
			Mon = "Magma Ninja";
			LevelQuest = 1;
			NameQuest = "FireSideQuest";
			NameMon = "Magma Ninja";
			CFrameQuest = CFrame.new(-5428.03174, 15.0622921, -5299.43457, -0.882952213, 0, 0.469463557, 0, 1, 0, -0.469463557, 0, -0.882952213);
			CFrameMon = CFrame.new(-5449.6728515625, 76.65874481201172, -5808.20068359375);
		elseif MyLevel == 1200 or MyLevel <= 1249 then
			Mon = "Lava Pirate";
			LevelQuest = 2;
			NameQuest = "FireSideQuest";
			NameMon = "Lava Pirate";
			CFrameQuest = CFrame.new(-5428.03174, 15.0622921, -5299.43457, -0.882952213, 0, 0.469463557, 0, 1, 0, -0.469463557, 0, -0.882952213);
			CFrameMon = CFrame.new(-5213.33154296875, 49.73788070678711, -4701.451171875);
		elseif MyLevel == 1250 or MyLevel <= 1274 then
			Mon = "Ship Deckhand";
			LevelQuest = 1;
			NameQuest = "ShipQuest1";
			NameMon = "Ship Deckhand";
			CFrameQuest = CFrame.new(1037.80127, 125.092171, 32911.6016);
			CFrameMon = CFrame.new(1212.0111083984375, 150.79205322265625, 33059.24609375);
			if _G.Settings.Main["Auto Farm"] and (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
				(game:GetService("ReplicatedStorage")).Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(923.21252441406, 126.9760055542, 32852.83203125));
			end;
		elseif MyLevel == 1275 or MyLevel <= 1299 then
			Mon = "Ship Engineer";
			LevelQuest = 2;
			NameQuest = "ShipQuest1";
			NameMon = "Ship Engineer";
			CFrameQuest = CFrame.new(1037.80127, 125.092171, 32911.6016);
			CFrameMon = CFrame.new(919.4786376953125, 43.54401397705078, 32779.96875);
			if _G.Settings.Main["Auto Farm"] and (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
				(game:GetService("ReplicatedStorage")).Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(923.21252441406, 126.9760055542, 32852.83203125));
			end;
		elseif MyLevel == 1300 or MyLevel <= 1324 then
			Mon = "Ship Steward";
			LevelQuest = 1;
			NameQuest = "ShipQuest2";
			NameMon = "Ship Steward";
			CFrameQuest = CFrame.new(968.80957, 125.092171, 33244.125);
			CFrameMon = CFrame.new(919.4385375976562, 129.55599975585938, 33436.03515625);
			if _G.Settings.Main["Auto Farm"] and (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
				(game:GetService("ReplicatedStorage")).Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(923.21252441406, 126.9760055542, 32852.83203125));
			end;
		elseif MyLevel == 1325 or MyLevel <= 1349 then
			Mon = "Ship Officer";
			LevelQuest = 2;
			NameQuest = "ShipQuest2";
			NameMon = "Ship Officer";
			CFrameQuest = CFrame.new(968.80957, 125.092171, 33244.125);
			CFrameMon = CFrame.new(1036.0179443359375, 181.4390411376953, 33315.7265625);
			if _G.Settings.Main["Auto Farm"] and (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
				(game:GetService("ReplicatedStorage")).Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(923.21252441406, 126.9760055542, 32852.83203125));
			end;
		elseif MyLevel == 1350 or MyLevel <= 1374 then
			Mon = "Arctic Warrior";
			LevelQuest = 1;
			NameQuest = "FrostQuest";
			NameMon = "Arctic Warrior";
			CFrameQuest = CFrame.new(5667.6582, 26.7997818, -6486.08984, -0.933587909, 0, -0.358349502, 0, 1, 0, 0.358349502, 0, -0.933587909);
			CFrameMon = CFrame.new(5966.24609375, 62.97002029418945, -6179.3828125);
			if _G.Settings.Main["Auto Farm"] and (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 10000 then
				(game:GetService("ReplicatedStorage")).Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(-6508.5581054688, 5000.034996032715, -132.83953857422));
			end;
		elseif MyLevel == 1375 or MyLevel <= 1424 then
			Mon = "Snow Lurker";
			LevelQuest = 2;
			NameQuest = "FrostQuest";
			NameMon = "Snow Lurker";
			CFrameQuest = CFrame.new(5667.6582, 26.7997818, -6486.08984, -0.933587909, 0, -0.358349502, 0, 1, 0, 0.358349502, 0, -0.933587909);
			CFrameMon = CFrame.new(5407.07373046875, 69.19437408447266, -6880.88037109375);
		elseif MyLevel == 1425 or MyLevel <= 1449 then
			Mon = "Sea Soldier";
			LevelQuest = 1;
			NameQuest = "ForgottenQuest";
			NameMon = "Sea Soldier";
			CFrameQuest = CFrame.new(-3054.44458, 235.544281, -10142.8193, 0.990270376, -0, -0.13915664, 0, 1, -0, 0.13915664, 0, 0.990270376);
			CFrameMon = CFrame.new(-3028.2236328125, 64.67451477050781, -9775.4267578125);
		elseif MyLevel >= 1450 then
			Mon = "Water Fighter";
			LevelQuest = 2;
			NameQuest = "ForgottenQuest";
			NameMon = "Water Fighter";
			CFrameQuest = CFrame.new(-3054.44458, 235.544281, -10142.8193, 0.990270376, -0, -0.13915664, 0, 1, -0, 0.13915664, 0, 0.990270376);
			CFrameMon = CFrame.new(-3352.9013671875, 285.01556396484375, -10534.841796875);
		end;
	elseif World3 then
		if MyLevel == 1500 or MyLevel <= 1524 then
			Mon = "Pirate Millionaire";
			LevelQuest = 1;
			NameQuest = "PiratePortQuest";
			NameMon = "Pirate Millionaire";
			CFrameQuest = CFrame.new(-290.074677, 42.9034653, 5581.58984, 0.965929627, -0, -0.258804798, 0, 1, -0, 0.258804798, 0, 0.965929627);
			CFrameMon = CFrame.new(-245.9963836669922, 47.30615234375, 5584.1005859375);
		elseif MyLevel == 1525 or MyLevel <= 1574 then
			Mon = "Pistol Billionaire";
			LevelQuest = 2;
			NameQuest = "PiratePortQuest";
			NameMon = "Pistol Billionaire";
			CFrameQuest = CFrame.new(-290.074677, 42.9034653, 5581.58984, 0.965929627, -0, -0.258804798, 0, 1, -0, 0.258804798, 0, 0.965929627);
			CFrameMon = CFrame.new(-187.3301544189453, 86.23987579345703, 6013.513671875);
		elseif MyLevel == 1575 or MyLevel <= 1599 then
			Mon = "Dragon Crew Warrior";
			LevelQuest = 1;
			NameQuest = "AmazonQuest";
			NameMon = "Dragon Crew Warrior";
			CFrameQuest = CFrame.new(5832.83594, 51.6806107, -1101.51563, 0.898790359, -0, -0.438378751, 0, 1, -0, 0.438378751, 0, 0.898790359);
			CFrameMon = CFrame.new(6141.140625, 51.35136413574219, -1340.738525390625);
		elseif MyLevel == 1600 or MyLevel <= 1624 then
			Mon = "Dragon Crew Archer [Lv. 1600]";
			NameQuest = "AmazonQuest";
			LevelQuest = 2;
			NameMon = "Dragon Crew Archer";
			CFrameQuest = CFrame.new(5833.1147460938, 51.60498046875, -1103.0693359375);
			CFrameMon = CFrame.new(6616.41748046875, 441.7670593261719, 446.0469970703125);
		elseif MyLevel == 1625 or MyLevel <= 1649 then
			Mon = "Female Islander";
			NameQuest = "AmazonQuest2";
			LevelQuest = 1;
			NameMon = "Female Islander";
			CFrameQuest = CFrame.new(5446.8793945313, 601.62945556641, 749.45672607422);
			CFrameMon = CFrame.new(4685.25830078125, 735.8078002929688, 815.3425903320312);
		elseif MyLevel == 1650 or MyLevel <= 1699 then
			Mon = "Giant Islander [Lv. 1650]";
			NameQuest = "AmazonQuest2";
			LevelQuest = 2;
			NameMon = "Giant Islander";
			CFrameQuest = CFrame.new(5446.8793945313, 601.62945556641, 749.45672607422);
			CFrameMon = CFrame.new(4729.09423828125, 590.436767578125, -36.97627639770508);
		elseif MyLevel == 1700 or MyLevel <= 1724 then
			Mon = "Marine Commodore";
			LevelQuest = 1;
			NameQuest = "MarineTreeIsland";
			NameMon = "Marine Commodore";
			CFrameQuest = CFrame.new(2180.54126, 27.8156815, -6741.5498, -0.965929747, 0, 0.258804798, 0, 1, 0, -0.258804798, 0, -0.965929747);
			CFrameMon = CFrame.new(2286.0078125, 73.13391876220703, -7159.80908203125);
		elseif MyLevel == 1725 or MyLevel <= 1774 then
			Mon = "Marine Rear Admiral [Lv. 1725]";
			NameMon = "Marine Rear Admiral";
			NameQuest = "MarineTreeIsland";
			LevelQuest = 2;
			CFrameQuest = CFrame.new(2179.98828125, 28.731239318848, -6740.0551757813);
			CFrameMon = CFrame.new(3656.773681640625, 160.52406311035156, -7001.5986328125);
		elseif MyLevel == 1775 or MyLevel <= 1799 then
			Mon = "Fishman Raider";
			LevelQuest = 1;
			NameQuest = "DeepForestIsland3";
			NameMon = "Fishman Raider";
			CFrameQuest = CFrame.new(-10581.6563, 330.872955, -8761.18652, -0.882952213, 0, 0.469463557, 0, 1, 0, -0.469463557, 0, -0.882952213);
			CFrameMon = CFrame.new(-10407.5263671875, 331.76263427734375, -8368.5166015625);
		elseif MyLevel == 1800 or MyLevel <= 1824 then
			Mon = "Fishman Captain";
			LevelQuest = 2;
			NameQuest = "DeepForestIsland3";
			NameMon = "Fishman Captain";
			CFrameQuest = CFrame.new(-10581.6563, 330.872955, -8761.18652, -0.882952213, 0, 0.469463557, 0, 1, 0, -0.469463557, 0, -0.882952213);
			CFrameMon = CFrame.new(-10994.701171875, 352.38140869140625, -9002.1103515625);
		elseif MyLevel == 1825 or MyLevel <= 1849 then
			Mon = "Forest Pirate";
			LevelQuest = 1;
			NameQuest = "DeepForestIsland";
			NameMon = "Forest Pirate";
			CFrameQuest = CFrame.new(-13234.04, 331.488495, -7625.40137, 0.707134247, -0, -0.707079291, 0, 1, -0, 0.707079291, 0, 0.707134247);
			CFrameMon = CFrame.new(-13274.478515625, 332.3781433105469, -7769.58056640625);
		elseif MyLevel == 1850 or MyLevel <= 1899 then
			Mon = "Mythological Pirate";
			LevelQuest = 2;
			NameQuest = "DeepForestIsland";
			NameMon = "Mythological Pirate";
			CFrameQuest = CFrame.new(-13234.04, 331.488495, -7625.40137, 0.707134247, -0, -0.707079291, 0, 1, -0, 0.707079291, 0, 0.707134247);
			CFrameMon = CFrame.new(-13680.607421875, 501.08154296875, -6991.189453125);
		elseif MyLevel == 1900 or MyLevel <= 1924 then
			Mon = "Jungle Pirate";
			LevelQuest = 1;
			NameQuest = "DeepForestIsland2";
			NameMon = "Jungle Pirate";
			CFrameQuest = CFrame.new(-12680.3818, 389.971039, -9902.01953, -0.0871315002, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, -0.0871315002);
			CFrameMon = CFrame.new(-12256.16015625, 331.73828125, -10485.8369140625);
		elseif MyLevel == 1925 or MyLevel <= 1974 then
			Mon = "Musketeer Pirate";
			LevelQuest = 2;
			NameQuest = "DeepForestIsland2";
			NameMon = "Musketeer Pirate";
			CFrameQuest = CFrame.new(-12680.3818, 389.971039, -9902.01953, -0.0871315002, 0, 0.996196866, 0, 1, 0, -0.996196866, 0, -0.0871315002);
			CFrameMon = CFrame.new(-13457.904296875, 391.545654296875, -9859.177734375);
		elseif MyLevel == 1975 or MyLevel <= 1999 then
			Mon = "Reborn Skeleton";
			LevelQuest = 1;
			NameQuest = "HauntedQuest1";
			NameMon = "Reborn Skeleton";
			CFrameQuest = CFrame.new(-9479.2168, 141.215088, 5566.09277, 0, 0, 1, 0, 1, -0, -1, 0, 0);
			CFrameMon = CFrame.new(-8763.7236328125, 165.72299194335938, 6159.86181640625);
		elseif MyLevel == 2000 or MyLevel <= 2024 then
			Mon = "Living Zombie";
			LevelQuest = 2;
			NameQuest = "HauntedQuest1";
			NameMon = "Living Zombie";
			CFrameQuest = CFrame.new(-9479.2168, 141.215088, 5566.09277, 0, 0, 1, 0, 1, -0, -1, 0, 0);
			CFrameMon = CFrame.new(-10144.1318359375, 138.62667846679688, 5838.0888671875);
		elseif MyLevel == 2025 or MyLevel <= 2049 then
			Mon = "Demonic Soul";
			LevelQuest = 1;
			NameQuest = "HauntedQuest2";
			NameMon = "Demonic Soul";
			CFrameQuest = CFrame.new(-9516.99316, 172.017181, 6078.46533, 0, 0, -1, 0, 1, 0, 1, 0, 0);
			CFrameMon = CFrame.new(-9505.8720703125, 172.10482788085938, 6158.9931640625);
		elseif MyLevel == 2050 or MyLevel <= 2074 then
			Mon = "Posessed Mummy";
			LevelQuest = 2;
			NameQuest = "HauntedQuest2";
			NameMon = "Posessed Mummy";
			CFrameQuest = CFrame.new(-9516.99316, 172.017181, 6078.46533, 0, 0, -1, 0, 1, 0, 1, 0, 0);
			CFrameMon = CFrame.new(-9582.0224609375, 6.251527309417725, 6205.478515625);
		elseif MyLevel == 2075 or MyLevel <= 2099 then
			Mon = "Peanut Scout";
			LevelQuest = 1;
			NameQuest = "NutsIslandQuest";
			NameMon = "Peanut Scout";
			CFrameQuest = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875, 0, 0, -1, 0, 1, 0, 1, 0, 0);
			CFrameMon = CFrame.new(-2143.241943359375, 47.72198486328125, -10029.9951171875);
		elseif MyLevel == 2100 or MyLevel <= 2124 then
			Mon = "Peanut President";
			LevelQuest = 2;
			NameQuest = "NutsIslandQuest";
			NameMon = "Peanut President";
			CFrameQuest = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875, 0, 0, -1, 0, 1, 0, 1, 0, 0);
			CFrameMon = CFrame.new(-1859.35400390625, 38.10316848754883, -10422.4296875);
		elseif MyLevel == 2125 or MyLevel <= 2149 then
			Mon = "Ice Cream Chef";
			LevelQuest = 1;
			NameQuest = "IceCreamIslandQuest";
			NameMon = "Ice Cream Chef";
			CFrameQuest = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438, 0, 0, -1, 0, 1, 0, 1, 0, 0);
			CFrameMon = CFrame.new(-872.24658203125, 65.81957244873047, -10919.95703125);
		elseif MyLevel == 2150 or MyLevel <= 2199 then
			Mon = "Ice Cream Commander";
			LevelQuest = 2;
			NameQuest = "IceCreamIslandQuest";
			NameMon = "Ice Cream Commander";
			CFrameQuest = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438, 0, 0, -1, 0, 1, 0, 1, 0, 0);
			CFrameMon = CFrame.new(-558.06103515625, 112.04895782470703, -11290.7744140625);
		elseif MyLevel == 2200 or MyLevel <= 2224 then
			Mon = "Cookie Crafter";
			LevelQuest = 1;
			NameQuest = "CakeQuest1";
			NameMon = "Cookie Crafter";
			CFrameQuest = CFrame.new(-2021.32007, 37.7982254, -12028.7295, 0.957576931, -0.0000000880302053, 0.288177818, 0.000000069301187, 1, 0.0000000751931211, -0.288177818, -0.000000052032135, 0.957576931);
			CFrameMon = CFrame.new(-2374.13671875, 37.79826354980469, -12125.30859375);
		elseif MyLevel == 2225 or MyLevel <= 2249 then
			Mon = "Cake Guard";
			LevelQuest = 2;
			NameQuest = "CakeQuest1";
			NameMon = "Cake Guard";
			CFrameQuest = CFrame.new(-2021.32007, 37.7982254, -12028.7295, 0.957576931, -0.0000000880302053, 0.288177818, 0.000000069301187, 1, 0.0000000751931211, -0.288177818, -0.000000052032135, 0.957576931);
			CFrameMon = CFrame.new(-1598.3070068359375, 43.773197174072266, -12244.5810546875);
		elseif MyLevel == 2250 or MyLevel <= 2274 then
			Mon = "Baking Staff";
			LevelQuest = 1;
			NameQuest = "CakeQuest2";
			NameMon = "Baking Staff";
			CFrameQuest = CFrame.new(-1927.91602, 37.7981339, -12842.5391, -0.96804446, 0.0000000422142143, 0.250778586, 0.0000000474911062, 1, 0.0000000149904711, -0.250778586, 0.0000000264211941, -0.96804446);
			CFrameMon = CFrame.new(-1887.8099365234375, 77.6185073852539, -12998.3505859375);
		elseif MyLevel == 2275 or MyLevel <= 2299 then
			Mon = "Head Baker";
			LevelQuest = 2;
			NameQuest = "CakeQuest2";
			NameMon = "Head Baker";
			CFrameQuest = CFrame.new(-1927.91602, 37.7981339, -12842.5391, -0.96804446, 0.0000000422142143, 0.250778586, 0.0000000474911062, 1, 0.0000000149904711, -0.250778586, 0.0000000264211941, -0.96804446);
			CFrameMon = CFrame.new(-2216.188232421875, 82.884521484375, -12869.2939453125);
		elseif MyLevel == 2300 or MyLevel <= 2324 then
			Mon = "Cocoa Warrior";
			LevelQuest = 1;
			NameQuest = "ChocQuest1";
			NameMon = "Cocoa Warrior";
			CFrameQuest = CFrame.new(233.22836303710938, 29.876001358032227, -12201.2333984375);
			CFrameMon = CFrame.new(-21.55328369140625, 80.57499694824219, -12352.3876953125);
		elseif MyLevel == 2325 or MyLevel <= 2349 then
			Mon = "Chocolate Bar Battler";
			LevelQuest = 2;
			NameQuest = "ChocQuest1";
			NameMon = "Chocolate Bar Battler";
			CFrameQuest = CFrame.new(233.22836303710938, 29.876001358032227, -12201.2333984375);
			CFrameMon = CFrame.new(582.590576171875, 77.18809509277344, -12463.162109375);
		elseif MyLevel == 2350 or MyLevel <= 2374 then
			Mon = "Sweet Thief";
			LevelQuest = 1;
			NameQuest = "ChocQuest2";
			NameMon = "Sweet Thief";
			CFrameQuest = CFrame.new(150.5066375732422, 30.693693161010742, -12774.5029296875);
			CFrameMon = CFrame.new(165.1884765625, 76.05885314941406, -12600.8369140625);
		elseif MyLevel == 2375 or MyLevel <= 2399 then
			Mon = "Candy Rebel";
			LevelQuest = 2;
			NameQuest = "ChocQuest2";
			NameMon = "Candy Rebel";
			CFrameQuest = CFrame.new(150.5066375732422, 30.693693161010742, -12774.5029296875);
			CFrameMon = CFrame.new(134.86563110351562, 77.2476806640625, -12876.5478515625);
		elseif MyLevel == 2400 or MyLevel <= 2424 then
			Mon = "Candy Pirate";
			LevelQuest = 1;
			NameQuest = "CandyQuest1";
			NameMon = "Candy Pirate";
			CFrameQuest = CFrame.new(-1150.0400390625, 20.378934860229492, -14446.3349609375);
			CFrameMon = CFrame.new(-1310.5003662109375, 26.016523361206055, -14562.404296875);
		elseif MyLevel == 2425 or MyLevel <= 2449 then
			Mon = "Snow Demon";
			LevelQuest = 2;
			NameQuest = "CandyQuest1";
			NameMon = "Snow Demon";
			CFrameQuest = CFrame.new(-1150.0400390625, 20.378934860229492, -14446.3349609375);
			CFrameMon = CFrame.new(-880.2006225585938, 71.24776458740234, -14538.609375);
		elseif MyLevel == 2450 or MyLevel <= 2474 then
			Mon = "Isle Outlaw";
			LevelQuest = 1;
			NameQuest = "TikiQuest1";
			NameMon = "Isle Outlaw";
			CFrameQuest = CFrame.new(-16547.748046875, 61.13533401489258, -173.41360473632812);
			CFrameMon = CFrame.new(-16442.814453125, 116.13899993896484, -264.4637756347656);
		elseif MyLevel == 2475 or MyLevel <= 2524 then
			Mon = "Island Boy";
			LevelQuest = 2;
			NameQuest = "TikiQuest1";
			NameMon = "Island Boy";
			CFrameQuest = CFrame.new(-16547.748046875, 61.13533401489258, -173.41360473632812);
			CFrameMon = CFrame.new(-16901.26171875, 84.06756591796875, -192.88906860351562);
		elseif MyLevel == 2525 or MyLevel <= 2549 then
			Mon = "Isle Champion";
			LevelQuest = 2;
			NameQuest = "TikiQuest2";
			NameMon = "Isle Champion";
			CFrameQuest = CFrame.new(-16539.078125, 55.68632888793945, 1051.5738525390625);
			CFrameMon = CFrame.new(-16641.6796875, 235.7825469970703, 1031.282958984375);
		elseif MyLevel == 2550 or MyLevel <= 2574 then
			Mon = "Serpent Hunter";
			LevelQuest = 1;
			NameQuest = "TikiQuest3";
			NameMon = "Serpent Hunter";
			CFrameQuest = CFrame.new(-16661.890625, 105.2862319946289, 1576.69775390625);
			CFrameMon = CFrame.new(-16587.896484375, 154.21299743652344, 1533.40966796875);
		elseif MyLevel == 2575 or MyLevel >= 2575 then
			Mon = "Skull Slayer";
			LevelQuest = 2;
			NameQuest = "TikiQuest3";
			NameMon = "Skull Slayer";
			CFrameQuest = CFrame.new(-16661.890625, 105.2862319946289, 1576.69775390625);
			CFrameMon = CFrame.new(-16885.203125, 114.12911224365234, 1627.949951171875);
		end;
	end;
end;

function enableNoclip()
    local hrp = game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp and not hrp:FindFirstChild("BodyClip") then
        local noclip = Instance.new("BodyVelocity")
        noclip.Name = "BodyClip"
        noclip.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        noclip.Velocity = Vector3.new(0, 0, 0)
        noclip.Parent = hrp
    end
end

function disableNoclip()
    local hrp = game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local clip = hrp:FindFirstChild("BodyClip")
        if clip then
            clip:Destroy()
        end
    end
end

function disableCollisions()
    for _, part in pairs(game:GetService("Players").LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

spawn(function()
    while task.wait(0.2) do
        local isActive = getgenv().Module or _G.DefendVolcano or getgenv().AutoFarm
        if isActive then
            enableNoclip()
            disableCollisions()
        else
            disableNoclip()
        end
    end
end)

local function StartQuest()
    pcall(function()
        if game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("QuestGui") then
            if game:GetService("Players").LocalPlayer.PlayerGui.QuestGui.Enabled == true then return end
        end

        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", NameQuest, LevelQuest)
    end)
end

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local function TweenTo(pos)
    local ts = game:GetService("TweenService")
    local player = game.Players.LocalPlayer
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local tween = ts:Create(hrp, TweenInfo.new(2, Enum.EasingStyle.Linear), { CFrame = pos })
    tween:Play()
    tween.Completed:Wait()
end

local function FarmMob()
    pcall(function()
        for i, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
            if v.Name == NameMon and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                repeat
                    pcall(function()
                        local player = game.Players.LocalPlayer
                        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and v:FindFirstChild("HumanoidRootPart") then
                            hrp.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0)
                        end
                        if player.Character:FindFirstChildOfClass("Tool") then
                            player.Character:FindFirstChildOfClass("Tool"):Activate()
                        end
                    end)
                    task.wait()
                until not v or not v.Parent or v.Humanoid.Health <= 0 or not _G.AutoFarm
            end
        end
    end)
end

function UnEquipWeapon(Weapon)
    if game.Players.LocalPlayer.Character:FindFirstChild(Weapon) then
        _G.NotAutoEquip = true
        wait(0.5)
        game.Players.LocalPlayer.Character:FindFirstChild(Weapon).Parent = game.Players.LocalPlayer.Backpack
        wait(0.1)
        _G.NotAutoEquip = false
    end
end

function EquipWeapon(ToolSe)
    if not _G.NotAutoEquip then
        if game.Players.LocalPlayer.Backpack:FindFirstChild(ToolSe) then
            local Tool = game.Players.LocalPlayer.Backpack:FindFirstChild(ToolSe)
            wait(0.1)
            game.Players.LocalPlayer.Character.Humanoid:EquipTool(Tool)
        end
    end
end

local Tabs = {
    MainFarm = Window:AddTab({ Title = "Main Farm", Icon = "" }),
    StackAutoFarm = Window:AddTab({ Title = "Stack Auto farm", Icon = "" }),
    SubFarming = Window:AddTab({ Title = "Sub Farming", Icon = "" }),
    Status = Window:AddTab({ Title = "Status", Icon = "" }),
    PlayerStatus = Window:AddTab({ Title = "Player-Status", Icon = "" }),
    Fruit = Window:AddTab({ Title = "Fruit", Icon = "" }),
    LocalPlayer = Window:AddTab({ Title = "Local Player", Icon = "" }),
    Travel = Window:AddTab({ Title = "Travel", Icon = "" }),
    SeaEvents = Window:AddTab({ Title = "Sea Events", Icon = "" }),
    SubClass = Window:AddTab({ Title = "Sub Class", Icon = "" }),
    Shop = Window:AddTab({ Title = "Shop", Icon = "" }),
    Setting = Window:AddTab({ Title = "Setting", Icon = "" }),
    Race = Window:AddTab({ Title = "Race V4", Icon = "" }),
    GameServer = Window:AddTab({ Title = "Game-Server", Icon = "" }),
    OneClick = Window:AddTab({ Title = "One Click", Icon = "" }),
    OneClickDebugger = Window:AddTab({ Title = "One Click Debugger", Icon = "" }),
}

function InstantTp(P)
	game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = P
end

function AutoHaki()
	if not (game:GetService("Players")).LocalPlayer.Character:FindFirstChild("HasBuso") then
		(game:GetService("ReplicatedStorage")).Remotes.CommF_:InvokeServer("Buso")
	end
end

Tabs.StackAutoFarm:AddToggle("AutoSecondSea", {
    Title = "Auto Second Sea",
    Default = false,
    Callback = function(value)
        _G.AutoSecondSea = value
    end
})

spawn(function()
    while wait() do
        if _G.AutoSecondSea then
            pcall(function()
                if game.Players.LocalPlayer.Data.Level.Value >= 700 and World1 then
                    _G.AutoFarm = false
                    local door = workspace.Map.Ice.Door
                    if door.CanCollide == true and door.Transparency == 0 then
                        repeat wait()
                            topos(CFrame.new(4851.8720703125, 5.6514348983765, 718.47094726563))
                        until (CFrame.new(4851.8720703125, 5.6514348983765, 718.47094726563).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 3 or not _G.AutoSecondSea

                        wait(1)
                        game.ReplicatedStorage.Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "Detective")
                        EquipWeapon("Key")
                        local pos2 = CFrame.new(1347.7124, 37.3751602, -1325.6488)
                        repeat wait()
                            topos(pos2)
                        until (pos2.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 3 or not _G.AutoSecondSea
                        wait(3)
                    elseif door.CanCollide == false and door.Transparency == 1 then
                        if workspace.Enemies:FindFirstChild("Ice Admiral") then
                            for _, v in pairs(workspace.Enemies:GetChildren()) do
                                if v.Name == "Ice Admiral" and v.Humanoid.Health > 0 then
                                    repeat wait()
                                        AutoHaki()
                                        EquipWeapon(_G.SelectWeapon)
                                        v.HumanoidRootPart.CanCollide = false
                                        StartBring = true
                                        v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                        v.HumanoidRootPart.Transparency = 1
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        game:GetService("VirtualUser"):CaptureController()
                                        game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 870), workspace.CurrentCamera.CFrame)
                                    until v.Humanoid.Health <= 0 or not v.Parent or not _G.AutoSecondSea

                                    game.ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelDressrosa")
                                end
                            end
                        else
                            topos(CFrame.new(1347.7124, 37.3751602, -1325.6488))
                        end
                    else
                        game.ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelDressrosa")
                    end
                end
            end)
        end
    end
end)

if World2 then
    Tabs.StackAutoFarm:AddToggle("AutoBartilo", {
        Title = "Auto Quest Bartilo",
        Default = false,
        Callback = function(value)
            _G.AutoBartilo = value
            StopTween(_G.AutoBartilo)
        end
    })

    spawn(function()
        while wait(0.1) do
            if _G.AutoBartilo then
                pcall(function()
                    local questProgress = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BartiloQuestProgress", "Bartilo")
                    local level = game.Players.LocalPlayer.Data.Level.Value

                    if level >= 800 and questProgress == 0 then
                        local gui = game.Players.LocalPlayer.PlayerGui.Main.Quest
                        local isSwanQuest = gui.Visible and gui.Container.QuestTitle.Title.Text:find("Swan Pirates")
                        if isSwanQuest then
                            for _, v in pairs(workspace.Enemies:GetChildren()) do
                                if v.Name:find("Swan Pirate") and v:FindFirstChild("HumanoidRootPart") then
                                    repeat task.wait()
                                        EquipWeapon(_G.SelectWeapon)
                                        AutoHaki()
                                        v.HumanoidRootPart.CanCollide = false
                                        v.HumanoidRootPart.Transparency = 1
                                        v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                        PosMonBarto = v.HumanoidRootPart.CFrame
                                        topos(PosMonBarto * CFrame.new(0, 30, 0))
                                        game:GetService("VirtualUser"):CaptureController()
                                        game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
                                        StartBring = true
                                    until not v.Parent or v.Humanoid.Health <= 0 or not gui.Visible or not _G.AutoBartilo
                                    StartBring = false
                                end
                            end
                        else
                            topos(CFrame.new(-456.28952, 73.0200958, 299.895966))
                            wait(1)
                            game.ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", "BartiloQuest", 1)
                        end
                    elseif level >= 800 and questProgress == 1 then
                        if workspace.Enemies:FindFirstChild("Jeremy") then
                            for _, v in pairs(workspace.Enemies:GetChildren()) do
                                if v.Name == "Jeremy" and v:FindFirstChild("HumanoidRootPart") then
                                    repeat wait()
                                        EquipWeapon(_G.SelectWeapon)
                                        AutoHaki()
                                        v.HumanoidRootPart.CanCollide = false
                                        v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        game:GetService("VirtualUser"):CaptureController()
                                        game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
                                    until not v.Parent or v.Humanoid.Health <= 0 or not _G.AutoBartilo
                                end
                            end
                        else
                            topos(CFrame.new(2099.88159, 448.931, 648.997375))
                        end
                    elseif level >= 800 and questProgress == 2 then
                        local sequence = {
                            Vector3.new(-1850.49, 13.17, 1750.89),
                            Vector3.new(-1858.87, 19.37, 1712.01),
                            Vector3.new(-1803.94, 16.57, 1750.89),
                            Vector3.new(-1858.55, 16.86, 1724.79),
                            Vector3.new(-1869.54, 15.98, 1681.00),
                            Vector3.new(-1800.09, 16.49, 1684.52),
                            Vector3.new(-1819.26, 14.79, 1717.90),
                            Vector3.new(-1813.51, 14.86, 1724.79)
                        }
                        for _, vec in ipairs(sequence) do
                            topos(CFrame.new(vec))
                            wait(1)
                        end
                    end
                end)
            end
        end
    end)
end

Tabs.StackAutoFarm:AddToggle("AutoThirdSea", {
    Title = "Auto Third Sea",
    Default = false,
    Callback = function(value)
        _G.ThirdSea = value
        StopTween(_G.ThirdSea)
    end
})

spawn(function()
    while wait() do
        if _G.ThirdSea then
            pcall(function()
                if World2 and game.Players.LocalPlayer.Data.Level.Value >= 1500 then
                    _G.AutoFarm = false
                    if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ZQuestProgress", "General") == 0 then
                        local indraCFrame = CFrame.new(-1926.32, 12.81, 1738.30)
                        topos(indraCFrame)
                        if (indraCFrame.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 10 then
                            wait(1.5)
                            game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ZQuestProgress", "Begin")
                        end
                    end

                    local rip = workspace.Enemies:FindFirstChild("rip_indra")
                    if rip then
                        repeat wait()
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            StartBring = true
                            topos(rip.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            rip.HumanoidRootPart.CanCollide = false
                            rip.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                            game.ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelZou")
                        until not rip or rip.Humanoid.Health <= 0 or not _G.ThirdSea
                    elseif not rip then
                        TP1(CFrame.new(-26880.93359375, 22.848554611206, 473.18951416016))
                    end
                end
            end)
        end
    end
end)

Tabs.StackAutoFarm:AddToggle("AutoRengoku", {
    Title = "Auto Get Sword Rengoku",
    Default = false,
    Callback = function(value)
        _G.AutoRengoku = value
        StopTween(_G.AutoRengoku)
    end
})

spawn(function()
    while wait() do
        if _G.AutoRengoku then
            pcall(function()
                local player = game.Players.LocalPlayer
                if player.Backpack:FindFirstChild("Hidden Key") or player.Character:FindFirstChild("Hidden Key") then
                    EquipWeapon("Hidden Key")
                    topos(CFrame.new(6571.1201171875, 299.23028564453, -6967.841796875))
                elseif workspace.Enemies:FindFirstChild("Awakened Ice Admiral") then
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v.Name == "Awakened Ice Admiral" and v.Humanoid.Health > 0 then
                            repeat wait()
                                EquipWeapon(_G.SelectWeapon)
                                AutoHaki()
                                v.HumanoidRootPart.CanCollide = false
                                v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                PosMon = v.HumanoidRootPart.CFrame
                                MonFarm = v.Name
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                AttackNoCD()
                                StartBring = true
                            until player.Backpack:FindFirstChild("Hidden Key") or not _G.AutoRengoku or not v.Parent or v.Humanoid.Health <= 0
                            StartBring = false
                        end
                    end
                else
                    StartBring = false
                    topos(CFrame.new(5439.716796875, 84.420944213867, -6715.1635742188))
                end
            end)
        end
    end
end)

Tabs.SubFarming:AddToggle("AutoStartChocola", {
    Title = "Auto Chocola",
    Default = false,
    Callback = function(value)
        _G.FarmChocola = value
        StopTween(_G.FarmChocola)
    end
})

spawn(function()
    while wait() do
        local Choccola = CFrame.new(87.94276428222656, 73.55451202392578, -12319.46484375)
        if _G.FarmChocola then
            pcall(function()
                if BypassTP then
                    if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Choccola.Position).Magnitude > 2000 then
                        BTP(Choccola)
                        wait(0.1)
                        for i = 1, 8 do
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Choccola
                            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
                            wait(0.1)
                        end
                    else
                        TP1(Choccola)
                    end
                else
                    TP1(Choccola)
                end

                local Enemies = workspace.Enemies
                if Enemies:FindFirstChild("Chocolate Bar Battler") or Enemies:FindFirstChild("Cocoa Warrior") or Enemies:FindFirstChild("Sweet Thief") or Enemies:FindFirstChild("Candy Rebel") then
                    for _, v in pairs(Enemies:GetChildren()) do
                        if table.find({"Chocolate Bar Battler", "Cocoa Warrior", "Sweet Thief", "Candy Rebel"}, v.Name) then
                            if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                repeat task.wait()
                                    AutoHaki()
                                    NeedAttacking = true
                                    EquipWeapon(_G.SelectWeapon)
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Humanoid.WalkSpeed = 0
                                    v.Head.CanCollide = false
                                    StartBring = true
                                    MonFarm = v.Name
                                    PosMon = v.HumanoidRootPart.CFrame
                                    topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                    sethiddenproperty(game.Players.LocalPlayer,"SimulationRadius",math.huge)
                                until not _G.FarmChocola or not v.Parent or v.Humanoid.Health <= 0
                            end
                        end
                    end
                else
                    StartBring = false
                    topos(CFrame.new(233.22836303710938, 29.876001358032227, -12201.2333984375))
                    for _, v in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
                        if table.find({"Chocolate Bar Battler", "Cocoa Warrior", "Sweet Thief", "Candy Rebel"}, v.Name) then
                            topos(v.HumanoidRootPart.CFrame * CFrame.new(2, 20, 2))
                        end
                    end
                end
            end)
        end
    end
end)

Tabs.SubFarming:AddToggle("AutoCakePrince", {
    Title = "Auto Farm Cake Prince",
    Default = false,
    Callback = function(value)
        _G.FarmCake = value
        StopTween(_G.FarmCake)
    end
})

local CakePos = CFrame.new(-2130.80712890625, 69.95634460449219, -12327.83984375)

spawn(function()
    while task.wait() do
        if _G.FarmCake then
            pcall(function()
                if workspace.Enemies:FindFirstChild("Cake Prince") then
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v.Name == "Cake Prince" and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            repeat
                                task.wait()
                                AutoHaki()
                                EquipWeapon(_G.SelectWeapon)
                                v.HumanoidRootPart.CanCollide = false
                                v.Humanoid.WalkSpeed = 0
                                v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                local ori = workspace:FindFirstChild("_WorldOrigin")
                                if ori and (ori:FindFirstChild("Ring") or ori:FindFirstChild("Fist") or ori:FindFirstChild("MochiSwirl")) then
                                    topos(v.HumanoidRootPart.CFrame * CFrame.new(0, -40, 0))
                                else
                                    topos(v.HumanoidRootPart.CFrame * CFrame.new(4, 10, 10))
                                end
                            until not _G.FarmCake or not v.Parent or v.Humanoid.Health <= 0
                            wait(1)
                        end
                    end
                else
                    local foundMob = false
                    for _, mob in ipairs({"Cookie Crafter", "Cake Guard", "Baking Staff", "Head Baker"}) do
                        if workspace.Enemies:FindFirstChild(mob) then
                            foundMob = true
                            break
                        end
                    end

                    if foundMob then
                        for _, v in pairs(workspace.Enemies:GetChildren()) do
                            if table.find({"Cookie Crafter", "Cake Guard", "Baking Staff", "Head Baker"}, v.Name) and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                repeat
                                    task.wait()
                                    AutoHaki()
                                    EquipWeapon(_G.SelectWeapon)
                                    v.HumanoidRootPart.CanCollide = false
                                    v.Humanoid.WalkSpeed = 0
                                    StartBring = true
                                    v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                    PosMon = v.HumanoidRootPart.CFrame
                                    MonFarm = v.Name
                                    v.Head.CanCollide = false
                                    topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                    if v.Name == "Cookie Crafter" then
                                        Bring(v.Name, CFrame.new(-2212.88965, 37.0051041, -11969.2568))
                                    elseif v.Name == "Cake Guard" then
                                        Bring(v.Name, CFrame.new(-1693.98047, 35.2188225, -12436.8438))
                                    elseif v.Name == "Baking Staff" then
                                        Bring(v.Name, CFrame.new(-1980.4375, 34.6653099, -12983.8408))
                                    elseif v.Name == "Head Baker" then
                                        Bring(v.Name, CFrame.new(-2151.37793, 51.0095749, -13033.3975))
                                    end
                                until not _G.FarmCake or not v.Parent or v.Humanoid.Health <= 0 or workspace.Map.CakeLoaf.BigMirror.Other.Transparency == 0 or game:GetService("ReplicatedStorage"):FindFirstChild("Cake Prince [Lv. 2300] [Raid Boss]") or workspace.Enemies:FindFirstChild("Cake Prince [Lv. 2300] [Raid Boss]")
                            end
                        end
                    else
                        local r = math.random(1, 3)
                        if r == 1 then
                            topos(CFrame.new(-1436.86011, 167.753616, -12296.9512))
                        elseif r == 2 then
                            topos(CFrame.new(-2383.78979, 150.450592, -12126.4961))
                        elseif r == 3 then
                            topos(CFrame.new(-2231.2793, 168.256653, -12845.7559))
                        end
                    end
                    topos(CakePos)
                end
            end)
        end
    end
end)

Tabs.SubFarming:AddToggle("AutoKatakuri", {
    Title = "Auto Katakuri V2",
    Default = false,
    Callback = function(value)
        _G.Fullykatakuri = value
        StopTween(_G.Fullykatakuri)
    end
})

spawn(function()
    while wait() do
        if _G.Fullykatakuri then
            pcall(function()
                local enemies = workspace.Enemies:GetChildren()

                local function attackEnemy(v)
                    repeat wait()
                        AutoHaki()
                        EquipWeapon(_G.SelectWeapon)
                        v.HumanoidRootPart.Size = Vector3.new(70,70,70)
                        v.HumanoidRootPart.CanCollide = false
                        v.Humanoid.WalkSpeed = 0
                        v.Head.CanCollide = false
                        StartBring = false
                        MonFarm = v.Name
                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                        game:GetService("VirtualUser"):CaptureController()
                        game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
                    until not _G.Fullykatakuri or not v.Parent or v.Humanoid.Health <= 0
                end

                if game.Players.LocalPlayer.Backpack:FindFirstChild("God's Chalice") or game.Players.LocalPlayer.Character:FindFirstChild("God's Chalice") then
                    local response = game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SweetChaliceNpc")
                    if string.find(response, "Where") then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SweetChaliceNpc")
                    end

                elseif game.Players.LocalPlayer.Backpack:FindFirstChild("Sweet Chalice") or game.Players.LocalPlayer.Character:FindFirstChild("Sweet Chalice") then
                    local response = game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner")
                    if string.find(response, "Do you want to open the portal now?") then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner")
                    else
                        local found = false
                        for _, v in pairs(enemies) do
                            if table.find({"Baking Staff", "Head Baker", "Cake Guard", "Cookie Crafter"}, v.Name) and v.Humanoid.Health > 0 then
                                attackEnemy(v)
                                found = true
                            end
                        end
                        if not found then
                            CakeBring = false
                            StartBring = false
                            topos(CFrame.new(-1820.0634765625, 210.74781799316406, -12297.49609375))
                        end
                    end

                elseif game.ReplicatedStorage:FindFirstChild("Dough King") or workspace.Enemies:FindFirstChild("Dough King") then
                    local king = workspace.Enemies:FindFirstChild("Dough King")
                    if king then
                        attackEnemy(king)
                    else
                        topos(CFrame.new(-2009.2802734375, 4532.97216796875, -14937.3076171875))
                    end

                elseif game.Players.LocalPlayer.Backpack:FindFirstChild("Red Key") or game.Players.LocalPlayer.Character:FindFirstChild("Red Key") then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakeScientist", "Check")

                else
                    local questUI = game.Players.LocalPlayer.PlayerGui.Main.Quest
                    if questUI.Visible and string.find(questUI.Container.QuestTitle.Title.Text, "Diablo") or string.find(questUI.Container.QuestTitle.Title.Text, "Deandre") or string.find(questUI.Container.QuestTitle.Title.Text, "Urban") then
                        for _, v in pairs(enemies) do
                            if table.find({"Diablo", "Deandre", "Urban"}, v.Name) and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                attackEnemy(v)
                                sethiddenproperty(game.Players.LocalPlayer,"SimulationRadius",math.huge)
                            end
                        end
                    else
                        wait(0.5)
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("EliteHunter")
                    end
                end
            end)
        end
    end
end)

Tabs.SubFarming:AddButton({
    Title = "TP Advanced Fruit Dealer",
    Callback = function()
        TweenNpc()
    end
})

function TweenNpc()
    repeat wait() until workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("MysticIsland")
    if workspace.Map:FindFirstChild("MysticIsland") then
        local AllNPCS = getnilinstances()
        for _, npc in pairs(workspace.NPCs:GetChildren()) do
            table.insert(AllNPCS, npc)
        end
        for _, npc in pairs(AllNPCS) do
            if npc.Name == "Advanced Fruit Dealer" and npc:FindFirstChild("HumanoidRootPart") then
                topos(npc.HumanoidRootPart.CFrame)
            end
        end
    end
end

local x2Code = {
    "KITTGAMING",
    "ENYU_IS_PRO",
    "FUDD10",
    "BIGNEWS",
    "THEGREATACE",
    "SUB2GAMERROBOT_EXP1",
    "STRAWHATMAIME",
    "SUB2OFFICIALNOOBIE",
    "SUB2NOOBMASTER123",
    "SUB2DAIGROCK",
    "AXIORE",
    "TANTAIGAMIMG",
    "STRAWHATMAINE",
    "JCWK",
    "FUDD10_V2",
    "SUB2FER999",
    "MAGICBIS",
    "TY_FOR_WATCHING",
    "STARCODEHEO"
}

Tabs.OneClick:AddButton({
    Title = "Redeem All Codes",
    Callback = function()
        local function RedeemCode(value)
            game:GetService("ReplicatedStorage").Remotes.Redeem:InvokeServer(value)
        end
        for _, code in pairs(x2Code) do
            RedeemCode(code)
        end
    end
})

-- Game-Server Tab
Tabs.GameServer:AddToggle("Disable3DRender", {
    Title = "Disable 3D Render",
    Default = false,
    Callback = function(Value) print("Disable 3D Render:", Value) end
})

Tabs.GameServer:AddToggle("DisableNotifications", {
    Title = "Disable Notifications",
    Default = false,
    Callback = function(Value) print("Disable Notifications:", Value) end
})

local DisableDMGCounter = false

Tabs.GameServer:AddToggle("DisableDMGCounter", {
    Title = "Disable DMG Counter",
    Default = false,
    Callback = function(Value) print("Disable DMG Counter:", Value) end
})

Tabs.GameServer:AddToggle("HideChat", {
    Title = "Hide Chat",
    Default = false,
    Callback = function(value)
        local StarterGui = game:GetService("StarterGui")
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, not value)
    end
})

Tabs.GameServer:AddToggle("HideLeaderboard", {
    Title = "Hide Leaderboard",
    Default = false,
    Callback = function(value)
        local StarterGui = game:GetService("StarterGui")
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not value)
    end
})

Tabs.GameServer:AddToggle("RemoveFog", {
    Title = "Remove Fog",
    Default = false,
    Callback = function(value)
        local lighting = game:GetService("Lighting")
        if value then
            if lighting:FindFirstChild("LightingLayers") then
                lighting.LightingLayers:Destroy()
            end
            if lighting:FindFirstChild("Sky") then
                lighting.Sky:Destroy()
            end
            lighting.FogEnd = 9000000000
        else
            lighting.FogEnd = 1000
        end
    end
})

Tabs.GameServer:AddToggle("AntiAFKToggle", {
    Title = "Anti-AFK",
    Default = true,
    Callback = function(state)
        if state then
            if not getgenv().AntiAFKThread then
                getgenv().AntiAFKThread = task.spawn(function()
                    local VirtualUser = game:GetService("VirtualUser")
                    while task.wait(math.random(300, 600)) do
                        pcall(function()
                            VirtualUser:CaptureController()
                            VirtualUser:ClickButton1(Vector2.new(0, 0))
                        end)
                    end
                end)
            end
        else
            if getgenv().AntiAFKThread then
                task.cancel(getgenv().AntiAFKThread)
                getgenv().AntiAFKThread = nil
            end
        end
    end
})

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local JobId = game.JobId

Tabs.GameServer:AddButton({
    Title = "Server Hop",
    Callback = function()
        local servers = HttpService:JSONDecode(game:HttpGet(
            string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100", PlaceId)
        ))
        for _, server in ipairs(servers.data) do
            if server.playing < server.maxPlayers and server.id ~= JobId then
                TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
                return
            end
        end
    end
})

Tabs.GameServer:AddButton({
    Title = "Low Player Server Hop",
    Callback = function()
        local cursor = ""
        while true do
            local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s",
                PlaceId, cursor ~= "" and ("&cursor=" .. cursor) or "")

            local response = HttpService:JSONDecode(game:HttpGet(url))
            for _, server in ipairs(response.data) do
                if server.playing > 0 and server.playing < server.maxPlayers and server.id ~= JobId then
                    TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
                    return
                end
            end
            if not response.nextPageCursor then break end
            cursor = response.nextPageCursor
        end
    end
})

Tabs.GameServer:AddButton({
    Title = "Rejoin",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(PlaceId, JobId, LocalPlayer)
    end
})

-- Local Player Tab
Tabs.LocalPlayer:AddSlider("WalkSpeedSlider", {
    Title = "WalkSpeed",
    Description = "Set your WalkSpeed",
    Default = 16,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = function(value)
        local character = LocalPlayer.Character
        if character and character:FindFirstChildOfClass("Humanoid") then
            character:FindFirstChildOfClass("Humanoid").WalkSpeed = value
        end
    end
})

Tabs.LocalPlayer:AddSlider("JumpPowerSlider", {
    Title = "JumpPower",
    Description = "Set your JumpPower",
    Default = 50,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = function(value)
        local character = LocalPlayer.Character
        if character and character:FindFirstChildOfClass("Humanoid") then
            character:FindFirstChildOfClass("Humanoid").JumpPower = value
        end
    end
})

Tabs.LocalPlayer:AddToggle("Auto Race V3", {
    Title = "Auto Race V3",
    Default = false,
    Callback = function(state)  -- was: function(value)
        _G.AutoRaceV3 = state    -- was: _G.AutoRaceV3 = value
    end
})

spawn(function()
    while wait() do
        pcall(function()
            if _G.AutoRaceV3 then
                game:GetService("ReplicatedStorage").Remotes.CommE:FireServer("ActivateAbility")
            end
        end)
    end
end)

Tabs.LocalPlayer:AddToggle("Auto Race V4", {
    Title = "Auto Race V4",
    Default = false,
    Callback = function(state)  -- was: function(value)
        _G.AutoRaceV4 = state    -- was: _G.AutoRaceV4 = value
    end
})

spawn(function()
    while wait() do
        pcall(function()
            if _G.AutoRaceV4 then
                local vim = game:GetService("VirtualInputManager")
                vim:SendKeyEvent(true, "Y", false, game)
                wait()
                vim:SendKeyEvent(false, "Y", false, game)
            end
        end)
    end
end)

Tabs.LocalPlayer:AddToggle("InfiniteEnergy", {
    Title = "Infinite Energy",
    Default = false,
    Callback = function(state)
        InfiniteEnergyEnabled = state
    end
})

Tabs.LocalPlayer:AddToggle("WalkOnWater", {
    Title = "Walk on Water",
    Default = false,
    Callback = function(state)
        WalkOnWaterEnabled = state
    end
})

Tabs.LocalPlayer:AddToggle("AutoHakiToggle", {
	Title = "Auto Haki",
	Default = true,
	Callback = function(state)
		if state then
			spawn(function()
				while state do
					pcall(AutoHaki)
					task.wait(1)
				end
			end)
		end
	end
})

spawn(function()
    while task.wait(0.2) do
        pcall(function()
            local water = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("WaterBase-Plane")
            if water then
                water.Size = WalkOnWaterEnabled and Vector3.new(1000, 112, 1000) or Vector3.new(1000, 80, 1000)
            end
        end)
    end
end)

local function infinitestam()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Energy") then
        local energy = char.Energy
        energy.Changed:Connect(function()
            if InfiniteEnergyEnabled and originalStamina then
                energy.Value = originalStamina
            end
        end)
    end
end

spawn(function()
    while task.wait(0.1) do
        if InfiniteEnergyEnabled then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Energy") then
                originalStamina = char.Energy.Value
                infinitestam()
            end
        end
    end
end)

-- Chest Farm Code
local MaxSpeed = 300
local UncheckedChests = {}
local FirstRun = true
local ChestFarmEnabled = false

local function getCharacter()
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    return LocalPlayer.Character
end

local function DistanceFromPlrSort(ObjectList)
    local RootPart = getCharacter().LowerTorso or getCharacter().HumanoidRootPart
    table.sort(ObjectList, function(a, b)
        return (RootPart.Position - a.Position).Magnitude < (RootPart.Position - b.Position).Magnitude
    end)
end

local function getChestsSorted()
    if FirstRun then
        FirstRun = false
        for _, obj in pairs(game:GetDescendants()) do
            if obj.Name:find("Chest") and obj:IsA("Part") then
                table.insert(UncheckedChests, obj)
            end
        end
    end
    local Chests = {}
    for _, chest in pairs(UncheckedChests) do
        if chest:FindFirstChild("TouchInterest") then
            table.insert(Chests, chest)
        end
    end
    DistanceFromPlrSort(Chests)
    return Chests
end

local function toggleNoclip(state)
    for _, v in pairs(getCharacter():GetChildren()) do
        if v:IsA("Part") then
            v.CanCollide = not state
        end
    end
end

local function Teleport(goal, speed)
    speed = speed or MaxSpeed
    toggleNoclip(true)
    local root = getCharacter().HumanoidRootPart
    local dist = (root.Position - goal.Position).Magnitude
    while ChestFarmEnabled and dist > 1 do
        local dir = (goal.Position - root.Position).Unit
        root.CFrame = root.CFrame + dir * (speed * task.wait())
        dist = (root.Position - goal.Position).Magnitude
    end
    toggleNoclip(false)
end

local function ChestFarmLoop()
    task.spawn(function()
        while true do
            task.wait()
            if not ChestFarmEnabled then continue end
            local chests = getChestsSorted()
            if #chests > 0 then
                Teleport(chests[1].CFrame, MaxSpeed)
            end
        end
    end)
end

Tabs.MainFarm:AddToggle("AutoFarmToggle", {
    Title = "Auto Farm",
    Default = false,
    Callback = function(state)
        AutoFarmEnabled = state
        _G.AutoFarm = state
        StopTween(_G.AutoFarm)
    end
})

-- Bring Mob Toggle (only used in Auto Farm)
Tabs.MainFarm:AddToggle("BringMobToggle", {
    Title = "Bring Mob (Auto Farm Only)",
    Default = true,
    Callback = function(state)
        AutoFarmBringMob = state
    end
})

-- Bring Mob Logic
spawn(function()
    while task.wait() do
        if _G.AutoFarm and AutoFarmBringMob and StartBring and MonFarm and PosMon then
            pcall(function()
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if not string.find(v.Name, "Boss") and v.Name == MonFarm and v:FindFirstChild("HumanoidRootPart") then
                        local dist = (v.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if dist <= 100 then
                            v.HumanoidRootPart.CFrame = PosMon
                            v.HumanoidRootPart.Size = Vector3.new(1, 1, 1)
                            v.HumanoidRootPart.CanCollide = false
                        end
                    end
                end
            end)
        end
    end
end)

-- Full Stellar-style Auto Farm (multi-mob attack)
spawn(function()
    while task.wait() do
        pcall(function()
            if _G.AutoFarm then
                local player = game.Players.LocalPlayer
                local questGui = player.PlayerGui:FindFirstChild("Main") and player.PlayerGui.Main:FindFirstChild("Quest")

                CheckQuest()

                if not questGui or not questGui.Visible or not questGui.Container.QuestTitle.Title.Text:find(NameMon) then
                    StartBring = false
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AbandonQuest")
                    if (player.Character.HumanoidRootPart.Position - CFrameQuest.Position).Magnitude > 2000 then
                        TP1(CFrameQuest)
                    else
                        TP1(CFrameQuest)
                    end
                    if (player.Character.HumanoidRootPart.Position - CFrameQuest.Position).Magnitude <= 20 then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", NameQuest, LevelQuest)
                        wait(0.5)
                    end
                else
                    local anyMob = false
                    for _, mob in pairs(workspace.Enemies:GetChildren()) do
                        if mob.Name == NameMon and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
                            anyMob = true
                            AutoHaki()
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            mob.HumanoidRootPart.CanCollide = false
                            mob.HumanoidRootPart.Size = Vector3.new(70, 70, 70)
                            mob.Humanoid.WalkSpeed = 0
                            mob.Head.CanCollide = false
                            PosMon = mob.HumanoidRootPart.CFrame
                            MonFarm = mob.Name
                            StartBring = true
                            game:GetService("VirtualUser"):CaptureController()
                            game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
                        end
                    end
                    if not anyMob then
                        TP1(CFrameMon)
                        StartBring = false
                    end
                end
            end
        end)
    end
end)

Tabs.MainFarm:AddDropdown("SelectWeaponDropdown", {
    Title = "Select Weapon",
    Values = {"Melee", "Sword", "Gun", "Blox Fruit"},
    Default = "Melee",
    Callback = function(value)
        _G.SelectWeapon = value
    end
})

Tabs.MainFarm:AddToggle("FastAttackToggle", {
    Title = "Fast Attack",
    Default = false,
    Callback = function(Value)
        FastAttackEnabled = Value
    end
})

Tabs.MainFarm:AddToggle("BringMobToggle", {
    Title = "Auto Bring Mob",
    Default = false,
    Callback = function(value)
        BringMobEnabled = value
    end
})

Tabs.MainFarm:AddToggle("ChestFarmToggle", {
    Title = "Chest Farm Tween",
    Default = false,
    Callback = function(state)
        ChestFarmEnabled = state
        if state then
            ChestFarmLoop()
        end
    end
})

Tabs.MainFarm:AddSlider("ChestFarmSpeedSlider", {
    Title = "Chest Speed",
    Description = "Set chest teleport speed",
    Default = 300,
    Min = 50,
    Max = 300,
    Rounding = 0,
    Callback = function(value)
        MaxSpeed = value
    end
})

local PointStats = 1
local melee, defense, sword, gun, demonfruit = false, false, false, false, false

Tabs.SubClass:AddToggle("melee", {
    Title = "Auto stats melee",
    Default = false,
    Callback = function(value)
        melee = value
    end
})

Tabs.SubClass:AddToggle("defense", {
    Title = "Auto stats defense",
    Default = false,
    Callback = function(value)
        defense = value
    end
})

Tabs.SubClass:AddToggle("sword", {
    Title = "Auto stats sword",
    Default = false,
    Callback = function(value)
        sword = value
    end
})

Tabs.SubClass:AddToggle("gun", {
    Title = "Auto stats gun",
    Default = false,
    Callback = function(value)
        gun = value
    end
})

Tabs.SubClass:AddToggle("demonfruit", {
    Title = "Auto stats demonfruit",
    Default = false,
    Callback = function(value)
        demonfruit = value
    end
})

spawn(function()
    while task.wait(1) do
        pcall(function()
            local stats = game:GetService("Players").LocalPlayer.Data.Stats
            local points = game:GetService("Players").LocalPlayer.Data.Points.Value
            if points >= PointStats then
                if melee then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AddPoint", "Melee", PointStats)
                end
                if defense then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AddPoint", "Defense", PointStats)
                end
                if sword then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AddPoint", "Sword", PointStats)
                end
                if gun then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AddPoint", "Gun", PointStats)
                end
                if demonfruit then
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AddPoint", "Demon Fruit", PointStats)
                end
            end
        end)
    end
end)

local function CreateESP(part, text, color)
    if part:FindFirstChild("FruitESP") then return end
    local esp = Instance.new("BillboardGui")
    esp.Name = "FruitESP"
    esp.Adornee = part
    esp.Size = UDim2.new(0, 100, 0, 40)
    esp.StudsOffset = Vector3.new(0, 2, 0)
    esp.AlwaysOnTop = true

    local label = Instance.new("TextLabel", esp)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.5
    label.TextScaled = true
    esp.Parent = part
end

-- Util: Get Distance
local function GetDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

-- ESP Logic Loop
local function FruitESPScan()
    task.spawn(function()
        while true do
            task.wait(1)
            if not FruitESPEnabled then continue end

            local hrp = getCharacter():FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            for _, fruit in pairs(workspace:GetChildren()) do
                if string.find(fruit.Name, "Fruit") and fruit:FindFirstChild("Handle") then
                    local handle = fruit.Handle
                    local distance = GetDistance(hrp.Position, handle.Position)
                    CreateESP(handle, fruit.Name .. "\n[" .. math.floor(distance) .. " studs]", Color3.fromRGB(0, 255, 255))
                end
            end
        end
    end)
end

Tabs.Fruit:AddToggle("FruitESP", {
    Title = "Fruit ESP",
    Default = false,
    Callback = function(state)
        FruitESPEnabled = state
        if state then
            FruitESPScan()
        end
    end
})

Tabs.Fruit:AddToggle("AutoStoreFruit", {
    Title = "Auto Store Fruit",
    Default = false,
    Callback = function(value)
        AutoStoreFruitEnabled = value
    end
})

Tabs.Fruit:AddToggle("FruitNotification", {
    Title = "Fruit Notification",
    Default = false,
    Callback = function(value)
        FruitNotificationEnabled = value
    end
})

Tabs.Fruit:AddToggle("Tween To Fruit", {
    Title = "Tween To Fruit",
    Default = false,
    Callback = function(value)
        _G.TweenFruit = value
    end
})

spawn(function()
    while wait(0.1) do
        if _G.TweenFruit then
            for i, v in pairs(game.Workspace:GetChildren()) do
                if string.find(v.Name, "Fruit") then
                    if v:FindFirstChild("Handle") then
                        TP1(v.Handle.CFrame)
                    end
                end
            end
        end
    end
end)

Tabs.Fruit:AddToggle("Auto Grab Fruit", {
    Title = "Auto Grab Fruit",
    Default = false,
    Callback = function(value)
        _G.Grabfruit = value
    end
})

spawn(function()
    while wait(0.1) do
        if _G.Grabfruit then
            for i, v in pairs(game.Workspace:GetChildren()) do
                if string.find(v.Name, "Fruit") and v:FindFirstChild("Handle") then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Handle.CFrame
                end
            end
        end
    end
end)

Tabs.Fruit:AddButton({
    Title = "Grab All Fruits",
    Callback = function()
        for i, v in pairs(game.Workspace:GetChildren()) do
            if v:IsA("Tool") and v:FindFirstChild("Handle") then
                v.Handle.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        end
    end
})

local function CheckFruits()
    ResultStoreFruits = {}
    local success, fruits = pcall(function()
        return game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("getInventoryFruits")
    end)
    if success and type(fruits) == "table" then
        for _, fruit in ipairs(fruits) do
            table.insert(ResultStoreFruits, fruit)
        end
    end
end

spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if AutoStoreFruitEnabled then
                CheckFruits()
                for _, fruit in ipairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                    if fruit:IsA("Tool") and string.find(fruit.Name, "Fruit") then
                        for _, invFruit in ipairs(ResultStoreFruits) do
                            if fruit.Name == invFruit then
                                local success, err = pcall(function()
                                    local nameClean = string.gsub(fruit.Name, " Fruit", "")
                                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", nameClean .. "-" .. nameClean, fruit)
                                end)
                                if not success then
                                    warn("Failed to store fruit:", err)
                                end
                                break
                            end
                        end
                    end
                end
            end
        end)
    end
end)

spawn(function()
    while task.wait(2) do
        if FruitNotificationEnabled then
            for _, v in pairs(game.Workspace:GetChildren()) do
                if string.find(v.Name, "Fruit") then
                    Fluent:Notify({ Title = "Fruit Spawned", Content = "Fruit: " .. v.Name, Duration = 3 })
                end
            end
        end
    end
end)

Tabs.Fruit:AddButton({
    Title = "Open Devil Shop",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("GetFruits")
        game:GetService("Players").LocalPlayer.PlayerGui.Main.FruitShop.Visible = true
    end
})

local function ChestESPScan()
    task.spawn(function()
        while true do
            task.wait(1)
            if not ChestESPEnabled then continue end

            local hrp = getCharacter():FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            for _, chest in pairs(workspace:GetChildren()) do
                if string.find(chest.Name, "Chest") and chest:FindFirstChild("TouchInterest") then
                    local distance = GetDistance(hrp.Position, chest.Position)
                    CreateESP(
                        chest,
                        chest.Name .. "\n[" .. math.floor(distance) .. " studs]",
                        Color3.new(0, 1, 0)
                    )
                end
            end
        end
    end)
end

local function round(n)
    return math.floor(n + 0.5)
end

local function ClearPlayerESP()
    for _, gui in pairs(PlayerESPObjects) do
        if gui and gui.Parent then
            gui:Destroy()
        end
    end
    PlayerESPObjects = {}
end

local function PlayerESPScan()
    task.spawn(function()
        while true do
            task.wait(1)
            if not PlayerESPEnabled then
                ClearPlayerESP()
                continue
            end

            for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                    local head = player.Character.Head
                    if not head:FindFirstChild("PlayerESP") then
                        local bill = Instance.new("BillboardGui")
                        bill.Name = "PlayerESP"
                        bill.ExtentsOffset = Vector3.new(0, 1.5, 0)
                        bill.Size = UDim2.new(0, 200, 0, 40)
                        bill.Adornee = head
                        bill.AlwaysOnTop = true
                        bill.Parent = head

                        local name = Instance.new("TextLabel")
                        name.Name = "ESPLabel"
                        name.Font = Enum.Font.GothamSemibold
                        name.TextWrapped = true
                        name.TextScaled = true
                        name.Size = UDim2.new(1, 0, 1, 0)
                        name.BackgroundTransparency = 1
                        name.TextStrokeTransparency = 0.5
                        name.TextYAlignment = Enum.TextYAlignment.Top
                        name.Parent = bill

                        PlayerESPObjects[#PlayerESPObjects + 1] = bill
                    end

                    local label = head:FindFirstChild("PlayerESP") and head.PlayerESP:FindFirstChild("ESPLabel")
                    if label then
                        local dist = (LocalPlayer.Character.Head.Position - head.Position).Magnitude
                        local healthPercent = player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth * 100 or 0
                        label.Text = player.Name .. "\n" .. round(dist) .. " studs | HP: " .. round(healthPercent) .. "%"
                        label.TextColor3 = (player.Team == LocalPlayer.Team) and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
                    end
                end
            end
        end
    end)
end

Tabs.PlayerStatus:AddToggle("PlayerESP", {
    Title = "Player ESP",
    Default = false,
    Callback = function(state)
        PlayerESPEnabled = state
        if state then
            PlayerESPScan()
        else
            ClearPlayerESP()
        end
    end
})

local function ClearIslandESP()
    for _, gui in pairs(IslandESPObjects) do
        if gui and gui.Parent then
            gui:Destroy()
        end
    end
    IslandESPObjects = {}
end

local function IslandESPScan()
    task.spawn(function()
        while true do
            task.wait(1)
            if not IslandESPEnabled then
                ClearIslandESP()
                continue
            end

            for _, v in pairs(game:GetService("Workspace")._WorldOrigin.Locations:GetChildren()) do
                if v.Name ~= "Sea" then
                    if not v:FindFirstChild("IslandESP") then
                        local bill = Instance.new("BillboardGui")
                        bill.Name = "IslandESP"
                        bill.ExtentsOffset = Vector3.new(0, 1, 0)
                        bill.Size = UDim2.new(0, 200, 0, 30)
                        bill.Adornee = v
                        bill.AlwaysOnTop = true
                        bill.Parent = v

                        local name = Instance.new("TextLabel")
                        name.Name = "ESPLabel"
                        name.Font = Enum.Font.GothamMedium
                        name.TextSize = 14
                        name.TextWrapped = true
                        name.Size = UDim2.new(1, 0, 1, 0)
                        name.TextYAlignment = Enum.TextYAlignment.Top
                        name.BackgroundTransparency = 1
                        name.TextColor3 = Color3.fromRGB(255, 255, 255)
                        name.Parent = bill

                        IslandESPObjects[#IslandESPObjects + 1] = bill
                    end

                    local label = v:FindFirstChild("IslandESP") and v.IslandESP:FindFirstChild("ESPLabel")
                    if label then
                        local dist = (LocalPlayer.Character.Head.Position - v.Position).Magnitude
                        label.Text = v.Name .. "\n" .. round(dist) .. " studs"
                    end
                end
            end
        end
    end)
end

Tabs.Travel:AddButton({
    Title = "Teleport To First Sea",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("TravelMain")
    end
})

Tabs.Travel:AddButton({
    Title = "Teleport To Second Sea",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("TravelDressrosa")
    end
})

Tabs.Travel:AddButton({
    Title = "Teleport To Third Sea",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("TravelZou")
    end
})

Tabs.Travel:AddParagraph({ Title = "Tween Island", Content = "Teleport to Island" })

Tabs.Travel:AddDropdown("SelectIslandDropdown", {
    Title = "Select Island",
    Values = (World1 and {"WindMill","Marine","Middle Town","Jungle","Pirate Village","Desert","Snow Island","MarineFord","Colosseum","Sky Island 1","Sky Island 2","Sky Island 3","Prison","Magma Village","Under Water Island","Fountain City","Shank Room","Mob Island"})
        or (World2 and {"The Cafe","Frist Spot","Dark Area","Flamingo Mansion","Flamingo Room","Green Zone","Factory","Colossuim","Zombie Island","Two Snow Mountain","Punk Hazard","Cursed Ship","Ice Castle","Forgotten Island","Ussop Island","Mini Sky Island"})
        or (World3 and {"Mansion","Port Town","Great Tree","Castle On The Sea","MiniSky","Hydra Island","Floating Turtle","Haunted Castle","Ice Cream Island","Peanut Island","Cake Island","Cocoa Island","Candy Island","Tiki Outpost"}),
    Default = "WindMill",
    Callback = function(value)
        _G.SelectIsland = value
    end
})

Tabs.Travel:AddToggle("AutoTweenIsland", {
    Title = "Auto Tween To Island",
    Default = false,
    Callback = function(value)
        _G.TeleportIsland = value
        if value then
            spawn(function()
                repeat wait()
                    local posMap = {
                        ["WindMill"] = CFrame.new(979.79895019531, 16.516613006592, 1429.0466308594),
                        ["Marine"] = CFrame.new(-2566.4296875, 6.8556680679321, 2045.2561035156),
                        ["Middle Town"] = CFrame.new(-690.33081054688, 15.09425163269, 1582.2380371094),
                        ["Jungle"] = CFrame.new(-1612.7957763672, 36.852081298828, 149.12843322754),
                        ["Pirate Village"] = CFrame.new(-1181.3093261719, 4.7514905929565, 3803.5456542969),
                        ["Desert"] = CFrame.new(944.15789794922, 20.919729232788, 4373.3002929688),
                        ["Snow Island"] = CFrame.new(1347.8067626953, 104.66806030273, -1319.7370605469),
                        ["MarineFord"] = CFrame.new(-4914.8212890625, 50.963626861572, 4281.0278320313),
                        ["Colosseum"] = CFrame.new(-1427.6203613281, 7.2881078720093, -2792.7722167969),
                        ["Sky Island 1"] = CFrame.new(-4869.1025390625, 733.46051025391, -2667.0180664063),
                        ["Prison"] = CFrame.new(4875.330078125, 5.6519818305969, 734.85021972656),
                        ["Magma Village"] = CFrame.new(-5247.7163085938, 12.883934020996, 8504.96875),
                        ["Fountain City"] = CFrame.new(5127.1284179688, 59.501365661621, 4105.4458007813),
                        ["Shank Room"] = CFrame.new(-1442.16553, 29.8788261, -28.3547478),
                        ["Mob Island"] = CFrame.new(-2850.20068, 7.39224768, 5354.99268),
                        ["The Cafe"] = CFrame.new(-380.47927856445, 77.220390319824, 255.82550048828),
                        ["Frist Spot"] = CFrame.new(-11.311455726624, 29.276733398438, 2771.5224609375),
                        ["Dark Area"] = CFrame.new(3780.0302734375, 22.652164459229, -3498.5859375),
                        ["Flamingo Mansion"] = CFrame.new(-483.73370361328, 332.0383605957, 595.32708740234),
                        ["Flamingo Room"] = CFrame.new(2284.4140625, 15.152037620544, 875.72534179688),
                        ["Green Zone"] = CFrame.new(-2448.5300292969, 73.016105651855, -3210.6306152344),
                        ["Factory"] = CFrame.new(424.12698364258, 211.16171264648, -427.54049682617),
                        ["Colossuim"] = CFrame.new(-1503.6224365234, 219.7956237793, 1369.3101806641),
                        ["Zombie Island"] = CFrame.new(-5622.033203125, 492.19604492188, -781.78552246094),
                        ["Two Snow Mountain"] = CFrame.new(753.14288330078, 408.23559570313, -5274.6147460938),
                        ["Punk Hazard"] = CFrame.new(-6127.654296875, 15.951762199402, -5040.2861328125),
                        ["Cursed Ship"] = CFrame.new(923.40197753906, 125.05712890625, 32885.875),
                        ["Ice Castle"] = CFrame.new(6148.4116210938, 294.38687133789, -6741.1166992188),
                        ["Forgotten Island"] = CFrame.new(-3032.7641601563, 317.89672851563, -10075.373046875),
                        ["Ussop Island"] = CFrame.new(4816.8618164063, 8.4599885940552, 2863.8195800781),
                        ["Mini Sky Island"] = CFrame.new(-288.74060058594, 49326.31640625, -35248.59375),
                        ["Great Tree"] = CFrame.new(2681.2736816406, 1682.8092041016, -7190.9853515625),
                        ["Castle On The Sea"] = CFrame.new(-5074.45556640625, 314.5155334472656, -2991.054443359375),
                        ["MiniSky"] = CFrame.new(-260.65557861328, 49325.8046875, -35253.5703125),
                        ["Port Town"] = CFrame.new(-290.7376708984375, 6.729952812194824, 5343.5537109375),
                        ["Hydra Island"] = CFrame.new(5255.1049, 1004.1949, 344.7700),
                        ["Floating Turtle"] = CFrame.new(-13274.528320313, 531.82073974609, -7579.22265625),
                        ["Haunted Castle"] = CFrame.new(-9515.3720703125, 164.00624084473, 5786.0610351562),
                        ["Ice Cream Island"] = CFrame.new(-902.56817626953, 79.93204498291, -10988.84765625),
                        ["Peanut Island"] = CFrame.new(-2062.7475585938, 50.473892211914, -10232.568359375),
                        ["Cake Island"] = CFrame.new(-1884.7747802734375, 19.327526092529297, -11666.8974609375),
                        ["Cocoa Island"] = CFrame.new(87.94276428222656, 73.55451202392578, -12319.46484375),
                        ["Candy Island"] = CFrame.new(-1014.4241943359375, 149.11068725585938, -14555.962890625),
                        ["Tiki Outpost"] = CFrame.new(-16218.6826, 9.08636189, 445.618408)
                    }
                    local selected = _G.SelectIsland
                    if posMap[selected] then
                        topos(posMap[selected])
                    elseif selected == "Sky Island 2" then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(-4607.82275, 872.54248, -1667.55688))
                    elseif selected == "Sky Island 3" then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047))
                    elseif selected == "Under Water Island" then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(61163.8515625, 11.6796875, 1819.7841796875))
                    elseif selected == "Mansion" then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(-12471.169921875, 374.94024658203, -7551.677734375))
                    end
                until not _G.TeleportIsland
            end)
        end
    end
})

Tabs.Travel:AddParagraph({ Title = "Tween NPC", Content = "Teleport to NPCs" })

Tabs.Travel:AddDropdown("SelectNPCDropdown", {
    Title = "Select NPC",
    Values = (World1 and {"Random Devil Fruit","Blox Fruits Dealer","Remove Devil Fruit","Ability Teacher","Dark Step","Electro","Fishman Karate"})
        or (World2 and {"Dargon Berath","Mtsterious Man","Mysterious Scientist","Awakening Expert","Nerd","Bar Manager","Blox Fruits Dealer","Trevor","Enhancement Editor","Pirate Recruiter","Marines Recruiter","Chemist","Cyborg","Ghoul Mark","Guashiem","El Admin","El Rodolfo","Arowe"})
        or (World3 and {"Blox Fruits Dealer","Remove Devil Fruit","Horned Man","Hungey Man","Previous Hero","Butler","Lunoven","Trevor","Elite Hunter","Player Hunter","Uzoth"}),
    Default = "Blox Fruits Dealer",
    Callback = function(value)
        _G.SelectNPC = value
    end
})

Tabs.Travel:AddToggle("AutoTeleportNPC", {
    Title = "Auto Teleporter Npc",
    Default = false,
    Callback = function(value)
        _G.TeleportNPC = value
        if value then
            spawn(function()
                repeat wait()
                    local npcMap = {
                        ["Dargon Berath"] = CFrame.new(703.372986, 186.985519, 654.522034),
                        ["Mtsterious Man"] = CFrame.new(-2574.43335, 1627.92371, -3739.35767),
                        ["Mysterious Scientist"] = CFrame.new(-6437.87793, 250.645355, -4498.92773),
                        ["Awakening Expert"] = CFrame.new(-408.098846, 16.0459061, 247.432846),
                        ["Nerd"] = CFrame.new(-401.783722, 73.0859299, 262.306702),
                        ["Bar Manager"] = CFrame.new(-385.84726, 73.0458984, 316.088806),
                        ["Blox Fruits Dealer"] = CFrame.new(-450.725464, 73.0458984, 355.636902),
                        ["Trevor"] = CFrame.new(-341.498322, 331.886444, 643.024963),
                        ["Plokster"] = CFrame.new(-1885.16016, 88.3838196, -1912.28723),
                        ["Enhancement Editor"] = CFrame.new(-346.820221, 72.9856339, 1194.36218),
                        ["Pirate Recruiter"] = CFrame.new(-428.072998, 72.9495239, 1445.32422),
                        ["Marines Recruiter"] = CFrame.new(-1349.77295, 72.9853363, -1045.12964),
                        ["Chemist"] = CFrame.new(-2777.45288, 72.9919434, -3572.25732),
                        ["Ghoul Mark"] = CFrame.new(635.172546, 125.976357, 33219.832),
                        ["Cyborg"] = CFrame.new(629.146851, 312.307373, -531.624146),
                        ["Guashiem"] = CFrame.new(937.953003, 181.083359, 33277.9297),
                        ["El Admin"] = CFrame.new(1322.80835, 126.345039, 33135.8789),
                        ["El Rodolfo"] = CFrame.new(941.228699, 40.4686775, 32778.9922),
                        ["Arowe"] = CFrame.new(-1994.51038, 125.519142, -72.2622986),
                        ["Random Devil Fruit"] = CFrame.new(-1436.19727, 61.8777695, 4.75247526),
                        ["Remove Devil Fruit"] = CFrame.new(5664.80469, 64.677681, 867.85907),
                        ["Ability Teacher"] = CFrame.new(-1057.67822, 9.65220833, 1799.49146),
                        ["Dark Step"] = CFrame.new(-987.873047, 13.7778397, 3989.4978),
                        ["Electro"] = CFrame.new(-5389.49561, 13.283, -2149.80151),
                        ["Fishman Karate"] = CFrame.new(61581.8047, 18.8965912, 987.832703),
                        ["Horned Man"] = CFrame.new(-11890, 931, -8760),
                        ["Hungey Man"] = CFrame.new(-10919, 624, -10268),
                        ["Previous Hero"] = CFrame.new(-10368, 332, -10128),
                        ["Butler"] = CFrame.new(-5125, 316, -3130),
                        ["Lunoven"] = CFrame.new(-5117, 316, -3093),
                        ["Elite Hunter"] = CFrame.new(-5420, 314, -2828),
                        ["Player Hunter"] = CFrame.new(-5559, 314, -2840),
                        ["Uzoth"] = CFrame.new(-9785, 852, 6667)
                    }
                    local cf = npcMap[_G.SelectNPC]
                    if cf then
                        topos(cf)
                    end
                until not _G.TeleportNPC
            end)
        end
    end
})


Tabs.Travel:AddToggle("IslandESP", {
    Title = "Island ESP",
    Default = false,
    Callback = function(state)
        IslandESPEnabled = state
        if state then
            IslandESPScan()
        else
            ClearIslandESP()
        end
    end
})

Tabs.Race:AddButton({
    Title = "Teleport To Top GreatTree",
    Callback = function()
        topos(CFrame.new(3030.39453125, 2280.6171875, -7320.18359375))
    end
})

Tabs.Race:AddButton({
    Title = "Teleport Temple Of Time",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(28286.35546875, 14895.3017578125, 102.62469482421875))
    end
})

Tabs.Race:AddButton({
    Title = "Teleport Lever Pull",
    Callback = function()
        topos(CFrame.new(28575.181640625, 14936.6279296875, 72.31636810302734))
    end
})

Tabs.Race:AddButton({
    Title = "Teleport To The Clock",
    Callback = function()
        topos(CFrame.new(29553.7812, 15066.6133, -88.2750015, 1, 0, 0, 0, 1, 0, 0, 0, 1))
    end
})

Tabs.Race:AddButton({
    Title = "Auto Race Door",
    Callback = function()
        local raceDoorCFrame = CFrame.new(28286.35546875, 14895.3017578125, 102.62469482421875)
        local player = game:GetService("Players").LocalPlayer
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

        if hrp then
            for i = 1, 4 do
                hrp.CFrame = raceDoorCFrame
                wait(0.1)
            end
        end

        wait(0.5)

        local race = player.Data.Race.Value
        local raceDestinations = {
            ["Human"]   = CFrame.new(29221.822, 14890.975, -205.991),
            ["Skypiea"] = CFrame.new(28960.158, 14919.624, 235.039),
            ["Fishman"] = CFrame.new(28231.175, 14890.975, -211.641),
            ["Cyborg"]  = CFrame.new(28502.681, 14895.975, -423.728),
            ["Ghoul"]   = CFrame.new(28674.244, 14890.676, 445.431),
            ["Mink"]    = CFrame.new(29012.342, 14890.975, -380.149),
        }

        if raceDestinations[race] then
            topos(raceDestinations[race])
        end
    end
})

Tabs.Race:AddButton({
    Title = "Buy Acient One Quest",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer('UpgradeRace','Buy')
    end
})

local TempleStatusBtn = Tabs.Race:AddButton({
    Title = "Temple Door Status",
    Description = "Checking...",
    Callback = function() end -- it's just a dummy status display
})

spawn(function()
    while task.wait(2) do
        local success, result = pcall(function()
            return game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CheckTempleDoor")
        end)
        if TempleStatusBtn and typeof(TempleStatusBtn.SetDesc) == "function" then
            if success then
                TempleStatusBtn:SetDesc("Pull Level: " .. (result and "Done ✅" or "Not Ready ❌"))
            else
                TempleStatusBtn:SetDesc("Pull Level: Error ⚠️")
            end
        end
    end
end)

local FullMoonBtn = Tabs.Race:AddButton({
    Title = "Full Moon Status",
    Description = "Checking...",
    Callback = function() end -- purely status display
})

spawn(function()
    while task.wait(2) do
        pcall(function()
            local moonId = game:GetService("Lighting").Sky.MoonTextureId
            local percent = ({
                ["http://www.roblox.com/asset/?id=9709149431"] = "100",
                ["http://www.roblox.com/asset/?id=9709149052"] = "75",
                ["http://www.roblox.com/asset/?id=9709143733"] = "50",
                ["http://www.roblox.com/asset/?id=9709150401"] = "25",
                ["http://www.roblox.com/asset/?id=9709149680"] = "15"
            })[moonId] or "0"
            FullMoonBtn:SetDesc("Full Moon: " .. percent .. "%")
        end)
    end
end)

local MirageBtn = Tabs.Status:AddButton({
    Title = "Mirage Island Status",
    Description = "Checking...",
    Callback = function() end
})

spawn(function()
    while task.wait(2) do
        pcall(function()
            local isVisible = workspace._WorldOrigin:FindFirstChild("Locations")
                and workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island")

            if MirageBtn and typeof(MirageBtn.SetDesc) == "function" then
                MirageBtn:SetDesc(isVisible and "Mirage Island is Spawning ✅" or "Mirage Island Is Not Spawned ❌")
            end
        end)
    end
end)

local KitsuneBtn = Tabs.Status:AddButton({
    Title = "Kitsune Island Status",
    Description = "Checking...",
    Callback = function() end
})

spawn(function()
    while task.wait(2) do
        pcall(function()
            local map = workspace:FindFirstChild("Map")
            local island = map and map:FindFirstChild("KitsuneIsland")

            if KitsuneBtn and typeof(KitsuneBtn.SetDesc) == "function" then
                KitsuneBtn:SetDesc(island and "Kitsune Island Spawning ✅" or "Kitsune Island Is Not Spawned ❌")
            end
        end)
    end
end)

local PrehistoricBtn = Tabs.Status:AddButton({
    Title = "Prehistoric Island Status",
    Description = "Checking...",
    Callback = function() end
})

spawn(function()
    while task.wait(2) do
        pcall(function()
            local map = workspace:FindFirstChild("Map")
            local island = map and map:FindFirstChild("PrehistoricIsland")

            if PrehistoricBtn and typeof(PrehistoricBtn.SetDesc) == "function" then
                PrehistoricBtn:SetDesc(island and "Prehistoric Island Is Spawning ✅" or "Prehistoric Island Is Not Spawned ❌")
            end
        end)
    end
end)

Tabs.MainFarm:AddToggle("ChestESP", {
    Title = "Chest ESP",
    Default = false,
    Callback = function(state)
        ChestESPEnabled = state
        if state then
            ChestESPScan()
        end
    end
})

Tabs.Shop:AddButton({
    Title = "Buy Geppo [ $10,000 ]",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyHaki", "Geppo")
    end
})

Tabs.Shop:AddButton({
    Title = "Buy Buso Haki [ $25,000 ]",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyHaki", "Buso")
    end
})

Tabs.Shop:AddButton({
    Title = "Buy Soru [ $25,000 ]",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyHaki", "Soru")
    end
})

Tabs.Shop:AddButton({
    Title = "Buy Observation Haki [ $750,000 ]",
    Callback = function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("KenTalk", "Buy")
    end
})

-- Addons
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("LeywinBF")
SaveManager:SetFolder("LeywinBF/specific-game")
Window:SelectTab(14)

Fluent:Notify({
    Title = "Leywin",
    Content = "The script has been loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
