--[[
    ═══════════════════════════════════════════════════════════════
    💜 XOTA HB - ELITE EDITION (PURPLE THEME) 💜
    Desenvolvido por: Senior Lua Architect
    Versão: 3.0.0 (Mobile Optimized)
    ═══════════════════════════════════════════════════════════════
]]

-- // SERVIÇOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- // VARIÁVEIS LOCAIS
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // CONFIGURAÇÕES (STATE)
local Settings = {
    Combat = {
        Enabled = false,
        TeamCheck = false,
        WallCheck = false,
        AliveCheck = true,
	Friendcheck = false,
        TargetPart = "Head", -- "Head" ou "HumanoidRootPart"
        FovSize = 100,
        ShowFov = false,
        Smoothness = 0.5, -- 0.1 (Rápido) a 1 (Lento)
        ActiveTarget = nil
    },
    Visuals = {
        Highlight = false,
        Names = false,
        Tracers = false,
        TeamCheck = false
    },
    UI = {
        Theme = {
            Main = Color3.fromRGB(25, 20, 35),      -- Roxo muito escuro (Fundo)
            Header = Color3.fromRGB(40, 30, 55),    -- Roxo escuro (Topo)
            Accent = Color3.fromRGB(140, 60, 255),  -- Roxo Neon (Destaque)
            Text = Color3.fromRGB(240, 240, 255),   -- Branco frio
            TextDim = Color3.fromRGB(180, 180, 200) -- Cinza claro
        },
        Open = true
    }
}

-- // CACHE DE DESENHO (DRAWING API)
local DrawingObjects = {
    FovCircle = nil,
    Tracers = {}
}

-- Verifica suporte a Drawing API
local Drawing = Drawing or require(script.Parent.Drawing) -- Fallback fake se necessário (apenas para não crashar no Studio)
if not Drawing then 
    warn("Drawing API não suportada. Tracers e FOV podem não funcionar.")
    Drawing = {new = function() return {Remove = function() end} end} -- Mock
end

-- // INICIALIZAÇÃO DO FOV
DrawingObjects.FovCircle = Drawing.new("Circle")
DrawingObjects.FovCircle.Thickness = 2
DrawingObjects.FovCircle.NumSides = 32 -- Otimização para mobile
DrawingObjects.FovCircle.Radius = Settings.Combat.FovSize
DrawingObjects.FovCircle.Filled = false
DrawingObjects.FovCircle.Transparency = 0.6
DrawingObjects.FovCircle.Color = Settings.UI.Theme.Accent
DrawingObjects.FovCircle.Visible = false

-- // SISTEMA DE UI (LIVRARIA CUSTOMIZADA)
local UI = {}

function UI.CreateMain()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "XotaHB_Purple"
    ScreenGui.ResetOnSpawn = false
    
    -- Tenta proteger na CoreGui (anti-detection básico de UI)
    if pcall(function() ScreenGui.Parent = CoreGui end) then
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Janela Principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.fromOffset(400, 320) -- Tamanho amigável para mobile
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Settings.UI.Theme.Main
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    -- Arredondamento e Borda
    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 10)
    
    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Color = Settings.UI.Theme.Accent
    UIStroke.Thickness = 2

    -- Barra Superior (Arrastável)
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Settings.UI.Theme.Header
    TopBar.Parent = MainFrame
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)
    
    -- Correção visual do canto inferior da TopBar
    local Filler = Instance.new("Frame", TopBar)
    Filler.Size = UDim2.new(1, 0, 0, 10)
    Filler.Position = UDim2.new(0, 0, 1, -10)
    Filler.BackgroundColor3 = Settings.UI.Theme.Header
    Filler.BorderSizePixel = 0
    Filler.ZIndex = 0

    -- Título
    local Title = Instance.new("TextLabel", TopBar)
    Title.Text = "XOTA HB <font color='rgb(140,60,255)'>ELITE</font>"
    Title.RichText = true
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Settings.UI.Theme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Botão Fechar (Minimizar)
    local CloseBtn = Instance.new("TextButton", TopBar)
    CloseBtn.Size = UDim2.fromOffset(30, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
    CloseBtn.BackgroundColor3 = Settings.UI.Theme.Accent
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = TopBar
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

    -- Container de Abas
    local TabContainer = Instance.new("Frame", MainFrame)
    TabContainer.Size = UDim2.new(0, 110, 1, -50)
    TabContainer.Position = UDim2.new(0, 10, 0, 45)
    TabContainer.BackgroundColor3 = Color3.fromRGB(30, 25, 45)
    TabContainer.BorderSizePixel = 0
    Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 8)
    
    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.Padding = UDim.new(0, 5)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Instance.new("UIPadding", TabContainer).PaddingTop = UDim.new(0, 10)

    -- Container de Conteúdo
    local PageContainer = Instance.new("Frame", MainFrame)
    PageContainer.Size = UDim2.new(1, -135, 1, -50)
    PageContainer.Position = UDim2.new(0, 125, 0, 45)
    PageContainer.BackgroundTransparency = 1

    -- Botão Flutuante (Mobile Toggle)
    local OpenBtn = Instance.new("TextButton", ScreenGui)
    OpenBtn.Size = UDim2.fromOffset(50, 50)
    OpenBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
    OpenBtn.BackgroundColor3 = Settings.UI.Theme.Main
    OpenBtn.Text = "💜"
    OpenBtn.TextSize = 24
    OpenBtn.Visible = false -- Começa invisível pois o menu está aberto
    Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 16)
    Instance.new("UIStroke", OpenBtn).Color = Settings.UI.Theme.Accent
    Instance.new("UIStroke", OpenBtn).Thickness = 2

    -- Lógica de Arrastar (Mobile Friendly)
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

    -- Lógica Abrir/Fechar
    local function ToggleMenu()
        Settings.UI.Open = not Settings.UI.Open
        MainFrame.Visible = Settings.UI.Open
        OpenBtn.Visible = not Settings.UI.Open
    end

    CloseBtn.MouseButton1Click:Connect(ToggleMenu)
    OpenBtn.MouseButton1Click:Connect(ToggleMenu)

    return {Tabs = TabContainer, Pages = PageContainer}
end

local Containers = UI.CreateMain()

-- Função para criar Páginas
local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame", Containers.Pages)
    Page.Name = name
    Page.Size = UDim2.fromScale(1, 1)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 4
    Page.Visible = false
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local List = Instance.new("UIListLayout", Page)
    List.Padding = UDim.new(0, 8)
    List.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Botão da Aba
    local TabBtn = Instance.new("TextButton", Containers.Tabs)
    TabBtn.Size = UDim2.new(0.9, 0, 0, 30)
    TabBtn.BackgroundColor3 = Settings.UI.Theme.Header
    TabBtn.Text = name
    TabBtn.TextColor3 = Settings.UI.Theme.TextDim
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.AutoButtonColor = false
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    TabBtn.MouseButton1Click:Connect(function()
        -- Esconde todas as páginas
        for _, p in pairs(Containers.Pages:GetChildren()) do p.Visible = false end
        -- Reseta botões
        for _, b in pairs(Containers.Tabs:GetChildren()) do 
            if b:IsA("TextButton") then 
                b.TextColor3 = Settings.UI.Theme.TextDim
                b.BackgroundColor3 = Settings.UI.Theme.Header
            end
        end
        -- Ativa atual
        Page.Visible = true
        TabBtn.TextColor3 = Settings.UI.Theme.Accent
        TabBtn.BackgroundColor3 = Color3.fromRGB(50, 40, 70)
    end)

    return Page
end

-- Função para criar Toggle
local function CreateToggle(parent, text, category, flag, callback)
    local Frame = Instance.new("TextButton") -- Botão inteiro clicável para facilitar mobile
    Frame.Size = UDim2.new(0.98, 0, 0, 35)
    Frame.BackgroundColor3 = Settings.UI.Theme.Header
    Frame.Text = ""
    Frame.AutoButtonColor = false
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Frame)
    Label.Text = text
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0.05, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Settings.UI.Theme.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham

    local Indicator = Instance.new("Frame", Frame)
    Indicator.Size = UDim2.fromOffset(20, 20)
    Indicator.Position = UDim2.new(1, -30, 0.5, 0)
    Indicator.AnchorPoint = Vector2.new(0, 0.5)
    Indicator.BackgroundColor3 = Color3.fromRGB(60, 50, 80)
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 4)

    Frame.MouseButton1Click:Connect(function()
        Settings[category][flag] = not Settings[category][flag]
        local state = Settings[category][flag]
        
        -- Animação
        TweenService:Create(Indicator, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Settings.UI.Theme.Accent or Color3.fromRGB(60, 50, 80)
        }):Play()

        if callback then callback(state) end
    end)
end

-- Função para criar Ajuste de Valor (+ / -) -> Melhor que Slider no Mobile
local function CreateAdjuster(parent, text, category, flag, step, min, max, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0.98, 0, 0, 40)
    Frame.BackgroundColor3 = Settings.UI.Theme.Header
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Frame)
    Label.Text = text .. ": " .. Settings[category][flag]
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Position = UDim2.new(0.05, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Settings.UI.Theme.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham

    -- Botão Menos
    local BtnMinus = Instance.new("TextButton", Frame)
    BtnMinus.Size = UDim2.fromOffset(30, 30)
    BtnMinus.Position = UDim2.new(1, -75, 0.5, 0)
    BtnMinus.AnchorPoint = Vector2.new(0, 0.5)
    BtnMinus.BackgroundColor3 = Color3.fromRGB(60, 50, 80)
    BtnMinus.Text = "-"
    BtnMinus.TextColor3 = Color3.new(1,1,1)
    BtnMinus.Font = Enum.Font.GothamBold
    Instance.new("UICorner", BtnMinus).CornerRadius = UDim.new(0, 4)

    -- Botão Mais
    local BtnPlus = Instance.new("TextButton", Frame)
    BtnPlus.Size = UDim2.fromOffset(30, 30)
    BtnPlus.Position = UDim2.new(1, -40, 0.5, 0)
    BtnPlus.AnchorPoint = Vector2.new(0, 0.5)
    BtnPlus.BackgroundColor3 = Settings.UI.Theme.Accent
    BtnPlus.Text = "+"
    BtnPlus.TextColor3 = Color3.new(1,1,1)
    BtnPlus.Font = Enum.Font.GothamBold
    Instance.new("UICorner", BtnPlus).CornerRadius = UDim.new(0, 4)

    BtnMinus.MouseButton1Click:Connect(function()
        local n = Settings[category][flag] - step
        if n >= min then
            Settings[category][flag] = math.round(n * 100) / 100 -- Arredonda precisão
            Label.Text = text .. ": " .. Settings[category][flag]
            if callback then callback(Settings[category][flag]) end
        end
    end)

    BtnPlus.MouseButton1Click:Connect(function()
        local n = Settings[category][flag] + step
        if n <= max then
            Settings[category][flag] = math.round(n * 100) / 100
            Label.Text = text .. ": " .. Settings[category][flag]
            if callback then callback(Settings[category][flag]) end
        end
    end)
end

-- Função para criar Botão de Seleção (Texto muda ao clicar)
local function CreateSelector(parent, text, category, flag, callback)
    local Frame = Instance.new("TextButton")
    Frame.Size = UDim2.new(0.98, 0, 0, 35)
    Frame.BackgroundColor3 = Settings.UI.Theme.Header
    Frame.Text = "" 
    Frame.AutoButtonColor = false
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Frame)
    -- Mostra o estado atual (ex: Target: Head)
    Label.Text = text .. ": " .. string.upper(Settings[category][flag] == "HumanoidRootPart" and "Torso" or Settings[category][flag])
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Settings.UI.Theme.Text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 14
    
    Frame.MouseButton1Click:Connect(function()
        if callback then callback() end
        -- Atualiza o texto após o clique
        Label.Text = text .. ": " .. string.upper(Settings[category][flag] == "HumanoidRootPart" and "Torso" or Settings[category][flag])
        
        -- Efeito visual de clique
        Frame.BackgroundColor3 = Settings.UI.Theme.Accent
        task.wait(0.1)
        Frame.BackgroundColor3 = Settings.UI.Theme.Header
    end)
end

-- // CRIAÇÃO DOS MENUS
local PageCombat = CreatePage("Combat")
local PageVisuals = CreatePage("Visuals")

-- ABA COMBAT
CreateToggle(PageCombat, "Enable Aimbot", "Combat", "Enabled")
CreateToggle(PageCombat, "Show FOV", "Combat", "ShowFov")
CreateAdjuster(PageCombat, "FOV Size", "Combat", "FovSize", 10, 20, 500)
CreateAdjuster(PageCombat, "Smoothness", "Combat", "Smoothness", 0.05, 0, 1)

-- [NOVO] Check de Amigo e Time
CreateToggle(PageCombat, "Team Check", "Combat", "TeamCheck")
CreateToggle(PageCombat, "Friend Check", "Combat", "FriendCheck") -- Botão novo
CreateToggle(PageCombat, "Wall Check", "Combat", "WallCheck")

-- [CORREÇÃO] Botão seletor de Target (Head/Torso)
CreateSelector(PageCombat, "Target", "Combat", "TargetPart", function()
    if Settings.Combat.TargetPart == "Head" then
        Settings.Combat.TargetPart = "HumanoidRootPart"
    else
        Settings.Combat.TargetPart = "Head"
    end
end)

-- ABA VISUALS
CreateToggle(PageVisuals, "ESP Highlight", "Visuals", "Highlight", function(v)
    if not v then
        -- Limpa Highlights ao desligar
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("XH_Highlight") then
                p.Character.XH_Highlight:Destroy()
            end
        end
    end
end)
CreateToggle(PageVisuals, "ESP Names", "Visuals", "Names", function(v)
    if not v then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("XH_NameInfo") then
                p.Character.XH_NameInfo:Destroy()
            end
        end
    end
end)
CreateToggle(PageVisuals, "Tracers (Lines)", "Visuals", "Tracers")
CreateToggle(PageVisuals, "Team Check (Vis)", "Visuals", "TeamCheck")


-- // LÓGICA DO AIMBOT & CHECKS

local function IsTeamMate(plr)
    if plr.Team and LocalPlayer.Team then
        return plr.Team == LocalPlayer.Team
    end
    return false
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
            
            -- Checks
            if Settings.Combat.TeamCheck and IsTeamMate(v) then continue end

	    -- [NOVO] Adicione esta linha aqui:
            if Settings.Combat.FriendCheck and v:IsFriendsWith(LocalPlayer.UserId) then continue end
            
            local Root = v.Character:FindFirstChild(Settings.Combat.TargetPart) or v.Character:FindFirstChild("HumanoidRootPart")
            if not Root then continue end

            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
            
            if OnScreen then
                local MouseDist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                
                if MouseDist < MaxDist then
                    if IsVisible(Root) then
                        MaxDist = MouseDist
                        Closest = Root
                    end
                end
            end
        end
    end
    return Closest
end

-- // LOOP PRINCIPAL (VISUALS & AIM)
RunService.RenderStepped:Connect(function()
    
    -- 1. ATUALIZAR FOV CIRCLE
    DrawingObjects.FovCircle.Visible = Settings.Combat.ShowFov
    DrawingObjects.FovCircle.Radius = Settings.Combat.FovSize
    DrawingObjects.FovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    -- 2. AIMBOT LOGIC
    if Settings.Combat.Enabled then
        local Target = GetClosestPlayer()
        if Target then
            local CurrentCF = Camera.CFrame
            local TargetPos = Target.Position
            local GoalCF = CFrame.new(CurrentCF.Position, TargetPos)
            
            -- Smoothness calculation
            local Alpha = math.clamp(1 - Settings.Combat.Smoothness, 0.01, 1)
            
            Camera.CFrame = CurrentCF:Lerp(GoalCF, Alpha)
        end
    end

    -- 3. VISUALS LOOP
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local Char = plr.Character
            local HRP = Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char:FindFirstChild("Humanoid")
            
            local IsAlly = Settings.Visuals.TeamCheck and IsTeamMate(plr)
            local ShouldShow = not IsAlly and Hum and Hum.Health > 0

            if ShouldShow and HRP then
                -- >> HIGHLIGHT (Chams) <<
                if Settings.Visuals.Highlight then
                    if not Char:FindFirstChild("XH_Highlight") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "XH_Highlight"
                        hl.FillColor = Settings.UI.Theme.Accent
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
                        hl.OutlineTransparency = 0.5
                        hl.Parent = Char
                    end
                elseif Char:FindFirstChild("XH_Highlight") then
                    Char.XH_Highlight:Destroy()
                end

                -- >> BILLBOARD (Names) <<
                if Settings.Visuals.Names then
                    if not Char:FindFirstChild("XH_NameInfo") then
                        local bg = Instance.new("BillboardGui")
                        bg.Name = "XH_NameInfo"
                        bg.Size = UDim2.fromOffset(200, 50)
                        bg.StudsOffset = Vector3.new(0, 3, 0)
                        bg.AlwaysOnTop = true
                        bg.Parent = Char
                        
                        local txt = Instance.new("TextLabel", bg)
                        txt.BackgroundTransparency = 1
                        txt.Size = UDim2.fromScale(1,1)
                        txt.TextColor3 = Settings.UI.Theme.Accent
                        txt.TextStrokeTransparency = 0
                        txt.Font = Enum.Font.GothamBold
                        txt.TextSize = 14
                        txt.Name = "Lbl"
                    end
                    Char.XH_NameInfo.Lbl.Text = plr.Name .. " [" .. math.floor(Hum.Health) .. " HP]"
                    Char.XH_NameInfo.Lbl.TextColor3 = IsVisible(HRP) and Color3.fromRGB(0, 255, 100) or Settings.UI.Theme.Accent
                elseif Char:FindFirstChild("XH_NameInfo") then
                    Char.XH_NameInfo:Destroy()
                end

                -- >> TRACERS (Lines) <<
                if Settings.Visuals.Tracers then
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(HRP.Position)
                    if OnScreen then
                        if not DrawingObjects.Tracers[plr.Name] then
                            local line = Drawing.new("Line")
                            line.Thickness = 1.5
                            line.Color = Settings.UI.Theme.Accent
                            DrawingObjects.Tracers[plr.Name] = line
                        end
                        
                        local Line = DrawingObjects.Tracers[plr.Name]
                        Line.Visible = true
                        Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y) -- De baixo
                        Line.To = Vector2.new(ScreenPos.X, ScreenPos.Y)
                    else
                        if DrawingObjects.Tracers[plr.Name] then DrawingObjects.Tracers[plr.Name].Visible = false end
                    end
                else
                    if DrawingObjects.Tracers[plr.Name] then 
                        DrawingObjects.Tracers[plr.Name].Visible = false 
                    end
                end

            else
                -- Limpeza se o player morreu ou não deve ser mostrado
                if Char:FindFirstChild("XH_Highlight") then Char.XH_Highlight:Destroy() end
                if Char:FindFirstChild("XH_NameInfo") then Char.XH_NameInfo:Destroy() end
                if DrawingObjects.Tracers[plr.Name] then DrawingObjects.Tracers[plr.Name].Visible = false end
            end
        end
    end
    
    -- Limpa tracers de players que saíram
    for name, line in pairs(DrawingObjects.Tracers) do
        if not Players:FindFirstChild(name) then
            line:Remove()
            DrawingObjects.Tracers[name] = nil
        end
    end
end)



-- Função de Notificação Customizada (Tema Roxo)
task.spawn(function()
    local gui = game:GetService("CoreGui"):FindFirstChild("XotaHB_Purple") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("XotaHB_Purple")
    if not gui then return end

    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.fromOffset(250, 50)
    notifFrame.Position = UDim2.new(0.5, -125, -0.2, 0) -- Começa fora da tela (topo)
    notifFrame.BackgroundColor3 = Color3.fromRGB(40, 30, 55)
    notifFrame.BorderSizePixel = 0
    notifFrame.Parent = gui
    
    local stroke = Instance.new("UIStroke", notifFrame)
    stroke.Color = Color3.fromRGB(140, 60, 255)
    stroke.Thickness = 2
    
    local corner = Instance.new("UICorner", notifFrame)
    corner.CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", notifFrame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "💜 Script Loaded Successfully"
    label.TextColor3 = Color3.fromRGB(240, 240, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14

    -- Animação de Entrada
    local TweenService = game:GetService("TweenService")
    TweenService:Create(notifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -125, 0.05, 0)}):Play()
    
    -- Espera e Saída
    task.wait(4)
    TweenService:Create(notifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -125, -0.2, 0)}):Play()
    task.wait(0.5)
    notifFrame:Destroy()
end)
