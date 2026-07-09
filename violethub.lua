--[[
═══════════════════════════════════════════════════════════════
💜 VIOLET HUB - ELITE EDITION 💜
Versão: 4.2.2 (ANTI-CRASH, CUSTOM NOTIFIER & FRIEND CHECK)
═══════════════════════════════════════════════════════════════
]]

local function InitVioletHub()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")

    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera

    local Settings = {
        Combat = {
            Enabled = false,
            TeamCheck = false,
            FriendCheck = false, -- [NOVO] Adicionado Friend Check no Combate
            WallCheck = false,
            TargetPart = "Head",
            FovSize = 100,
            ShowFov = false,
            Smoothness = 0.5
        },
        Visuals = {
            Highlight = false,
            Names = false,
            Tracers = false,
            TeamCheck = false,
            FriendCheck = false -- [NOVO] Adicionado Friend Check no Visual
        },
        UI = {
            Theme = {
                Main = Color3.fromRGB(15, 12, 20),      
                Header = Color3.fromRGB(25, 18, 35),    
                Accent = Color3.fromRGB(160, 60, 255),  
                Text = Color3.fromRGB(245, 245, 255),   
                TextDim = Color3.fromRGB(160, 160, 180) 
            },
            Open = true
        }
    }

    -- // SISTEMA DE GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VioletHub_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true 

    local guiSuccess = pcall(function() ScreenGui.Parent = CoreGui end)
    if not guiSuccess then  
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")  
    end  

    -- // SISTEMA DE NOTIFICAÇÃO CUSTOMIZADO (Não depende do Roblox Core)
    local NotifyContainer = Instance.new("Frame", ScreenGui)
    NotifyContainer.BackgroundTransparency = 1
    NotifyContainer.Size = UDim2.new(0, 300, 1, -20)
    NotifyContainer.Position = UDim2.new(1, -320, 0, 10)
    
    local NotifyLayout = Instance.new("UIListLayout", NotifyContainer)
    NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifyLayout.Padding = UDim.new(0, 10)

    local function CustomNotify(title, text, duration)
        local Notif = Instance.new("Frame", NotifyContainer)
        Notif.Size = UDim2.new(1, 0, 0, 60)
        Notif.BackgroundColor3 = Settings.UI.Theme.Main
        Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 8)
        
        local Stroke = Instance.new("UIStroke", Notif)
        Stroke.Color = Settings.UI.Theme.Accent
        Stroke.Thickness = 1.5

        local TitleLbl = Instance.new("TextLabel", Notif)
        TitleLbl.Size = UDim2.new(1, -10, 0, 20)
        TitleLbl.Position = UDim2.new(0, 10, 0, 5)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Text = title
        TitleLbl.TextColor3 = Settings.UI.Theme.Accent
        TitleLbl.Font = Enum.Font.GothamBold
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

        local TextLbl = Instance.new("TextLabel", Notif)
        TextLbl.Size = UDim2.new(1, -20, 0, 30)
        TextLbl.Position = UDim2.new(0, 10, 0, 25)
        TextLbl.BackgroundTransparency = 1
        TextLbl.Text = text
        TextLbl.TextColor3 = Settings.UI.Theme.Text
        TextLbl.Font = Enum.Font.Gotham
        TextLbl.TextXAlignment = Enum.TextXAlignment.Left
        TextLbl.TextWrapped = true

        Notif.Position = UDim2.new(1, 50, 0, 0)
        TweenService:Create(Notif, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()

        task.delay(duration or 5, function()
            local fade = TweenService:Create(Notif, TweenInfo.new(0.5), {BackgroundTransparency = 1})
            TweenService:Create(Stroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
            TweenService:Create(TitleLbl, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
            TweenService:Create(TextLbl, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
            fade:Play()
            fade.Completed:Wait()
            Notif:Destroy()
        end)
    end

    -- FOV NATIVO E CENTRALIZADO
    local FovContainer = Instance.new("Frame", ScreenGui)
    FovContainer.Name = "FOV_Container"
    FovContainer.BackgroundTransparency = 1
    FovContainer.AnchorPoint = Vector2.new(0.5, 0.5) 
    FovContainer.Position = UDim2.new(0, Camera.ViewportSize.X / 2, 0, Camera.ViewportSize.Y / 2) 
    FovContainer.Size = UDim2.fromOffset(Settings.Combat.FovSize * 2, Settings.Combat.FovSize * 2)
    FovContainer.Visible = false

    local FovStroke = Instance.new("UIStroke", FovContainer)
    FovStroke.Color = Settings.UI.Theme.Accent
    FovStroke.Thickness = 1.5
    FovStroke.Transparency = 0.3
    Instance.new("UICorner", FovContainer).CornerRadius = UDim.new(1, 0) 

    -- Interface Principal  
    local MainFrame = Instance.new("Frame")  
    MainFrame.Name = "MainFrame"  
    MainFrame.Size = UDim2.fromOffset(420, 340) 
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)  
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)  
    MainFrame.BackgroundColor3 = Settings.UI.Theme.Main  
    MainFrame.BorderSizePixel = 0  
    MainFrame.Parent = ScreenGui  

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)  
    local UIStroke = Instance.new("UIStroke", MainFrame)  
    UIStroke.Color = Settings.UI.Theme.Accent  
    UIStroke.Thickness = 1.5  

    local TopBar = Instance.new("Frame", MainFrame)  
    TopBar.Size = UDim2.new(1, 0, 0, 45)  
    TopBar.BackgroundColor3 = Settings.UI.Theme.Header  
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)  
      
    local Filler = Instance.new("Frame", TopBar)  
    Filler.Size = UDim2.new(1, 0, 0, 10)  
    Filler.Position = UDim2.new(0, 0, 1, -10)  
    Filler.BackgroundColor3 = Settings.UI.Theme.Header  
    Filler.BorderSizePixel = 0  

    local Title = Instance.new("TextLabel", TopBar)  
    Title.Text = "VIOLET HUB <font color='rgb(160,60,255)'>ELITE</font>"  
    Title.RichText = true  
    Title.Size = UDim2.new(1, -50, 1, 0)  
    Title.Position = UDim2.new(0, 15, 0, 0)  
    Title.BackgroundTransparency = 1  
    Title.TextColor3 = Settings.UI.Theme.Text  
    Title.Font = Enum.Font.GothamBlack  
    Title.TextSize = 16  
    Title.TextXAlignment = Enum.TextXAlignment.Left  

    local CloseBtn = Instance.new("TextButton", TopBar)  
    CloseBtn.Size = UDim2.fromOffset(28, 28)  
    CloseBtn.Position = UDim2.new(1, -38, 0.5, -14)  
    CloseBtn.BackgroundColor3 = Settings.UI.Theme.Accent  
    CloseBtn.Text = "X"  
    CloseBtn.TextColor3 = Color3.new(1,1,1)  
    CloseBtn.Font = Enum.Font.GothamBold  
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)  

    local TabContainer = Instance.new("Frame", MainFrame)  
    TabContainer.Size = UDim2.new(0, 120, 1, -55)  
    TabContainer.Position = UDim2.new(0, 10, 0, 50)  
    TabContainer.BackgroundColor3 = Settings.UI.Theme.Header  
    TabContainer.BorderSizePixel = 0  
    Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 6)  
      
    local TabList = Instance.new("UIListLayout", TabContainer)  
    TabList.Padding = UDim.new(0, 6)  
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center  
    Instance.new("UIPadding", TabContainer).PaddingTop = UDim.new(0, 10)  

    local PageContainer = Instance.new("Frame", MainFrame)  
    PageContainer.Size = UDim2.new(1, -145, 1, -55)  
    PageContainer.Position = UDim2.new(0, 135, 0, 50)  
    PageContainer.BackgroundTransparency = 1  

    local OpenBtn = Instance.new("TextButton", ScreenGui)  
    OpenBtn.Size = UDim2.fromOffset(45, 45)  
    OpenBtn.Position = UDim2.new(0.05, 0, 0.1, 0)  
    OpenBtn.BackgroundColor3 = Settings.UI.Theme.Main  
    OpenBtn.Text = "💜"  
    OpenBtn.TextSize = 20  
    OpenBtn.Visible = false 
    Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 12)  
    Instance.new("UIStroke", OpenBtn).Color = Settings.UI.Theme.Accent  
    OpenBtn.UIStroke.Thickness = 1.5  

    local function MakeDraggable(obj, handle)  
        local dragging, dragInput, dragStart, startPos  
        handle.InputBegan:Connect(function(input)  
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then  
                dragging = true  
                dragStart = input.Position  
                startPos = obj.Position  
            end  
        end)  
        handle.InputEnded:Connect(function(input)  
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then  
                dragging = false  
            end  
        end)  
        UserInputService.InputChanged:Connect(function(input)  
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then  
                local delta = input.Position - dragStart  
                obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)  
            end  
        end)  
    end  
    MakeDraggable(MainFrame, TopBar)  
    MakeDraggable(OpenBtn, OpenBtn)  

    local function ToggleMenu()  
        Settings.UI.Open = not Settings.UI.Open  
        MainFrame.Visible = Settings.UI.Open  
        OpenBtn.Visible = not Settings.UI.Open  
    end  

    CloseBtn.MouseButton1Click:Connect(ToggleMenu)  
    OpenBtn.MouseButton1Click:Connect(ToggleMenu)  

    local function CreatePage(name)
        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Name = name
        Page.Size = UDim2.fromScale(1, 1)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.Visible = false
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.BorderSizePixel = 0

        local List = Instance.new("UIListLayout", Page)  
        List.Padding = UDim.new(0, 8)  
        List.HorizontalAlignment = Enum.HorizontalAlignment.Center  

        local TabBtn = Instance.new("TextButton", TabContainer)  
        TabBtn.Size = UDim2.new(0.85, 0, 0, 32)  
        TabBtn.BackgroundColor3 = Settings.UI.Theme.Main  
        TabBtn.Text = name  
        TabBtn.TextColor3 = Settings.UI.Theme.TextDim  
        TabBtn.Font = Enum.Font.GothamMedium  
        TabBtn.AutoButtonColor = false  
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)  

        TabBtn.MouseButton1Click:Connect(function()  
            for _, p in pairs(PageContainer:GetChildren()) do p.Visible = false end  
            for _, b in pairs(TabContainer:GetChildren()) do   
                if b:IsA("TextButton") then   
                    b.TextColor3 = Settings.UI.Theme.TextDim  
                    b.BackgroundColor3 = Settings.UI.Theme.Main  
                end  
            end  
            Page.Visible = true  
            TabBtn.TextColor3 = Settings.UI.Theme.Text  
            TabBtn.BackgroundColor3 = Settings.UI.Theme.Accent  
        end)  

        return Page
    end

    local function CreateToggle(parent, text, category, flag, callback)
        local Frame = Instance.new("TextButton", parent) 
        Frame.Size = UDim2.new(0.98, 0, 0, 38)
        Frame.BackgroundColor3 = Settings.UI.Theme.Header
        Frame.Text = ""
        Frame.AutoButtonColor = false
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

        local Label = Instance.new("TextLabel", Frame)  
        Label.Text = text  
        Label.Size = UDim2.new(0.7, 0, 1, 0)  
        Label.Position = UDim2.new(0.05, 0, 0, 0)  
        Label.BackgroundTransparency = 1  
        Label.TextColor3 = Settings.UI.Theme.Text  
        Label.TextXAlignment = Enum.TextXAlignment.Left  
        Label.Font = Enum.Font.GothamMedium  

        local Indicator = Instance.new("Frame", Frame)  
        Indicator.Size = UDim2.fromOffset(22, 22)  
        Indicator.Position = UDim2.new(1, -32, 0.5, 0)  
        Indicator.AnchorPoint = Vector2.new(0, 0.5)  
        Indicator.BackgroundColor3 = Settings.UI.Theme.Main  
        Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 4)  

        Frame.MouseButton1Click:Connect(function()  
            Settings[category][flag] = not Settings[category][flag]  
            local state = Settings[category][flag]  
            TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = state and Settings.UI.Theme.Accent or Settings.UI.Theme.Main}):Play()  
            if callback then callback(state) end  
        end)
    end

    local function CreateButton(parent, text, initialVal, callback)
        local Frame = Instance.new("TextButton", parent) 
        Frame.Size = UDim2.new(0.98, 0, 0, 38)
        Frame.BackgroundColor3 = Settings.UI.Theme.Header
        Frame.Text = ""
        Frame.AutoButtonColor = false
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

        local Label = Instance.new("TextLabel", Frame)  
        Label.Text = text .. ": " .. tostring(initialVal)
        Label.Size = UDim2.new(0.9, 0, 1, 0)  
        Label.Position = UDim2.new(0.05, 0, 0, 0)  
        Label.BackgroundTransparency = 1  
        Label.TextColor3 = Settings.UI.Theme.Text  
        Label.TextXAlignment = Enum.TextXAlignment.Left  
        Label.Font = Enum.Font.GothamMedium  

        Frame.MouseButton1Click:Connect(function()  
            local newVal = callback()
            Label.Text = text .. ": " .. tostring(newVal)
        end)
    end

    local function CreateAdjuster(parent, text, category, flag, step, min, max)
        local Frame = Instance.new("Frame", parent)
        Frame.Size = UDim2.new(0.98, 0, 0, 40)
        Frame.BackgroundColor3 = Settings.UI.Theme.Header
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

        local Label = Instance.new("TextLabel", Frame)  
        Label.Text = text .. ": " .. Settings[category][flag]  
        Label.Size = UDim2.new(0.5, 0, 1, 0)  
        Label.Position = UDim2.new(0.05, 0, 0, 0)  
        Label.BackgroundTransparency = 1  
        Label.TextColor3 = Settings.UI.Theme.Text  
        Label.TextXAlignment = Enum.TextXAlignment.Left  
        Label.Font = Enum.Font.GothamMedium  

        local BtnMinus = Instance.new("TextButton", Frame)  
        BtnMinus.Size = UDim2.fromOffset(28, 28)  
        BtnMinus.Position = UDim2.new(1, -70, 0.5, 0)  
        BtnMinus.AnchorPoint = Vector2.new(0, 0.5)  
        BtnMinus.BackgroundColor3 = Settings.UI.Theme.Main  
        BtnMinus.Text = "-"  
        BtnMinus.TextColor3 = Color3.new(1,1,1)  
        BtnMinus.Font = Enum.Font.GothamBold  
        Instance.new("UICorner", BtnMinus).CornerRadius = UDim.new(0, 4)  

        local BtnPlus = Instance.new("TextButton", Frame)  
        BtnPlus.Size = UDim2.fromOffset(28, 28)  
        BtnPlus.Position = UDim2.new(1, -35, 0.5, 0)  
        BtnPlus.AnchorPoint = Vector2.new(0, 0.5)  
        BtnPlus.BackgroundColor3 = Settings.UI.Theme.Accent  
        BtnPlus.Text = "+"  
        BtnPlus.TextColor3 = Color3.new(1,1,1)  
        BtnPlus.Font = Enum.Font.GothamBold  
        Instance.new("UICorner", BtnPlus).CornerRadius = UDim.new(0, 4)  

        BtnMinus.MouseButton1Click:Connect(function()  
            local n = Settings[category][flag] - step  
            if n >= min then  
                Settings[category][flag] = math.round(n * 100) / 100 
                Label.Text = text .. ": " .. Settings[category][flag]  
            end  
        end)  

        BtnPlus.MouseButton1Click:Connect(function()  
            local n = Settings[category][flag] + step  
            if n <= max then  
                Settings[category][flag] = math.round(n * 100) / 100  
                Label.Text = text .. ": " .. Settings[category][flag]  
            end  
        end)
    end

    local PageCombat = CreatePage("Combat")
    local PageVisuals = CreatePage("Visuals")

    CreateToggle(PageCombat, "Enable Aimbot", "Combat", "Enabled")
    CreateToggle(PageCombat, "Show FOV", "Combat", "ShowFov")
    CreateAdjuster(PageCombat, "FOV Size", "Combat", "FovSize", 10, 20, 500)
    CreateAdjuster(PageCombat, "Smoothness", "Combat", "Smoothness", 0.1, 0, 1) 
    CreateToggle(PageCombat, "Team Check", "Combat", "TeamCheck")
    CreateToggle(PageCombat, "Friend Check", "Combat", "FriendCheck") -- [NOVO] Adicionado no menu Combat
    CreateToggle(PageCombat, "Wall Check", "Combat", "WallCheck")
    
    CreateButton(PageCombat, "Target Mode", Settings.Combat.TargetPart, function()
        Settings.Combat.TargetPart = Settings.Combat.TargetPart == "Head" and "HumanoidRootPart" or "Head"
        return Settings.Combat.TargetPart
    end)

    local TracersCache = {}
    CreateToggle(PageVisuals, "ESP Highlight", "Visuals", "Highlight", function(v)
        if not v then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("VH_Highlight") then
                    p.Character.VH_Highlight:Destroy()
                end
            end
        end
    end)
    
    CreateToggle(PageVisuals, "ESP Names", "Visuals", "Names", function(v)
        if not v then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("VH_NameInfo") then
                    p.Character.VH_NameInfo:Destroy()
                end
            end
        end
    end)
    
    CreateToggle(PageVisuals, "Tracers (Lines)", "Visuals", "Tracers", function(v)
        if not v then
            for _, line in pairs(TracersCache) do
                if typeof(line) == "table" or typeof(line) == "Instance" then
                    pcall(function() line.Visible = false end)
                end
            end
        end
    end)
    
    CreateToggle(PageVisuals, "Team Check (Vis)", "Visuals", "TeamCheck")
    CreateToggle(PageVisuals, "Friend Check (Vis)", "Visuals", "FriendCheck") -- [NOVO] Adicionado no menu Visuals

    local function IsTeamMate(plr)
        return (plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team) or false
    end

    -- [NOVO] Sistema de Cache de Amigos (Para evitar que o Roblox pause/trave o script a cada frame)
    local FriendCache = {}
    local function IsFriend(plr)
        if FriendCache[plr.UserId] == nil then
            FriendCache[plr.UserId] = false -- Previne yield/spam no loop
            task.spawn(function()
                local success, result = pcall(function()
                    return LocalPlayer:IsFriendsWith(plr.UserId)
                end)
                if success then
                    FriendCache[plr.UserId] = result
                end
            end)
        end
        return FriendCache[plr.UserId]
    end

    local function IsVisible(targetPart)
        if not Settings.Combat.WallCheck then return true end
        local Origin = Camera.CFrame.Position  
        local Direction = targetPart.Position - Origin  
        local Params = RaycastParams.new()  
        Params.FilterType = Enum.RaycastFilterType.Exclude  
        Params.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}  
        local Result = Workspace:Raycast(Origin, Direction, Params)  
        return Result == nil
    end

    local function GetClosestPlayer()
        local Closest = nil
        local MaxDist = Settings.Combat.FovSize

        for _, v in pairs(Players:GetPlayers()) do  
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then  
                if Settings.Combat.TeamCheck and IsTeamMate(v) then continue end  
                if Settings.Combat.FriendCheck and IsFriend(v) then continue end -- [NOVO] Ignora se for amigo
                
                local Root = v.Character:FindFirstChild(Settings.Combat.TargetPart) or v.Character:FindFirstChild("HumanoidRootPart")  
                if not Root then continue end  

                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)  
                if OnScreen then  
                    local CenterX, CenterY = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
                    local MouseDist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Vector2.new(CenterX, CenterY)).Magnitude  
                      
                    if MouseDist < MaxDist and IsVisible(Root) then  
                        MaxDist = MouseDist  
                        Closest = Root
                    end  
                end  
            end  
        end  
        return Closest
    end

    -- // LOOP PRINCIPAL PROTEGIDO COM PCALL
    local RenderConnection
    RenderConnection = RunService.RenderStepped:Connect(function()
        local loopSuccess, loopError = pcall(function()
            if Settings.Combat.ShowFov then
                FovContainer.Visible = true
                FovContainer.Size = UDim2.fromOffset(Settings.Combat.FovSize * 2, Settings.Combat.FovSize * 2)
                FovContainer.Position = UDim2.new(0, Camera.ViewportSize.X / 2, 0, Camera.ViewportSize.Y / 2)
            else
                FovContainer.Visible = false
            end

            if Settings.Combat.Enabled then  
                local Target = GetClosestPlayer()  
                if Target then  
                    local GoalCF = CFrame.new(Camera.CFrame.Position, Target.Position)  
                    Camera.CFrame = Camera.CFrame:Lerp(GoalCF, math.clamp(1 - Settings.Combat.Smoothness, 0.01, 1))  
                end  
            end  

            for _, plr in pairs(Players:GetPlayers()) do  
                if plr ~= LocalPlayer and plr.Character then  
                    local Char = plr.Character  
                    local HRP = Char:FindFirstChild("HumanoidRootPart")  
                    local Hum = Char:FindFirstChild("Humanoid")  
                      
                    -- [NOVO] Lógica atualizada para Friend Check nos Visuais (ESP)
                    local ShouldShow = not (Settings.Visuals.TeamCheck and IsTeamMate(plr)) 
                                       and not (Settings.Visuals.FriendCheck and IsFriend(plr))
                                       and Hum and Hum.Health > 0  

                    if ShouldShow and HRP then  
                        if Settings.Visuals.Highlight then
                            local hl = Char:FindFirstChild("VH_Highlight")
                            if not hl then
                                hl = Instance.new("Highlight", Char)
                                hl.Name = "VH_Highlight"
                                hl.FillColor = Settings.UI.Theme.Accent
                                hl.OutlineColor = Color3.new(1, 1, 1)
                            end
                        elseif Char:FindFirstChild("VH_Highlight") then
                            Char.VH_Highlight:Destroy()
                        end

                        if Settings.Visuals.Names then
                            local nameTag = Char:FindFirstChild("VH_NameInfo")
                            if not nameTag then
                                nameTag = Instance.new("BillboardGui", Char)
                                nameTag.Name = "VH_NameInfo"
                                nameTag.Size = UDim2.new(0, 200, 0, 50)
                                nameTag.StudsOffset = Vector3.new(0, 3, 0)
                                nameTag.AlwaysOnTop = true
                                
                                local txt = Instance.new("TextLabel", nameTag)
                                txt.Size = UDim2.new(1, 0, 1, 0)
                                txt.BackgroundTransparency = 1
                                txt.Text = plr.Name
                                txt.TextColor3 = Settings.UI.Theme.Text
                                txt.Font = Enum.Font.GothamBold
                            end
                        elseif Char:FindFirstChild("VH_NameInfo") then
                            Char.VH_NameInfo:Destroy()
                        end

                        if Settings.Visuals.Tracers then
                            -- Checagem segura para Drawing API (Evita crashs em executores incompatíveis)
                            if type(Drawing) ~= "nil" then
                                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(HRP.Position)
                                if OnScreen then
                                    local line = TracersCache[plr.UserId]
                                    if not line then
                                        line = Drawing.new("Line")
                                        line.Thickness = 1.5
                                        line.Color = Settings.UI.Theme.Accent
                                        TracersCache[plr.UserId] = line
                                    end
                                    line.Visible = true
                                    line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                    line.To = Vector2.new(ScreenPos.X, ScreenPos.Y)
                                else
                                    if TracersCache[plr.UserId] then TracersCache[plr.UserId].Visible = false end
                                end
                            end
                        else
                            if TracersCache[plr.UserId] then pcall(function() TracersCache[plr.UserId].Visible = false end) end
                        end
                    else
                        if Char:FindFirstChild("VH_Highlight") then Char.VH_Highlight:Destroy() end
                        if Char:FindFirstChild("VH_NameInfo") then Char.VH_NameInfo:Destroy() end
                        if TracersCache[plr.UserId] then pcall(function() TracersCache[plr.UserId].Visible = false end) end
                    end
                end  
            end  
        end)

        -- Se o loop der erro, ele desconecta para não travar o jogo e exibe o erro na tela
        if not loopSuccess then
            RenderConnection:Disconnect()
            CustomNotify("Render Error", tostring(loopError), 15)
            warn("[Violet Hub] Render Error: ", loopError)
        end
    end)

    -- Inicialização bem-sucedida
    CustomNotify("Violet Hub Elite", "Script executed successfully! No errors.", 5)
    return true
end

-- Tenta iniciar o Hub e captura qualquer erro brutal logo de cara
local initSuccess, initError = pcall(function()
    InitVioletHub()
end)

if not initSuccess then
    warn("[Violet Hub] FATAL INITIALIZATION ERROR: ", initError)
    -- Fallback simples caso o GUI customizado falhe de ser criado
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Violet Hub Crash",
            Text = tostring(initError),
            Duration = 15
        })
    end)
end
