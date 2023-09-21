import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Card').extends(gfx.sprite)

---Card constructor
---@param centerX integer Rotation center X
---@param centerY integer Rotation center Y
---@param radius integer Rotation radius
---@param angle integer Rotation angle (degrees)
---@param cardNo integer Card number
---@param frontFacing ?boolean Wether or not the card is front facing (defaults to false)
---@param rotateImage ?boolean Wether or not to rotate the image along the radius (defaults to false)
function Card:init(centerX, centerY, radius, angle, cardNo, frontFacing, rotateImage)
    ---Params defaults
    self.angle = ((angle or 0) % 360)
    self.angleRad = math.rad(self.angle)
    self.centerX = centerX
    self.centerY = centerY
    self.radius = radius
    self.cardNo = cardNo
    self.rotateImage = rotateImage or false
    self.frontFacing = frontFacing or false

    ---Class data
    self.cardImageTable = gfx.imagetable.new('images/card')
    self.noOfCardStates, self.noOfCards = self.cardImageTable:getSize()
    self.flippingAnimator = nil
    self.animationDuration = 500

    if self.frontFacing then
        self.currentState = 1
    else
        self.currentState = self.noOfCardStates
    end

    self:draw()

    self:add()
end

function Card:update()
    ---If the flippingAnimator is set, animates the card (or stops it if it is ended)
    if self.flippingAnimator and not self.flippingAnimator:ended() then
        self.currentState = math.floor(self.flippingAnimator:currentValue())
        self:draw()
    elseif self.flippingAnimator and self.flippingAnimator:ended() then
        self.flippingAnimator = nil
    end
end

---Draws the card
function Card:draw()
    ---Polar to cartesian coords
    local x = self.centerX + (self.radius * math.sin(self.angleRad))
    local y = self.centerY - (self.radius * math.cos(self.angleRad))

    ---Gets the card image
    local cardImage = self.cardImageTable:getImage(self.currentState, self.cardNo)

    ---If the image will be rotated, calculates the canvas width and height, and draws it in the canvas
    if self.rotateImage then
        local width = math.abs(cardImage.width * math.cos(self.angleRad)) + math.abs(cardImage.height * math.sin(self.angleRad))
        local height = math.abs(cardImage.width * math.sin(self.angleRad)) + math.abs(cardImage.height * math.cos(self.angleRad))

        ---Creates canvas image
        local image = gfx.image.new(width, height)

        ---Draws the image
        gfx.lockFocus(image)
            cardImage:drawRotated(0 + width/2, 0 + height/2, self.angle)
        gfx.unlockFocus()

        self:setImage(image)
    ---Else sets the cardImage as the sprite image
    else
        self:setImage(cardImage)
    end

    ---Moves the image in the right position
    self:moveTo(x, y)
end

---Moves the card by an angle
---@param angle integer angle (degrees)
function Card:moveByAngle(angle)
    self:setAngle(self.angle + angle)
end

---Sets a new angle for the card
---@param angle integer angle (degrees)
function Card:setAngle(angle)
    self.angle = angle % 360
    self.angleRad = math.rad(self.angle)

    self:draw()
end

---Flips the card
function Card:flip()
    if self.isFrontFacing then
        self.flippingAnimator = gfx.animator.new(self.animationDuration, self.currentState, self.noOfCardStates)
    else
        self.flippingAnimator = gfx.animator.new(self.animationDuration, self.currentState, 1)
    end

    self.isFrontFacing = not self.isFrontFacing
end