---------------------------------------------------------------------------
-- util/Format.lua -- Text and texture formatting helpers
---------------------------------------------------------------------------
local _, ns = ...
ns.Format = {}
local Format = ns.Format

function Format:DifficultyColor(skillType)
    if skillType == "optimal" then
        return 1.0, 0.50, 0.25
    elseif skillType == "medium" then
        return 1.0, 1.0, 0.0
    elseif skillType == "easy" then
        return 0.25, 0.75, 0.25
    elseif skillType == "trivial" then
        return 0.50, 0.50, 0.50
    else
        return 0.80, 0.80, 0.80
    end
end

function Format:SetSolidTexture(tex, r, g, b, a)
    if tex.SetColorTexture then
        tex:SetColorTexture(r, g, b, a or 1)
    else
        tex:SetTexture(r, g, b, a or 1)
    end
end
