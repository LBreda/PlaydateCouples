import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Arrow').extends(gfx.sprite)

---Sprite containing text
---@param x integer X
---@param y integer Y
function Arrow:init(x, y)
    -- Writes the image
    local image = gfx.image.new('images/arrow')
	self:setImage(image)

    -- Prints the image
    self:add()

    self:moveTo(x, y)
end