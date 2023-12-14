import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/graphics"
import "sceneManager"
import "scenes/gameOverScene"
import "scenes/titleScene"
import "sprites/card"
import "sprites/image"
import "sprites/text"

local pd <const> = playdate
local gfx <const> = pd.graphics
local sound <const> = pd.sound

class("GameScene").extends(Room)

---Generates the game scene
---@param previous table Previous scene
---@param level Level
function GameScene:enter(previous, level)
    ---Levels settings
    local levels = {
        {
            howManyCards = 6,
            radius = 80,
            introMusic = nil,
            selectedCardDisplayX = 200,
            loopMusic = 'xDeviruchi - The Final of The Fantasy',
        },
        {
            howManyCards = 9,
            radius = 130,
            selectedCardDisplayX = 200,
            introMusic = 'xDeviruchi - Take some rest and eat some food! (Intro)',
            loopMusic = 'xDeviruchi - Take some rest and eat some food! (Loop)',
        },
        {
            howManyCards = 12,
            radius = 160,
            selectedCardDisplayX = 200,
            introMusic = 'xDeviruchi - And The Journey Begins (Intro)',
            loopMusic = 'xDeviruchi - And The Journey Begins (Loop)',
        },
    }

    ---Scene configurations
    self.level = level
    self.howManyCards = levels[self.level]['howManyCards']
    self.radius = levels[self.level]['radius']

    ---Game data
    self.centerX = 200 + (self.radius - 80)
    self.centerY = 120
    self.selectedCardDisplayX = levels[self.level]['selectedCardDisplayX']
    self.step = 360/(self.howManyCards * 2)
    self.isRunning = true
    self.timerValue = 0
    self.wrongAttempts = 0
    self.discoveredCards = 0
    self.selectedCard = nil
    self.selectedCardSprite = nil
    self.sfxPickup = playdate.sound.sampleplayer.new('sounds/sfx/pepSound3')
    self.sfxWrong = playdate.sound.sampleplayer.new('sounds/sfx/pepSound4')
    self.sfxRight = playdate.sound.sampleplayer.new('sounds/sfx/pepSound5')

    ---Plays music
    self.bgMusic = playBgMusicWithIntro(levels[self.level]['introMusic'], levels[self.level]['loopMusic'])

    ---Generates cards list
    local cardList = {}
    for i = 1, self.howManyCards, 1 do
        table.insert(cardList, i)
        table.insert(cardList, i)
    end

    ---Prints cards
    local cardNos = shuffleTable(cardList)
    self.cards = {}
    for i = 0, 359, self.step do
        table.insert(self.cards, Card(self.centerX, self.centerY, self.radius, i, cardNos[#self.cards+1]))
    end

    ---Masking image
    Image(200, 120, gfx.image.new('images/gameSceneMask'), true)

    ---Game info screen
    local InfoX = 351
    Text("c\no\nu\np\nl\ne\ns", 51, 121, 'center', 'Carded Bigger Run Bordered')
    self.elapsedTimeKey = Text('Time', InfoX, 58, 'center')
    self.elapsedTimeValue = Text('0:00', InfoX, 78, 'center', 'Kerned Bigger Run')
    self.wrongAttemptsKey = Text('Errors', InfoX, 108, 'center')
    self.wrongAttemptsValue = Text('0', InfoX, 128, 'center', 'Kerned Bigger Run')
    self.discoveredCardsKey = Text('Found', InfoX, 158, 'center')
    self.discoveredCardsValue = Text('0/' .. self.howManyCards, InfoX, 178, 'center', 'Kerned Bigger Run')

    ---Crank indicator
    pd.ui.crankIndicator:start()

    ---Modify system menu
    local menu = pd.getSystemMenu()
    menu:removeAllMenuItems()
    menu:addMenuItem('Restart level', function ()
        self.isRunning = false
        self.bgMusic:stop()
        sceneManager:enter(GameScene(), self.level)
    end)
    menu:addMenuItem('Main menu', function ()
        self.isRunning = false
        self.bgMusic:stop()
        sceneManager:enter(TitleScene())
    end)

    ---Game pause
    function pd.gameWillPause()
        pd.setMenuImage(self:menuImage())
    end

    pd.resetElapsedTime()
end

function GameScene:update()
    gfx.sprite.update()
    pd.timer.updateTimers()

    if(pd.isCrankDocked()) then
        pd.ui.crankIndicator:update()
    end

    ---If the game is running, updates the elapsed time
    if self.isRunning then
        self:updateTimer()
    end
end

function GameScene:cranked(change)
    for i = 1, #self.cards, 1 do
        self.cards[i]:moveByAngle(change)
    end
end
function GameScene:AButtonDown()
    self:selectCard()
end
function GameScene:BButtonDown()
    self:AButtonDown()
end
function GameScene:upButtonDown()
    self:AButtonDown()
end
function GameScene:downButtonDown()
    self:AButtonDown()
end
function GameScene:leftButtonDown()
    self:AButtonDown()
end
function GameScene:rightButtonDown()
    self:AButtonDown()
end

---Game logic
function GameScene:selectCard()
    ---Selects the card on the 270° position if it is not selected
    for i = 1, #self.cards, 1 do
        if (not self.cards[i].isFrontFacing) and self.cards[i].angle > (270 - self.step/2) and self.cards[i].angle < (270 + self.step/2) then
            ---Flips the card
            self.sfxPickup:play()
            self.cards[i]:flip()
            ---Waits for it to be fipped before checking its value
            pd.timer.new(self.cards[i].animationDuration, function ()
                ---If a card is already selected
                if self.selectedCard then
                    ---Waits a little and
                    pd.timer.new(self.cards[i].animationDuration, function ()
                        ---and it contains the same figure
                        if self.selectedCard.cardNo == self.cards[i].cardNo then
                            self.sfxRight:play()

                            ---Increments the discoveredCards
                            self:incrementDiscoveredCards()

                            ---Rolls the selected card display
                            if self.selectedCardSprite then
                                self.selectedCardSprite:roll()
                            end

                            ---Removes the selected card display after the animation
                            pd.timer.new(self.cards[i].animationDuration, function ()
                                if (not self.selectedCard or self.selectedCard.cardNo == self.selectedCardSprite.cardNo) and self.selectedCardSprite ~= nil then
                                    self.selectedCardSprite:remove()
                                    self.selectedCardSprite = nil
                                end
                            end)
                        ---and it does not contain the same figure
                        else
                            self.sfxWrong:play()

                            ---Flips the cards back again
                            self.selectedCard:flip()
                            self.cards[i]:flip()

                            ---Increments the wrongAttempts
                            self:incrementWrongAttempts()

                            --Removes the selected card display
                            if self.selectedCardSprite then
                                self.selectedCardSprite:remove()
                            end
                            self.selectedCardSprite = nil
                        end

                        ---Unselects the selected card
                        self.selectedCard = nil
                    end)
                ---If there is no selected card
                else
                    ---selects the current one
                    self.selectedCard = self.cards[i]
                    self.selectedCardSprite = Card(self.selectedCardDisplayX, self.centerY, 0, 0, self.cards[i].cardNo, true, false, true)
                end
            end)
        end
    end
end

---Updates the on-screen timer
function GameScene:updateTimer()
    self.timerValue = pd.getElapsedTime()
    self.elapsedTimeValue:changeText(prettyPrintTime(self.timerValue))
end

---Increments the wrongAttempts counter
function GameScene:incrementWrongAttempts()
    self.wrongAttempts += 1
    self.wrongAttemptsValue:changeText(self.wrongAttempts)
end

---Increments the discoveredCards counter
function GameScene:incrementDiscoveredCards()
    if self.isRunning then
        self.discoveredCards += 1
        self.discoveredCardsValue:changeText(self.discoveredCards .. '/' .. self.howManyCards)
        if self.discoveredCards == self.howManyCards then
            self.isRunning = false
            self.bgMusic:stop()
            sceneManager:enter(GameOverScene())
        end
    end
end

---Generates the menu image
function GameScene:menuImage()
    local pauseImage = gfx.image.new(400, 240, gfx.kColorWhite)
    gfx.lockFocus(pauseImage)
        gfx.setFont(gfx.font.new('fonts/Carded Bigger Run'))
        gfx.drawTextAligned("c\no\nu\np\nl\ne\ns", 49, 25, kTextAlignment.center)
        local InfoX = 150

        gfx.setFont(gfx.font.new('fonts/Kerned Big Run'))
        gfx.drawTextAligned('Time', InfoX, 54, kTextAlignment.center)
        gfx.drawTextAligned('Errors', InfoX, 103, kTextAlignment.center)
        gfx.drawTextAligned('Found', InfoX, 153, kTextAlignment.center)

        gfx.setFont(gfx.font.new('fonts/Kerned Bigger Run'))
        gfx.drawTextAligned(prettyPrintTime(self.timerValue), InfoX, 69, kTextAlignment.center)
        gfx.drawTextAligned(self.wrongAttempts, InfoX, 120, kTextAlignment.center)
        gfx.drawTextAligned(self.discoveredCards .. '/' .. self.howManyCards, InfoX, 169, kTextAlignment.center)
	gfx.unlockFocus()

    return pauseImage
end