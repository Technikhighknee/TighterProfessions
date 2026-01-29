---------------------------------------------------------------------------
-- util/Links.lua -- Item-link parsing and shift-click integration
---------------------------------------------------------------------------
local _, ns = ...
ns.Links = {}
local Links = ns.Links

function Links:ParseItemLink(link)
    if not link then return nil, nil end
    local itemID = link:match("item:(%d+)")
    local name   = link:match("%[(.-)%]")
    return name, itemID and tonumber(itemID)
end

function Links:ExtractItemName(text)
    if not text then return nil end
    return text:match("%[(.-)%]") or text
end

-- Pre-hook ChatEdit_InsertLink so Shift+Click pastes the item name
-- into our search box when it has focus. We need a pre-hook (not
-- hooksecurefunc) because we must suppress the original when the
-- search box consumes the link.
function Links:HookShiftClick(editBox)
    if not editBox or self._hooked then return end
    self._hooked = true

    local orig = ChatEdit_InsertLink
    ChatEdit_InsertLink = function(link, ...)
        if editBox:IsVisible() and editBox:HasFocus() and link then
            local name = Links:ExtractItemName(link)
            if name then
                editBox:SetText(name)
                editBox:SetCursorPosition(#name)
                if ns.RecipesList then ns.RecipesList:Refresh() end
                return true
            end
        end
        if orig then return orig(link, ...) end
    end
end
