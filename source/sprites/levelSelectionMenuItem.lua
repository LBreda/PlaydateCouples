import "CoreLibs/sprites"
import "CoreLibs/crank"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('LevelSelectionMenuItem').extends(gfx.sprite)

function LevelSelectionMenuItem:init(text, x, y, isSelected, isLocked)
    self.text = text
    self.isSelected = isSelected or false
    self.isLocked = isLocked or false
    self.font = 'fonts/Roobert 11 Medium'

    -- Writes the image
    self:resetImage()

    -- Prints the text
    self:moveTo(x - gfx.font.new(self.font):getHeight()/2, y)
   
    self:add()
end

function LevelSelectionMenuItem:resetImage()
    local currentFont = gfx.font.new(self.font)
    gfx.setFont(currentFont)
    local currentFontHeight = currentFont:getHeight()
    local bulletRadius = currentFontHeight * .2

    local image = gfx.image.new(currentFont:getTextWidth(self.text) + currentFontHeight, currentFontHeight)
    gfx.lockFocus(image)
        if self.isSelected and not self.isLocked then
            gfx.fillCircleAtPoint(currentFontHeight/2, currentFontHeight/2, bulletRadius)
        elseif self.isSelected and self.isLocked then
            local lock = gfx.image.new('images/locK')
            lock:draw(currentFontHeight/2 - lock.width/2, currentFontHeight/2 - lock.height/2)
        end
        gfx.drawText(self.text,currentFontHeight, 0)
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