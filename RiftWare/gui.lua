-- Rise ClickGUI - Roblox Edition (Inspired by Vape Framework)
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local GUI = {
    isOpen = true,
    selectedCategory = 1,
    modules = {},
    categories = {}
}

-- UI Palette (Rise-inspired)
local UIColors = {
    Main = Color3.fromRGB(23, 26, 33),
    MainColor = Color3.fromRGB(12, 163, 232),
    SecondaryColor = Color3.fromRGB(12, 232, 199),
    Text = Color3.fromRGB(200, 200, 210),
    TextDark = Color3.fromRGB(100, 100, 110),
    Background = Color3.fromRGB(30, 30, 35),
    Sidebar = Color3.fromRGB(25, 25, 30)
}

local ConfigCategories = {
    "Combat", "Movement", "Player", "Render", "Exploit", "Ghost", "Other", "Script", "Themes", "Language"
}

-- Initialize
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RiseGUI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 9999999
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 800, 0, 600)
mainFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
mainFrame.BackgroundColor3 = UIColors.Sidebar
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Add corner
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = UIColors.Sidebar
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Rise"
titleLabel.TextColor3 = UIColors.Text
titleLabel.TextSize = 20
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 40, 1, 0)
closeBtn.Position = UDim2.new(1, -40, 0, 0)
closeBtn.BackgroundColor3 = UIColors.MainColor
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    GUI:toggle()
end)

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 200, 1, -40)
sidebar.Position = UDim2.new(0, 0, 0, 40)
sidebar.BackgroundColor3 = UIColors.Sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

-- Content area
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -200, 1, -40)
contentArea.Position = UDim2.new(0, 200, 0, 40)
contentArea.BackgroundColor3 = UIColors.Background
contentArea.BorderSizePixel = 0
contentArea.Parent = mainFrame

local contentScroll = Instance.new("ScrollingFrame")
contentScroll.Name = "ContentScroll"
contentScroll.Size = UDim2.new(1, -15, 1, 0)
contentScroll.Position = UDim2.new(0, 0, 0, 0)
contentScroll.BackgroundTransparency = 1
contentScroll.BorderSizePixel = 0
contentScroll.ScrollBarThickness = 6
contentScroll.ScrollBarImageColor3 = UIColors.TextDark
contentScroll.Parent = contentArea

-- Initialize categories
for i, catName in ipairs(ConfigCategories) do
    GUI.categories[i] = {
        name = catName,
        options = {},
        button = nil,
        isActive = (i == 1)
    }
end

-- Create category buttons
local function createCategoryButtons()
    local yPos = 10
    for i, cat in ipairs(GUI.categories) do
        local catBtn = Instance.new("TextButton")
        catBtn.Name = "Category_" .. cat.name
        catBtn.Size = UDim2.new(1, -20, 0, 32)
        catBtn.Position = UDim2.new(0, 10, 0, yPos)
        catBtn.BackgroundColor3 = cat.isActive and UIColors.MainColor or UIColors.Main
        catBtn.BorderSizePixel = 0
        catBtn.Text = cat.name
        catBtn.TextColor3 = Color3.new(1, 1, 1)
        catBtn.TextSize = 14
        catBtn.Font = Enum.Font.Gotham
        catBtn.Parent = sidebar
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = catBtn
        
        cat.button = catBtn
        
        catBtn.MouseButton1Click:Connect(function()
            GUI:selectCategory(i)
        end)
        
        catBtn.MouseEnter:Connect(function()
            if not cat.isActive then
                TweenService:Create(catBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundColor3 = UIColors.MainColor:Lerp(UIColors.Main, 0.5)
                }):Play()
            end
        end)
        
        catBtn.MouseLeave:Connect(function()
            if not cat.isActive then
                TweenService:Create(catBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundColor3 = UIColors.Main
                }):Play()
            end
        end)
        
        yPos = yPos + 40
    end
end

createCategoryButtons()

-- Add option to category
function GUI:addOption(categoryName, optionName, callback, categoryIndex)
    local cat = self.categories[categoryIndex or 1]
    if not cat then return end
    
    table.insert(cat.options, {
        name = optionName,
        callback = callback,
        enabled = false
    })
    
    self:refreshDisplay()
end

-- Toggle GUI
function GUI:toggle()
    self.isOpen = not self.isOpen
    mainFrame.Visible = self.isOpen
end

-- Select category
function GUI:selectCategory(index)
    if index > 0 and index <= #self.categories then
        -- Reset old category
        if self.selectedCategory then
            local oldCat = self.categories[self.selectedCategory]
            if oldCat.button then
                TweenService:Create(oldCat.button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundColor3 = UIColors.Main
                }):Play()
            end
            oldCat.isActive = false
        end
        
        self.selectedCategory = index
        local newCat = self.categories[index]
        newCat.isActive = true
        
        if newCat.button then
            TweenService:Create(newCat.button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = UIColors.MainColor
            }):Play()
        end
        
        self:refreshDisplay()
    end
end

-- Refresh display
function GUI:refreshDisplay()
    -- Clear content
    for _, child in pairs(contentScroll:GetChildren()) do
        child:Destroy()
    end
    
    -- Show content for selected category
    if self.categories[self.selectedCategory] then
        local cat = self.categories[self.selectedCategory]
        local yPos = 10
        
        for optIdx, option in ipairs(cat.options) do
            local optionFrame = Instance.new("Frame")
            optionFrame.Size = UDim2.new(1, -20, 0, 40)
            optionFrame.Position = UDim2.new(0, 10, 0, yPos)
            optionFrame.BackgroundTransparency = 1
            optionFrame.BorderSizePixel = 0
            optionFrame.Parent = contentScroll
            
            local checkbox = Instance.new("Frame")
            checkbox.Size = UDim2.new(0, 16, 0, 16)
            checkbox.Position = UDim2.new(0, 0, 0.5, -8)
            checkbox.BackgroundColor3 = option.enabled and UIColors.MainColor or UIColors.Main
            checkbox.BorderSizePixel = 0
            checkbox.Parent = optionFrame
            
            local checkCorner = Instance.new("UICorner")
            checkCorner.CornerRadius = UDim.new(0, 4)
            checkCorner.Parent = checkbox
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -30, 1, 0)
            label.Position = UDim2.new(0, 25, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = option.name
            label.TextColor3 = UIColors.Text
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = optionFrame
            
            local clickBtn = Instance.new("TextButton")
            clickBtn.Size = UDim2.new(1, 0, 1, 0)
            clickBtn.Position = UDim2.new(0, 0, 0, 0)
            clickBtn.BackgroundTransparency = 1
            clickBtn.BorderSizePixel = 0
            clickBtn.Text = ""
            clickBtn.Parent = optionFrame
            
            clickBtn.MouseButton1Click:Connect(function()
                self:toggleOption(self.selectedCategory, optIdx)
            end)
            
            yPos = yPos + 45
        end
        
        contentScroll.CanvasSize = UDim2.new(0, 0, 0, yPos)
    end
end

-- Toggle option
function GUI:toggleOption(categoryIndex, optionIndex)
    local cat = self.categories[categoryIndex]
    if cat and cat.options[optionIndex] then
        local option = cat.options[optionIndex]
        option.enabled = not option.enabled
        if option.callback then
            option.callback(option.enabled)
        end
        self:refreshDisplay()
    end
end

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightShift then
        GUI:toggle()
    end
end)

-- Make window draggable
local dragging = false
local dragStart = nil
local framePos = nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = UserInputService:GetMouseLocation()
        framePos = mainFrame.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Mouse and dragging then
        local currentMouse = UserInputService:GetMouseLocation()
        local delta = Vector2.new(currentMouse.X - dragStart.X, currentMouse.Y - dragStart.Y)
        mainFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)

GUI:refreshDisplay()

print("[Rise GUI] Loaded successfully!")
print("[Rise GUI] Press RIGHT SHIFT to toggle GUI")
print("[Rise GUI] Categories: " .. #GUI.categories)

return GUI
