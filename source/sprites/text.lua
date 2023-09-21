import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Text').extends(gfx.sprite)

---Sprite containing text
---@param text string The text to show
---@param x integer X
---@param y integer Y
---@param centered ?boolean If true, X and Y are used for the center, if false they are used for the top-left. Defaults to false
---@param fontFile string Font file
function Text:init(text, x, y, centered, fontFile)
    self.centered = centered or false
    self.selectedX, self.selectedY = x, y
    fontFile = fontFile or 'fonts/Big Run'
    self.font = gfx.font.new(fontFile)
    printTable(self.font)

    self:changeText(text)

    -- Prints the image
    self:add()
end

---Changes the text
---@param text string New text
function Text:changeText(text)
    gfx.setFont(self.font)
    local width = 0
    local height = 0
    if self.font then
        width = self.font:getTextWidth(text)
        height = self.font:getHeight() * (select(2, string.gsub(text, "\n", '')) + 1)
    end

    -- Writes the image
    local image = gfx.image.new(width, height)
    gfx.lockFocus(image)
        gfx.drawText(text, 0,0)
	gfx.unlockFocus()
	self:setImage(image)

    -- Realigns the image
    if self.centered then
        self:moveTo(self.selectedX, self.selectedY)
    else
        self:moveTo(self.selectedX + width/2, self.selectedY + height/2)
    end
end
