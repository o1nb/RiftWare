-- ClickGUI System for Rise
-- A clean, dark-themed menu system with expandable categories

local GUI = {}
GUI.windows = {}
GUI.selectedCategory = nil
GUI.isDragging = false
GUI.dragOffset = {x = 0, y = 0}

-- Configuration
local CONFIG = {
    window = {
        width = 400,
        height = 500,
        x = 50,
        y = 50,
        title = "Rise",
        backgroundColor = {30, 30, 35, 200},
        borderColor = {50, 50, 60, 255},
        borderWidth = 2
    },
    categories = {
        {name = "Combat", icon = "⚔"},
        {name = "Movement", icon = "→"},
        {name = "Player", icon = "👤"},
        {name = "Render", icon = "🎨"},
        {name = "Exploit", icon = "💥"},
        {name = "Ghost", icon = "👻"},
        {name = "Other", icon = "≡"},
        {name = "Script", icon = "📝"},
        {name = "Themes", icon = "🎭"},
        {name = "Language", icon = "🌐"}
    },
    colors = {
        background = {30, 30, 35},
        sidebarBg = {25, 25, 30},
        categoryButton = {40, 40, 50},
        categoryHover = {50, 50, 70},
        categoryActive = {70, 100, 200},
        text = {200, 200, 210},
        textDark = {150, 150, 160},
        separator = {50, 50, 60}
    },
    sizes = {
        categoryWidth = 120,
        categoryHeight = 35,
        padding = 10,
        fontSize = 14,
        smallFontSize = 12
    }
}

-- Initialize GUI
function GUI:init()
    self.window = {
        x = CONFIG.window.x,
        y = CONFIG.window.y,
        width = CONFIG.window.width,
        height = CONFIG.window.height,
        isOpen = true,
        isDragging = false,
        dragStartX = 0,
        dragStartY = 0
    }
    
    self.categories = {}
    for i, cat in ipairs(CONFIG.categories) do
        self.categories[i] = {
            name = cat.name,
            icon = cat.icon,
            isHovered = false,
            isActive = i == 1,
            options = {}
        }
    end
    
    self.selectedCategory = 1
end

-- Add option to a category
function GUI:addOption(categoryName, optionName, callback, optionType)
    for _, cat in ipairs(self.categories) do
        if cat.name == categoryName then
            table.insert(cat.options, {
                name = optionName,
                callback = callback,
                type = optionType or "toggle",
                value = false
            })
            return
        end
    end
end

-- Draw the GUI window title bar
function GUI:drawTitleBar()
    local y = self.window.y
    local x = self.window.x
    
    -- Title bar background
    self:drawRect(x, y, self.window.width, 40, CONFIG.colors.sidebarBg)
    
    -- Title text
    self:drawText(x + 15, y + 12, CONFIG.window.title, CONFIG.colors.text, 16)
    
    -- Close button
    local closeX = x + self.window.width - 30
    self:drawRect(closeX, y + 8, 20, 20, CONFIG.colors.categoryHover)
    self:drawText(closeX + 6, y + 10, "✕", CONFIG.colors.text, 12)
    
    -- Separator
    self:drawRect(x, y + 40, self.window.width, 1, CONFIG.colors.separator)
end

-- Draw sidebar with categories
function GUI:drawSidebar()
    local sidebarWidth = CONFIG.sizes.categoryWidth
    local x = self.window.x
    local y = self.window.y + 40
    
    -- Sidebar background
    self:drawRect(x, y, sidebarWidth, self.window.height - 40, CONFIG.colors.sidebarBg)
    
    -- Draw categories
    for i, cat in ipairs(self.categories) do
        local categoryY = y + (i - 1) * CONFIG.sizes.categoryHeight
        local isActive = i == self.selectedCategory
        
        -- Category button background
        local bgColor = CONFIG.colors.categoryButton
        if isActive then
            bgColor = CONFIG.colors.categoryActive
        elseif cat.isHovered then
            bgColor = CONFIG.colors.categoryHover
        end
        
        self:drawRect(x, categoryY, sidebarWidth, CONFIG.sizes.categoryHeight, bgColor)
        
        -- Category text
        local textColor = CONFIG.colors.text
        if isActive then
            textColor = {255, 255, 255}
        end
        self:drawText(x + 10, categoryY + 10, cat.icon .. " " .. cat.name, textColor, CONFIG.sizes.fontSize)
        
        -- Separator
        self:drawRect(x, categoryY + CONFIG.sizes.categoryHeight - 1, sidebarWidth, 1, CONFIG.colors.separator)
    end
end

-- Draw main content area
function GUI:drawContent()
    local contentX = self.window.x + CONFIG.sizes.categoryWidth
    local contentY = self.window.y + 40
    local contentWidth = self.window.width - CONFIG.sizes.categoryWidth
    local contentHeight = self.window.height - 40
    
    -- Content background
    self:drawRect(contentX, contentY, contentWidth, contentHeight, CONFIG.colors.background)
    
    -- Draw selected category options
    if self.selectedCategory and self.categories[self.selectedCategory] then
        local category = self.categories[self.selectedCategory]
        self:drawText(contentX + 15, contentY + 15, category.name, CONFIG.colors.text, 16)
        
        -- Draw separator
        self:drawRect(contentX, contentY + 35, contentWidth, 1, CONFIG.colors.separator)
        
        -- Draw options
        local optionY = contentY + 50
        for _, option in ipairs(category.options) do
            self:drawOption(contentX, optionY, contentWidth, option)
            optionY = optionY + 35
        end
    end
end

-- Draw individual option
function GUI:drawOption(x, y, width, option)
    local boxSize = 16
    local padding = 15
    
    -- Draw toggle box
    self:drawRect(x + padding, y, boxSize, boxSize, CONFIG.colors.categoryButton)
    
    if option.value then
        self:drawRect(x + padding + 2, y + 2, boxSize - 4, boxSize - 4, {70, 150, 200})
    end
    
    -- Draw option text
    self:drawText(x + padding + 25, y + 4, option.name, CONFIG.colors.text, CONFIG.sizes.smallFontSize)
end

-- Draw rectangle (placeholder - implement with your graphics library)
function GUI:drawRect(x, y, width, height, color)
    -- Implementation depends on your graphics library (e.g., love2D, custom renderer)
    -- This is a placeholder
end

-- Draw text (placeholder - implement with your graphics library)
function GUI:drawText(x, y, text, color, size)
    -- Implementation depends on your graphics library
    -- This is a placeholder
end

-- Handle mouse click
function GUI:handleClick(mouseX, mouseY)
    local x = self.window.x
    local y = self.window.y
    
    -- Check if clicking close button
    local closeX = x + self.window.width - 30
    if mouseX >= closeX and mouseX <= closeX + 20 and mouseY >= y + 8 and mouseY <= y + 28 then
        self.window.isOpen = false
        return
    end
    
    -- Check if clicking on category
    if mouseX >= x and mouseX <= x + CONFIG.sizes.categoryWidth then
        local categoryY = mouseY - (y + 40)
        local categoryIndex = math.floor(categoryY / CONFIG.sizes.categoryHeight) + 1
        
        if categoryIndex > 0 and categoryIndex <= #self.categories then
            self.selectedCategory = categoryIndex
            return
        end
    end
    
    -- Check if clicking on option
    local contentX = x + CONFIG.sizes.categoryWidth
    if mouseX >= contentX and self.selectedCategory then
        local category = self.categories[self.selectedCategory]
        local optionY = mouseY - (y + 40 + 50)
        local optionIndex = math.floor(optionY / 35) + 1
        
        if optionIndex > 0 and optionIndex <= #category.options then
            local option = category.options[optionIndex]
            if option.type == "toggle" then
                option.value = not option.value
                if option.callback then
                    option.callback(option.value)
                end
            end
        end
    end
end

-- Handle mouse movement
function GUI:handleMouseMove(mouseX, mouseY)
    local x = self.window.x
    local y = self.window.y
    
    -- Update category hover states
    if mouseX >= x and mouseX <= x + CONFIG.sizes.categoryWidth then
        local categoryY = mouseY - (y + 40)
        local categoryIndex = math.floor(categoryY / CONFIG.sizes.categoryHeight) + 1
        
        for i, cat in ipairs(self.categories) do
            cat.isHovered = (i == categoryIndex)
        end
    else
        for _, cat in ipairs(self.categories) do
            cat.isHovered = false
        end
    end
end

-- Render the GUI
function GUI:render()
    if not self.window.isOpen then
        return
    end
    
    -- Draw window background
    self:drawRect(self.window.x, self.window.y, self.window.width, self.window.height, CONFIG.colors.sidebarBg)
    
    -- Draw components
    self:drawTitleBar()
    self:drawSidebar()
    self:drawContent()
end

-- Update GUI
function GUI:update(dt)
    -- Placeholder for update logic
end

-- Toggle GUI visibility
function GUI:toggle()
    self.window.isOpen = not self.window.isOpen
end

-- Initialize on load
GUI:init()

return GUI
