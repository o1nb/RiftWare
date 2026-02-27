-- Rise ClickGUI - Roblox Edition
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local GUI = {
    isOpen = true,
    selectedCategory = 1,
    isDragging = false,
    dragStart = {x = 0, y = 0},
    offset = {x = 0, y = 0}
}

local CONFIG = {
    window = {
        width = 400,
        height = 500,
        x = 50,
        y = 50,
        title = "Rise"
    },
    categories = {
        "Combat", "Movement", "Player", "Render", "Exploit", "Ghost", "Other", "Script", "Themes", "Language"
    },
    colors = {
        bg = Color3.fromRGB(30, 30, 35),
        sidebar = Color3.fromRGB(25, 25, 30),
        button = Color3.fromRGB(40, 40, 50),
        hover = Color3.fromRGB(50, 50, 70),
        active = Color3.fromRGB(70, 100, 200),
        text = Color3.fromRGB(200, 200, 210),
        white = Color3.fromRGB(255, 255, 255)
    }
}

-- Initialize categories
GUI.categories = {}
for i, name in ipairs(CONFIG.categories) do
    GUI.categories[i] = {
        name = name,
        options = {},
        isOpen = (i == 1)
    }
end

-- Create GUI elements
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RiseGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, CONFIG.window.width, 0, CONFIG.window.height)
mainFrame.Position = UDim2.new(0, CONFIG.window.x, 0, CONFIG.window.y)
mainFrame.BackgroundColor3 = CONFIG.colors.sidebar
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = CONFIG.colors.sidebar
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = CONFIG.window.title
titleLabel.TextColor3 = CONFIG.colors.text
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -40, 0, 0)
closeBtn.BackgroundColor3 = CONFIG.colors.hover
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = CONFIG.colors.text
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

closeBtn.MouseButton1Click:Connect(function()
    GUI:toggle()
end)

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 120, 1, -40)
sidebar.Position = UDim2.new(0, 0, 0, 40)
sidebar.BackgroundColor3 = CONFIG.colors.sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

-- Content area
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -120, 1, -40)
contentArea.Position = UDim2.new(0, 120, 0, 40)
contentArea.BackgroundColor3 = CONFIG.colors.bg
contentArea.BorderSizePixel = 0
contentArea.Parent = mainFrame

local contentScroll = Instance.new("ScrollingFrame")
contentScroll.Name = "ContentScroll"
contentScroll.Size = UDim2.new(1, 0, 1, 0)
contentScroll.BackgroundTransparency = 1
contentScroll.BorderSizePixel = 0
contentScroll.ScrollBarThickness = 8
contentScroll.Parent = contentArea

-- Create category buttons
local function createCategoryButtons()
    local yPos = 0
    for i, cat in ipairs(GUI.categories) do
        local catBtn = Instance.new("TextButton")
        catBtn.Name = "Category_" .. cat.name
        catBtn.Size = UDim2.new(1, 0, 0, 35)
        catBtn.Position = UDim2.new(0, 0, 0, yPos)
        catBtn.BackgroundColor3 = (i == GUI.selectedCategory) and CONFIG.colors.active or CONFIG.colors.button
        catBtn.BorderSizePixel = 0
        catBtn.Text = cat.name
        catBtn.TextColor3 = (i == GUI.selectedCategory) and CONFIG.colors.white or CONFIG.colors.text
        catBtn.TextSize = 14
        catBtn.Font = Enum.Font.Gotham
        catBtn.Parent = sidebar
        
        catBtn.MouseButton1Click:Connect(function()
            GUI:selectCategory(i)
        end)
        
        catBtn.MouseEnter:Connect(function()
            if i ~= GUI.selectedCategory then
                catBtn.BackgroundColor3 = CONFIG.colors.hover
            end
        end)
        
        catBtn.MouseLeave:Connect(function()
            if i ~= GUI.selectedCategory then
                catBtn.BackgroundColor3 = CONFIG.colors.button
            end
        end)
        
        yPos = yPos + 35
    end
end

createCategoryButtons()

-- Add option to category
function GUI:addOption(categoryName, optionName, callback)
    for _, cat in ipairs(self.categories) do
        if cat.name == categoryName then
            table.insert(cat.options, {
                name = optionName,
                callback = callback,
                enabled = false
            })
            return
        end
    end
end

-- Toggle GUI
function GUI:toggle()
    self.isOpen = not self.isOpen
    mainFrame.Visible = self.isOpen
end

-- Select category
function GUI:selectCategory(index)
    if index > 0 and index <= #self.categories then
        self.selectedCategory = index
        self:refreshDisplay()
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

-- Refresh display
function GUI:refreshDisplay()
    -- Clear content
    for _, child in pairs(contentScroll:GetChildren()) do
        child:Destroy()
    end
    
    -- Refresh sidebar colors
    for i, btn in pairs(sidebar:GetChildren()) do
        if btn:IsA("TextButton") then
            btn.BackgroundColor3 = (i == self.selectedCategory) and CONFIG.colors.active or CONFIG.colors.button
            btn.TextColor3 = (i == self.selectedCategory) and CONFIG.colors.white or CONFIG.colors.text
        end
    end
    
    -- Show content for selected category
    if self.categories[self.selectedCategory] then
        local cat = self.categories[self.selectedCategory]
        local yPos = 10
        
        for optIdx, option in ipairs(cat.options) do
            local optionFrame = Instance.new("Frame")
            optionFrame.Size = UDim2.new(1, -20, 0, 30)
            optionFrame.Position = UDim2.new(0, 10, 0, yPos)
            optionFrame.BackgroundTransparency = 1
            optionFrame.BorderSizePixel = 0
            optionFrame.Parent = contentScroll
            
            local checkbox = Instance.new("Frame")
            checkbox.Size = UDim2.new(0, 16, 0, 16)
            checkbox.Position = UDim2.new(0, 0, 0.5, -8)
            checkbox.BackgroundColor3 = option.enabled and CONFIG.colors.active or CONFIG.colors.button
            checkbox.BorderSizePixel = 0
            checkbox.Parent = optionFrame
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -30, 1, 0)
            label.Position = UDim2.new(0, 25, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = option.name
            label.TextColor3 = CONFIG.colors.text
            label.TextSize = 12
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
            
            yPos = yPos + 35
        end
        
        contentScroll.CanvasSize = UDim2.new(0, 0, 0, yPos)
    end
end

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Right then
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

print("[GUI] Rise ClickGUI loaded!")
print("[GUI] Press RIGHT arrow to toggle GUI")
print("[GUI] Categories: " .. #GUI.categories)

return GUI
