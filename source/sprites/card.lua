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
---@param rotationAngle ?integer Image rotation angle
---@param isBig ?boolean Wether the card is the big version or not
function Card:init(centerX, centerY, radius, angle, cardNo, frontFacing, rotationAngle, isBig)
    ---Params defaults
    self.angle = ((angle or 0) % 360)
    self.angleRad = math.rad(self.angle)
    self.centerX = centerX
    self.centerY = centerY
    self.radius = radius
    self.cardNo = cardNo
    self.rotationAngle = rotationAngle or 0
    self.rotationAngleRad = math.rad(self.rotationAngle)
    self.frontFacing = frontFacing or false
    self.isBig = isBig or false

    ---Class data
    if not isBig then
        self.cardImageTable = gfx.imagetable.new('images/card')
    else
        self.cardImageTable = gfx.imagetable.new('images/card-medium')
    end
    self.noOfCardStates, self.noOfCards = self.cardImageTable:getSize()
    self.flippingAnimator = nil
    self.rollingAnimator = nil
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

    ---If the RollingAnimator is set, rolls the card (or removes it if ended)
    if self.rollingAnimator and not self.rollingAnimator:ended() then
        print(math.floor(self.rollingAnimator:currentValue()))
        self.rotationAngle = math.floor(self.rollingAnimator:currentValue())
        self.rotationAngleRad = math.rad(self.rotationAngle)
        self:draw()
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
    if self.rotationAngle ~= 0 then
        local width = math.abs(cardImage.width * math.cos(self.rotationAngleRad)) + math.abs(cardImage.height * math.sin(self.rotationAngleRad))
        local height = math.abs(cardImage.width * math.sin(self.rotationAngleRad)) + math.abs(cardImage.height * math.cos(self.rotationAngleRad))

        ---Creates canvas image
        local image = gfx.image.new(width, height)

        ---Draws the image
        gfx.lockFocus(image)
            cardImage:drawRotated(0 + width/2, 0 + height/2, self.rotationAngle)
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

---Rolls the card
function Card:roll()
    self.rollingAnimator = gfx.animator.new(self.animationDuration, 0, 360)
end