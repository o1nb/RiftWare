-- Rise ClickGUI - Universal Script
-- Minimal, lightweight clickgui implementation

local GUI = {
    isOpen = true,
    selectedCategory = 1,
    objects = {}
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
        bg = {30, 30, 35},
        sidebar = {25, 25, 30},
        button = {40, 40, 50},
        hover = {50, 50, 70},
        active = {70, 100, 200},
        text = {200, 200, 210}
    }
}

-- Initialize categories
GUI.categories = {}
for i, name in ipairs(CONFIG.categories) do
    GUI.categories[i] = {
        name = name,
        options = {},
        isOpen = false
    }
end

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
end

-- Select category
function GUI:selectCategory(index)
    if index > 0 and index <= #self.categories then
        self.selectedCategory = index
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
    end
end

-- Get category
function GUI:getCategory(name)
    for _, cat in ipairs(self.categories) do
        if cat.name == name then
            return cat
        end
    end
    return nil
end

-- Log info
print("[GUI] Loaded successfully!")
print("[GUI] Categories: " .. #self.categories)

return GUI
