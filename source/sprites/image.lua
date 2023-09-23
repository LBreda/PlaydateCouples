import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Image').extends(gfx.sprite)

---Sprite to print any image
---@param x integer X
---@param y integer Y
---@param image table
---@param centered ?boolean Whether the image is centered
function Image:init(x, y, image)
    -- Writes the image
	self:setImage(image)

    -- Prints the image
    self:add()

    self:moveTo(x, y)
end