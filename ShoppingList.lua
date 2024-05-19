-- Initialize the variable if it's not already set
if not ShoppingList then
    ShoppingList = {
        { itemID = 191329, requiredQuantity = 10 },
    }
end




local configFrame = CreateFrame("Frame", "ShoppingListConfigFrame", UIParent, "BasicFrameTemplateWithInset")
configFrame:SetSize(600, 200)  -- width, height
configFrame:SetPoint("CENTER", UIParent, "CENTER")
configFrame:SetMovable(true)
configFrame:EnableMouse(true)
configFrame:RegisterForDrag("LeftButton")
configFrame:SetScript("OnDragStart", configFrame.StartMoving)
configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)
configFrame:Hide()  -- hide initially

local itemIDBox = CreateFrame("EditBox", nil, configFrame, "InputBoxTemplate")
itemIDBox:SetSize(100, 20)
itemIDBox:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 10, -50)

local quantityBox = CreateFrame("EditBox", nil, configFrame, "InputBoxTemplate")
quantityBox:SetSize(100, 20)
quantityBox:SetPoint("LEFT", itemIDBox, "RIGHT", 10, 0)

local title = configFrame:CreateFontString(nil, "OVERLAY")
title:SetFontObject("GameFontHighlight")
title:SetPoint("TOP", configFrame, "TOP", 0, -10)
title:SetText("Configure Shopping List")

local header = configFrame:CreateFontString(nil, "OVERLAY")
header:SetFontObject("GameFontHighlight")
header:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 10, -40)
header:SetText("Item ID       Quantity")


if not configFrame.addButton then
    local addButton = CreateFrame("Button", nil, configFrame, "GameMenuButtonTemplate")
    addButton:SetSize(80, 22)
    addButton:SetText("Add")
    configFrame.addButton = addButton  -- Store it in the configFrame for future reference

    addButton:SetScript("OnClick", function()
        local itemID = tonumber(itemIDBox:GetText())
        local quantity = tonumber(quantityBox:GetText())
        if itemID and quantity then
            table.insert(ShoppingList, { itemID = itemID, requiredQuantity = quantity })
            itemIDBox:SetText("")
            quantityBox:SetText("")
            UpdateConfigFrame()  -- Refresh the list of items
        end
    end)
end

-- Position the Add button dynamically based on the content of the frame
local function UpdateConfigFrame()
    -- Clear existing item rows, if necessary
    if configFrame.itemRows then
        for _, row in ipairs(configFrame.itemRows) do
            row.itemIDBox:ClearFocus()
            row.itemIDBox:Hide()
            row.quantityBox:Hide()
            row:Hide()
        end
    end
    configFrame.itemRows = {}

    local yOffset = -70

    for i, item in ipairs(ShoppingList) do
        local row = CreateFrame("Frame", nil, configFrame)
        row:SetSize(280, 20)
        row:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 10, yOffset)

        local itemIDBox = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
        itemIDBox:SetSize(100, 20)
        itemIDBox:SetPoint("LEFT", row, "LEFT", 0, 0)
        itemIDBox:SetText(item.itemID)
        row.itemIDBox = itemIDBox

        local quantityBox = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
        quantityBox:SetSize(50, 20)
        quantityBox:SetPoint("LEFT", itemIDBox, "RIGHT", 10, 0)
        quantityBox:SetText(item.requiredQuantity)
        row.quantityBox = quantityBox

        table.insert(configFrame.itemRows, row)
        yOffset = yOffset - 30
    end

    -- Position the Add button below the last item row
    configFrame.addButton:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 10, yOffset - 40)
end

-- Call UpdateConfigFrame initially or when needed
UpdateConfigFrame()






local frame = CreateFrame("Frame", "ShoppingListFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(600, 100)  -- width, height
frame:SetPoint("CENTER") -- position on the screen
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

frame.title = frame:CreateFontString(nil, "OVERLAY")
frame.title:SetFontObject("GameFontHighlight")
frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 5, 0)
frame.title:SetText("Shopping List")

frame.text = frame:CreateFontString(nil, "OVERLAY")
frame.text:SetFontObject("GameFontHighlight")
frame.text:SetPoint("CENTER", frame, "CENTER", 0, -10)

local okButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
okButton:SetSize(100, 22)  -- width, height
okButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
okButton:SetText("OK")
okButton:SetScript("OnClick", function()
    frame:Hide()
end)

frame:Hide() -- hide initially

local function UpdateShoppingList()
    for _, item in ipairs(ShoppingList) do
        local itemName, _, _, _, _, _, _, _, _, _, _ = GetItemInfo(item.itemID)
        local itemCount = GetItemCount(item.itemID)
        if itemCount < item.requiredQuantity then
            frame.text:SetText("You need to go shopping! Low on " .. itemName .. " [" .. itemCount .. "]")
            break
        else
            frame.text:SetText("You have enough of " .. itemName .. " [" .. itemCount .. "]")
        end
    end
end

SLASH_SHOPPINGLIST1 = '/shoppinglist'
SlashCmdList["SHOPPINGLIST"] = function(msg)
    UpdateConfigFrame()
    configFrame:Show()
end

local function OnEvent(self, event, ...)
    if IsResting() then
        UpdateShoppingList()
        frame:Show()
    else
        frame:Hide()
    end
end

frame:SetScript("OnEvent", OnEvent)
frame:RegisterEvent("PLAYER_UPDATE_RESTING")