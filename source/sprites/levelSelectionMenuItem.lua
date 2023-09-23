import "CoreLibs/sprites"
import "CoreLibs/crank"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('LevelSelectionMenuItem').extends(gfx.sprite)

function LevelSelectionMenuItem:init(text, x, y, isSelected)
    self.text = text
    self.isSelected = isSelected or false

    -- Writes the image
    self:resetImage()

    -- Prints the text
    self:moveTo(x, y)
    self:add()
end

function LevelSelectionMenuItem:resetImage()
    local currentFont = gfx.font.new('fonts/Kerned Big Run')
    gfx.setFont(currentFont)
    local currentFontHeight = currentFont:getHeight()
    local bulletRadius = currentFontHeight * .2

    local image = gfx.image.new(currentFont:getTextWidth(self.text) + currentFontHeight, currentFontHeight)
    gfx.lockFocus(image)
        if self.isSelected then
            gfx.fillCircleAtPoint(0 + currentFontHeight/2, currentFontHeight/2, bulletRadius)
        end
        gfx.drawText(self.text, 0 + currentFontHeight, 0)
    gfx.unlockFocus()
    self:setImage(image)
end

function LevelSelectionMenuItem:setSelection(isSelected)
    self.isSelected = isSelected
    self:resetImage()
end

function LevelSelectionMenuItem:toggleSelection()
    self:setSelection(not self.isSelected)
end